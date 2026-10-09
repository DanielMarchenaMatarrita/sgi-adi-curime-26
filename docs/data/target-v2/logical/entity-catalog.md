# Checkpoint 9.4B — catálogo lógico de entidades

**Estado:** contrato lógico para revisión; no congelado, no implementado. **Corte:** 2026-10-08.

**Baseline fijada:** `e8e2beb33eea8c1207fe77fe65dbd3228362bc5f` ([resumen y verificación](../../baseline-v1.1/README.md)).

**Alcance:** claves y campos que participan en identidad, relaciones o integridad. Los demás escalares V1.1 permanecen exactamente como en `schema.prisma` fijado. Toda forma física V2 sigue pendiente de 9.4C.

## Leyenda

- **BASELINE V1.1:** hecho congelado en fuente fijada; no implica datos conciliados.
- **DECISIÓN VALIDADA:** regla funcional aprobada en [registro de decisiones](../../../architecture/decisions/decision-register.md).
- **PROPUESTA ARQUITECTÓNICA:** forma lógica recomendada para materializar reglas; requiere freeze posterior.
- **CONDICIONADA:** existencia depende de aprobación institucional.
- **Gate:** condición de reconciliación antes de `NOT NULL`, eliminación o constraint destructivo.
- **Validación:** `V` = verificado contra fuente fijada; `P` = propuesto y trazado; `C` = condicionado; nunca significa implementado.

Convenciones: `PK` clave primaria; `CK/UQ` clave candidata/unicidad; `?` nullable; `→` FK. PK V2 `id` (`Int` autogenerado) es **PROPUESTA ARQUITECTÓNICA**, no requisito institucional. Acciones y cardinalidades completas: [matriz de relaciones](relationship-matrix.md). Reglas de enforcement: [matriz de restricciones](constraint-matrix.md).

## Conteo y límites

| Grupo | Conteo | Resultado |
|---|---:|---|
| Persistentes BASELINE V1.1 | 49 | V; regex de modelos y catálogo fijado coinciden |
| Transicional BASELINE V1.1 | 1 | V; `IdentityReconciliationManifest`, fuera de 49 |
| Candidatas V2 principales | 30 | P |
| Candidata V2 condicionada | 1 | C; `BoardSessionAttendance` |
| Técnicas de persistencia, fuera de candidatas V2 | 3 | P; `DocumentFolioCounter` y dos asociaciones tipadas de procedencia; no alteran 31 |

No se crean `AssetLoan` ni `FundDestination`: se reutilizan `InventoryLoan` e `Initiative`. `Person`, `User`, `Affiliate` y `Donor` conservan responsabilidades distintas.

## 49 entidades persistentes BASELINE V1.1

Cada fila preserva nombre, PK, UQ y FK del Prisma fijado. `id: Int` significa `@id @default(autoincrement())`, salvo indicación.

| # | Dominio | Entidad / estado | PK | CK/UQ relacional | FKs propietarias (nullable marcado `?`) | Gate / validación / fuente |
|---:|---|---|---|---|---|---|
| 1 | Organización | `OrganizationProfile` — BASELINE V1.1 | `id Int @default(1)` | singleton por PK fija | — | V; schema fijado, `ORG-01` |
| 2 | Identidad | `Person` — BASELINE V1.1 | `id` | `(identificationType, normalizedIdentification)` | — | V; `ID-R01` |
| 3 | IAM | `Role` — BASELINE V1.1 | `id` | `name` | — | V; schema fijado |
| 4 | IAM | `Permission` — BASELINE V1.1 | `id` | `code` | — | V; `SEC-01` |
| 5 | IAM | `RolePermission` — BASELINE V1.1 | `(roleId, permissionId)` | PK compuesta | `roleId → Role.id`; `permissionId → Permission.id` | V; `SEC-02` |
| 6 | IAM | `User` — BASELINE V1.1 | `id` | `identification`; `email`; `personId` | `roleId → Role.id`; `personId? → Person.id` | V; `personId` final obligatorio tras `ID-01` |
| 7 | IAM | `Session` — BASELINE V1.1 | `id` | `refreshTokenHash` | `userId → User.id` | V |
| 8 | Auditoría | `AuditLog` — BASELINE V1.1 | `id` | — | `userId? → User.id` | V |
| 9 | IAM | `PasswordResetToken` — BASELINE V1.1 | `id` | `tokenHash` | `userId → User.id` | V; `SEC-07` |
| 10 | IAM | `AccountActivationToken` — BASELINE V1.1 | `id` | `tokenHash` | `userId → User.id` | V; `SEC-07` |
| 11 | Identidad | `UserRequest` — BASELINE V1.1 | `id` | — | `reviewedById? → User.id`; `personId? → Person.id` | V; snapshots inmutables `ID-R04` |
| 12 | Afiliación | `Affiliate` — BASELINE V1.1 | `id` | `identification`; `email?`; `personId` | `personId? → Person.id`; `legacyRoleId?` no FK | V; `personId` final obligatorio tras `ID-01` |
| 13 | Afiliación | `AffiliateRequest` — BASELINE V1.1 | `id` | — | `reviewedById? → User.id`; `personId? → Person.id` | V; snapshots inmutables |
| 14 | Afiliación | `AffiliateSanction` — BASELINE V1.1 | `id` | — | `affiliateId → Affiliate.id`; `createdById → User.id` | V |
| 15 | Gobernanza | `GovernancePosition` — BASELINE V1.1 | `id` | `code` | — | V; `GOV-R01` |
| 16 | Gobernanza | `GovernanceTerm` — BASELINE V1.1 | `id` | — | `legacyInstitutionalProfileId` no FK | V; tabla física mapeada `BoardTerm` |
| 17 | Gobernanza | `GovernanceMembership` — BASELINE V1.1 | `id` | parcial activa `(termId, positionId, seatNumber)` pendiente SQL | `termId → GovernanceTerm.id`; `positionId? → GovernancePosition.id`; `affiliateId? → Affiliate.id`; `appointedByAssemblyId? → Assembly.id`; `legacyPersonId` no FK | V; `GOV-HIST-01` |
| 18 | Asambleas | `Assembly` — BASELINE V1.1 | `id` | — | — | V; `ASM-DATE-01` |
| 19 | Asambleas | `AssemblyCall` — BASELINE V1.1 | `id` | `(assemblyId, callNumber)` | `assemblyId → Assembly.id` | V; `ASM-R03` |
| 20 | Asambleas | `AssemblyConvocation` — BASELINE V1.1 | `id` | `(assemblyId, affiliateId)` | `assemblyId → Assembly.id`; `affiliateId → Affiliate.id`; `governanceMembershipId? → GovernanceMembership.id`; `legacyRoleId?` no FK | V; `GOV-HIST-01` |
| 21 | Asambleas | `AssemblyAttendance` — BASELINE V1.1 | `id` | `convocationId?`; `(legacyAssemblyId, legacyAffiliateId)` | `convocationId? → AssemblyConvocation.id`; campos legacy no FK | V; `ASM-ATT-01` |
| 22 | Asambleas | `AbsenceJustification` — BASELINE V1.1 | `id` | `attendanceId?`; `(legacyAssemblyId, legacyAffiliateId)` | `attendanceId? → AssemblyAttendance.id`; `reviewedById? → User.id`; campos legacy no FK | V; `ASM-ATT-01` |
| 23 | Asambleas | `AssemblyMinute` — BASELINE V1.1 | `id` | `assemblyId` | `assemblyId → Assembly.id` | V; lifecycle institucional aún por aprobar (`ASM-R12`) |
| 24 | Asambleas | `AssemblyResolution` — BASELINE V1.1 | `id` | — | `assemblyId → Assembly.id` | V |
| 25 | Eventos | `Event` — BASELINE V1.1 | `id` | `publicId` | — | V; V2 propone `initiativeId?` por `FIN-VAL-03` |
| 26 | Reservas | `ReservableResource` — BASELINE V1.1 | `id` | — | — | V; V2 propone `facilityId?` |
| 27 | Reservas | `Reservation` — BASELINE V1.1 | `id` | — | `resourceId → ReservableResource.id`; `requesterUserId → User.id`; `approvedById? → User.id`; `eventId? → Event.id` | V; `RES-01..10` |
| 28 | Finanzas | `FinancialAccount` — BASELINE V1.1 | `id` | `code` | — | V |
| 29 | Finanzas | `FinancialCharge` — BASELINE V1.1 | `id` | `reservationId` | `reservationId → Reservation.id` | V; `RES-08` |
| 30 | Finanzas | `Payment` — BASELINE V1.1 | `id` | `movementId?` | `chargeId → FinancialCharge.id`; `movementId? → FinancialMovement.id`; `recordedById? → User.id` | V; `movementId` final obligatorio tras `FIN-ORIGIN-01` |
| 31 | Finanzas | `FinancialMovement` — BASELINE V1.1 | `id` | `reversalOfId?` | `accountId? → FinancialAccount.id`; `recordedById? → User.id`; `voidedById? → User.id`; `reversalOfId? → FinancialMovement.id` | V; cuenta final obligatoria tras reconciliación; V2 propone `initiativeId?` |
| 32 | Donaciones | `Donation` — BASELINE V1.1 | `id` | `originalMovementId?`; `legacyReversalMovementId?` scalar UQ | `donorPersonId? → Person.id`; `recordedById → User.id`; `cancelledById? → User.id`; `originalMovementId? → FinancialMovement.id` | V; movimiento final obligatorio tras `FIN-DON-01`; V2 propone `donorId? → Donor.id` |
| 33 | Finanzas | `Expense` — BASELINE V1.1 | `id` | — | `authorizationResolutionId? → AssemblyResolution.id` | V; V2 propone orden y acuerdo de Junta opcionales |
| 34 | Finanzas | `ExpenseDocument` — BASELINE V1.1 | `id` | — | `expenseId → Expense.id` | V; V2 propone `documentVersionId?` |
| 35 | Finanzas | `Disbursement` — BASELINE V1.1 | `id` | `movementId` | `expenseId → Expense.id`; `movementId → FinancialMovement.id` | V; `Expense 1:N Disbursement`; `INT-01`, `FIN-R12/20` |
| 36 | Finanzas | `FundingAllocation` — BASELINE V1.1 | `id` | — | `expenseId → Expense.id`; `incomeMovementId? → FinancialMovement.id` | V; se conserva, `FIN-R16/25` |
| 37 | Inventario | `InventoryCategory` — BASELINE V1.1 | `id` | `name` | — | V |
| 38 | Inventario | `InventoryItem` — BASELINE V1.1 | `id` | `code` | `categoryId → InventoryCategory.id` | V; `currentQuantity` = disponibilidad |
| 39 | Inventario | `InventoryMovement` — BASELINE V1.1 | `id` | — | `itemId → InventoryItem.id`; `createdById? → User.id` | V; `INV-LEDGER-01` |
| 40 | Inventario | `InventoryLoan` — BASELINE V1.1, reutilizada V2 | `id` | `checkoutMovementId?`; `returnMovementId?`; `cancellationMovementId?` | `itemId → InventoryItem.id`; `borrowerAffiliateId? → Affiliate.id`; `createdById?`, `receivedById?`, `cancelledById? → User.id`; tres movement IDs `? → InventoryMovement.id` | V; `INV-LOAN-01`; no `AssetLoan` |
| 41 | Voluntariado | `VolunteerOpportunity` — BASELINE V1.1 | `id` | — | `createdByUserId → User.id` | V; V2 propone `initiativeId?` |
| 42 | Voluntariado | `VolunteerSession` — BASELINE V1.1 | `id` | — | `opportunityId → VolunteerOpportunity.id` | V |
| 43 | Voluntariado | `VolunteerApplication` — BASELINE V1.1 | `id` | parcial pendiente `(opportunityId, personId)` para PENDING | `opportunityId → VolunteerOpportunity.id`; `personId? → Person.id`; `reviewedByUserId? → User.id` | V; `VOL-I08` SQL |
| 44 | Voluntariado | `VolunteerParticipation` — BASELINE V1.1 | `id` | `applicationId`; `(opportunityId, personId)` | `opportunityId → VolunteerOpportunity.id`; `personId → Person.id`; `applicationId → VolunteerApplication.id` | V |
| 45 | Voluntariado | `VolunteerAttendance` — BASELINE V1.1 | `id` | `(participationId, sessionId)` | `participationId → VolunteerParticipation.id`; `sessionId → VolunteerSession.id`; `recordedByUserId → User.id` | V |
| 46 | Emprendimiento | `Venture` — BASELINE V1.1 | `id` | nombre no UQ | — | V; `ENT-I02` |
| 47 | Emprendimiento | `VentureAssociation` — BASELINE V1.1 | `id` | parcial abierta `(personId, ventureId)` | `personId → Person.id`; `ventureId → Venture.id` | V; `ENT-I04` SQL |
| 48 | Emprendimiento | `VentureRequest` — BASELINE V1.1 | `id` | — | `reconciledPersonId? → Person.id`; `ventureId? → Venture.id` | V |
| 49 | Emprendimiento | `VentureRequestRevision` — BASELINE V1.1 | `id` | `(requestId, revisionNumber)` | `requestId → VentureRequest.id` | V |

### Entidad transicional fuera del conteo 49

| Dominio | Entidad / estado | PK | CK/UQ | FK | Gate / validación / fuente |
|---|---|---|---|---|---|
| Reconciliación | `IdentityReconciliationManifest` — BASELINE V1.1 transicional | `id` | `(normalizationVersion, decisionVersion, sourceModel, sourceId)` | `selectedPersonId? → Person.id` (`SET NULL`) | V; existe solo para `ID-01`; no es persistente objetivo |

## 31 candidatas V2

Campos listados son **PROPUESTA ARQUITECTÓNICA**, salvo semántica respaldada por decisión indicada. Ninguna candidata está implementada ni congelada. Toda FK usa por defecto `onUpdate CASCADE`; `onDelete` exacto figura en matriz de relaciones.

| # | Dominio | Entidad / estado | PK propuesta | CK/UQ propuesta | Campos FK propuestos y nulabilidad | Validación / fuente |
|---:|---|---|---|---|---|---|
| V2-01 | Gobernanza | `BoardSession` — principal | `id` | `(termId, sessionNumber)`; número local por período | `termId → GovernanceTerm.id` | P; [9.2A](../../../architecture/v2/checkpoints/9.2A-gobernanza.md) |
| V2-02 | Gobernanza | `BoardMinute` — principal | `id` | `boardSessionId` | `boardSessionId → BoardSession.id`; `documentRecordId? → DocumentRecord.id` | P; 0..1 por sesión; lifecycle abierto |
| V2-03 | Gobernanza | `BoardResolution` — principal | `id` | `(boardSessionId, resolutionNumber)` | `boardSessionId → BoardSession.id`; `documentRecordId? → DocumentRecord.id` | P; acuerdo de Junta distinto de Asamblea |
| V2-04 | Gobernanza | `BoardSessionAttendance` — **CONDICIONADA** | `id` | `(boardSessionId, membershipId)` | `boardSessionId → BoardSession.id`; `membershipId → GovernanceMembership.id` | C; solo si se aprueba registro individual estructurado |
| V2-05 | Eventos | `EventRevision` — principal | `id` | `(eventId, revisionNumber)` | `eventId → Event.id`; `submittedByUserId? → User.id` | P; revisión histórica, no decisión |
| V2-06 | Eventos | `EventReviewDecision` — principal | `id` | — | `eventRevisionId → EventRevision.id`; `membershipId → GovernanceMembership.id`; `decidedByUserId? → User.id` | P; competencia institucional separada de cuenta |
| V2-07 | Eventos | `EventBudgetLine` — principal | `id` | `(eventId, lineNumber)` | `eventId → Event.id` | P; presupuesto no movimiento contable |
| V2-08 | Donaciones | `InKindDonation` — principal | `id` | — | `donorId? → Donor.id`; `recordedByUserId? → User.id` | P; `donorId` nullable solo en DRAFT; someter, decidir, aceptar o confirmar exige donante válido; no crea ingreso monetario |
| V2-09 | Donaciones | `InKindDonationItem` — principal | `id` | `(donationId, lineNumber)` | `donationId → InKindDonation.id` | P; borrador admite 0 ítems; presentación exige 1..N y cantidad positiva |
| V2-10 | Donaciones | `InKindDonationDecision` — principal | `id` | — | `donationId → InKindDonation.id`; `membershipId → GovernanceMembership.id`; `boardResolutionId? → BoardResolution.id`; `decidedByUserId? → User.id` | P; `DON-VAL-05/07` |
| V2-11 | Donaciones | `InKindDonationReceipt` — principal | `id` | `(donationId, receiptNumber)` | `donationId → InKindDonation.id`; `receivedByUserId → User.id`; `documentRecordId? → DocumentRecord.id` | P; recepción parcial/total distinta de oferta |
| V2-12 | Donaciones | `InKindDonationReceiptLine` — principal | `id` | `(receiptId, lineNumber)` | `receiptId → InKindDonationReceipt.id`; `donationItemId → InKindDonationItem.id`; `itemId → InventoryItem.id` | P; borrador admite 0 líneas; confirmación exige 1..N, cantidad positiva y misma donación |
| V2-13 | Inventario | `InstitutionalFacility` — principal | `id` | `code` | `parentFacilityId? → InstitutionalFacility.id` | P; jerarquía acíclica |
| V2-14 | Inventario | `InventoryStockLot` — principal | `id` | `code` | `itemId → InventoryItem.id` | P; existencia física separada de disponibilidad; procedencia opcional en asociación técnica tipada |
| V2-15 | Inventario | `InventoryUnit` — principal | `id` | `assetCode` | `itemId → InventoryItem.id` | P; procedencia opcional en asociación técnica tipada |
| V2-16 | Mantenimiento | `MaintenanceIncident` — principal | `id` | — | exactamente una: `facilityId? → InstitutionalFacility.id`, `stockLotId? → InventoryStockLot.id`, `unitId? → InventoryUnit.id`; `reportedByPersonId? → Person.id` | P; `INV-VAL-02`, XOR SQL |
| V2-17 | Mantenimiento | `MaintenanceWorkOrder` — principal | `id` | — | `incidentId? → MaintenanceIncident.id`; exactamente una de `facilityId?`, `stockLotId?`, `unitId?`; `executorPersonId? → Person.id`; `authorizedByUserId? → User.id`; `initiativeId? → Initiative.id`; `documentRecordId? → DocumentRecord.id` | P; objeto obligatorio al autorizar y ejecutor al asignar; `MNT-VAL-01..05` |
| V2-18 | Inventario/reservas | `ResourceUnavailability` — principal | `id` | exclusión temporal activa pendiente SQL | `reservableResourceId → ReservableResource.id`; `incidentId? → MaintenanceIncident.id`; `workOrderId? → MaintenanceWorkOrder.id`; `releasedByUserId? → User.id` | P; bloqueo no cancela reservas |
| V2-19 | Préstamos | `InventoryLoanCheckoutAllocation` — principal | `id` | `checkoutMovementId?` | `loanId → InventoryLoan.id`; XOR `lotId? → InventoryStockLot.id` / `unitId? → InventoryUnit.id`; `checkoutMovementId? → InventoryMovement.id` | P; mismo `InventoryItem`, cantidad positiva |
| V2-20 | Préstamos | `InventoryLoanReturn` — principal | `id` | `(loanId, returnNumber)` | `loanId → InventoryLoan.id`; `receivedByUserId → User.id` | P; múltiples devoluciones parciales |
| V2-21 | Préstamos | `InventoryLoanReturnDetail` — principal | `id` | `(returnId, checkoutAllocationId)`; `availableEntryMovementId?` | `returnId → InventoryLoanReturn.id`; `checkoutAllocationId → InventoryLoanCheckoutAllocation.id`; `availableEntryMovementId? → InventoryMovement.id` | P; borrador admite 0 detalles; confirmación exige 1..N; movimiento solo si vuelve a disponibilidad |
| V2-22 | Préstamos | `InventoryLoanShortage` — principal | `id` | — | `checkoutAllocationId → InventoryLoanCheckoutAllocation.id` | P; préstamo deriva por allocation; faltante no retorno físico |
| V2-23 | Préstamos | `InventoryLoanShortageDecision` — principal | `id` | — | `shortageId → InventoryLoanShortage.id`; `membershipId → GovernanceMembership.id`; `boardResolutionId? → BoardResolution.id`; `decidedByUserId? → User.id` | P; `INV-VAL-05` |
| V2-24 | Iniciativas | `Initiative` — principal | `id` | `code` | — | P; `FIN-VAL-02/03`; no `FundDestination` |
| V2-25 | Documentación | `DocumentRecord` — principal | `id` sustituta | **solo** `(seriesId, folioYear, folioSequence)` para foliados; `officialRegistrationRequestKey` UQ nullable | `seriesId? → DocumentSeries.id` en borrador; obligatorio al foliar | P; conserva `officialRegisteredAt` y `status`; `DOC-VAL-01..04`; sin UQ global ni campo `folio` editable |
| V2-26 | Documentación | `DocumentVersion` — principal | `id` | `(documentId, versionNumber)`; opcional `(documentId, checksum)` | `documentId → DocumentRecord.id`; `createdByUserId? → User.id`; `rectifiesVersionId? → DocumentVersion.id` | P; nunca consume folio; oficial/evidencia inmutable; rectificación oficial independiente recibe folio propio |
| V2-27 | Documentación | `DocumentSeries` — principal | `id` | `code` institucional UQ | — | P; código canónico inmutable después de primera emisión oficial; historia de serie se retiene; numeración anual independiente |
| V2-28 | Donantes | `Donor` — principal | `id` | `personId?`; identificación jurídica normalizada parcial según tipo | `personId? → Person.id` | P; no reemplaza `Person`, `User` ni `Affiliate` |
| V2-29 | Documentos financieros | `ExpenseDocumentLog` — principal | `id` | — | `expenseDocumentId → ExpenseDocument.id`; `actorUserId? → User.id` | P; append-only |
| V2-30 | Correspondencia | `Correspondence` — principal | `id` | `documentRecordId` | `documentRecordId → DocumentRecord.id` | P; folio canónico vive en documento |
| V2-31 | Correspondencia | `CorrespondenceLog` — principal | `id` | — | `correspondenceId → Correspondence.id`; `actorUserId? → User.id` | P; append-only |

### Entidades técnicas de persistencia — fuera de las 31 candidatas V2

| Dominio | Entidad / estado | PK | Campos / FK | Fuente y alcance |
|---|---|---|---|---|
| Documentación | `DocumentFolioCounter` — técnica, no candidata de negocio | `(seriesId, folioYear)` | `seriesId → DocumentSeries.id`; `folioYear`; `lastAssigned` | P; soporte PostgreSQL para asignación anual concurrente. FK durable `RESTRICT / CASCADE`; fuente `DOC-VAL-01..04`, `OD-05`. No cambia conteo 49 baseline ni 31 candidatas V2. |
| Inventario | `InventoryStockLotReceiptOrigin` — asociación técnica tipada | `id` | `lotId` UQ `→ InventoryStockLot.id`; `receiptLineId → InKindDonationReceiptLine.id` | P; 0..1 origen por lote; una línea puede originar varios lotes solo si partición física lo amerita. FK durable `RESTRICT / CASCADE`; igualdad de `InventoryItem` por trigger/TX. No altera 31 candidatas V2. |
| Inventario | `InventoryUnitReceiptOrigin` — asociación técnica tipada | `id` | `unitId` UQ `→ InventoryUnit.id`; `receiptLineId → InKindDonationReceiptLine.id` | P; 0..1 origen por unidad; una línea puede originar varias unidades solo si partición física lo amerita. FK durable `RESTRICT / CASCADE`; igualdad de `InventoryItem` por trigger/TX. No altera 31 candidatas V2. |

## Campos relacionales V2 añadidos a entidades V1.1

Todos son **PROPUESTA ARQUITECTÓNICA**; preservan contratos baseline hasta gates.

| Entidad existente | Campo / clave propuesta | Semántica y estado |
|---|---|---|
| `Event` | `initiativeId? → Initiative.id` | agrupación opcional, `FIN-VAL-03` |
| `VolunteerOpportunity` | `initiativeId? → Initiative.id` | agrupación opcional, `FIN-VAL-03` |
| `ReservableResource` | `facilityId? → InstitutionalFacility.id` | ubicación institucional estructurada; no obliga a migrar `location` sin evidencia |
| `FinancialMovement` | `initiativeId? → Initiative.id`; `destinationType` | ingreso confirmado: `INITIATIVE` XOR `GENERAL_FUND`; no fraccionamiento, `FIN-VAL-02` |
| `Donation` | `donorId? → Donor.id` | reemplazo objetivo de `donorPersonId` solo tras gate; conserva snapshots históricos |
| `Expense` | `maintenanceWorkOrderId? → MaintenanceWorkOrder.id`; `boardResolutionId? → BoardResolution.id`; `expenseType`; `maintenanceCostRecognizedAt?` | `Expense 1:N Disbursement`; costo mantenimiento solo tras cierre verificado |
| `Disbursement` | `purpose` (`REGULAR/ADVANCE/SETTLEMENT`); `settledAt?`; `settledByUserId? → User.id`; UQ parcial propuesta `expenseId WHERE purpose=SETTLEMENT` | todo anticipo se concilia por su mismo `expenseId`; liquidación marca avances pendientes y solo el residual efectivamente pagado crea `SETTLEMENT` + movimiento |
| `ExpenseDocument` | `documentVersionId? → DocumentVersion.id` | adaptación documental opcional; asociación exacta sujeta a decisión documental |

## Dependencias funcionales y no-duplicación

- `Disbursement.movementId → expenseId, amount, currency, method, paidAt`; UQ no-null fija `FinancialMovement 1:0..1 Disbursement`.
- `Disbursement.expenseId` es la relación de conciliación: cada `ADVANCE` y su costo definitivo pertenecen al mismo `Expense`; no se necesita entidad ni FK adicional anticipo↔costo.
- Para un `Expense` de mantenimiento reconocido, `A = Σ Disbursement.amount` de sus `ADVANCE` efectivos no anulados y `C = Expense.amount`, siempre en `Expense.currency`. La liquidación bloquea el gasto y sus desembolsos, marca atómicamente todos los `ADVANCE` pendientes aplicables con `settledAt/settledByUserId`, y crea un único `SETTLEMENT` solo si existe pago residual real `R = C - A > 0`.
- Idempotencia: UQ parcial lógica de máximo un `SETTLEMENT` por `expenseId`, actualización condicionada de anticipos `settledAt IS NULL` y reconocimiento único `maintenanceCostRecognizedAt`. Repetir la misma liquidación produce cero movimientos nuevos. Si `A > C`, no se crea importe negativo: queda excepción de reconciliación y cualquier devolución/reversión usa proceso monetario auditado existente.
- `(seriesId, folioYear, folioSequence) → DocumentRecord`; ningún `folio` global ni cadena `folio` editable se declara/persiste. Borrador puede tener `seriesId` sin folio; `folioYear` y `folioSequence` son ambos `NULL` o ambos no nulos; registro oficial exige los tres más `officialRegisteredAt` y `status` oficial.
- Folio visible es derivado, nunca columna editable: `SERIE-2026-000123` para código canónico `SERIE`, año `2026` y secuencia serializada a ancho fijo. Código canónico inmutable + año + serialización inyectiva de secuencia + UQ triple prueban ausencia de colisión lógica.
- `(documentId, versionNumber) → DocumentVersion`; versión nunca consume folio ni se sobrescribe. Corrección oficial es `DocumentRecord` independiente con folio propio y `rectifiesVersionId` hacia versión origen.
- `(eventId, revisionNumber) → EventRevision`; revisión no equivale a decisión.
- `InventoryLoan` sigue siendo raíz del préstamo; allocations, retornos y faltantes son detalle, no préstamo alterno.
- `InventoryLoanShortage.checkoutAllocationId → InventoryLoanCheckoutAllocation.loanId`; faltante no persiste `loanId` redundante.
- Procedencia de recepción es opcional y tipada: cada lote/unidad tiene cero-o-un registro de origen; una línea de recepción puede originar múltiples lotes/unidades solo ante partición física justificada. No se usa `entityType/entityId`; historia y reconciliación bloquean fabricar orígenes.
- `InKindDonation.donorId` puede ser nulo solo en DRAFT; fuera de DRAFT requiere donante válido. `Donor` puede ser persona u organización; no requiere cuenta `User`.
- `Initiative` es destino/agregador; no duplica `Event`, `VolunteerOpportunity` ni fondo general.
- `Person` identifica persona física; `User` autentica; `Affiliate` registra afiliación; `Donor` registra rol de donante persona u organización.

## Fuentes

1. [Baseline V1.1 y revisión fijada](../../baseline-v1.1/README.md).
2. `schema.prisma`, `target-model.md` e `integrity-rules.md` fijados en `e8e2beb33eea8c1207fe77fe65dbd3228362bc5f`.
3. [Inventario 49/31](../entity-inventory.md), [borrador 9.4B](../9.4B-borrador-relacional.md), [freeze gates](../freeze-gates.md).
4. [Registro de decisiones](../../../architecture/decisions/decision-register.md) y checkpoints 9.2A–9.3D enlazados allí.
