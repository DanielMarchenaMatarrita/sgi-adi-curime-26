-- Firm CHECK ledger C01-C41 (C27/C39 conditional: not installed).
ALTER TABLE public."InstitutionalProfile" ADD CONSTRAINT "ck_org_singleton" CHECK ("id" = 1); -- C01
ALTER TABLE public."BoardTerm" ADD CONSTRAINT "ck_term_dates" CHECK ("startsOn" < "endsOn"); -- C02
ALTER TABLE public."BoardAppointment" ADD CONSTRAINT "ck_membership_values" CHECK ("seatNumber" > 0 AND ("endsOn" IS NULL OR "endsOn" >= "startsOn")); -- C03
ALTER TABLE public."AssemblyCall" ADD CONSTRAINT "ck_assembly_call_values" CHECK ("callNumber" > 0 AND (("quorumType" = 'FIXED' AND "quorumValue" IS NOT NULL AND "quorumValue" > 0) OR ("quorumType" = 'PERCENTAGE' AND "quorumValue" IS NOT NULL AND "quorumValue" > 0 AND "quorumValue" <= 100))); -- C04
ALTER TABLE public."AbsenceJustification" ADD CONSTRAINT "ck_absence_attachment_metadata" CHECK (("attachmentOriginalName" IS NULL AND "attachmentMimeType" IS NULL AND "attachmentSize" IS NULL AND "attachmentUrl" IS NULL) OR (NULLIF(BTRIM("attachmentOriginalName"),'') IS NOT NULL AND NULLIF(BTRIM("attachmentMimeType"),'') IS NOT NULL AND "attachmentSize" IS NOT NULL AND "attachmentSize" > 0 AND NULLIF(BTRIM("attachmentUrl"),'') IS NOT NULL)); -- C05
ALTER TABLE public."ExpenseDocument" ADD CONSTRAINT "ck_expense_document_size" CHECK ("size" > 0); -- C06
ALTER TABLE public."Reservation" ADD CONSTRAINT "ck_reservation_interval" CHECK ("startAt" < "endAt"); -- C07
ALTER TABLE public."ReservableResource" ADD CONSTRAINT "ck_resource_pricing" CHECK (("pricingType" = 'FREE' AND COALESCE("price",0) = 0) OR ("pricingType" = 'FIXED' AND "price" IS NOT NULL AND "price" > 0 AND NULLIF(BTRIM("currency"),'') IS NOT NULL)); -- C08
ALTER TABLE public."FinancialCharge" ADD CONSTRAINT "ck_charge_amount_positive" CHECK ("amount" > 0); -- C09
ALTER TABLE public."Payment" ADD CONSTRAINT "ck_payment_amount_positive" CHECK ("amount" > 0); -- C10
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "ck_movement_amount_positive" CHECK ("amount" > 0); -- C11
ALTER TABLE public."Donation" ADD CONSTRAINT "ck_donation_amount_positive" CHECK ("amount" > 0); -- C12
ALTER TABLE public."Expense" ADD CONSTRAINT "ck_expense_amount_positive" CHECK ("amount" > 0); -- C13
ALTER TABLE public."Disbursement" ADD CONSTRAINT "ck_disbursement_amount_positive" CHECK ("amount" > 0); -- C14
ALTER TABLE public."FundingAllocation" ADD CONSTRAINT "ck_funding_allocation_amount_positive" CHECK ("amount" > 0); -- C15
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "ck_movement_void" CHECK (("reversalOfId" IS NULL OR "reversalOfId" <> "id") AND ("status" IS DISTINCT FROM 'VOIDED' OR ("voidedAt" IS NOT NULL AND "voidedById" IS NOT NULL AND NULLIF(BTRIM("voidReason"),'') IS NOT NULL))); -- C16
ALTER TABLE public."InventoryMovement" ADD CONSTRAINT "ck_inventory_delta" CHECK ("quantityDelta" IS NULL OR ("quantityDelta" <> 0 AND (("type" = 'ENTRY' AND "quantityDelta" > 0) OR ("type" = 'EXIT' AND "quantityDelta" < 0) OR ("type" = 'OPENING_BALANCE' AND "quantityDelta" > 0) OR "type" = 'ADJUSTMENT'))); -- C17
ALTER TABLE public."InventoryItem" ADD CONSTRAINT "ck_inventory_nonnegative" CHECK ("currentQuantity" >= 0 AND "minimumQuantity" >= 0); -- C18
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "ck_loan_values" CHECK ("quantity" > 0 AND "expectedReturnDate" >= "loanDate" AND ("returnedAt" IS NULL OR "returnedAt" >= "loanDate") AND ("status" <> 'RETURNED' OR "returnedAt" IS NOT NULL) AND ("status" <> 'CANCELLED' OR "cancelledAt" IS NOT NULL)); -- C19
ALTER TABLE public."VolunteerOpportunity" ADD CONSTRAINT "ck_volunteer_capacity" CHECK ("capacity" IS NULL OR "capacity" > 0); -- C20
ALTER TABLE public."VolunteerSession" ADD CONSTRAINT "ck_volunteer_session_interval" CHECK ("startAt" < "endAt"); -- C21
ALTER TABLE public."VolunteerAttendance" ADD CONSTRAINT "ck_volunteer_attendance_values" CHECK ("creditedHours" >= 0 AND ("checkInAt" IS NULL OR "checkOutAt" IS NULL OR "checkInAt" <= "checkOutAt")); -- C22
ALTER TABLE public."Venture" ADD CONSTRAINT "ck_venture_publication" CHECK ("publicationStatus" <> 'PUBLISHED' OR "status" = 'ACTIVE'); -- C23
ALTER TABLE public."VentureAssociation" ADD CONSTRAINT "ck_venture_association_dates" CHECK ("endedAt" IS NULL OR "endedAt" >= "startedAt"); -- C24
ALTER TABLE public."VentureRequest" ADD CONSTRAINT "ck_venture_request_resolution" CHECK (("purpose" <> 'UPDATE' OR "ventureId" IS NOT NULL) AND ("status" <> 'APPROVED' OR "ventureId" IS NOT NULL) AND ("status" NOT IN ('APPROVED','REJECTED','WITHDRAWN') OR "resolvedAt" IS NOT NULL)); -- C25
ALTER TABLE public."maintenance_incident" ADD CONSTRAINT "ck_incident_target_xor" CHECK (NUM_NONNULLS("facility_id","stock_lot_id","unit_id") = 1); -- C26
ALTER TABLE public."Expense" ADD CONSTRAINT "ck_expense_resolution_xor" CHECK (NUM_NONNULLS("authorizationResolutionId","board_resolution_id") <= 1); -- C28
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "ck_income_destination" CHECK ("status" IS DISTINCT FROM 'POSTED' OR "type" <> 'INCOME' OR ("destination_type" IS NOT NULL AND (("destination_type" = 'GENERAL_FUND' AND "initiative_id" IS NULL) OR ("destination_type" = 'INITIATIVE' AND "initiative_id" IS NOT NULL)))); -- C29
ALTER TABLE public."inventory_loan_checkout_allocation" ADD CONSTRAINT "ck_checkout_target_quantity" CHECK (NUM_NONNULLS("lot_id","unit_id") = 1 AND "quantity" > 0); -- C30
ALTER TABLE public."inventory_loan_return_detail" ADD CONSTRAINT "ck_return_detail_quantity" CHECK ("quantity" > 0); -- C31
ALTER TABLE public."inventory_loan_shortage" ADD CONSTRAINT "ck_shortage_quantity" CHECK ("quantity" > 0); -- C32
ALTER TABLE public."institutional_facility" ADD CONSTRAINT "ck_facility_not_self_parent" CHECK ("parent_facility_id" IS NULL OR "parent_facility_id" <> "id"); -- C33
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "ck_unavailability_interval" CHECK ("ends_at" IS NULL OR "starts_at" < "ends_at"); -- C34
ALTER TABLE public."document_record" ADD CONSTRAINT "ck_document_folio_shape" CHECK ((NUM_NONNULLS("folio_year","folio_sequence") IN (0,2) AND ("folio_year" IS NULL OR ("folio_year" > 0 AND "folio_sequence" > 0 AND "series_id" IS NOT NULL))) AND ("official_registered_at" IS NULL OR ("series_id" IS NOT NULL AND "folio_year" IS NOT NULL AND "folio_sequence" IS NOT NULL))); -- C35
ALTER TABLE public."document_series" ADD CONSTRAINT "ck_document_series_code" CHECK ("code" COLLATE "C" ~ '^[A-Z0-9]+(-[A-Z0-9]+)*$'); -- C36
ALTER TABLE public."donor" ADD CONSTRAINT "ck_donor_shape" CHECK (("donor_type" = 'PERSON' AND "person_id" IS NOT NULL AND "legal_name" IS NULL) OR ("donor_type" = 'ORGANIZATION' AND "person_id" IS NULL AND NULLIF(BTRIM("legal_name"),'') IS NOT NULL AND NULLIF(BTRIM("normalized_identification"),'') IS NOT NULL)); -- C37
ALTER TABLE public."Disbursement" ADD CONSTRAINT "ck_disbursement_settlement_fields" CHECK (("settled_at" IS NULL AND "settled_by_user_id" IS NULL) OR ("purpose" = 'ADVANCE' AND "settled_at" IS NOT NULL AND "settled_by_user_id" IS NOT NULL)); -- C38
ALTER TABLE public."document_version" ADD CONSTRAINT "ck_document_version_shape" CHECK ("version_number" > 0 AND "size_bytes" > 0 AND "checksum_sha256" COLLATE "C" ~ '^[0-9a-fA-F]{64}$'); -- C40
ALTER TABLE public."document_record" ADD CONSTRAINT "ck_document_classification" CHECK ("classification" IN ('PUBLIC','INTERNAL','RESTRICTED')); -- C41

-- PO-05: exclusive ACTIVE reservations for maintenance unavailability.
-- Baseline ts uses timestamp WITHOUT time zone; tsrange, not tstzrange.
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "ex_unavailability_active_period"
  EXCLUDE USING gist ("reservable_resource_id" WITH =, tsrange("starts_at", COALESCE("ends_at", 'infinity'::timestamp), '[)') WITH &&)
  WHERE ("released_at" IS NULL);
