# Checkpoint 9.4C-A — dependencias funcionales

**Estado:** análisis de normalización para revisión; no congelado, no implementado. **Corte:** 2026-10-09.

## Alcance y método

Se analizaron exactamente **49 entidades**:

- las **31 candidatas V2** del [catálogo lógico](../logical/entity-catalog.md), incluida la condicionada `BoardSessionAttendance`;
- la entidad técnica `DocumentFolioCounter`, fuera del conteo de candidatas de negocio;
- **17 entidades V1.1 seleccionadas**, porque reciben campos V2 o contienen determinantes necesarios para finanzas, inventario, préstamos, donaciones, documentación, actas e iniciativas.

Este número **no significa** que las 49 entidades persistentes baseline fueran normalizadas de nuevo. Las otras 32 entidades persistentes V1.1 conservan su contrato heredado y quedan fuera de este corte. Las 17 revisadas son: `Person`, `GovernanceTerm`, `GovernanceMembership`, `AssemblyMinute`, `AssemblyResolution`, `Event`, `ReservableResource`, `FinancialMovement`, `Donation`, `Expense`, `ExpenseDocument`, `Disbursement`, `FundingAllocation`, `InventoryItem`, `InventoryMovement`, `InventoryLoan` y `VolunteerOpportunity`.

Notación: `X → Y` expresa dependencia funcional; `↛` expresa dependencia **no** confirmada. Una UQ nullable solo actúa como clave candidata sobre el subconjunto no nulo. Atributos escalares no detallados siguen dependiendo de la clave de su fila. PK sustituta no se usa para ocultar determinantes naturales, condicionales o transitivos.

## Registro de claves y dependencias

| # | Entidad | Claves candidatas consideradas | Dependencias funcionales significativas |
|---:|---|---|---|
| 1 | `BoardSession` | `id`; `(termId, sessionNumber)` | Cada clave → atributos de sesión. `(termId, sessionNumber) → id`. Número es local al período, no global. |
| 2 | `BoardMinute` | `id`; `boardSessionId` solo si OD-02 aprueba identidad única | `id → boardSessionId, documentRecordId, atributos editoriales`. `boardSessionId → id` queda condicionado por OD-02. `documentRecordId → id` solo si se adopta UQ tipada. |
| 3 | `BoardResolution` | `id`; `(boardSessionId, resolutionNumber)` | Cada clave → contenido, fecha y vínculo documental. Número depende de sesión, no existe FD `resolutionNumber → fila`. |
| 4 | `BoardSessionAttendance` | `id`; `(boardSessionId, membershipId)` | Cada clave → estado/evidencia de asistencia. Existencia completa depende de OD-01. |
| 5 | `EventRevision` | `id`; `(eventId, revisionNumber)` | Cada clave → snapshot sometido, actor y fecha. Snapshot depende de la revisión, no del estado mutable actual de `Event`. |
| 6 | `EventReviewDecision` | `id` | `id → eventRevisionId, membershipId, decidedByUserId, resultado, fecha`. No se presume una sola decisión por revisión. |
| 7 | `EventBudgetLine` | `id`; `(eventId, lineNumber)` | Cada clave → concepto e importe presupuestario. Presupuesto ↛ movimiento contable. |
| 8 | `InKindDonation` | `id` | `id → donorId, recordedByUserId, estado y datos de oferta`. `donorId` nullable solo en DRAFT; toda frontera no-DRAFT exige donante identificable, sin requerir `User`. |
| 9 | `InKindDonationItem` | `id`; `(donationId, lineNumber)` | Cada clave → descripción, cantidad ofrecida y atributos de línea. `donationId` por sí solo ↛ línea. |
| 10 | `InKindDonationDecision` | `id` | `id → donationId, membershipId, boardResolutionId, decidedByUserId, resultado, fecha`. Donación ↛ decisión única. |
| 11 | `InKindDonationReceipt` | `id`; `(donationId, receiptNumber)` | Cada clave → receptor, fecha, estado y vínculo documental. Número es local a oferta. |
| 12 | `InKindDonationReceiptLine` | `id`; `(receiptId, lineNumber)` | Cada clave → `donationItemId, itemId, quantity, condition`. `receiptId → donationId`; `donationItemId → donationId`; ambas rutas deben coincidir. No está confirmado `donationItemId → itemId`. |
| 13 | `InstitutionalFacility` | `id`; `code` | Cada clave → nombre, estado y `parentFacilityId`. Padre no determina hijo. |
| 14 | `InventoryStockLot` | `id`; `code` | Cada clave → `itemId`, condición y datos de lote. Procedencia opcional vive en asociación tipada UQ por lote; no hay `originReceiptLineId` en la fila física. |
| 15 | `InventoryUnit` | `id`; `assetCode` | Cada clave → `itemId`, condición y datos unitarios. Procedencia opcional vive en asociación tipada UQ por unidad; no hay `originReceiptLineId` en la fila física. |
| 16 | `MaintenanceIncident` | `id` | `id → facilityId, stockLotId, unitId, reportedByPersonId, estado`; exactamente un target físico por XOR. Ninguna FK target aislada es clave. |
| 17 | `MaintenanceWorkOrder` | `id` | `id → incidentId, target físico, executorPersonId, initiativeId, documentRecordId, estado`. El contrato confirma un target de orden, pero no confirma `incidentId → target de orden`: una incidencia puede originar varias órdenes y no se ha fijado que todas deban repetir su objeto. Igualdad, si se exige, es control intertabla, no FD demostrada. |
| 18 | `ResourceUnavailability` | `id` | `id → reservableResourceId, incidentId, workOrderId, intervalo, liberación`. Recurso+intervalo no es clave por sí solo; exclusión evita solapamiento incompatible. |
| 19 | `InventoryLoanCheckoutAllocation` | `id`; `checkoutMovementId` en subconjunto no nulo | Cada clave → `loanId`, `lotId/unitId`, cantidad. `loanId → itemId`; `lotId → itemId`; `unitId → itemId`; igualdad es invariante intertabla, no atributo duplicado en allocation. |
| 20 | `InventoryLoanReturn` | `id`; `(loanId, returnNumber)` | Cada clave → receptor, fecha y estado. Número es local al préstamo. |
| 21 | `InventoryLoanReturnDetail` | `id`; `(returnId, checkoutAllocationId)`; `availableEntryMovementId` no nulo | Cada clave → cantidad, condición y disponibilidad. `returnId → loanId`; `checkoutAllocationId → loanId`; ambas rutas deben coincidir. |
| 22 | `InventoryLoanShortage` | `id` | `id → checkoutAllocationId, quantity, estado`. `checkoutAllocationId → loanId` ofrece ruta derivada; `loanId` no se persiste en faltante. |
| 23 | `InventoryLoanShortageDecision` | `id` | `id → shortageId, membershipId, boardResolutionId, decidedByUserId, resultado, fecha`. Faltante ↛ decisión única. |
| 24 | `Initiative` | `id`; `code` | Cada clave → nombre, clasificación y ciclo. Estados/transiciones dependen de OD-08, no la identidad. |
| 25 | `DocumentRecord` | `id`; `(seriesId, folioYear, folioSequence)` para foliados; `officialRegistrationRequestKey` no nulo | Cada clave aplicable → identidad, clasificación, estado y registro oficial. Triple → documento. Folio visible se deriva de `DocumentSeries.code`, año y secuencia; no es atributo editable. |
| 26 | `DocumentVersion` | `id`; `(documentId, versionNumber)`; opcional `(documentId, checksum)` | Cada clave → contenido/ubicación, checksum, actor y fecha. `rectifiesVersionId` apunta versión origen pero no determina `documentId`; rectificación oficial pertenece a otro `DocumentRecord`. |
| 27 | `DocumentSeries` | `id`; `code` | Cada clave → metadatos de serie. Código canónico permanece inmutable después de primera emisión oficial. |
| 28 | `Donor` | `id`; `personId` para tipo persona; identificación jurídica normalizada para tipo organización | Cada clave parcial → perfil donante. `personId → Person` no fusiona rol donante con identidad física. |
| 29 | `ExpenseDocumentLog` | `id` | `id → expenseDocumentId, actorUserId, evento, fecha, snapshot`. Secuencia histórica append-only; documento ↛ un solo evento. |
| 30 | `Correspondence` | `id`; `documentRecordId` | Cada clave → metadatos propios de correspondencia. Folio depende del documento, no se replica. |
| 31 | `CorrespondenceLog` | `id` | `id → correspondenceId, actorUserId, evento, fecha, snapshot`. Es evidencia append-only. |
| 32 | `DocumentFolioCounter` | `(seriesId, folioYear)` | `(seriesId, folioYear) → lastAssigned`. `DocumentSeries.code` no se copia. PK compuesta conserva granularidad anual por serie. |
| 33 | `Person` | `id`; `(identificationType, normalizedIdentification)` cuando identificación existe | Cada clave → datos canónicos de persona. Rol donante, cuenta y afiliación ↛ atributos de `Person`. |
| 34 | `GovernanceTerm` | `id` | `id → startDate, endDate, status, legacyInstitutionalProfileId`. Ninguna fecha aislada es clave. |
| 35 | `GovernanceMembership` | `id`; `(termId, positionId, seatNumber)` solo para ocupación activa | `id → affiliateId, período, cargo, asiento, nombramiento`. Clave parcial activa no identifica episodios históricos cerrados. |
| 36 | `AssemblyMinute` | `id`; `assemblyId` bajo contrato baseline, condicionado en destino por OD-02 | Baseline: cada clave → `content, createdAt, updatedAt`. Si contenido migra a `DocumentVersion`, no deben quedar dos fuentes mutables de verdad. |
| 37 | `AssemblyResolution` | `id` | `id → assemblyId, title, content, resolvedAt`. No se presume numeración natural inexistente. |
| 38 | `Event` | `id`; `publicId` | Cada clave → atributos canónicos e `initiativeId`. `initiativeId` agrupa; no determina evento. |
| 39 | `ReservableResource` | `id` | `id → facilityId, nombre, precio, estado y capacidad`. `facilityId` no identifica recurso. `location` legacy no debe contradecir ubicación estructurada. |
| 40 | `FinancialMovement` | `id`; `reversalOfId` en subconjunto reversor | `id → accountId, type, amount, currency, origin, status, destinationType, initiativeId`. Ingreso confirmado determina exactamente un destino lógico. `initiativeId` ↛ allocations de ejecución. |
| 41 | `Donation` | `id`; `originalMovementId` no nulo; `legacyReversalMovementId` mientras exista | Cada clave aplicable → monto, moneda, donante snapshot, estado. `donorId` identifica rol actual; snapshots históricos dependen de la donación. |
| 42 | `Expense` | `id` | `id → amount, currency, status, maintenanceWorkOrderId, fundamento, expenseType, maintenanceCostRecognizedAt`. `amount` es obligación/costo; no es siempre `Σ Disbursement.amount`. |
| 43 | `ExpenseDocument` | `id` | `id → expenseId, metadatos legacy, documentVersionId`. Si se adopta versión documental, definir una sola fuente de contenido/metadatos después de `DOC-HIST-01`. |
| 44 | `Disbursement` | `id`; `movementId`; `(expenseId)` solo para fila `SETTLEMENT` por UQ parcial, no global | Cada clave aplicable → `expenseId, amount, currency, method, paidAt, purpose, settlement`. `expenseId` admite N desembolsos. |
| 45 | `FundingAllocation` | `id` | `id → expenseId, sourceType, amount, incomeMovementId`. `incomeMovementId` admite N allocations; representa uso posterior de fondos, no destino inicial del ingreso. |
| 46 | `InventoryItem` | `id`; `code` | Cada clave → categoría, unidad, mínimos y `currentQuantity`. Disponibilidad se deriva del ledger pero se cachea bajo `INV-LEDGER-01`; existencia física vive en lotes/unidades. |
| 47 | `InventoryMovement` | `id` | `id → itemId, type, quantityDelta, reason, actor, createdAt`. Referencias textuales ↛ identidad relacional de préstamo/recepción. |
| 48 | `InventoryLoan` | `id`; cada FK de movimiento no nula en su rol | `id → itemId, quantity, prestatario snapshot, ciclo y movimientos agregados legacy`. Allocation → loan → item; detalle V2 no cambia raíz del préstamo. |
| 49 | `VolunteerOpportunity` | `id` | `id → initiativeId, atributos de oportunidad y ciclo`. Iniciativa agrupa; no determina oportunidad. |

## Conclusiones de dependencias críticas

1. **Foliación:** `(seriesId, folioYear)` determina contador; `(seriesId, folioYear, folioSequence)` determina `DocumentRecord`; `(documentId, versionNumber)` determina versión. Versión no consume folio. Código de serie es canónico, UQ e inmutable tras emisión. Arquitectura de folios queda cerrada; OD-05 no se reabre.
2. **Caja y costo:** `movementId → Disbursement`; `Expense 1:N Disbursement`. `Expense.amount` no se reemplaza por una suma materializada: anticipo, residual y obligación son hechos distintos.
3. **Destino y ejecución:** `FinancialMovement.initiativeId` clasifica destino único del ingreso; `FundingAllocation.incomeMovementId` registra uso posterior N:1. No son dependencias equivalentes.
4. **Inventario:** `currentQuantity` es disponibilidad cacheada, no existencia física. Lotes/unidades conservan existencia; ledger conserva cambios de disponibilidad.
5. **Historia:** snapshots de solicitudes, préstamo/donación y logs dependen del evento histórico, no de la entidad canónica mutable. Son evidencia, no duplicación accidental.
6. **Rectificación:** `rectifiesVersionId` conserva linaje de contenido. Corrección oficial usa `DocumentRecord` independiente con folio propio; vínculo no convierte versión en documento foliado.
7. **Procedencia física:** `InventoryStockLotReceiptOrigin.lotId` e `InventoryUnitReceiptOrigin.unitId` son únicos; cada físico tiene cero-o-un origen y una línea puede originar varios físicos solo por partición justificada. Trigger/TX comprueba mismo `InventoryItem`; reconciliación preserva ausencia de origen sin fabricarlo.

Evaluación formal y correcciones: [matriz de normalización](normalization-matrix.md) y [anomalías y resoluciones](anomalies-and-resolutions.md).
