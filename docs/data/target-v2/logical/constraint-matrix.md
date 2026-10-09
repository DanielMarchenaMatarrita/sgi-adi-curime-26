# Checkpoint 9.4B — matriz de restricciones y enforcement

**Estado:** contrato lógico; no congelado, no implementado. Este documento **no contiene SQL ni autoriza migraciones**. Nombres físicos, tipos exactos, índices, triggers y orden de despliegue pertenecen a 9.4C.

## Leyenda

- **BASELINE V1.1:** contrato verificado contra revisión `e8e2beb33eea8c1207fe77fe65dbd3228362bc5f`.
- **DECISIÓN VALIDADA:** semántica funcional aprobada en [registro](../../../architecture/decisions/decision-register.md).
- **PROPUESTA ARQUITECTÓNICA:** enforcement lógico recomendado, pendiente de freeze/9.4C.
- **CONDICIONADA:** depende de decisión institucional.
- Capas: **Prisma** (PK/FK/UQ/nullability); **PostgreSQL SQL** (`CHECK`, parcial, exclusión, trigger/política); **TX/servicio** (lectura/escritura atómica y autorización contextual); **Gate** (reconciliación antes de endurecer).

Fuente base: [Integrity Rules V1.1 fijadas](../../baseline-v1.1/README.md), [catálogo](entity-catalog.md), [relaciones](relationship-matrix.md), [freeze gates](../freeze-gates.md).

## 1. Restricciones expresables en Prisma

| ID | Entidades/campos | Restricción lógica | Estado | Fuente / nota |
|---|---|---|---|---|
| P-001 | Todas | PK y FK según catálogos; `onUpdate: Cascade`; `onDelete` por relación | BASELINE/PROPUESTA | Matriz de relaciones; revisar nombres en 9.4C |
| P-002 | `OrganizationProfile.id` | PK fija `1` como raíz singleton | BASELINE V1.1 | `ORG-01`; SQL puede reforzar singleton |
| P-003 | `Person` | UQ `(identificationType, normalizedIdentification)` | BASELINE V1.1 | `ID-R01`; semántica de NULL PostgreSQL |
| P-004 | `User.personId`, `Affiliate.personId` | FK UQ; destino final NOT NULL | BASELINE V1.1 + gate | `ID-R02/03`, `ID-01` |
| P-005 | `Role.name`, `Permission.code`, `GovernancePosition.code` | UQ | BASELINE V1.1 | S/IR |
| P-006 | `RolePermission` | PK `(roleId, permissionId)` | BASELINE V1.1 | `SEC-02` |
| P-007 | Tokens/sesiones | UQ `Session.refreshTokenHash`, `PasswordResetToken.tokenHash`, `AccountActivationToken.tokenHash` | BASELINE V1.1 | `SEC-07` |
| P-008 | `AssemblyCall` | UQ `(assemblyId, callNumber)` | BASELINE V1.1 | `ASM-R03` |
| P-009 | `AssemblyConvocation` | UQ `(assemblyId, affiliateId)` | BASELINE V1.1 | `ASM-R05` |
| P-010 | `AssemblyAttendance`, `AbsenceJustification`, `AssemblyMinute` | UQ en `convocationId`, `attendanceId`, `assemblyId` respectivamente | BASELINE V1.1 | `ASM-R08/10`, `ASM-R12` |
| P-011 | `FinancialCharge.reservationId` | FK UQ: reserva 1:0..1 cargo | BASELINE V1.1 | `RES-08` |
| P-012 | `Payment.movementId`, `Donation.originalMovementId` | FK UQ; destino final NOT NULL tras gates | BASELINE V1.1 + gate | `FIN-R09/10`, `FIN-ORIGIN-01`, `FIN-DON-01` |
| P-013 | `FinancialMovement.reversalOfId` | self-FK UQ nullable | BASELINE V1.1 | `FIN-R07/08` |
| P-014 | `Disbursement.movementId` | FK UQ NOT NULL | DECISIÓN VALIDADA | `INT-01`: movimiento 1:0..1 desembolso |
| P-015 | `Disbursement.expenseId` | FK NOT NULL no UQ | DECISIÓN VALIDADA | `Expense 1:N Disbursement` |
| P-016 | `InventoryLoan` | tres FK de movimiento nullable y UQ | BASELINE V1.1 | `INV-R08`, gate `INV-LOAN-01` |
| P-017 | Voluntariado | UQ `Participation.applicationId`, `(opportunityId,personId)`, `(participationId,sessionId)` | BASELINE V1.1 | `VOL-I03..05` |
| P-018 | `VentureRequestRevision` | UQ `(requestId, revisionNumber)` | BASELINE V1.1 | `ENT-I09` |
| P-019 | `BoardSession` | UQ `(termId, sessionNumber)` | PROPUESTA ARQUITECTÓNICA | identificador local, no global |
| P-020 | `BoardMinute.boardSessionId` | FK UQ NOT NULL | PROPUESTA ARQUITECTÓNICA | 0..1 acta por sesión; lifecycle abierto |
| P-021 | `BoardResolution` | UQ `(boardSessionId, resolutionNumber)` | PROPUESTA ARQUITECTÓNICA | número local de acuerdo |
| P-022 | `BoardSessionAttendance` | UQ `(boardSessionId, membershipId)` | CONDICIONADA | solo si entidad aprobada |
| P-023 | `EventRevision` | UQ `(eventId, revisionNumber)` | PROPUESTA ARQUITECTÓNICA | 9.2B |
| P-024 | `EventBudgetLine` | UQ `(eventId, lineNumber)` | PROPUESTA ARQUITECTÓNICA | presupuesto ≠ contabilidad |
| P-025 | Donaciones físicas | UQ locales `(donationId,lineNumber)`, `(donationId,receiptNumber)`, `(receiptId,lineNumber)` | PROPUESTA ARQUITECTÓNICA | 9.2C |
| P-026 | Inventario físico | UQ `InstitutionalFacility.code`, `InventoryStockLot.code`, `InventoryUnit.assetCode` | PROPUESTA ARQUITECTÓNICA | alcance institucional único |
| P-027 | `InventoryLoanCheckoutAllocation.checkoutMovementId` | FK UQ nullable | PROPUESTA ARQUITECTÓNICA | se completa solo con evidencia |
| P-028 | `InventoryLoanReturn` | UQ `(loanId, returnNumber)` | PROPUESTA ARQUITECTÓNICA | devoluciones parciales |
| P-029 | `InventoryLoanReturnDetail` | UQ `(returnId, checkoutAllocationId)` y UQ nullable `availableEntryMovementId` | PROPUESTA ARQUITECTÓNICA | una entrada no se reutiliza |
| P-030 | `Initiative.code` | UQ | PROPUESTA ARQUITECTÓNICA | se reutiliza; no `FundDestination` |
| P-031 | `DocumentSeries.code` | UQ de código institucional canónico | PROPUESTA ARQUITECTÓNICA | `DOC-VAL-02`; formato e inmutabilidad requieren PostgreSQL |
| P-032 | `DocumentRecord` | UQ **exacta** `(seriesId, folioYear, folioSequence)`; UQ nullable `officialRegistrationRequestKey` para reintento | DECISIÓN VALIDADA + propuesta de idempotencia | `DOC-VAL-02/03`; **sin UQ global ni campo `folio` editable** |
| P-033 | `DocumentVersion` | UQ `(documentId, versionNumber)` | DECISIÓN VALIDADA + propuesta física | `DOC-VAL-01` |
| P-034 | `Donor.personId` | FK UQ nullable | PROPUESTA ARQUITECTÓNICA | solo donante tipo persona; no fusiona identidades |
| P-035 | `Correspondence.documentRecordId` | FK UQ NOT NULL | PROPUESTA ARQUITECTÓNICA | folio reside en `DocumentRecord` |
| P-036 | Vínculos documentales tipados | FK nullable/UQ según matriz | PROPUESTA ARQUITECTÓNICA | forma exacta abierta; no usar `entityType+entityId` como único respaldo |
| P-037 | `DocumentFolioCounter` | PK compuesta `(seriesId, folioYear)`; FK `seriesId → DocumentSeries.id` | PROPUESTA ARQUITECTÓNICA | tabla técnica, fuera de 31 candidatas; `RESTRICT/CASCADE`; `DOC-VAL-01..04`, `OD-05` |
| P-038 | `InventoryStockLotReceiptOrigin`, `InventoryUnitReceiptOrigin` | FK obligatorias; UQ respectivamente en `lotId` y `unitId` | PROPUESTA ARQUITECTÓNICA | asociaciones técnicas tipadas, fuera de 31 candidatas; `RESTRICT/CASCADE`; no `entityType/entityId` |

## 2. Restricciones PostgreSQL SQL — diseño, sin generar SQL

| ID | Entidades/campos | Invariante | Mecanismo lógico | Estado / fuente |
|---|---|---|---|---|
| S-001 | `OrganizationProfile.id` | solo valor `1` | `CHECK`/protección singleton | BASELINE `ORG-01` |
| S-002 | `GovernanceTerm` | `startDate < endDate` | `CHECK` | BASELINE `GOV-R02` |
| S-003 | `GovernanceMembership` | `seatNumber > 0`; fin no anterior al inicio | `CHECK` | BASELINE `GOV-R03/06` |
| S-004 | `GovernanceMembership` | una ocupación activa `(termId,positionId,seatNumber)` | índice UQ parcial `endedAt IS NULL` | BASELINE `GOV-R04` |
| S-005 | `AssemblyCall` | `callNumber > 0`; cuórum coherente por tipo | `CHECK` | BASELINE `ASM-R03/04` |
| S-006 | Evidencia adjunta | tamaño positivo y metadatos completos | `CHECK` | BASELINE `ASM-R13`, `FIN-R15/22` |
| S-007 | `Reservation` | `startAt < endAt` | `CHECK` | BASELINE `RES-01` |
| S-008 | Recurso/cargo | FREE sin precio/cargo pagable; FIXED precio CRC positivo | `CHECK` condicionado + TX | BASELINE `RES-10` |
| S-009 | Importes financieros | cargos, pagos, movimientos, donaciones, gastos, desembolsos y allocations `> 0` | `CHECK` | BASELINE `FIN-R02` |
| S-010 | `FinancialMovement` | no autorreversión; VOIDED exige actor/fecha/razón | `CHECK` | BASELINE `FIN-R06/08` |
| S-011 | Movimientos contabilizados | impedir hard-delete y reescritura económica | permisos/trigger de protección | BASELINE `FIN-R04/05` |
| S-012 | Inventario | `quantityDelta != 0`; signo coherente con tipo | `CHECK` | BASELINE `INV-R01..03` |
| S-013 | `InventoryItem` | `currentQuantity >= 0`, `minimumQuantity >= 0` | `CHECK` | BASELINE `INV-R04/05`; primer punto tras gate |
| S-014 | `InventoryLoan` | cantidad positiva; retorno esperado posterior; estado/fechas coherentes | `CHECK` | BASELINE `INV-R06/07` |
| S-015 | Voluntariado | capacidad positiva; sesión positiva; horas no negativas; check-in ≤ check-out | `CHECK` | BASELINE `VOL-I01/02/06/07` |
| S-016 | `VolunteerApplication` | una PENDING por `(opportunityId,personId)` reconciliado | UQ parcial | BASELINE `VOL-I08` |
| S-017 | `Venture` | `PUBLISHED => ACTIVE` | `CHECK` | BASELINE `ENT-I01` |
| S-018 | `VentureAssociation` | fin ≥ inicio; una asociación abierta por par | `CHECK` + UQ parcial | BASELINE `ENT-I03/04` |
| S-019 | `VentureRequest` | UPDATE/APPROVED REGISTRATION requieren venture; terminal exige `resolvedAt` | `CHECK` | BASELINE `ENT-I06..08` |
| S-020 | Objetos de mantenimiento | incidencia tiene exactamente uno de facility/lot/unit | `CHECK` XOR | PROPUESTA; `INV-VAL-02` |
| S-021 | Orden de mantenimiento | exactamente un objeto al estado autorizado o posterior; ejecutor en ASSIGNED+ | `CHECK` condicionado o trigger | DECISIÓN VALIDADA + propuesta; `MNT-VAL-01/02` |
| S-022 | Orden cerrada | `closedAt` requiere verificación satisfactoria previa | trigger/constraint según ciclo físico | DECISIÓN VALIDADA; no equipara enum VERIFIED y CLOSED |
| S-023 | `Expense.maintenanceCostRecognizedAt` | solo después de cierre verificado de orden | trigger intertabla o TX; no `CHECK` simple | DECISIÓN VALIDADA `FIN-MNT-VAL-01` |
| S-024 | Autorización de gasto | como máximo uno de `authorizationResolutionId`, `boardResolutionId` cuando fundamento único | `CHECK` XOR | PROPUESTA; `FIN-VAL-01` |
| S-025 | Destino de ingreso | `INCOME` confirmado: `destinationType=GENERAL_FUND` sin initiative o `INITIATIVE` con initiative; no ambos | `CHECK` condicionado | DECISIÓN VALIDADA `FIN-VAL-02/03` |
| S-026 | Allocation de checkout | exactamente uno de `lotId`, `unitId`; cantidad positiva | `CHECK` XOR | PROPUESTA; 9.3C |
| S-027 | Identidad de allocation | lote/unidad pertenece al mismo `InventoryItem` del préstamo | trigger o TX intertabla | DECISIÓN VALIDADA + propuesta |
| S-028 | Detalles de devolución/faltante | cantidades positivas; ninguna cantidad simultáneamente devuelta y faltante | `CHECK` local + TX agregada | DECISIÓN VALIDADA `INV-VAL-04/05` |
| S-029 | Instalaciones | `parentFacilityId != id`; jerarquía sin ciclos | `CHECK` local + trigger/TX recursiva | PROPUESTA |
| S-030 | Bloqueos de recurso | intervalos válidos; no solapamiento incompatible activo | exclusión por rango/índice parcial | PROPUESTA; `MNT-VAL-04` |
| S-031 | `DocumentRecord` foliado/oficial | `folioYear > 0`, `folioSequence > 0`; año+secuencia ambos null o ambos no null; si hay componentes, `seriesId` existe; estado oficial exige serie+año+secuencia+`officialRegisteredAt` | `CHECK` | DECISIÓN VALIDADA `DOC-VAL-02/03`; borrador puede conservar `seriesId` sin folio |
| S-032 | `DocumentSeries.code` | formato canónico institucional `[A-Z0-9]+(?:-[A-Z0-9]+)*`; histórico retenido; no actualizar código si existe emisión oficial de serie | `CHECK` de formato + trigger intertabla | PROPUESTA; `DOC-VAL-02`, `OD-05`; Prisma no basta |
| S-033 | `DocumentRecord` oficial | impedir mutar `seriesId`, `folioYear`, `folioSequence`, `officialRegisteredAt` o salida de estado oficial que reabra folio; folio comprometido nunca se reutiliza | trigger de transición/política | PROPUESTA; `DOC-VAL-01..04`, `OD-05` |
| S-034 | `DocumentFolioCounter` | solo ruta controlada puede insertar o incrementar `lastAssigned`; no decremento, update directo ni delete ordinario | privilegios PostgreSQL y protección trigger/política | PROPUESTA; regla lógica fijada; reparto exacto trigger versus privilegios se reserva a 9.4C |
| S-035 | Numeración anual | asignación concurrente sin duplicados por serie/año | PK contador + UQ triple + transacción | DECISIÓN VALIDADA; `DOC-VAL-01..04`, `OD-05` |
| S-036 | Documento oficial | versiones oficiales y evidencias no se actualizan/eliminan; rectificación agrega versión | permisos/trigger/política | DECISIÓN VALIDADA `DOC-VAL-01` |
| S-037 | Logs | `ExpenseDocumentLog`, `CorrespondenceLog` append-only | permisos/trigger/política | PROPUESTA respaldada por trazabilidad |
| S-038 | `Donor` | forma persona requiere `personId`; forma organización no lo usa; identificación jurídica normalizada coherente | `CHECK` condicionado + UQ parcial | PROPUESTA; política identificatoria exacta pendiente |
| S-039 | Asistencia Junta | par sesión/membresía único y membresía vigente en fecha | UQ + TX | CONDICIONADA |
| S-040 | `Disbursement` residual | máximo un `SETTLEMENT` por `expenseId` | UQ parcial `expenseId WHERE purpose=SETTLEMENT` | PROPUESTA ARQUITECTÓNICA; clave de idempotencia FIN-MNT |
| S-041 | `Disbursement` conciliado | `settledAt/settledByUserId` solo aplican a `purpose=ADVANCE` y aparecen juntos | `CHECK` local | PROPUESTA ARQUITECTÓNICA |
| S-042 | `InKindDonation.donorId` | nullable solo en frontera semántica DRAFT; cualquier estado no-DRAFT exige `donorId` | `CHECK` condicionado por estado, si enum soporta DRAFT/no-DRAFT | DECISIÓN VALIDADA OD-10; Prisma expresa FK nullable, no esta transición |

## 3. Reglas transaccionales, de servicio y autorización

| ID | Operación | Regla atómica/contextual | Estado / fuente |
|---|---|---|---|
| T-001 | Reserva | revalidar recurso activo, duración y no-overlap en transacción serializable | BASELINE `RES-02..06` |
| T-002 | Pago | movimiento `INCOME/PAYMENT`, monto/moneda iguales, un origen singular | BASELINE `FIN-R18/21/23` |
| T-003 | Donación monetaria | movimiento `INCOME/DONATION`, monto/moneda iguales, un origen singular | BASELINE `FIN-R19/21/23` |
| T-004 | Desembolso | crear/confirmar `Disbursement` y único movimiento `EXPENSE/DISBURSEMENT` con monto/moneda iguales | DECISIÓN VALIDADA `INT-01`, `FIN-R20/21` |
| T-005 | Gasto con varios pagos | bloquear gasto, validar suma/moneda y crear cada nuevo desembolso una sola vez | DECISIÓN VALIDADA: `Expense 1:N Disbursement` |
| T-006 | Anticipo | en pago efectivo crear una sola salida de caja y marcar `purpose=ADVANCE`; nunca esperar cierre para afectar caja | DECISIÓN VALIDADA `FIN-MNT-VAL-02` |
| T-007 | Liquidación | por el mismo `Expense.id`, bloquear gasto+desembolsos; exigir moneda de cada desembolso = `Expense.currency`; calcular `A=Σ ADVANCE` efectivo no anulado y `C=Expense.amount`; marcar atómicamente todo ADVANCE pendiente; crear único `SETTLEMENT`+movimiento solo por residual real `C-A>0`; `A>C` queda excepción sin importe negativo | DECISIÓN VALIDADA `FIN-MNT-VAL-01/02`; propuesta operativa exacta |
| T-008 | Reconocimiento mantenimiento | tras cierre verificado, fijar una vez `maintenanceCostRecognizedAt`; junto con UQ parcial de SETTLEMENT y update `settledAt IS NULL`, reintento produce cero movimientos; reporting reutiliza desembolsos | DECISIÓN VALIDADA + idempotencia arquitectónica |
| T-009 | Reversión/void | `VOIDED` controlado o nuevo movimiento compensatorio; nunca borrar/reusar movimiento | BASELINE `FIN-R04..08`; aplica a anticipos |
| T-010 | Funding allocation | validar ingreso, disponibilidad y suma sin inventar política de overspend | BASELINE `FIN-R16/25`; permanece junto a Initiative |
| T-011 | Destino de ingreso | asignar exactamente iniciativa activa o fondo general al confirmar; sin split | DECISIÓN VALIDADA `FIN-VAL-02/03` |
| T-012 | Gobernanza | comprobar `GovernanceMembership` vigente y competencia; cuenta `User` no basta | DECISIÓN VALIDADA; 9.2A/B/C |
| T-013 | Donación en especie | aceptación y recepción son hechos separados; recepción jamás crea `FinancialMovement` monetario | DECISIÓN VALIDADA `DON-VAL-04..08` |
| T-014 | Recepción física | suma recibida no excede oferta aprobada; línea corresponde a misma donación; idempotencia por evento | DECISIÓN VALIDADA + propuesta; 9.2C/9.3C |
| T-015 | Alta inventario | crear lote/unidad para todo bien bajo custodia; crear ENTRY disponible solo si apto | DECISIÓN VALIDADA `DON-INV-VAL-01`, `INV-VAL-03` |
| T-016 | Movimiento inventario | actualizar ledger y `currentQuantity` disponible atómicamente, sin saldo negativo | BASELINE `INV-R01..04`, gate `INV-LEDGER-01` |
| T-017 | Préstamo | allocations suman cantidad prestada, mismo item; movimientos no se reutilizan entre roles | BASELINE `INV-R11` + propuesta V2 |
| T-018 | Devolución parcial | bloquear loan/allocations; `prestada = devuelta física + faltante resuelto + pendiente`; condiciones por detalle | DECISIÓN VALIDADA `INV-VAL-04/05` |
| T-019 | Retorno apto | ENTRY disponible máximo una vez por detalle; retorno dañado no aumenta `currentQuantity` | DECISIÓN VALIDADA `INV-VAL-03/04` |
| T-020 | Faltante | decisión competente puede cerrar administrativamente; nunca simular devolución ni nueva salida | DECISIÓN VALIDADA `INV-VAL-05` |
| T-021 | Orden mantenimiento | autorización operativa separada de financiera; objeto exacto y ejecutor según estado | DECISIÓN VALIDADA `MNT-VAL-01..03` |
| T-022 | Cierre mantenimiento | verificar aptitud/evidencia, liberar bloqueo solo si no hay otras restricciones, después cerrar | DECISIÓN VALIDADA `MNT-VAL-05` |
| T-023 | Bloqueo recurso | detectar reservas afectadas; no cancelarlas automáticamente | DECISIÓN VALIDADA `MNT-VAL-04` |
| T-024 | Voluntariado | publicación, aplicación/aprobación, capacidad e identidad en transacción | BASELINE `VOL-I10..13` |
| T-025 | Emprendimiento | no solapar asociaciones; aplicar patch explícito; cierre/suspensión despublica atómicamente | BASELINE `ENT-I05/13/14` |
| T-026 | Versionado evento | append-only; decisión apunta revisión exacta; cambios posteriores crean nueva revisión | PROPUESTA; 9.2B |
| T-027 | Folio | PostgreSQL: en misma transacción ejecutar `INSERT ... ON CONFLICT (series_id, folio_year) DO UPDATE SET last_assigned = document_folio_counter.last_assigned + 1 RETURNING last_assigned`; fila contador serializa concurrencia por `(seriesId, folioYear)`. Con secuencia retornada, asignar `DocumentRecord.seriesId/folioYear/folioSequence`, `officialRegisteredAt` y `status` oficial. Inicialización anual ocurre por mismo upsert. | PROPUESTA operacional; `DOC-VAL-01..04`, `OD-05`; no SQL Server |
| T-028 | Reintento de folio | aceptar `officialRegistrationRequestKey` durable UQ; repetir clave localiza resultado ya comprometido, no vuelve a incrementar. Upsert contador + registro oficial + clave ocurren atómicamente: rollback no persiste contador ni consume folio. Asignación comprometida después anulada conserva folio y puede dejar hueco; no se promete numeración sin huecos. | PROPUESTA de idempotencia; `DOC-VAL-01..04`, `OD-05` |
| T-029 | Documento oficial | emitir versión inmutable; corrección por rectificación crea documento oficial independiente con folio propio y `rectifiesVersionId` a origen; versiones nunca consumen folio; RBAC por clasificación/contexto | DECISIÓN VALIDADA `DOC-VAL-01/04` |
| T-030 | Logs documentales | agregar evento con actor/fecha; prohibir update/delete ordinario | PROPUESTA |
| T-031 | Identidades | autorización usa `User`; autoridad usa membership; persona física usa `Person`; afiliación usa `Affiliate`; donación usa `Donor` | BASELINE + propuesta V2; no fusionar roles |
| T-032 | Estados con detalle obligatorio | borradores de donación, recepción y devolución admiten 0 detalles; someter/confirmar exige al menos uno | PROPUESTA ARQUITECTÓNICA coherente con 9.2C/9.3C |
| T-033 | Ciclo de donación en especie | antes de someter, decidir, aceptar o confirmar recepción, validar `donorId` existente; no exigir `User` al donante y conservar formas persona/organización separadas | DECISIÓN VALIDADA OD-10; validación de ciclo complementa CHECK sin inventar estados |
| T-034 | Procedencia física | al insertar/modificar origen tipado, bloquear lote/unidad y línea; exigir mismo `InventoryItem`; permitir múltiples orígenes desde una línea solo por partición física justificada; nunca fabricar origen al reconciliar historia | PROPUESTA ARQUITECTÓNICA; trigger/TX; `DON-INV-VAL-01` |

## 4. Gates de migración y reconciliación

Gates no son decisiones abiertas: son evidencia obligatoria antes de constraints. No se declaran completados.

| Gate | Bloquea | Evidencia de salida | Estado / fuente |
|---|---|---|---|
| `ID-01` | `User.personId` y `Affiliate.personId` NOT NULL; retiro de manifiesto/duplicados | cobertura, decisiones de duplicados, cuarentena y rollback validados | Pendiente; IR |
| `GOV-HIST-01` | completar memberships/links históricos | mapping convocatoria-cargo y snapshots preservados | Pendiente; IR |
| `ASM-ATT-01` | endurecer FKs asistencia/justificación | parents verificados, excepciones en cuarentena | Pendiente; IR |
| `ASM-DATE-01` | poblar/endurecer `heldAt` | extract fecha/estado y excepciones | Pendiente; IR |
| `RES-STATUS-01` | eliminar estados legacy | cero lectores/escritores/filas dependientes y aprobación | Pendiente; IR |
| `FIN-ORIGIN-01` | `Payment.movementId` NOT NULL; quitar source genérico | clasificación de origen y correspondencia verificadas | Pendiente; IR |
| `FIN-DON-01` | `Donation.originalMovementId` NOT NULL; retirar reversión redundante | matching/reversión y excepciones revisadas | Pendiente; IR |
| `INV-LEDGER-01` | enforcement ledger firmado/saldo disponible | opening balance aprobado y balances no negativos | Pendiente; IR |
| `INV-LOAN-01` | poblar/endurecer vínculos históricos de préstamo | reporte loan-movement; solo vínculos con evidencia | Pendiente; IR |
| `DOC-HIST-01` | imponer vínculos/versiones documentales sobre historia | inventario, hashes/metadatos, mapping y excepciones aprobadas | PROPUESTA de gate en 9.4B; criterios físicos 9.4C |
| `DONOR-01` | reemplazar `Donation.donorPersonId` por `donorId` y cumplimiento histórico de obligatoriedad | donor rows deduplicadas, snapshots preservados, cobertura/excepciones, historia reconciliada sin identidades fabricadas | PROPUESTA ARQUITECTÓNICA; OD-10 no vuelve automáticamente conforme la historia |
| `FIN-MNT-01` | clasificar anticipos históricos y activar reporting de costo final | reconciliación Expense–Disbursement–Movement, sumas, moneda, cierres y excepciones | PROPUESTA ARQUITECTÓNICA |
| `INV-PHYS-01` | hacer obligatorios lotes/unidades/allocations | inventario físico conciliado sin fabricar existencia | PROPUESTA ARQUITECTÓNICA |

## 5. Decisiones físicas reservadas para 9.4C

- Tipos SQL, nombres finales de constraints/índices y estrategia de deferrability.
- Trigger vs servicio para invariantes intertabla y detalle de privilegios DB append-only.
- Nombres físicos y reparto trigger versus privilegios/rol controlado de folio; algoritmo PostgreSQL, atomicidad, idempotencia y protección contra mutación no autorizada ya son contrato lógico.
- Forma de índices parciales/exclusión e impacto de tamaño/selectividad.
- Orden de backfill, validación `NOT VALID`/`VALIDATE`, rollback o forward-fix.
- Índices de acceso no derivados de una UQ/FK y medición de planes.

Estas elecciones no cambian semántica lógica anterior y no deben adelantarse con migraciones en 9.4B.
