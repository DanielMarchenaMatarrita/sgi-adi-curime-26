# Checkpoint 9.4C-C — mapeo Prisma candidato

**Estado:** CANDIDATO V2, documentación de traducción; no `schema.prisma`, migración, DDL, dependencia ni código. Fuente física exhaustiva: [diccionario](data-dictionary.md), [relaciones](postgresql-constraints.md) e [invariantes](transactional-invariants.md). Conserva [gates](../freeze-gates.md) y OD-01/02/03/04/06/07/08/09.

## Convención de traducción

- Cada columna escalar de esta tabla se mapea una vez. `#` es número de campos escalares Prisma y columnas físicas, no relaciones inversas. Total firme: **82 modelos / 888 campos-columnas** = 49 baseline/584 + 14 adiciones V2 sobre modelos baseline + 30 nuevos/281 + 3 técnicos/9. OD-01 queda fuera: 1 modelo/8 campos.
- Baseline conserva modelo, campo, enum, default y nombre físico fijados. Campo con nombre físico igual: sin `@map`; excepciones indicadas por diccionario usan `@map("physical_name")`; tabla distinta usa `@@map("physical_table")`. No se renombran contratos baseline.
- Nuevo V2: modelo PascalCase; tabla/columna `snake_case` con `@@map`/`@map`; campo Prisma es `camelCase` mecánico (`document_record.folio_year` → `DocumentRecord.folioYear`). Cada columna listada en diccionario queda cubierta por esta regla. `id` permanece `id`.
- Tipos: `i4`→`Int @db.Integer`; `txt`→`String @db.Text`; `vN`→`String @db.VarChar(N)`; `char(N)`→`String @db.Char(N)`; `bool`→`Boolean`; `ts`→`DateTime @db.Timestamp(3)`; `date`→`DateTime @db.Date`; `num(p,s)`→`Decimal @db.Decimal(p,s)`; `json`→`Json @db.JsonB`. `enum(X)` solo usa enum Prisma ya fijado/validado; `v32` de estado/resultado/tipo/condición permanece `String @db.VarChar(32)` hasta cierre de vocabulario. `commandKey` usa `String @db.VarChar(128)`; collation `C` queda PostgreSQL-only.
- `=now` se traduce `@default(now())`; `=uuid` requiere decisión de generación compatible antes de schema; `=CRC`, booleanos y literales se preservan como `@default(...)`. `updatedAt` usa `@updatedAt` solo donde contrato Prisma lo exige; no sustituye regla PostgreSQL de actualización. Identidad nueva: `@id @default(autoincrement()) @db.Integer`; baseline conserva estrategia fijada.
- PK/UQ/FK total: `@id`/`@@id`, `@unique`/`@@unique`, `@relation(... onDelete, onUpdate: Cascade)`. Índices B-tree completos: `@@index`. Acciones exactas B001–B077 y V001–V083 son autoridad; no inferir acciones desde esta guía.

## Cobertura exhaustiva de modelos y campos

`Campos` referencia lista atómica exacta del diccionario: baseline §1, adiciones V2 §2, nuevos §3 y técnicos §4. Por tanto no omite campos aunque esta tabla no repita 888 nombres.

| Grupo | Modelo Prisma → tabla | # | Campos / mapeo |
|---|---|---:|---|
| Baseline | `OrganizationProfile` → `InstitutionalProfile` | 28 | diccionario §1; `@@map`; singleton PG-only |
| Baseline | `Person` → `Person` | 15 | §1; directo |
| Baseline | `Role` → `Role` | 6 | §1; directo |
| Baseline | `Permission` → `Permission` | 6 | §1; directo |
| Baseline | `RolePermission` → `RolePermission` | 2 | §1; PK compuesta |
| Baseline | `User` → `User` | 19 | §1; directo |
| Baseline | `Session` → `Session` | 7 | §1; directo |
| Baseline | `AuditLog` → `AuditLog` | 10 | §1; directo |
| Baseline | `PasswordResetToken` → `PasswordResetToken` | 6 | §1; directo |
| Baseline | `AccountActivationToken` → `AccountActivationToken` | 6 | §1; directo |
| Baseline | `UserRequest` → `UserRequest` | 26 | §1; directo |
| Baseline | `Affiliate` → `Affiliate` | 20 | §1; `legacyRoleId @map("roleId")` |
| Baseline | `AffiliateRequest` → `AffiliateRequest` | 34 | §1; directo |
| Baseline | `AffiliateSanction` → `AffiliateSanction` | 9 | §1; directo |
| Baseline | `GovernancePosition` → `GovernancePosition` | 7 | §1; directo |
| Baseline | `GovernanceTerm` → `BoardTerm` | 7 | §1; `legacyInstitutionalProfileId`, `startDate`, `endDate` mapean nombres físicos indicados |
| Baseline | `GovernanceMembership` → `BoardAppointment` | 12 | §1; campos legacy indicados |
| Baseline | `Assembly` → `Assembly` | 15 | §1; `type`, `legacyType`, `legacyDate` según diccionario |
| Baseline | `AssemblyCall` → `AssemblyCall` | 9 | §1; directo |
| Baseline | `AssemblyConvocation` → `AssemblyConvocation` | 10 | §1; `legacyRoleId @map("roleId")` |
| Baseline | `AssemblyAttendance` → `AssemblyAttendance` | 9 | §1; `legacyAssemblyId`, `legacyAffiliateId` |
| Baseline | `AbsenceJustification` → `AbsenceJustification` | 16 | §1; directo |
| Baseline | `AssemblyMinute` → `AssemblyMinute` | 5 | §1; directo |
| Baseline | `AssemblyResolution` → `AssemblyResolution` | 7 | §1; directo |
| Baseline | `Event` → `Event` | 12 | §1; directo |
| Baseline | `ReservableResource` → `ReservableResource` | 11 | §1; directo |
| Baseline | `Reservation` → `Reservation` | 16 | §1; directo |
| Baseline | `FinancialAccount` → `FinancialAccount` | 8 | §1; directo |
| Baseline | `FinancialCharge` → `FinancialCharge` | 8 | §1; directo |
| Baseline | `Payment` → `Payment` | 12 | §1; `legacyMethod @map("method")` |
| Baseline | `FinancialMovement` → `FinancialMovement` | 19 | §1; directo |
| Baseline | `Donation` → `Donation` | 20 | §1; directo |
| Baseline | `Expense` → `Expense` | 9 | §1; directo |
| Baseline | `ExpenseDocument` → `ExpenseDocument` | 7 | §1; directo |
| Baseline | `Disbursement` → `Disbursement` | 10 | §1; directo |
| Baseline | `FundingAllocation` → `FundingAllocation` | 7 | §1; directo |
| Baseline | `InventoryCategory` → `InventoryCategory` | 6 | §1; directo |
| Baseline | `InventoryItem` → `InventoryItem` | 13 | §1; directo |
| Baseline | `InventoryMovement` → `InventoryMovement` | 10 | §1; `legacyQuantity @map("quantity")` |
| Baseline | `InventoryLoan` → `InventoryLoan` | 20 | §1; directo |
| Baseline | `VolunteerOpportunity` → `VolunteerOpportunity` | 15 | §1; directo |
| Baseline | `VolunteerSession` → `VolunteerSession` | 12 | §1; directo |
| Baseline | `VolunteerApplication` → `VolunteerApplication` | 18 | §1; directo |
| Baseline | `VolunteerParticipation` → `VolunteerParticipation` | 11 | §1; directo |
| Baseline | `VolunteerAttendance` → `VolunteerAttendance` | 12 | §1; directo |
| Baseline | `Venture` → `Venture` | 14 | §1; directo |
| Baseline | `VentureAssociation` → `VentureAssociation` | 7 | §1; directo |
| Baseline | `VentureRequest` → `VentureRequest` | 9 | §1; directo |
| Baseline | `VentureRequestRevision` → `VentureRequestRevision` | 7 | §1; directo |
| Adición V2 | `Event.initiativeId` → `Event.initiative_id` | 1 | §2; `@map("initiative_id")` |
| Adición V2 | `VolunteerOpportunity.initiativeId` → `VolunteerOpportunity.initiative_id` | 1 | §2; `@map("initiative_id")` |
| Adición V2 | `ReservableResource.facilityId` → `ReservableResource.facility_id` | 1 | §2; `@map("facility_id")` |
| Adición V2 | `FinancialMovement.initiativeId`, `destinationType` | 2 | §2; `@map("initiative_id")`, `@map("destination_type")` |
| Adición V2 | `Donation.donorId` → `Donation.donor_id` | 1 | §2; `@map("donor_id")` |
| Adición V2 | `Expense.maintenanceWorkOrderId`, `boardResolutionId`, `expenseType`, `maintenanceCostRecognizedAt` | 4 | §2; snake-case `@map` |
| Adición V2 | `Disbursement.purpose`, `settledAt`, `settledByUserId` | 3 | §2; snake-case `@map` where names differ |
| Adición V2 | `ExpenseDocument.documentVersionId` → `ExpenseDocument.document_version_id` | 1 | §2; `@map("document_version_id")` |
| Nuevo | `BoardSession` → `board_session` | 9 | §3; camel/snake |
| Nuevo | `BoardMinute` → `board_minute` | 6 | §3; camel/snake; OD-02/03 |
| Nuevo | `BoardResolution` → `board_resolution` | 9 | §3; camel/snake; OD-03 |
| Nuevo | `EventRevision` → `event_revision` | 8 | §3; camel/snake |
| Nuevo | `EventReviewDecision` → `event_review_decision` | 10 | §3; camel/snake; `commandKey` |
| Nuevo | `EventBudgetLine` → `event_budget_line` | 8 | §3; camel/snake |
| Nuevo | `InKindDonation` → `in_kind_donation` | 9 | §3; camel/snake |
| Nuevo | `InKindDonationItem` → `in_kind_donation_item` | 8 | §3; camel/snake |
| Nuevo | `InKindDonationDecision` → `in_kind_donation_decision` | 10 | §3; camel/snake; `commandKey` |
| Nuevo | `InKindDonationReceipt` → `in_kind_donation_receipt` | 9 | §3; camel/snake; OD-03 |
| Nuevo | `InKindDonationReceiptLine` → `in_kind_donation_receipt_line` | 9 | §3; camel/snake |
| Nuevo | `InstitutionalFacility` → `institutional_facility` | 9 | §3; camel/snake |
| Nuevo | `InventoryStockLot` → `inventory_stock_lot` | 9 | §3; camel/snake |
| Nuevo | `InventoryUnit` → `inventory_unit` | 9 | §3; camel/snake |
| Nuevo | `MaintenanceIncident` → `maintenance_incident` | 10 | §3; camel/snake |
| Nuevo | `MaintenanceWorkOrder` → `maintenance_work_order` | 18 | §3; camel/snake; OD-03/06 |
| Nuevo | `ResourceUnavailability` → `resource_unavailability` | 11 | §3; camel/snake |
| Nuevo | `InventoryLoanCheckoutAllocation` → `inventory_loan_checkout_allocation` | 9 | §3; camel/snake |
| Nuevo | `InventoryLoanReturn` → `inventory_loan_return` | 9 | §3; camel/snake |
| Nuevo | `InventoryLoanReturnDetail` → `inventory_loan_return_detail` | 9 | §3; camel/snake |
| Nuevo | `InventoryLoanShortage` → `inventory_loan_shortage` | 8 | §3; camel/snake |
| Nuevo | `InventoryLoanShortageDecision` → `inventory_loan_shortage_decision` | 10 | §3; camel/snake; `commandKey` |
| Nuevo | `Initiative` → `initiative` | 8 | §3; camel/snake; OD-08 |
| Nuevo | `DocumentRecord` → `document_record` | 13 | §3; camel/snake; folio gates/OD-03/04 |
| Nuevo | `DocumentVersion` → `document_version` | 11 | §3; camel/snake |
| Nuevo | `DocumentSeries` → `document_series` | 8 | §3; camel/snake |
| Nuevo | `Donor` → `donor` | 12 | §3; camel/snake |
| Nuevo | `ExpenseDocumentLog` → `expense_document_log` | 8 | §3; camel/snake |
| Nuevo | `Correspondence` → `correspondence` | 7 | §3; camel/snake |
| Nuevo | `CorrespondenceLog` → `correspondence_log` | 8 | §3; camel/snake |
| Técnico | `DocumentFolioCounter` → `document_folio_counter` | 3 | §4; `@@id([seriesId, folioYear])` |
| Técnico | `InventoryStockLotReceiptOrigin` → `inventory_stock_lot_receipt_origin` | 3 | §4; camel/snake |
| Técnico | `InventoryUnitReceiptOrigin` → `inventory_unit_receipt_origin` | 3 | §4; camel/snake |
| Condicional | `BoardSessionAttendance` → `board_session_attendance` | 8 | §3; **no declarar hasta OD-01** |

Arithmetic: **baseline 49/584** + **V2 additions 14** = 598 fields on the 49 existing models; plus 30 firm new-business models/281 and 3 technical models/9 = **82/888**. New-business ledger has 281 only after excluding conditional attendance 8.

## Relations, keys, indexes, enums

| Prisma declaration class | Firm mapping | Conditional / limitation |
|---|---|---|
| Relations | Baseline B001–B077 (77) preserve fixed named relations where ambiguity requires it. V001–V003 and V006–V083 yield 81 firm V2 FKs. Total firm FK relations **158**. Each owns scalar FK field, uses exact nullability/action from source ledger and `onUpdate: Cascade`. | V004–V005 add 2 only after OD-01. T001 remains transition-only until ID-01. |
| PK | 81 single integer `@id`; `RolePermission` and `DocumentFolioCounter` use `@@id`, producing **82 firm PKs**. | Attendance adds one single PK. |
| Total UQ | 37 baseline `BU` + 26 firm V2 total `VU` = 63 declarations with `@unique`/`@@unique`. The three F-02 command keys are `@unique`; preserve binary collation outside Prisma. | VU05, VU07, VU31–VU34 are conditional; do not declare while OD open. |
| Explicit ordinary indexes | 108 accepted baseline + 58 firm V2 `@@index` mappings. `BI038` preserved legacy but rejected as target; `VI001` is firm only while OD-02 open. | VI002 conditional; VU05 replaces VI001 if OD-02 approves. Exact index method/concurrent creation stays SQL migration work. |
| Enums | Existing baseline enums retain exact values from frozen V1.1: `InstitutionalOrganizationType`, `IdentificationType`, `UserStatus`, `RequestStatus`, `AffiliateStatus`, `SanctionStatus`, `GovernanceTermStatus`, `BoardPosition`, `AssemblyType`, `AssemblyStatus`, `AssemblyQuorumType`, `AttendanceStatus`, `JustificationStatus`, `EventStatus`, `PublicationStatus`, `ReservableResourceStatus`, `ResourcePricingType`, `ReservationStatus`, `FinancialChargeStatus`, `PaymentStatus`, `PaymentMethod`, `FinancialMethod`, `FinancialMovementType`, `FinancialMovementSource`, `FinancialMovementOriginType`, `FinancialMovementStatus`, `DonationMethod`, `DonationStatus`, `ExpenseStatus`, `FundingSourceType`, `InventoryItemStatus`, `InventoryItemCondition`, `InventoryMovementType`, `InventoryLoanStatus`, `VolunteerOpportunityStatus`, `VolunteerSessionStatus`, `VolunteerApplicationStatus`, `VolunteerParticipationStatus`, `VolunteerAttendanceStatus`, `VentureStatus`, `VenturePublicationStatus`, `VentureRequestPurpose`, `VentureRequestStatus`. | No new enum from unconfirmed `v32` vocabulary. OD-06/08/09 block vocabulary finalization. |

## TX-01..TX-34 — future NestJS service responsibility

No service/code is opened. Future NestJS boundary owns transaction orchestration, authorization, locks, retry and error translation; Prisma client is data access only.

| TX | Future service responsibility |
|---|---|
| TX-01 | ReservationService creates reservation serializably after resource/conflict validation. |
| TX-02–05 | FinanceService confirms payment/donation/disbursement and multi-payment under money locks. |
| TX-06–08 | FinanceService records advance, settlement or excess exception without double cash. |
| TX-09–12 | MaintenanceFinanceService recognizes cost; FinanceService voids, allocates funding, confirms destination. |
| TX-13 | InstitutionalDecisionService implements durable command-key replay/compare protocol. |
| TX-14–17 | InKindDonationService submits/receives; InventoryIntakeService creates physical stock and availability. |
| TX-18 | InventoryService writes signed movement and balance atomically. |
| TX-19–25 | InventoryLoanService checks out, returns, records shortages/decisions, reconciles loan. |
| TX-26–28 | MaintenanceService authorizes/closes work and controls resource unavailability. |
| TX-29 | EventGovernanceService versions event and records exact revision decision. |
| TX-30–31 | DocumentFolioService allocates/retries/voids folio with counter lock and request key. |
| TX-32–33 | DocumentService creates/rectifies version and appends protected logs. |
| TX-34 | IdentityReconciliationService reconciles identity/donor only with evidence. |

## Non-authorization boundary

This mapping supports later schema drafting only. It does not authorize `schema.prisma`, SQL, migration, enum creation, backfill, removal/retype, NestJS implementation or freeze. PostgreSQL-only enforcement is isolated in [gap matrix](prisma-postgresql-gap-matrix.md).
