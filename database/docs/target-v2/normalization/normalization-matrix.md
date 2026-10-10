# Checkpoint 9.4C-A — matriz de normalización 1FN–3FN

**Estado:** revisión estructural; no congelada, no implementada. **Universo:** exactamente **49 entidades** definido en [dependencias funcionales](functional-dependencies.md).

## Criterios

- **1FN:** atributos escalares/atómicos para el contrato conocido; JSON histórico se trata como evidencia opaca versionada, no como sustituto de relaciones operativas.
- **2FN:** todo atributo no clave depende de la clave candidata completa; se revisan claves naturales aunque exista `id` sustituta.
- **3FN:** ningún atributo no clave depende de otro atributo no clave. Dependencias condicionales por FK también cuentan.
- **Pasa con excepción** no significa violación: identifica snapshot histórico, evidencia append-only, caché derivada controlada o campo transicional.
- Severidad: **A** alta, **M** media, **B** baja, **—** sin anomalía. Estados: **violación confirmada**, **riesgo**, **excepción justificada**, **dependiente de decisión**, **sin defecto**.

## Matriz

| Entidad | Claves candidatas | Dependencias funcionales | 1FN | 2FN | 3FN | Anomalía | Corrección | Estado / fuente de decisión |
|---|---|---|---|---|---|---|---|---|
| `BoardSession` | `id`; `(termId,sessionNumber)` | claves → sesión | Sí | Sí | Sí | — | Ninguna | Sin defecto; candidato V2, 9.2A/P-019 |
| `BoardMinute` | `id`; `boardSessionId` cond.; `documentRecordId` cond. | clave → acta/vínculo | Sí | Sí | Sí | M: cardinalidad y fuente editorial abiertas | Fijar identidad y autoridad de contenido antes de UQ física | Dependiente de OD-02/OD-03; 9.2A/9.3D |
| `BoardResolution` | `id`; `(boardSessionId,resolutionNumber)` | claves → acuerdo | Sí | Sí | Sí | B: vínculo documental exacto abierto | Mantener FK tipada propuesta; concretar con OD-03 | Riesgo; P-021/V078 |
| `BoardSessionAttendance` | `id`; `(boardSessionId,membershipId)` | claves → asistencia | Sí | Sí | Sí | M: entidad no aprobada | No crear físicamente hasta decisión | Dependiente de OD-01; CONDICIONADA |
| `EventRevision` | `id`; `(eventId,revisionNumber)` | claves → snapshot de revisión | Sí | Sí | Sí | B: snapshot podría confundirse con estado actual | Declarar inmutable y campos materiales | Excepción justificada; OD-09/T-026 |
| `EventReviewDecision` | `id` | `id` → revisión, autoridad, resultado | Sí | Sí | Sí | — | Ninguna | Sin defecto; 9.2B |
| `EventBudgetLine` | `id`; `(eventId,lineNumber)` | claves → línea presupuestaria | Sí | Sí | Sí | — | No vincularla como movimiento contable | Sin defecto; 9.2B/P-024 |
| `InKindDonation` | `id` | `id` → oferta, donante, estado | Sí | Sí | Sí | — | `donorId` nullable solo DRAFT; CHECK por estado + TX de ciclo en no-DRAFT; `Donor` persona/organización, no `User` | Sin defecto; OD-10 integrado; historia depende de `DONOR-01` |
| `InKindDonationItem` | `id`; `(donationId,lineNumber)` | claves → línea ofrecida | Sí | Sí | Sí | — | Ninguna | Sin defecto; DON-VAL-04/P-025 |
| `InKindDonationDecision` | `id` | `id` → oferta, autoridad, decisión | Sí | Sí | Sí | — | Ninguna | Sin defecto; DON-VAL-05/07 |
| `InKindDonationReceipt` | `id`; `(donationId,receiptNumber)` | claves → recepción | Sí | Sí | Sí | B: documento obligatorio por trámite abierto | Mantener vínculo nullable hasta matriz documental | Dependiente de OD-03; DON-VAL-06 |
| `InKindDonationReceiptLine` | `id`; `(receiptId,lineNumber)` | clave → item ofrecido, item inventario, cantidad; ambos padres → donación | Sí | Sí | Sí | M: `itemId` podría duplicar clasificación de `donationItemId`, pero FD no está confirmada | No eliminar; definir si una línea ofrecida admite varios `InventoryItem`; siempre validar misma donación | Riesgo; T-014 |
| `InstitutionalFacility` | `id`; `code` | claves → instalación/padre | Sí | Sí | Sí | — | Preservar aciclicidad fuera de FN | Sin defecto; S-029 |
| `InventoryStockLot` | `id`; `code` | claves → lote; procedencia opcional separada | Sí | Sí | Sí | — | Asociación tipada UQ por lote; trigger/TX iguala `InventoryItem` | Sin defecto; DON-INV-VAL-01/V026-028 |
| `InventoryUnit` | `id`; `assetCode` | claves → unidad; procedencia opcional separada | Sí | Sí | Sí | — | Asociación tipada UQ por unidad; trigger/TX iguala `InventoryItem` | Sin defecto; DON-INV-VAL-01/V029-031 |
| `MaintenanceIncident` | `id` | `id` → target XOR y reporte | Sí | Sí | Sí | — | Inmutabilizar target tras aceptación | Sin defecto; INV-VAL-02/S-020 |
| `MaintenanceWorkOrder` | `id` | `id` → orden y target; `incidentId → target de orden` no está confirmada | Sí | Sí | Sí | M: targets de incidencia/orden podrían divergir; puede ser alcance legítimo de varias órdenes | En 9.4C-B fijar regla intertabla: igualdad si negocio la exige, o divergencia explícita y auditada; conservar XOR propio de orden | Riesgo/control físico; MNT-VAL-01/S-020/021 |
| `ResourceUnavailability` | `id` | `id` → recurso, causa, intervalo | Sí | Sí | Sí | B: dos causas opcionales no son duplicación si ambas documentan cadena causal | Definir regla de coexistencia; conservar exclusión temporal | Riesgo; MNT-VAL-04/S-030 |
| `InventoryLoanCheckoutAllocation` | `id`; `checkoutMovementId` no nulo | claves → loan, target XOR, cantidad | Sí | Sí | Sí | M: rutas loan/lot/unit deben resolver mismo item | Trigger/TX de igualdad; no agregar `itemId` | Riesgo; S-026/027 |
| `InventoryLoanReturn` | `id`; `(loanId,returnNumber)` | claves → devolución | Sí | Sí | Sí | — | Ninguna | Sin defecto; INV-VAL-04 |
| `InventoryLoanReturnDetail` | `id`; `(returnId,checkoutAllocationId)`; movement no nulo | claves → cantidad/condición; ambos padres → loan | Sí | Sí | Sí | M: padres pueden pertenecer a préstamos distintos | Constraint intertabla/TX de mismo préstamo | Riesgo; INV-VAL-04/T-018 |
| `InventoryLoanShortage` | `id` | `id` → fila; allocation → loan derivado | Sí | Sí | Sí | — | Sin `loanId`; índice/ruta allocation→loan para consulta | Sin defecto; INV-VAL-05 |
| `InventoryLoanShortageDecision` | `id` | `id` → faltante, autoridad, resultado | Sí | Sí | Sí | — | Ninguna | Sin defecto; INV-VAL-05 |
| `Initiative` | `id`; `code` | claves → iniciativa/ciclo | Sí | Sí | Sí | M: ciclo/corrección de destino abiertos, no defecto NF | No inventar estados; preparar auditoría sin cambiar destino confirmado | Dependiente de OD-08; FIN-VAL-02/03 |
| `DocumentRecord` | `id`; triple foliado; request key no nula | claves → documento; triple → identidad oficial | Sí | Sí | Sí | — | Conservar triple UQ, idempotencia e inmutabilidad | Sin defecto; DOC-VAL-01..04/OD-05 |
| `DocumentVersion` | `id`; `(documentId,versionNumber)`; checksum cond. | claves → versión; rectified version ↛ document | Sí | Sí | Sí | M: vínculo de rectificación puede aceptar mismo documento/ciclos | Exigir documento distinto, no autociclo y linaje válido; no UQ sin política | Riesgo; DOC-VAL-01/T-029 |
| `DocumentSeries` | `id`; `code` | claves → serie | Sí | Sí | Sí | — | Código inmutable tras primera emisión | Sin defecto; DOC-VAL-02/S-032 |
| `Donor` | `id`; `personId` parcial; identificación jurídica parcial | clave aplicable → perfil donante | Sí | Sí | Sí | — | Mantener separación de roles y UQ parciales por tipo | Sin defecto; OD-10/S-038 |
| `ExpenseDocumentLog` | `id` | `id` → evento histórico | Sí | Sí | Sí | B: datos repetidos son evidencia temporal | Append-only; snapshot explícito, no fuente canónica | Excepción justificada; S-037/T-030 |
| `Correspondence` | `id`; `documentRecordId` | claves → correspondencia | Sí | Sí | Sí | — | No copiar folio | Sin defecto; P-035 |
| `CorrespondenceLog` | `id` | `id` → evento histórico | Sí | Sí | Sí | B: snapshot/evento repetido intencional | Append-only | Excepción justificada; S-037 |
| `DocumentFolioCounter` | `(seriesId,folioYear)` | PK completa → `lastAssigned` | Sí | Sí | Sí | — | Proteger incremento; no PK sustituta | Sin defecto; P-037/S-034/035 |
| `Person` | `id`; identificación normalizada compuesta | claves → persona canónica | Sí | Sí | Sí | — | No absorber `Donor`, `User` ni `Affiliate` | Sin defecto; ID-R01/OD-10 |
| `GovernanceTerm` | `id` | `id` → período | Sí | Sí | Sí | B: scalar institucional legacy transicional | Retirar solo con evidencia, no fabricar raíz | Excepción justificada; GOV-HIST-01 |
| `GovernanceMembership` | `id`; ocupación activa parcial | clave → episodio de membresía | Sí | Sí | Sí | B: cargo/persona legacy son evidencia de transición | Reconciliar antes de NOT NULL/retiro | Excepción justificada; GOV-HIST-01 |
| `AssemblyMinute` | `id`; `assemblyId` baseline, final condicionado | claves → contenido baseline | Sí | Sí | Sí | M: `content` y `DocumentVersion` podrían competir como fuente | Tras OD-02/03, migrar contenido o declararlo snapshot inmutable; no dos maestros | Dependiente de OD-02/OD-03; ASM-R12 |
| `AssemblyResolution` | `id` | `id` → acuerdo de Asamblea | Sí | Sí | Sí | — | Mantener distinta de `BoardResolution` | Sin defecto; ASM-R11 |
| `Event` | `id`; `publicId` | claves → evento e iniciativa | Sí | Sí | Sí | — | No copiar datos de iniciativa ni revisión vigente | Sin defecto; FIN-VAL-03 |
| `ReservableResource` | `id` | `id` → recurso/facility | Sí | Sí | Sí | B: `location` legacy puede divergir de facility estructurada | Definir precedence y gate; no borrar snapshot sin evidencia | Riesgo; V025 |
| `FinancialMovement` | `id`; reversal source no nula | `id` → movimiento/destino | Sí | Sí | Sí | M: confundir destino `initiativeId` con financiación posterior | Mantener semánticas separadas y XOR destino | Sin defecto con límite; FIN-VAL-02/T-010/011 |
| `Donation` | `id`; movement original no nulo; reversal legacy | claves → donación/snapshots | Sí | Sí | Sí | B: donor snapshot y `donorId` coexistirán en transición | Preservar snapshot; reemplazar FK solo tras `DONOR-01` | Excepción justificada; FIN-DON-01/DONOR-01 |
| `Expense` | `id` | `id` → obligación/costo | Sí | Sí | Sí | M: asumir `amount = Σ desembolsos` destruiría distinción contable | Mantener importe del gasto; validar conciliación por propósito/moneda | Sin defecto con límite; FIN-MNT-VAL-01/02 |
| `ExpenseDocument` | `id` | `id` → gasto, metadata legacy, versión | Sí | Sí | Sí | M: posible doble fuente de archivo/metadatos | Elegir autoridad y transición en OD-03/DOC-HIST-01; no sincronización mutable indefinida | Riesgo; V081 |
| `Disbursement` | `id`; `movementId`; settlement parcial | claves → pago y gasto | Sí | Sí | Sí | — | Mantener 1:N con Expense y UQ movement | Sin defecto; INT-01/FIN-MNT-VAL-02 |
| `FundingAllocation` | `id` | `id` → gasto, fuente, monto, ingreso | Sí | Sí | Sí | — | Mantener separada de destino inicial | Sin defecto; FIN-R16/25 |
| `InventoryItem` | `id`; `code` | claves → artículo/disponibilidad | Sí | Sí | Sí | B: `currentQuantity` es caché derivada | Ledger autoritativo + actualización atómica + reconciliación | Excepción justificada; INV-R04/INV-LEDGER-01 |
| `InventoryMovement` | `id` | `id` → delta/ítem/evento | Sí | Sí | Sí | — | Mantener append-only económico-operativo y FK explícitas | Sin defecto; INV-R01..03 |
| `InventoryLoan` | `id`; movement FK por rol no nula | `id` → raíz/ítem/snapshot | Sí | Sí | Sí | B: movimientos agregados legacy coexistirán con detalle V2 | Conservar durante `INV-LOAN-01`; retirar/endurecer solo con evidencia | Excepción justificada; INV-R08/11 |
| `VolunteerOpportunity` | `id` | `id` → oportunidad/iniciativa | Sí | Sí | Sí | — | No duplicar Initiative | Sin defecto; FIN-VAL-03 |

## Totales

| Resultado | 1FN | 2FN | 3FN |
|---|---:|---:|---:|
| Cumple | **49** | **49** | **49** |
| No cumple | **0** | **0** | **0** |

Las 49 filas cumplen 3FN tras separar procedencia física tipada, derivar préstamo de faltante por allocation y cerrar OD-10 en contrato. `MaintenanceWorkOrder` conserva riesgo N-02: el contrato no confirma que `incidentId` determine target de cada orden; coherencia queda como control físico/intertabla de 9.4C-B. Obligación histórica de donante permanece gate `DONOR-01`; no se fabrica ni declara conforme automáticamente.
