# Checkpoint 9.4C-A — anomalías y resoluciones

**Estado:** correcciones estructurales integradas al contrato lógico; no DDL, migración, Prisma ni freeze. Detalle físico queda para 9.4C-B.

## Resumen de hallazgos

Se registran **14 hallazgos**: **3 severidad alta**, **8 media** y **3 baja**. Tras corrección: **0 violaciones pendientes**, **6 riesgos**, **3 excepciones justificadas**, **2 dependientes de decisión institucional** y **3 resueltos**. N-01 afecta lote y unidad.

| ID | Severidad | Estado | Entidades | ¿Corrección antes de 9.4C-B? |
|---|---|---|---|---|
| N-01 | Alta | Resuelto | `InventoryStockLot`, `InventoryUnit`, `InKindDonationReceiptLine` | Integrado |
| N-02 | Media | Riesgo/control físico | `MaintenanceIncident`, `MaintenanceWorkOrder` | No; concretar en 9.4C-B |
| N-03 | Alta | Resuelto | `InventoryLoanShortage`, `InventoryLoanCheckoutAllocation` | Integrado |
| N-04 / OD-10 | Alta | Resuelto | `InKindDonation`, `Donor` | Integrado |
| N-05 | Media | Riesgo | líneas de oferta/recepción | No; aclarar en 9.4C-B antes de constraint físico |
| N-06 | Media | Riesgo | allocations, retornos y faltantes | No; controles físicos en 9.4C-B |
| N-07 | Media | Riesgo | `DocumentVersion`, rectificación | No; regla física en 9.4C-B |
| N-08 | Media | Riesgo | `ExpenseDocument`, `DocumentVersion` | No; depende además de OD-03/DOC-HIST-01 |
| N-09 | Media | Riesgo | `ReservableResource`, `InstitutionalFacility` | No; requiere gate de transición |
| N-10 | Baja | Excepción justificada | solicitudes, decisiones y logs | No |
| N-11 | Baja | Excepción justificada | `InventoryItem.currentQuantity` | No; preservar gate |
| N-12 | Baja | Excepción justificada | `Expense.amount`, desembolsos | No |
| N-13 | Media | Dependiente de decisión | actas y documentos | OD-02 bloquea forma final; no bloquea las tres correcciones |
| N-14 | Media | Dependiente de decisión | asistencia, firmas, egresos, iniciativas | OD-01/04/07/08 delimitan diseño físico |

## Hallazgos prioritarios y correcciones

### N-01 — procedencia de recepción dentro de lote/unidad

**Hecho:** `InKindDonationReceiptLine.itemId` identifica el artículo recibido. Si `InventoryStockLot.originReceiptLineId` o `InventoryUnit.originReceiptLineId` existe, esa FK determina el mismo `itemId`. En cada tabla física aparece entonces `originReceiptLineId → itemId`, con determinante no clave; `id` sustituta no elimina la dependencia transitiva.

**Anomalías:** una actualización puede enlazar origen de artículo A con lote/unidad de artículo B; corregir clasificación exige coordinar dos filas; una FK por sí sola no prueba igualdad.

**Corrección integrada:** se retiró `originReceiptLineId` de lote y unidad. Procedencia usa `InventoryStockLotReceiptOrigin(lotId UQ, receiptLineId)` e `InventoryUnitReceiptOrigin(unitId UQ, receiptLineId)`, asociaciones técnicas fuera de las 31 candidatas V2. `InventoryStockLot.itemId` e `InventoryUnit.itemId` siguen ownership físico canónico. Cada físico tiene cero-o-un origen; una línea puede originar múltiples lotes/unidades solo si partición física lo amerita. No se usa polimorfismo `entityType/entityId`.

**Pérdida/dependencias:** descomposición es sin pérdida: `lotId`/`unitId` UQ y FK permiten reconstruir exactamente el origen opcional mediante left join. Claves de lote/unidad y línea permanecen en sus dueños. Igualdad de artículo se preserva como constraint intertabla/TX sobre asociación; no queda atributo duplicado actualizable dentro de lote/unidad.

**Enforcement/gate:** FK tipadas durables `RESTRICT/CASCADE`; trigger/TX valida mismo `InventoryItem`. Reconciliación preserva historia y ausencia de origen: no fabrica procedencias. Corrección lógica integrada; no crea migración ni altera conteo de 31 candidatas.

### N-02 — targets físicos de incidencia y orden

**Hecho:** `MaintenanceIncident` determina su target y `MaintenanceWorkOrder` determina el suyo. El contrato permite varias órdenes por incidencia y no confirma que `incidentId → target de cada orden`; por tanto, no se demostró dependencia transitiva ni violación 3FN. Sí existe riesgo de divergencia accidental si negocio espera mismo objeto.

**Control físico propuesto para 9.4C-B:** elegir y documentar una de estas reglas sin cambiar cardinalidades:

- si toda orden reactiva debe actuar sobre objeto de incidencia, validar igualdad intertabla al autorizar;
- si una incidencia puede originar orden sobre otro objeto relacionado, conservar ambos targets y exigir razón/alcance explícito;
- en ambos casos, cada orden autorizada mantiene exactamente un target propio; preventiva puede no tener incidencia.

**Pérdida/dependencias:** no se propone descomposición hasta confirmar semántica. XOR de orden preserva MNT-VAL-01; validación intertabla evita inconsistencia si se aprueba igualdad. Ninguna PK/FK existente necesita cambiar para este control.

**Gate:** no bloquea entrada a 9.4C-B por normalización; 9.4C-B debe cerrar el control antes del diseño físico final.

### N-03 — `loanId` redundante en faltante

**Hecho:** `InventoryLoanShortage.checkoutAllocationId → InventoryLoanCheckoutAllocation.loanId`. `InventoryLoanShortage` almacenaba ambos. Surrogate `InventoryLoanShortage.id` ocultaba dependencia no clave `checkoutAllocationId → loanId`.

**Corrección integrada:** se eliminó `InventoryLoanShortage.loanId`; préstamo deriva por `checkoutAllocationId`. Índice sobre `InventoryLoanCheckoutAllocation.loanId` y ruta allocation→shortage cubren consulta por préstamo sin FK redundante.

**Pérdida/dependencias:** join con allocation reconstruye exactamente `loanId`; FK obligatoria hace descomposición sin pérdida. Dependencia se conserva en allocation y no requiere sincronización duplicada. Cardinalidad préstamo→faltantes sigue derivable y regla INV-VAL-05 permanece intacta.

**Resultado:** corrección lógica integrada antes de 9.4C-B; shortage→decision, cantidades, trazabilidad, autorización e `INV-VAL-05` no cambian.

### N-04 — donante identificable frente a FK nullable

**Hecho:** [OD-10](../logical/open-decisions.md#od-10--identificación-jurídica-de-donantes) está resuelta: no se permiten donantes anónimos. Catálogo 9.4B todavía describe `InKindDonation.donorId?` y permite anónimo/no identificado. Es contradicción de contrato, no decisión abierta.

**Corrección integrada:** `donorId` puede ser nulo solo en DRAFT; someter, decidir, aceptar o confirmar exige `donorId` válido. `Donor` conserva formas persona/organización y permanece separado de `Person`, `User` y `Affiliate`; cuenta `User` nunca es requisito del donante. Prisma expresa FK nullable/UQ; PostgreSQL aplica CHECK condicionado por estado si enum soporta frontera DRAFT/no-DRAFT y TX/servicio valida transiciones. No se inventan estados.

**Pérdida/dependencias:** no se descompone información ni se fusionan roles. Restricción de transición preserva ofertas en elaboración y evita hechos oficiales sin determinante de donante. Backfill histórico requiere `DONOR-01`; no fabricar identidades.

**Gate:** contrato lógico reconciliado; datos históricos se endurecen solo después de `DONOR-01`. OD-10 no vuelve historia automáticamente conforme ni fabrica identidades.

## Riesgos probados, no asumidos como violación

### N-05 — `itemId` en líneas de recepción

`receiptId → donationId` y `donationItemId → donationId`; la línea no almacena `donationId`, por lo que no existe duplicación intrafila. Tampoco está confirmada la FD `donationItemId → itemId`: una descripción ofrecida podría requerir clasificación física más granular al recibir. No retirar `itemId`. 9.4C-B debe fijar semántica y validar que recibo e ítem ofrecido pertenezcan a misma donación.

### N-06 — `itemId` en préstamo/allocation/retorno

`InventoryLoan.itemId`, target de allocation y movimientos deben resolver el mismo artículo. Allocation y return detail no copian `itemId`; son rutas de consistencia, no violación 3FN. Mantener igualdad intertabla y ecuación `prestada = devuelta + faltante resuelto + pendiente`. No agregar `itemId` a detalles para “facilitar” consultas.

### N-07 — rectificación documental

`DocumentVersion.rectifiesVersionId` no sustituye `documentId`. Versión correctora oficial pertenece a `DocumentRecord` independiente, recibe folio propio y apunta versión origen. Riesgos físicos: autociclo, ciclo largo o rectificación dentro del mismo documento. 9.4C-B debe prohibirlos conforme a DOC-VAL-01, sin imponer unicidad de origen no aprobada.

### N-08 — `ExpenseDocument` y versión compartida

Metadata legacy (`originalName`, `mimeType`, `size`, `url`) podría competir con metadata/contenido de `DocumentVersion`. Hasta OD-03 y `DOC-HIST-01`, conservar ambas como transición, declarar autoridad por etapa y prohibir sincronización mutable indefinida. No borrar comprobantes ni forzar asociación sin mapping.

### N-09 — ubicación textual y `facilityId`

`ReservableResource.location` puede ser snapshot/texto legacy mientras `facilityId` estructura ubicación. No son automáticamente equivalentes. Definir precedencia y reconciliación; nunca derivar facility por coincidencia textual sin evidencia.

## Excepciones justificadas

### N-10 — snapshots y evidencia append-only

Campos sometidos en solicitudes/revisiones, snapshots de prestatario/donante, `AuditLog.details`, `ExpenseDocumentLog` y `CorrespondenceLog` repiten valores deliberadamente. Dependencia es `evento histórico → snapshot`, no `entidad canónica actual → snapshot`. Condiciones: inmutabilidad/append-only, versión/formato interpretable, timestamps y actor cuando corresponda. No tratarlos como fuente operacional canónica.

### N-11 — `InventoryItem.currentQuantity`

Es caché derivada de disponibilidad, no existencia total. Se justifica para concurrencia/consulta solo con ledger autoritativo, actualización atómica, no negatividad y cierre de `INV-LEDGER-01`. Bien dañado bajo custodia aparece en lote/unidad sin aumentar disponibilidad. Excepción no autoriza escribir saldo fuera de transacción.

### N-12 — `Expense.amount` frente a suma de desembolsos

No existe FD general que obligue `Expense.amount = Σ Disbursement.amount` en todo estado. `Expense.amount` expresa obligación/costo; desembolsos expresan caja, pueden ser parciales, anticipos y settlement residual. Para mantenimiento: misma moneda, `A=Σ ADVANCE` efectivo, `C=Expense.amount`, máximo un settlement real `C-A>0`; anticipo no genera segunda salida. Diferencia es separación de hechos, no anomalía.

## Dependencias institucionales no resueltas aquí

### N-13 — actas y autoridad documental

- **OD-02:** decide una o varias identidades institucionales de acta. Bloquea CK/UQ final de `AssemblyMinute` y `BoardMinute`, no el análisis de las otras entidades.
- **OD-03:** matriz por trámite determina obligatoriedad de `DocumentRecord` y transición de contenido legacy.
- `AssemblyMinute.content` puede conservarse como baseline hasta decisión/gate. Si `DocumentVersion` se vuelve maestro, contenido legacy debe migrarse o quedar snapshot inmutable; nunca dos fuentes mutables.

### N-14 — otras decisiones abiertas

- **OD-01:** decide existencia de `BoardSessionAttendance`; si no se aprueba, asistencia queda documental. Bloquea diseño físico de esa entidad, no normalización restante.
- **OD-04:** firma, autoridad formal y retención. No altera 1FN–3FN del núcleo; bloquea campos/constraints/política de borrado.
- **OD-07:** umbrales/caja chica. No fusionar `Expense`, `Disbursement` y `FinancialMovement`; bloquea política física de autorización extraordinaria.
- **OD-08:** estados y corrección de destino. Destino único ya está confirmado; decisión bloquea ciclo/auditoría, no relación normalizada `FinancialMovement.initiativeId`.

Ninguna se decide en 9.4C-A.

## Controles negativos confirmados

- `FinancialMovement.initiativeId` = destino inicial único; `FundingAllocation.incomeMovementId` = aplicación posterior de fondos. No consolidar.
- `DocumentFolioCounter` mantiene PK `(seriesId, folioYear)`; `DocumentRecord` mantiene UQ `(seriesId, folioYear, folioSequence)`; display se deriva y no es editable.
- `DocumentSeries.code` permanece UQ e inmutable tras primera emisión. `DocumentVersion` no consume folio.
- OD-05 permanece cerrada: folio comprometido no se reutiliza. Contradicción histórica sobre “almacenamiento del string completo” resuelta: no existe columna editable/persistida ni UQ global; representación visible se deriva determinísticamente del código canónico e inmutable de la serie, año y secuencia.
