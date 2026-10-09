# Checkpoint 9.4C-B — constraints e índices PostgreSQL

**Estado:** CANDIDATO V2; sin DDL, migración ni freeze. Complementa [diccionario](data-dictionary.md) y materializa, sin cambiar semántica, la [matriz lógica](../logical/constraint-matrix.md).

## 1. Capas de enforcement

| Capa | Prisma futuro | PostgreSQL específico |
|---|---|---|
| PK, FK, acciones, nulabilidad, UQ total | `@id`, `@@id`, `@relation`, `?`, `@unique`, `@@unique` | nombres físicos; solo FK admite rollout `NOT VALID`/`VALIDATE` |
| CHECK local | no soportado declarativamente por Prisma schema | `CHECK` nombrado |
| UQ parcial | no | índice `UNIQUE ... WHERE` |
| No solapamiento | no | `EXCLUDE USING gist` con `btree_gist` |
| Integridad intertabla, inmutabilidad, append-only | no | trigger mínimo + privilegios; servicio también valida |
| Sumas, competencia, ciclo, idempotencia | transacción Prisma/servicio | locks, aislamiento y constraints como última defensa |

Convención: `pk_<tabla>`, `uq_<tabla>_<columnas>`, `fk_<tabla>_<columna>`, `ck_<tabla>_<regla>`, `ix_<tabla>_<columnas>`, `ex_<tabla>_<regla>`. Máximo PostgreSQL 63 bytes: abreviar determinísticamente en migración sin perder prefijo/tabla/regla.

## 2. Conteos firmes y condicionados

Objetos OD nunca se mezclan con conteo firme. Ledgers §§4–6 permiten reproducir CK/UQ, CHECK e índices.

| Familia | Base firme con OD abiertas | Delta condicionada | Rango simultáneo | Base |
|---|---:|---:|---:|---|
| PK | **82** | **+1** OD-01 | **82–83** | 49 baseline + 30 V2 + 3 técnicas; asistencia separada |
| CK/UQ totales o parciales | **68** | **+6** OD-01/02/03 | **68–74** | 37 baseline + 31 refinamientos firmes + 6 condicionados |
| FK | **158** | **+2** OD-01 | **158–160** | 77 baseline + 81 firmes + 2 asistencia |
| CHECK físicos nombrados | **39** | **+2** vocabulario pendiente | **39–41** | objetos por tabla en ledger §5.2; no grupos intertabla |
| EXCLUDE | **1** | **0** | **1** | indisponibilidad activa |
| Índices explícitos baseline declarados | **109** | **0** | **109** | ledger §4; incluye 1 redundante legacy preservado |
| Índices explícitos baseline aceptados | **108** | **0** | **108** | `BI038` rechazado del objetivo; retiro requiere autorización |
| Índices explícitos V2 no redundantes | **58** | **+1** OD-01; **−1** si OD-02 activa UQ | **57–59** | `VI001` se sustituye por `VU05`; `VI002` depende OD-01 |
| Índices explícitos aceptados, baseline + V2 | **166** | mismos del renglón anterior | **165–167** | 108 baseline + 57–59 V2; escenario todas OD = 166 |
| Invariantes PostgreSQL-only | **24** | **0** | **24** | PO-01..PO-24 |

Índices de PK/UQ son implícitos y no se vuelven a contar como explícitos. `AssemblyConvocation(assemblyId)` (`BI038`) es redundante porque UQ `(assemblyId,affiliateId)` ya sirve por prefijo: queda **REJECT V2 / legacy preservado**, no se recrea; retirarlo exige autorización y medición. `board_minute(board_session_id)` (`VI001`) cubre FK solo mientras OD-02 no autorice `VU05`; si la autoriza, UQ lo sustituye, nunca coexisten como diseño objetivo. Ningún otro índice explícito repite prefijo de PK/UQ.

## 3. Ledger físico de relaciones V2 — 83/83

Cada ID aparece una vez. Todas usan `ON UPDATE CASCADE`. Acciones mostradas son `ON DELETE`; nulabilidad viene del diccionario. Relaciones baseline B001–B077 permanecen exactas; T001 permanece hasta `ID-01`.

| ID | Constraint físico: hija(columna) → padre(columna) | Delete | Índice/clave |
|---|---|---|---|
| V001 | `fk_board_session_term`: `board_session(term_id)` → `BoardTerm(id)` | RESTRICT | UQ `(term_id,session_number)` |
| V002 | `fk_board_minute_session`: `board_minute(board_session_id)` → `board_session(id)` | RESTRICT | UQ solo si OD-02 aprueba identidad única |
| V003 | `fk_board_resolution_session`: `board_resolution(board_session_id)` → `board_session(id)` | RESTRICT | UQ `(board_session_id,resolution_number)` |
| V004 | `fk_board_attendance_session`: `board_session_attendance(board_session_id)` → `board_session(id)` | RESTRICT | UQ par; condicionada OD-01 |
| V005 | `fk_board_attendance_membership`: `board_session_attendance(membership_id)` → `BoardAppointment(id)` | RESTRICT | `ix_..._membership` |
| V006 | `fk_event_revision_event`: `event_revision(event_id)` → `Event(id)` | RESTRICT | UQ `(event_id,revision_number)` |
| V007 | `fk_event_revision_submitter`: `event_revision(submitted_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V008 | `fk_event_decision_revision`: `event_review_decision(event_revision_id)` → `event_revision(id)` | RESTRICT | índice FK |
| V009 | `fk_event_decision_membership`: `event_review_decision(membership_id)` → `BoardAppointment(id)` | RESTRICT | índice FK |
| V010 | `fk_event_decision_user`: `event_review_decision(decided_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V011 | `fk_event_budget_event`: `event_budget_line(event_id)` → `Event(id)` | RESTRICT | UQ `(event_id,line_number)` |
| V012 | `fk_inkind_donation_donor`: `in_kind_donation(donor_id)` → `donor(id)` | SET NULL | índice FK; CHECK no-DRAFT |
| V013 | `fk_inkind_donation_recorder`: `in_kind_donation(recorded_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V014 | `fk_inkind_item_donation`: `in_kind_donation_item(donation_id)` → `in_kind_donation(id)` | RESTRICT | UQ `(donation_id,line_number)` |
| V015 | `fk_inkind_decision_donation`: `in_kind_donation_decision(donation_id)` → `in_kind_donation(id)` | RESTRICT | índice FK |
| V016 | `fk_inkind_decision_membership`: `in_kind_donation_decision(membership_id)` → `BoardAppointment(id)` | RESTRICT | índice FK |
| V017 | `fk_inkind_decision_resolution`: `in_kind_donation_decision(board_resolution_id)` → `board_resolution(id)` | RESTRICT | índice FK |
| V018 | `fk_inkind_decision_user`: `in_kind_donation_decision(decided_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V019 | `fk_inkind_receipt_donation`: `in_kind_donation_receipt(donation_id)` → `in_kind_donation(id)` | RESTRICT | UQ `(donation_id,receipt_number)` |
| V020 | `fk_inkind_receipt_receiver`: `in_kind_donation_receipt(received_by_user_id)` → `User(id)` | RESTRICT | índice FK |
| V021 | `fk_inkind_receipt_line_receipt`: `in_kind_donation_receipt_line(receipt_id)` → `in_kind_donation_receipt(id)` | RESTRICT | UQ `(receipt_id,line_number)` |
| V022 | `fk_inkind_receipt_line_offer`: `in_kind_donation_receipt_line(donation_item_id)` → `in_kind_donation_item(id)` | RESTRICT | índice FK |
| V023 | `fk_inkind_receipt_line_item`: `in_kind_donation_receipt_line(item_id)` → `InventoryItem(id)` | RESTRICT | índice FK |
| V024 | `fk_facility_parent`: `institutional_facility(parent_facility_id)` → `institutional_facility(id)` | RESTRICT | índice FK + anticiclo PO-06 |
| V025 | `fk_resource_facility`: `ReservableResource(facility_id)` → `institutional_facility(id)` | RESTRICT | índice FK; gate ubicación |
| V026 | `fk_stock_lot_item`: `inventory_stock_lot(item_id)` → `InventoryItem(id)` | RESTRICT | índice FK; UQ code |
| V027 | `fk_lot_origin_lot`: `inventory_stock_lot_receipt_origin(lot_id)` → `inventory_stock_lot(id)` | RESTRICT | UQ `lot_id` |
| V028 | `fk_lot_origin_line`: `inventory_stock_lot_receipt_origin(receipt_line_id)` → `in_kind_donation_receipt_line(id)` | RESTRICT | índice FK |
| V029 | `fk_unit_item`: `inventory_unit(item_id)` → `InventoryItem(id)` | RESTRICT | índice FK; UQ asset_code |
| V030 | `fk_unit_origin_unit`: `inventory_unit_receipt_origin(unit_id)` → `inventory_unit(id)` | RESTRICT | UQ `unit_id` |
| V031 | `fk_unit_origin_line`: `inventory_unit_receipt_origin(receipt_line_id)` → `in_kind_donation_receipt_line(id)` | RESTRICT | índice FK |
| V032 | `fk_incident_facility`: `maintenance_incident(facility_id)` → `institutional_facility(id)` | RESTRICT | índice FK + XOR |
| V033 | `fk_incident_lot`: `maintenance_incident(stock_lot_id)` → `inventory_stock_lot(id)` | RESTRICT | índice FK + XOR |
| V034 | `fk_incident_unit`: `maintenance_incident(unit_id)` → `inventory_unit(id)` | RESTRICT | índice FK + XOR |
| V035 | `fk_incident_reporter`: `maintenance_incident(reported_by_person_id)` → `Person(id)` | SET NULL | índice FK |
| V036 | `fk_work_order_incident`: `maintenance_work_order(incident_id)` → `maintenance_incident(id)` | RESTRICT | índice FK; N-02 auditado |
| V037 | `fk_work_order_facility`: `maintenance_work_order(facility_id)` → `institutional_facility(id)` | RESTRICT | índice FK + XOR por estado |
| V038 | `fk_work_order_lot`: `maintenance_work_order(stock_lot_id)` → `inventory_stock_lot(id)` | RESTRICT | índice FK + XOR por estado |
| V039 | `fk_work_order_unit`: `maintenance_work_order(unit_id)` → `inventory_unit(id)` | RESTRICT | índice FK + XOR por estado |
| V040 | `fk_work_order_executor`: `maintenance_work_order(executor_person_id)` → `Person(id)` | RESTRICT | índice FK |
| V041 | `fk_work_order_authorizer`: `maintenance_work_order(authorized_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V042 | `fk_expense_work_order`: `Expense(maintenance_work_order_id)` → `maintenance_work_order(id)` | RESTRICT | índice FK |
| V043 | `fk_expense_board_resolution`: `Expense(board_resolution_id)` → `board_resolution(id)` | RESTRICT | índice FK + fundamento XOR |
| V044 | `fk_disbursement_settler`: `Disbursement(settled_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V045 | `fk_unavailability_resource`: `resource_unavailability(reservable_resource_id)` → `ReservableResource(id)` | RESTRICT | EXCLUDE temporal |
| V046 | `fk_unavailability_incident`: `resource_unavailability(incident_id)` → `maintenance_incident(id)` | RESTRICT | índice FK |
| V047 | `fk_unavailability_order`: `resource_unavailability(work_order_id)` → `maintenance_work_order(id)` | RESTRICT | índice FK |
| V048 | `fk_unavailability_releaser`: `resource_unavailability(released_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V049 | `fk_checkout_allocation_loan`: `inventory_loan_checkout_allocation(loan_id)` → `InventoryLoan(id)` | RESTRICT | `ix_..._loan` |
| V050 | `fk_checkout_allocation_lot`: `inventory_loan_checkout_allocation(lot_id)` → `inventory_stock_lot(id)` | RESTRICT | índice FK + XOR |
| V051 | `fk_checkout_allocation_unit`: `inventory_loan_checkout_allocation(unit_id)` → `inventory_unit(id)` | RESTRICT | índice FK + XOR |
| V052 | `fk_checkout_allocation_movement`: `inventory_loan_checkout_allocation(checkout_movement_id)` → `InventoryMovement(id)` | RESTRICT | UQ nullable |
| V053 | `fk_loan_return_loan`: `inventory_loan_return(loan_id)` → `InventoryLoan(id)` | RESTRICT | UQ `(loan_id,return_number)` |
| V054 | `fk_loan_return_receiver`: `inventory_loan_return(received_by_user_id)` → `User(id)` | RESTRICT | índice FK |
| V055 | `fk_return_detail_return`: `inventory_loan_return_detail(return_id)` → `inventory_loan_return(id)` | RESTRICT | UQ `(return_id,checkout_allocation_id)` |
| V056 | `fk_return_detail_allocation`: `inventory_loan_return_detail(checkout_allocation_id)` → `inventory_loan_checkout_allocation(id)` | RESTRICT | índice FK |
| V057 | `fk_return_detail_movement`: `inventory_loan_return_detail(available_entry_movement_id)` → `InventoryMovement(id)` | RESTRICT | UQ nullable |
| V058 | `fk_shortage_allocation`: `inventory_loan_shortage(checkout_allocation_id)` → `inventory_loan_checkout_allocation(id)` | RESTRICT | índice FK; loan derivado |
| V059 | `fk_shortage_decision_shortage`: `inventory_loan_shortage_decision(shortage_id)` → `inventory_loan_shortage(id)` | RESTRICT | índice FK |
| V060 | `fk_shortage_decision_membership`: `inventory_loan_shortage_decision(membership_id)` → `BoardAppointment(id)` | RESTRICT | índice FK |
| V061 | `fk_shortage_decision_resolution`: `inventory_loan_shortage_decision(board_resolution_id)` → `board_resolution(id)` | RESTRICT | índice FK |
| V062 | `fk_shortage_decision_user`: `inventory_loan_shortage_decision(decided_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V063 | `fk_event_initiative`: `Event(initiative_id)` → `initiative(id)` | SET NULL | índice FK |
| V064 | `fk_volunteer_opportunity_initiative`: `VolunteerOpportunity(initiative_id)` → `initiative(id)` | SET NULL | índice FK |
| V065 | `fk_work_order_initiative`: `maintenance_work_order(initiative_id)` → `initiative(id)` | SET NULL | índice FK |
| V066 | `fk_financial_movement_initiative`: `FinancialMovement(initiative_id)` → `initiative(id)` | RESTRICT | índice FK + destino CHECK |
| V067 | `fk_document_record_series`: `document_record(series_id)` → `document_series(id)` | RESTRICT | UQ triple |
| V068 | `fk_document_version_document`: `document_version(document_id)` → `document_record(id)` | RESTRICT | UQ `(document_id,version_number)` |
| V069 | `fk_document_version_creator`: `document_version(created_by_user_id)` → `User(id)` | SET NULL | índice FK |
| V070 | `fk_document_version_rectifies`: `document_version(rectifies_version_id)` → `document_version(id)` | RESTRICT | índice FK + PO-17 |
| V071 | `fk_donor_person`: `donor(person_id)` → `Person(id)` | RESTRICT | UQ nullable |
| V072 | `fk_donation_donor`: `Donation(donor_id)` → `donor(id)` | RESTRICT | índice FK; B041 coexiste hasta DONOR-01 |
| V073 | `fk_expense_doc_log_document`: `expense_document_log(expense_document_id)` → `ExpenseDocument(id)` | RESTRICT | índice FK |
| V074 | `fk_expense_doc_log_actor`: `expense_document_log(actor_user_id)` → `User(id)` | SET NULL | índice FK |
| V075 | `fk_correspondence_document`: `correspondence(document_record_id)` → `document_record(id)` | RESTRICT | UQ |
| V076 | `fk_correspondence_log_parent`: `correspondence_log(correspondence_id)` → `correspondence(id)` | RESTRICT | índice FK |
| V077 | `fk_correspondence_log_actor`: `correspondence_log(actor_user_id)` → `User(id)` | SET NULL | índice FK |
| V078 | `fk_board_minute_document`: `board_minute(document_record_id)` → `document_record(id)` | RESTRICT | UQ condicional OD-03 |
| V079 | `fk_board_resolution_document`: `board_resolution(document_record_id)` → `document_record(id)` | RESTRICT | UQ condicional OD-03 |
| V080 | `fk_inkind_receipt_document`: `in_kind_donation_receipt(document_record_id)` → `document_record(id)` | RESTRICT | UQ condicional OD-03 |
| V081 | `fk_work_order_document`: `maintenance_work_order(document_record_id)` → `document_record(id)` | RESTRICT | UQ condicional OD-03 |
| V082 | `fk_expense_document_version`: `ExpenseDocument(document_version_id)` → `document_version(id)` | RESTRICT | índice FK; fuente depende DOC-HIST-01 |
| V083 | `fk_folio_counter_series`: `document_folio_counter(series_id)` → `document_series(id)` | RESTRICT | PK `(series_id,folio_year)` |

## 4. Ledger baseline CK/UQ e índices explícitos

Fuente de todas las filas: Prisma V1.1 en revisión fijada `e8e2beb...`. `BU*` es CK/UQ con índice implícito; `BI*` es `@@index` explícito. Cada ID representa exactamente un objeto. Cero explícito evita inferir índices por FK. Tabla incluye las 49 persistentes, incluso las que tienen cero objetos.

| Tabla | CK/UQ implícitos | Índices explícitos | Estado |
|---|---|---|---|
| `OrganizationProfile` | — | — | FIRME baseline |
| `Person` | `BU01:(identificationType,normalizedIdentification)` | — | FIRME baseline |
| `Role` | `BU02:(name)` | — | FIRME baseline |
| `Permission` | `BU03:(code)` | — | FIRME baseline |
| `RolePermission` | — | `BI001:(permissionId)` | FIRME baseline |
| `User` | `BU04:(identification)`; `BU05:(email)`; `BU06:(personId)` | — | FIRME baseline |
| `Session` | `BU07:(refreshTokenHash)` | `BI002:(userId)`; `BI003:(expiresAt)` | FIRME baseline |
| `AuditLog` | — | `BI004:(userId)`; `BI005:(action)`; `BI006:(module)`; `BI007:(createdAt)` | FIRME baseline |
| `PasswordResetToken` | `BU08:(tokenHash)` | `BI008:(userId)`; `BI009:(expiresAt)` | FIRME baseline |
| `AccountActivationToken` | `BU09:(tokenHash)` | `BI010:(userId)`; `BI011:(expiresAt)` | FIRME baseline |
| `UserRequest` | — | `BI012:(identification)`; `BI013:(email)`; `BI014:(status)`; `BI015:(reviewedById)`; `BI016:(personId)` | FIRME baseline |
| `Affiliate` | `BU10:(identification)`; `BU11:(email)`; `BU12:(personId)` | `BI017:(legacyRoleId)` | FIRME baseline |
| `AffiliateRequest` | — | `BI018:(identification)`; `BI019:(email)`; `BI020:(status)`; `BI021:(reviewedById)`; `BI022:(personId)` | FIRME baseline |
| `AffiliateSanction` | — | `BI023:(affiliateId)`; `BI024:(status)`; `BI025:(date)`; `BI026:(createdById)` | FIRME baseline |
| `GovernancePosition` | `BU13:(code)` | — | FIRME baseline |
| `GovernanceTerm` | — | `BI027:(legacyInstitutionalProfileId,startDate)` | FIRME baseline |
| `GovernanceMembership` | — | `BI028:(termId)`; `BI029:(legacyPersonId)`; `BI030:(legacyPosition,seatNumber)`; `BI031:(positionId)`; `BI032:(affiliateId)`; `BI033:(appointedByAssemblyId)` | FIRME baseline |
| `Assembly` | — | `BI034:(legacyDate)`; `BI035:(scheduledAt)`; `BI036:(status)` | FIRME baseline |
| `AssemblyCall` | `BU14:(assemblyId,callNumber)` | `BI037:(scheduledAt)` | FIRME baseline |
| `AssemblyConvocation` | `BU15:(assemblyId,affiliateId)` | `BI038:(assemblyId)`; `BI039:(affiliateId)`; `BI040:(legacyRoleId)`; `BI041:(governanceMembershipId)` | `BI038` REJECT V2 por prefijo `BU15`; resto FIRME |
| `AssemblyAttendance` | `BU16:(convocationId)`; `BU17:(legacyAssemblyId,legacyAffiliateId)` | `BI042:(legacyAssemblyId,status)`; `BI043:(legacyAffiliateId)` | FIRME baseline |
| `AbsenceJustification` | `BU18:(attendanceId)`; `BU19:(legacyAssemblyId,legacyAffiliateId)` | `BI044:(status)`; `BI045:(reviewedById)` | FIRME baseline |
| `AssemblyMinute` | `BU20:(assemblyId)` | — | FIRME baseline; destino OD-02 no lo borra sin gate |
| `AssemblyResolution` | — | `BI046:(assemblyId)` | FIRME baseline |
| `Event` | `BU21:(publicId)` | `BI047:(publicationStatus,startAt)`; `BI048:(startAt)` | FIRME baseline; `BI048` no es prefijo de `BI047` |
| `ReservableResource` | — | `BI049:(status)` | FIRME baseline |
| `Reservation` | — | `BI050:(requesterUserId)`; `BI051:(eventId)`; `BI052:(status)`; `BI053:(resourceId,startAt,endAt)` | FIRME baseline |
| `FinancialAccount` | `BU22:(code)` | — | FIRME baseline |
| `FinancialCharge` | `BU23:(reservationId)` | `BI054:(status)`; `BI055:(createdAt)` | FIRME baseline |
| `Payment` | `BU24:(movementId)` | `BI056:(chargeId)`; `BI057:(status)`; `BI058:(recordedById)`; `BI059:(createdAt)` | FIRME baseline |
| `FinancialMovement` | `BU25:(reversalOfId)` | `BI060:(accountId)`; `BI061:(occurredAt)`; `BI062:(type,occurredAt)`; `BI063:(legacySource,legacySourceId)`; `BI064:(recordedById)`; `BI065:(status,occurredAt)` | FIRME baseline |
| `Donation` | `BU26:(originalMovementId)`; `BU27:(legacyReversalMovementId)` | `BI066:(donorPersonId)`; `BI067:(status)`; `BI068:(legacyMethod)`; `BI069:(receivedAt)`; `BI070:(recordedById)`; `BI071:(cancelledById)`; `BI072:(status,receivedAt)` | FIRME baseline |
| `Expense` | — | `BI073:(authorizationResolutionId)`; `BI074:(status,incurredAt)` | FIRME baseline |
| `ExpenseDocument` | — | `BI075:(expenseId)` | FIRME baseline |
| `Disbursement` | `BU28:(movementId)` | `BI076:(expenseId)` | FIRME baseline |
| `FundingAllocation` | — | `BI077:(expenseId)`; `BI078:(incomeMovementId)` | FIRME baseline |
| `InventoryCategory` | `BU29:(name)` | `BI079:(isActive)` | FIRME baseline |
| `InventoryItem` | `BU30:(code)` | `BI080:(categoryId)`; `BI081:(status)`; `BI082:(condition)` | FIRME baseline |
| `InventoryMovement` | — | `BI083:(itemId)`; `BI084:(type)`; `BI085:(createdById)`; `BI086:(createdAt)` | FIRME baseline |
| `InventoryLoan` | `BU31:(checkoutMovementId)`; `BU32:(returnMovementId)`; `BU33:(cancellationMovementId)` | `BI087:(itemId)`; `BI088:(status)`; `BI089:(borrowerAffiliateId)`; `BI090:(createdById)`; `BI091:(cancelledById)`; `BI092:(expectedReturnDate)` | FIRME baseline |
| `VolunteerOpportunity` | — | `BI093:(createdByUserId)`; `BI094:(status,applicationDeadline)` | FIRME baseline |
| `VolunteerSession` | — | `BI095:(opportunityId,startAt)` | FIRME baseline |
| `VolunteerApplication` | — | `BI096:(opportunityId,status)`; `BI097:(personId,status)`; `BI098:(submittedNormalizedIdentification)`; `BI099:(reviewedByUserId)` | FIRME baseline |
| `VolunteerParticipation` | `BU34:(applicationId)`; `BU35:(opportunityId,personId)` | `BI100:(personId,status)`; `BI101:(opportunityId,status)` | FIRME baseline |
| `VolunteerAttendance` | `BU36:(participationId,sessionId)` | `BI102:(sessionId,status)`; `BI103:(recordedByUserId)` | FIRME baseline |
| `Venture` | — | `BI104:(status,publicationStatus)` | FIRME baseline |
| `VentureAssociation` | — | `BI105:(personId)`; `BI106:(ventureId)` | FIRME baseline |
| `VentureRequest` | — | `BI107:(reconciledPersonId)`; `BI108:(ventureId)`; `BI109:(status,createdAt)` | FIRME baseline |
| `VentureRequestRevision` | `BU37:(requestId,revisionNumber)` | — | FIRME baseline |
| **Total por IDs** | **37 `BU`** | **109 `BI`: 108 aceptados + 1 rechazado/preservado** | exhaustivo 49/49 |

## 5. Ledger CK/UQ V2 y CHECK físicos

### 5.1 CK/UQ V2

`TOTAL` crea constraint/UQ con índice implícito; `PARCIAL` es índice único parcial PostgreSQL, no attachable como constraint. Fuente refiere matriz lógica; F-02 es refinamiento físico identificado.

| ID | Objeto | Tabla / columnas o predicado | Familia | Fuente | Estado/instalación |
|---|---|---|---|---|---|
| VU01 | `uq_membership_active_seat` | `BoardAppointment(boardTermId,positionId,seatNumber) WHERE endsOn IS NULL` | PARCIAL | S-004 | FIRME |
| VU02 | `uq_volunteer_application_pending` | `VolunteerApplication(opportunityId,personId) WHERE status='PENDING' AND personId IS NOT NULL` | PARCIAL | S-016 | FIRME |
| VU03 | `uq_venture_association_open` | `VentureAssociation(personId,ventureId) WHERE endedAt IS NULL` | PARCIAL | S-018 | FIRME |
| VU04 | `uq_board_session_number` | `board_session(term_id,session_number)` | TOTAL | P-019 | FIRME |
| VU05 | `uq_board_minute_session` | `board_minute(board_session_id)` | TOTAL | OD-02 | CONDICIONADA; no instalar; sustituye VI001 si se aprueba |
| VU06 | `uq_board_resolution_number` | `board_resolution(board_session_id,resolution_number)` | TOTAL | P-021 | FIRME |
| VU07 | `uq_board_attendance_pair` | `board_session_attendance(board_session_id,membership_id)` | TOTAL | OD-01/P-022 | CONDICIONADA; no instalar |
| VU08 | `uq_event_revision_number` | `event_revision(event_id,revision_number)` | TOTAL | P-023 | FIRME |
| VU09 | `uq_event_decision_command` | `event_review_decision(command_key)` | TOTAL | F-02/TX-13 | FIRME; refinamiento físico |
| VU10 | `uq_event_budget_line` | `event_budget_line(event_id,line_number)` | TOTAL | P-024 | FIRME |
| VU11 | `uq_inkind_item_line` | `in_kind_donation_item(donation_id,line_number)` | TOTAL | P-025 | FIRME |
| VU12 | `uq_inkind_decision_command` | `in_kind_donation_decision(command_key)` | TOTAL | F-02/TX-13 | FIRME; refinamiento físico |
| VU13 | `uq_inkind_receipt_number` | `in_kind_donation_receipt(donation_id,receipt_number)` | TOTAL | P-025 | FIRME |
| VU14 | `uq_inkind_receipt_line` | `in_kind_donation_receipt_line(receipt_id,line_number)` | TOTAL | P-025 | FIRME |
| VU15 | `uq_facility_code` | `institutional_facility(code)` | TOTAL | P-026 | FIRME |
| VU16 | `uq_stock_lot_code` | `inventory_stock_lot(code)` | TOTAL | P-026 | FIRME |
| VU17 | `uq_inventory_unit_asset_code` | `inventory_unit(asset_code)` | TOTAL | P-026 | FIRME |
| VU18 | `uq_checkout_movement` | `inventory_loan_checkout_allocation(checkout_movement_id)` | TOTAL | P-027 | FIRME |
| VU19 | `uq_loan_return_number` | `inventory_loan_return(loan_id,return_number)` | TOTAL | P-028 | FIRME |
| VU20 | `uq_return_detail_allocation` | `inventory_loan_return_detail(return_id,checkout_allocation_id)` | TOTAL | P-029 | FIRME |
| VU21 | `uq_return_detail_movement` | `inventory_loan_return_detail(available_entry_movement_id)` | TOTAL | P-029 | FIRME |
| VU22 | `uq_shortage_decision_command` | `inventory_loan_shortage_decision(command_key)` | TOTAL | F-02/TX-13 | FIRME; refinamiento físico |
| VU23 | `uq_initiative_code` | `initiative(code)` | TOTAL | P-030 | FIRME |
| VU24 | `uq_document_series_code` | `document_series(code)` | TOTAL | P-031 | FIRME |
| VU25 | `uq_document_folio` | `document_record(series_id,folio_year,folio_sequence)` | TOTAL | P-032 | FIRME |
| VU26 | `uq_document_registration_request` | `document_record(official_registration_request_key)` | TOTAL | P-032 | FIRME |
| VU27 | `uq_document_version_number` | `document_version(document_id,version_number)` | TOTAL | P-033 | FIRME |
| VU28 | `uq_donor_person` | `donor(person_id)` | TOTAL | P-034 | FIRME |
| VU29 | `uq_donor_legal_identity` | `donor(identification_type,normalized_identification) WHERE donor_type='ORGANIZATION'` | PARCIAL | S-038 | FIRME |
| VU30 | `uq_correspondence_document` | `correspondence(document_record_id)` | TOTAL | P-035 | FIRME |
| VU31 | `uq_board_minute_document` | `board_minute(document_record_id)` | TOTAL | OD-03/P-036 | CONDICIONADA; no instalar |
| VU32 | `uq_board_resolution_document` | `board_resolution(document_record_id)` | TOTAL | OD-03/P-036 | CONDICIONADA; no instalar |
| VU33 | `uq_inkind_receipt_document` | `in_kind_donation_receipt(document_record_id)` | TOTAL | OD-03/P-036 | CONDICIONADA; no instalar |
| VU34 | `uq_work_order_document` | `maintenance_work_order(document_record_id)` | TOTAL | OD-03/P-036 | CONDICIONADA; no instalar |
| VU35 | `uq_lot_origin_lot` | `inventory_stock_lot_receipt_origin(lot_id)` | TOTAL | P-038 | FIRME |
| VU36 | `uq_unit_origin_unit` | `inventory_unit_receipt_origin(unit_id)` | TOTAL | P-038 | FIRME |
| VU37 | `uq_disbursement_settlement` | `Disbursement(expenseId) WHERE purpose='SETTLEMENT'` | PARCIAL | S-040 | FIRME |

Totales por IDs: **31 firmes + 6 condicionadas = 37 V2**; **5 parciales firmes**. Con baseline: **68 firmes + 6 condicionadas = 74**. Objetos condicionados permanecen diseño, no instalación.

### 5.2 CHECK físicos

Una fila es un constraint instalable sobre una sola tabla. Reglas antes agrupadas por dominio se desglosan; así no se cuenta un supuesto CHECK intertabla.

| ID | Tabla | Nombre / expresión compacta | Fuente | Estado |
|---|---|---|---|---|
| C01 | `InstitutionalProfile` | `ck_org_singleton`: `id=1` | S-001 | FIRME |
| C02 | `BoardTerm` | `ck_term_dates`: `startsOn < endsOn` | S-002 | FIRME |
| C03 | `BoardAppointment` | `ck_membership_values`: asiento positivo y fin ≥ inicio | S-003 | FIRME |
| C04 | `AssemblyCall` | `ck_assembly_call_values`: número positivo y quorum coherente | S-005 | FIRME |
| C05 | `AbsenceJustification` | `ck_absence_attachment_metadata`: tamaño positivo y metadatos all-null/all-present | S-006 | FIRME |
| C06 | `ExpenseDocument` | `ck_expense_document_size`: `size > 0` | S-006 | FIRME |
| C07 | `Reservation` | `ck_reservation_interval`: `startAt < endAt` | S-007 | FIRME |
| C08 | `ReservableResource` | `ck_resource_pricing`: FREE/FIXED coherente con precio | S-008 | FIRME |
| C09 | `FinancialCharge` | `ck_charge_amount_positive`: `amount > 0` | S-009 | FIRME |
| C10 | `Payment` | `ck_payment_amount_positive`: `amount > 0` | S-009 | FIRME |
| C11 | `FinancialMovement` | `ck_movement_amount_positive`: `amount > 0` | S-009 | FIRME |
| C12 | `Donation` | `ck_donation_amount_positive`: `amount > 0` | S-009 | FIRME |
| C13 | `Expense` | `ck_expense_amount_positive`: `amount > 0` | S-009 | FIRME |
| C14 | `Disbursement` | `ck_disbursement_amount_positive`: `amount > 0` | S-009 | FIRME |
| C15 | `FundingAllocation` | `ck_funding_allocation_amount_positive`: `amount > 0` | S-009 | FIRME |
| C16 | `FinancialMovement` | `ck_movement_void`: no autorreversión y VOIDED completo | S-010 | FIRME |
| C17 | `InventoryMovement` | `ck_inventory_delta`: delta no cero/signo coherente | S-012 | FIRME |
| C18 | `InventoryItem` | `ck_inventory_nonnegative`: disponible/mínimo ≥ 0 | S-013 | FIRME |
| C19 | `InventoryLoan` | `ck_loan_values`: cantidad/fechas/estado coherentes | S-014 | FIRME |
| C20 | `VolunteerOpportunity` | `ck_volunteer_capacity`: capacidad nula o positiva | S-015 | FIRME |
| C21 | `VolunteerSession` | `ck_volunteer_session_interval`: `startAt < endAt` | S-015 | FIRME |
| C22 | `VolunteerAttendance` | `ck_volunteer_attendance_values`: horas ≥ 0 y check-in ≤ check-out | S-015 | FIRME |
| C23 | `Venture` | `ck_venture_publication`: PUBLISHED implica ACTIVE | S-017 | FIRME |
| C24 | `VentureAssociation` | `ck_venture_association_dates`: fin ≥ inicio | S-018 | FIRME |
| C25 | `VentureRequest` | `ck_venture_request_resolution`: terminal/venture/resolvedAt coherentes | S-019 | FIRME |
| C26 | `maintenance_incident` | `ck_incident_target_xor`: exactamente un target | S-020 | FIRME |
| C27 | `maintenance_work_order` | `ck_work_order_state_requirements`: target/ejecutor según estado | S-021 | CONDICIONADA a vocabulario final |
| C28 | `Expense` | `ck_expense_resolution_xor`: máximo un fundamento | S-024 | FIRME |
| C29 | `FinancialMovement` | `ck_income_destination`: POSTED INCOME tiene iniciativa XOR fondo general | S-025 | FIRME |
| C30 | `inventory_loan_checkout_allocation` | `ck_checkout_target_quantity`: target XOR y cantidad positiva | S-026 | FIRME |
| C31 | `inventory_loan_return_detail` | `ck_return_detail_quantity`: cantidad positiva | S-028 | FIRME |
| C32 | `inventory_loan_shortage` | `ck_shortage_quantity`: cantidad positiva | S-028 | FIRME |
| C33 | `institutional_facility` | `ck_facility_not_self_parent`: parent distinto de id | S-029 | FIRME |
| C34 | `resource_unavailability` | `ck_unavailability_interval`: fin nulo o `starts_at < ends_at` | S-030 | FIRME |
| C35 | `document_record` | `ck_document_folio_shape`: par año/secuencia, positivos y oficial completo | S-031 | FIRME |
| C36 | `document_series` | `ck_document_series_code`: formato canónico | S-032 | FIRME |
| C37 | `donor` | `ck_donor_shape`: persona/organización e identidad coherentes | S-038 | FIRME |
| C38 | `Disbursement` | `ck_disbursement_settlement_fields`: settlement fields juntos y solo ADVANCE | S-041 | FIRME |
| C39 | `in_kind_donation` | `ck_inkind_donor_after_draft`: no-DRAFT exige donor | S-042 | CONDICIONADA a vocabulario final |
| C40 | `document_version` | `ck_document_version_shape`: versión/tamaño positivos y SHA-256 hexadecimal | DOC-VAL-01; §7 | FIRME |
| C41 | `document_record` | `ck_document_classification`: `PUBLIC/INTERNAL/RESTRICTED` | DOC-VAL-04; §7 | FIRME |

Totales por IDs: **39 firmes + 2 condicionados = 41**.

## 6. Ledger de índices explícitos V2

Cada `VI*` identifica un B-tree explícito. PK/UQ (`VU*`) y EXCLUDE no se cuentan aquí. Fuente `Vnnn` es FK de §3. Auditoría de prefijos: `VI001` y `VU05` son alternativas; resto no repite prefijo de PK/UQ.

| Tabla | Índices explícitos | Fuente | Estado |
|---|---|---|---|
| `board_minute` | `VI001:(board_session_id)` | V002 | FIRME mientras OD-02 abierta; reemplazar por VU05 si aprueba |
| `board_session_attendance` | `VI002:(membership_id)` | V005/OD-01 | CONDICIONADA; no instalar |
| `event_revision` | `VI003:(submitted_by_user_id)` | V007 | FIRME |
| `event_review_decision` | `VI004:(event_revision_id)`; `VI005:(membership_id)`; `VI006:(decided_by_user_id)` | V008–V010 | FIRME |
| `in_kind_donation` | `VI007:(donor_id)`; `VI008:(recorded_by_user_id)` | V012–V013 | FIRME |
| `in_kind_donation_decision` | `VI009:(donation_id)`; `VI010:(membership_id)`; `VI011:(board_resolution_id)`; `VI012:(decided_by_user_id)` | V015–V018 | FIRME |
| `in_kind_donation_receipt` | `VI013:(received_by_user_id)` | V020 | FIRME; VU33 OD-03 no se instala |
| `in_kind_donation_receipt_line` | `VI014:(donation_item_id)`; `VI015:(item_id)` | V022–V023 | FIRME |
| `institutional_facility` | `VI016:(parent_facility_id)` | V024 | FIRME |
| `inventory_stock_lot` | `VI017:(item_id)` | V026 | FIRME |
| `inventory_unit` | `VI018:(item_id)` | V029 | FIRME |
| `maintenance_incident` | `VI019:(facility_id)`; `VI020:(stock_lot_id)`; `VI021:(unit_id)`; `VI022:(reported_by_person_id)` | V032–V035 | FIRME |
| `maintenance_work_order` | `VI023:(incident_id)`; `VI024:(facility_id)`; `VI025:(stock_lot_id)`; `VI026:(unit_id)`; `VI027:(executor_person_id)`; `VI028:(authorized_by_user_id)`; `VI029:(initiative_id)` | V036–V041,V065 | FIRME; VU34 OD-03 no se instala |
| `resource_unavailability` | `VI030:(incident_id)`; `VI031:(work_order_id)`; `VI032:(released_by_user_id)` | V046–V048 | FIRME; recurso cubierto por EXCLUDE |
| `inventory_loan_checkout_allocation` | `VI033:(loan_id)`; `VI034:(lot_id)`; `VI035:(unit_id)` | V049–V051 | FIRME |
| `inventory_loan_return` | `VI036:(received_by_user_id)` | V054 | FIRME |
| `inventory_loan_return_detail` | `VI037:(checkout_allocation_id)` | V056 | FIRME |
| `inventory_loan_shortage` | `VI038:(checkout_allocation_id)` | V058 | FIRME |
| `inventory_loan_shortage_decision` | `VI039:(shortage_id)`; `VI040:(membership_id)`; `VI041:(board_resolution_id)`; `VI042:(decided_by_user_id)` | V059–V062 | FIRME |
| `Event` | `VI043:(initiative_id)` | V063 | FIRME |
| `VolunteerOpportunity` | `VI044:(initiative_id)` | V064 | FIRME |
| `FinancialMovement` | `VI045:(initiative_id)` | V066 | FIRME |
| `document_version` | `VI046:(created_by_user_id)`; `VI047:(rectifies_version_id)` | V069–V070 | FIRME |
| `Donation` | `VI048:(donor_id)` | V072 | FIRME |
| `expense_document_log` | `VI049:(expense_document_id)`; `VI050:(actor_user_id)` | V073–V074 | FIRME |
| `correspondence_log` | `VI051:(correspondence_id)`; `VI052:(actor_user_id)` | V076–V077 | FIRME |
| `ExpenseDocument` | `VI053:(document_version_id)` | V082 | FIRME |
| `inventory_stock_lot_receipt_origin` | `VI054:(receipt_line_id)` | V028 | FIRME |
| `inventory_unit_receipt_origin` | `VI055:(receipt_line_id)` | V031 | FIRME |
| `Expense` | `VI056:(maintenance_work_order_id)`; `VI057:(board_resolution_id)` | V042–V043 | FIRME |
| `Disbursement` | `VI058:(settled_by_user_id)` | V044 | FIRME |
| `ReservableResource` | `VI059:(facility_id)` | V025 | FIRME |
| **Total por IDs** | **59: 58 firmes + 1 condicionada** | — | simultáneos **57–59** por sustitución VI001↔VU05 |

## 7. Checks, parciales y exclusión críticos

Esta sección solo resume objetos definidos por §§5–6; no declara constraints adicionales ni alias físicos.

- Folios: `C35 ck_document_folio_shape` es **un solo CHECK compuesto** con tres cláusulas —par año/secuencia, positividad y completitud oficial—; UQ exacta `VU25 uq_document_folio`; UQ idempotencia `VU26 uq_document_registration_request`. Nunca UQ global ni columna editable `folio`.
- Finanzas: importes positivos `C09`–`C15`; destino `C29 ck_income_destination`; conciliación `C38 ck_disbursement_settlement_fields`; índice parcial `VU37 uq_disbursement_settlement` sobre `expenseId WHERE purpose='SETTLEMENT'`; fundamento único `C28 ck_expense_resolution_xor`. OD-07 impide umbrales nuevos.
- Inventario: XOR de targets; cantidades positivas; `quantityDelta <> 0`; no-negatividad; igualdad intertabla vía trigger/TX; retorno y faltante disjuntos.
- Donante: `ck_donor_shape`; UQ parcial de identificación jurídica por tipo; `ck_inkind_donation_donor_after_draft`. `DONOR-01` precede enforcement histórico.
- Mantenimiento: intervalos `starts_at < ends_at` cuando fin existe; `ex_unavailability_active_period` usa `tstzrange` solo si timestamps migran a `timestamptz`; con baseline `timestamp`, usar `tsrange`. Predicado activo: `released_at IS NULL`. `btree_gist` debe aprobarse como extensión antes de migración.
- Documentos: tamaño positivo, checksum SHA-256 hexadecimal, número de versión positivo, clasificación limitada a `PUBLIC/INTERNAL/RESTRICTED`. **UQ total:** ejecutar reporte determinista de duplicados/NULL semantics, resolver o cuarentenar colisiones, crear `CREATE UNIQUE INDEX CONCURRENTLY` fuera de bloque transaccional y adjuntarlo con `ALTER TABLE ... ADD CONSTRAINT ... UNIQUE USING INDEX` solo cuando sea B-tree total compatible, no parcial ni de expresión y con definición equivalente. **UQ parcial:** reportar colisiones del predicado y crear `CREATE UNIQUE INDEX CONCURRENTLY ... WHERE`; permanece índice, nunca constraint adjunta. **Objeto OD no resuelto:** no crear índice ni constraint. `NOT VALID` se reserva a FK/CHECK permitidos; PostgreSQL no admite `UNIQUE NOT VALID`.

## 8. Registro PostgreSQL-only

| ID | Invariante | Mecanismo mínimo |
|---|---|---|
| PO-01 | singleton organización | CHECK `id=1` |
| PO-02 | membresía activa única | UQ parcial |
| PO-03 | aplicación pendiente única | UQ parcial |
| PO-04 | asociación de venture abierta única | UQ parcial |
| PO-05 | no solapamiento de indisponibilidad activa | EXCLUDE GiST |
| PO-06 | jerarquía facility acíclica | trigger diferible/CTE |
| PO-07 | target XOR incidencia | CHECK |
| PO-08 | target XOR orden según estado | CHECK + trigger de transición |
| PO-09 | objeto orden/incidencia: igualdad solo si misma intervención; divergencia exige `scope` | trigger al autorizar; resuelve N-02 sin asumir FD |
| PO-10 | allocation XOR y mismo item del préstamo | CHECK + trigger |
| PO-11 | retorno y allocation pertenecen al mismo préstamo | trigger |
| PO-12 | ecuación préstamo y cantidades disjuntas | trigger diferible/TX |
| PO-13 | procedencia lote/unidad comparte item con línea | trigger |
| PO-14 | línea recibida y ofrecida pertenecen a misma donación | trigger |
| PO-15 | recepción no excede oferta aprobada | trigger diferible/TX |
| PO-16 | documento/versión oficial inmutable | trigger + privilegios |
| PO-17 | rectificación sin autociclo, ciclo ni mismo documento | trigger recursivo |
| PO-18 | código serie inmutable tras primera emisión | trigger |
| PO-19 | folio oficial inmutable/no reutilizable | trigger + UQ triple |
| PO-20 | contador solo incrementa por función/ruta controlada | privilegios + trigger |
| PO-21 | logs append-only | privilegios + trigger común |
| PO-22 | movimiento contabilizado append-only económico | privilegios + trigger existente/refinado |
| PO-23 | costo mantenimiento solo tras cierre verificado | trigger intertabla/TX |
| PO-24 | máximo un settlement e idempotencia de conciliación | UQ parcial + TX |

Triggers se limitan a estas invariantes imposibles con PK/FK/UQ/CHECK. No usar trigger para defaults, timestamps ordinarios ni índices redundantes.

## 9. Gates de instalación

FK/CHECK sobre historia: añadir nullable, backfill verificable, constraint `NOT VALID`, cuarentena y `VALIDATE CONSTRAINT`; luego `SET NOT NULL` solo si gate cierra. UQ total/parcial sigue exclusivamente estrategia §7, nunca `NOT VALID`. Fallo del build concurrente: retirar solo índice `INVALID` nuevo y repetir tras corregir colisiones; fallo antes de attach deja índice válido sin constraint, recuperable. Rollback de fase aditiva: desactivar trigger/constraint/índice nuevo y conservar columnas/datos; eliminación o re-tipado requiere autorización separada. Detalle: [invariantes transaccionales](transactional-invariants.md).
