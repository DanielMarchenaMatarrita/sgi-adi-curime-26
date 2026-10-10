-- SGI-Curime V2: PostgreSQL-only integrity controls. Do not expose these functions through the public API.
-- TX-level authorization, idempotence, lock ordering and policies remain the NestJS service's responsibility.

-- Common immutable row protection for approved decisions, revisions and durable logs.
CREATE OR REPLACE FUNCTION public.sgi_reject_mutation() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
  RAISE EXCEPTION 'SGI immutable record: %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE='23514';
END $$;
CREATE TRIGGER tg_venture_revision_immutable BEFORE UPDATE OR DELETE ON public."VentureRequestRevision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_venture_decision_immutable BEFORE UPDATE OR DELETE ON public."VentureReviewDecision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_document_version_immutable BEFORE UPDATE OR DELETE ON public."document_version" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_expense_doc_log_append_only BEFORE UPDATE OR DELETE ON public."expense_document_log" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_correspondence_log_append_only BEFORE UPDATE OR DELETE ON public."correspondence_log" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_event_decision_append_only BEFORE UPDATE OR DELETE ON public."event_review_decision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_inkind_decision_append_only BEFORE UPDATE OR DELETE ON public."in_kind_donation_decision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_shortage_decision_append_only BEFORE UPDATE OR DELETE ON public."inventory_loan_shortage_decision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();

-- PO-06: no cycles in facilities; also local self-parent CHECK C33.
CREATE OR REPLACE FUNCTION public.sgi_facility_no_cycles() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
DECLARE cycle_found boolean;
BEGIN
 IF NEW.parent_facility_id IS NULL THEN RETURN NEW; END IF;
 WITH RECURSIVE ancestors(id,parent_id) AS (
   SELECT f.id, f.parent_facility_id FROM public.institutional_facility f WHERE f.id=NEW.parent_facility_id
   UNION
   SELECT f.id, f.parent_facility_id FROM public.institutional_facility f JOIN ancestors a ON f.id=a.parent_id
 ) SELECT EXISTS(SELECT 1 FROM ancestors WHERE id=NEW.id) INTO cycle_found;
 IF cycle_found THEN RAISE EXCEPTION 'Facility hierarchy cycle detected for id %',NEW.id USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_facility_no_cycles BEFORE INSERT OR UPDATE OF parent_facility_id ON public.institutional_facility
FOR EACH ROW EXECUTE FUNCTION public.sgi_facility_no_cycles();

-- PO-08/09: order target is unambiguous at authorization; divergence requires scope.
CREATE OR REPLACE FUNCTION public.sgi_work_order_integrity() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE inc public.maintenance_incident%ROWTYPE;
BEGIN
 IF NEW.authorized_at IS NOT NULL THEN
  IF num_nonnulls(NEW.facility_id,NEW.stock_lot_id,NEW.unit_id)<>1 THEN
   RAISE EXCEPTION 'Authorized work order requires exactly one target' USING ERRCODE='23514';
  END IF;
  IF NEW.incident_id IS NOT NULL THEN
   SELECT * INTO inc FROM public.maintenance_incident WHERE id=NEW.incident_id;
   IF NOT FOUND THEN RAISE EXCEPTION 'Work order incident missing' USING ERRCODE='23503'; END IF;
   IF NOT (NEW.facility_id IS NOT DISTINCT FROM inc.facility_id AND NEW.stock_lot_id IS NOT DISTINCT FROM inc.stock_lot_id AND NEW.unit_id IS NOT DISTINCT FROM inc.unit_id)
      AND NULLIF(btrim(NEW.scope),'') IS NULL THEN
     RAISE EXCEPTION 'Different maintenance targets require a documented scope' USING ERRCODE='23514';
   END IF;
  END IF;
 END IF;
 IF NEW.assigned_at IS NOT NULL AND NEW.executor_person_id IS NULL THEN
   RAISE EXCEPTION 'Assigned work order requires executor' USING ERRCODE='23514';
 END IF;
 IF NEW.closed_at IS NOT NULL AND (NEW.verified_at IS NULL OR NEW.verified_at>NEW.closed_at OR NEW.verification_evidence IS NULL) THEN
   RAISE EXCEPTION 'Work order close requires verified evidence before closure' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_work_order_integrity BEFORE INSERT OR UPDATE ON public.maintenance_work_order FOR EACH ROW EXECUTE FUNCTION public.sgi_work_order_integrity();

-- PO-10: checkout target must represent the same inventory item as the loan.
CREATE OR REPLACE FUNCTION public.sgi_loan_allocation_item() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE loan_item integer; target_item integer;
BEGIN
 SELECT "itemId" INTO loan_item FROM public."InventoryLoan" WHERE id=NEW.loan_id;
 IF NEW.lot_id IS NOT NULL THEN
  SELECT item_id INTO target_item FROM public.inventory_stock_lot WHERE id=NEW.lot_id;
 ELSE
  SELECT item_id INTO target_item FROM public.inventory_unit WHERE id=NEW.unit_id;
 END IF;
 IF loan_item IS NULL OR target_item IS NULL OR loan_item<>target_item THEN
  RAISE EXCEPTION 'Checkout allocation item does not match loan item' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_loan_allocation_item BEFORE INSERT OR UPDATE OF loan_id, lot_id, unit_id ON public.inventory_loan_checkout_allocation
FOR EACH ROW EXECUTE FUNCTION public.sgi_loan_allocation_item();

-- PO-11: returns and allocations must belong to the same loan.
CREATE OR REPLACE FUNCTION public.sgi_return_detail_loan() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE return_loan integer; allocation_loan integer;
BEGIN
 SELECT loan_id INTO return_loan FROM public.inventory_loan_return WHERE id=NEW.return_id;
 SELECT loan_id INTO allocation_loan FROM public.inventory_loan_checkout_allocation WHERE id=NEW.checkout_allocation_id;
 IF return_loan IS NULL OR allocation_loan IS NULL OR return_loan<>allocation_loan THEN
  RAISE EXCEPTION 'Return detail belongs to a different loan' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_return_detail_loan BEFORE INSERT OR UPDATE OF return_id,checkout_allocation_id ON public.inventory_loan_return_detail
FOR EACH ROW EXECUTE FUNCTION public.sgi_return_detail_loan();

-- PO-12: defer quantity equation check until commit, lock allocation to serialize competing writes.
CREATE OR REPLACE FUNCTION public.sgi_allocation_quantities() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE alloc_id integer; cap numeric; returned numeric; missing numeric;
BEGIN
 alloc_id := CASE WHEN TG_OP='DELETE' THEN OLD.checkout_allocation_id ELSE NEW.checkout_allocation_id END;
 SELECT quantity INTO cap FROM public.inventory_loan_checkout_allocation WHERE id=alloc_id FOR UPDATE;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT COALESCE(SUM(quantity),0) INTO returned FROM public.inventory_loan_return_detail WHERE checkout_allocation_id=alloc_id;
 SELECT COALESCE(SUM(quantity),0) INTO missing FROM public.inventory_loan_shortage WHERE checkout_allocation_id=alloc_id AND status IS DISTINCT FROM 'CANCELLED';
 IF returned + missing > cap THEN
  RAISE EXCEPTION 'Return + shortage (%) exceeds checkout allocation (%)', returned + missing, cap USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER tg_return_allocation_limit AFTER INSERT OR UPDATE OR DELETE ON public.inventory_loan_return_detail
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.sgi_allocation_quantities();
CREATE CONSTRAINT TRIGGER tg_shortage_allocation_limit AFTER INSERT OR UPDATE OR DELETE ON public.inventory_loan_shortage
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.sgi_allocation_quantities();

-- PO-13: origin receipt line must identify the same inventory item as the asset/lot.
CREATE OR REPLACE FUNCTION public.sgi_receipt_origin_match() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE expected_item integer; actual_item integer;
BEGIN
 SELECT item_id INTO expected_item FROM public.in_kind_donation_receipt_line WHERE id=NEW.receipt_line_id;
 IF TG_TABLE_NAME='inventory_stock_lot_receipt_origin' THEN
   SELECT item_id INTO actual_item FROM public.inventory_stock_lot WHERE id=NEW.lot_id;
 ELSE
   SELECT item_id INTO actual_item FROM public.inventory_unit WHERE id=NEW.unit_id;
 END IF;
 IF expected_item IS NULL OR actual_item IS NULL OR expected_item<>actual_item THEN
  RAISE EXCEPTION 'Receipt origin item mismatch' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_lot_receipt_origin_match BEFORE INSERT OR UPDATE ON public.inventory_stock_lot_receipt_origin
FOR EACH ROW EXECUTE FUNCTION public.sgi_receipt_origin_match();
CREATE TRIGGER tg_unit_receipt_origin_match BEFORE INSERT OR UPDATE ON public.inventory_unit_receipt_origin
FOR EACH ROW EXECUTE FUNCTION public.sgi_receipt_origin_match();

-- PO-14/15: offer and receipt must refer to same donation and aggregate received <= offered.
CREATE OR REPLACE FUNCTION public.sgi_receipt_line_integrity() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE offered_donation integer; received_donation integer; offered_quantity numeric; quantity_used numeric;
BEGIN
 SELECT donation_id,quantity INTO offered_donation,offered_quantity
 FROM public.in_kind_donation_item WHERE id=NEW.donation_item_id FOR UPDATE;
 SELECT donation_id INTO received_donation FROM public.in_kind_donation_receipt WHERE id=NEW.receipt_id;
 IF offered_donation IS NULL OR received_donation IS NULL OR offered_donation<>received_donation THEN
  RAISE EXCEPTION 'Receipt line and offer belong to different donations' USING ERRCODE='23514';
 END IF;
 SELECT COALESCE(SUM(quantity),0) INTO quantity_used FROM public.in_kind_donation_receipt_line
 WHERE donation_item_id=NEW.donation_item_id AND id IS DISTINCT FROM NEW.id;
 IF NEW.quantity<=0 OR quantity_used + NEW.quantity>offered_quantity THEN
  RAISE EXCEPTION 'Received quantity exceeds offered quantity' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_receipt_line_integrity BEFORE INSERT OR UPDATE ON public.in_kind_donation_receipt_line
FOR EACH ROW EXECUTE FUNCTION public.sgi_receipt_line_integrity();

-- PO-17: document rectification must point to distinct document and cannot form a cycle.
CREATE OR REPLACE FUNCTION public.sgi_document_rectification_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE origin_document integer; found_cycle boolean;
BEGIN
 IF NEW.rectifies_version_id IS NULL THEN RETURN NEW; END IF;
 IF NEW.rectifies_version_id=NEW.id THEN RAISE EXCEPTION 'Self rectification not allowed' USING ERRCODE='23514'; END IF;
 SELECT document_id INTO origin_document FROM public.document_version WHERE id=NEW.rectifies_version_id;
 IF origin_document=NEW.document_id THEN RAISE EXCEPTION 'Rectification requires a different official document' USING ERRCODE='23514'; END IF;
 WITH RECURSIVE lineage(id,rectifies_version_id) AS (
  SELECT id,rectifies_version_id FROM public.document_version WHERE id=NEW.rectifies_version_id
  UNION
  SELECT v.id,v.rectifies_version_id FROM public.document_version v JOIN lineage l ON v.id=l.rectifies_version_id
 ) SELECT EXISTS(SELECT 1 FROM lineage WHERE id=NEW.id) INTO found_cycle;
 IF found_cycle THEN RAISE EXCEPTION 'Document rectification cycle detected' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_document_rectification_check BEFORE INSERT ON public.document_version
FOR EACH ROW EXECUTE FUNCTION public.sgi_document_rectification_check();

-- PO-18: series.code immutable after first official emission.
CREATE OR REPLACE FUNCTION public.sgi_series_code_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code AND EXISTS (
  SELECT 1 FROM public.document_record WHERE series_id=OLD.id AND official_registered_at IS NOT NULL
 ) THEN RAISE EXCEPTION 'Issued document series code cannot change' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_document_series_code_guard BEFORE UPDATE OF code ON public.document_series
FOR EACH ROW EXECUTE FUNCTION public.sgi_series_code_guard();

-- PO-19: committed official folios cannot be changed or recycled.
CREATE OR REPLACE FUNCTION public.sgi_document_official_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF OLD.official_registered_at IS NOT NULL THEN RAISE EXCEPTION 'Official document cannot be deleted' USING ERRCODE='23514'; END IF;
  RETURN OLD;
 END IF;
 IF OLD.official_registered_at IS NOT NULL AND (
  NEW.series_id IS DISTINCT FROM OLD.series_id OR NEW.folio_year IS DISTINCT FROM OLD.folio_year OR
  NEW.folio_sequence IS DISTINCT FROM OLD.folio_sequence OR NEW.official_registered_at IS DISTINCT FROM OLD.official_registered_at OR
  NEW.official_registration_request_key IS DISTINCT FROM OLD.official_registration_request_key
 ) THEN RAISE EXCEPTION 'Official document folio is immutable' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_document_official_guard BEFORE UPDATE OR DELETE ON public.document_record
FOR EACH ROW EXECUTE FUNCTION public.sgi_document_official_guard();

-- PO-20: monotonic folio counter. Application grants must be restricted to a controlled backend DB principal.
CREATE OR REPLACE FUNCTION public.sgi_folio_counter_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Folio counter cannot be deleted' USING ERRCODE='23514'; END IF;
 IF NEW.last_assigned<0 OR (TG_OP='UPDATE' AND NEW.last_assigned<=OLD.last_assigned) THEN
  RAISE EXCEPTION 'Folio counter may only increase' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_folio_counter_guard BEFORE INSERT OR UPDATE OR DELETE ON public.document_folio_counter
FOR EACH ROW EXECUTE FUNCTION public.sgi_folio_counter_guard();

-- PO-22: immutable economics after a financial movement is posted; VOIDED keeps the ledger row.
CREATE OR REPLACE FUNCTION public.sgi_financial_movement_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF OLD.status IN ('POSTED','VOIDED') THEN RAISE EXCEPTION 'Posted financial movement cannot be deleted' USING ERRCODE='23514'; END IF;
  RETURN OLD;
 END IF;
 IF OLD.status IN ('POSTED','VOIDED') AND (
  NEW."accountId" IS DISTINCT FROM OLD."accountId" OR NEW."amount" IS DISTINCT FROM OLD."amount" OR
  NEW."currency" IS DISTINCT FROM OLD."currency" OR NEW."type" IS DISTINCT FROM OLD."type" OR
  NEW."source" IS DISTINCT FROM OLD."source" OR NEW."sourceId" IS DISTINCT FROM OLD."sourceId" OR
  NEW."originType" IS DISTINCT FROM OLD."originType" OR NEW.initiative_id IS DISTINCT FROM OLD.initiative_id OR
  NEW.destination_type IS DISTINCT FROM OLD.destination_type OR NEW."reversalOfId" IS DISTINCT FROM OLD."reversalOfId"
 ) THEN RAISE EXCEPTION 'Posted financial movement economics are immutable' USING ERRCODE='23514'; END IF;
 IF OLD.status='VOIDED' AND NEW.status IS DISTINCT FROM OLD.status THEN
   RAISE EXCEPTION 'Voided movement cannot be reopened' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_financial_movement_guard BEFORE UPDATE OR DELETE ON public."FinancialMovement"
FOR EACH ROW EXECUTE FUNCTION public.sgi_financial_movement_guard();

-- PO-23: recognition of maintenance expense only after verified work order closure.
CREATE OR REPLACE FUNCTION public.sgi_maintenance_cost_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE work_verified timestamp; work_closed timestamp;
BEGIN
 IF NEW.maintenance_cost_recognized_at IS NULL THEN RETURN NEW; END IF;
 IF NEW.maintenance_work_order_id IS NULL THEN RAISE EXCEPTION 'Maintenance cost requires work order' USING ERRCODE='23514'; END IF;
 SELECT verified_at,closed_at INTO work_verified,work_closed FROM public.maintenance_work_order WHERE id=NEW.maintenance_work_order_id;
 IF work_verified IS NULL OR work_closed IS NULL OR work_closed>NEW.maintenance_cost_recognized_at THEN
  RAISE EXCEPTION 'Maintenance expense may be recognized only after verified closure' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_maintenance_cost_guard BEFORE INSERT OR UPDATE ON public."Expense"
FOR EACH ROW EXECUTE FUNCTION public.sgi_maintenance_cost_guard();


-- PO-12 (completion): returned loan cannot close with unallocated/unaccounted quantity.
-- Runs deferred so checkout/return/shortage rows may be written in one transaction.
CREATE OR REPLACE FUNCTION public.sgi_loan_close_equation() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE allocated numeric; accounted numeric;
BEGIN
 IF NEW.status<>'RETURNED' THEN RETURN NULL; END IF;
 SELECT COALESCE(SUM(quantity),0) INTO allocated FROM public.inventory_loan_checkout_allocation WHERE loan_id=NEW.id;
 SELECT COALESCE(SUM(d.quantity),0) INTO accounted
 FROM public.inventory_loan_return_detail d JOIN public.inventory_loan_checkout_allocation a ON a.id=d.checkout_allocation_id
 WHERE a.loan_id=NEW.id;
 SELECT accounted+COALESCE(SUM(s.quantity),0) INTO accounted
 FROM public.inventory_loan_shortage s JOIN public.inventory_loan_checkout_allocation a ON a.id=s.checkout_allocation_id
 WHERE a.loan_id=NEW.id AND s.status IS DISTINCT FROM 'CANCELLED';
 IF allocated<>NEW.quantity OR accounted<>allocated THEN
  RAISE EXCEPTION 'Cannot close loan %: loan qty %, allocated %, accounted %', NEW.id,NEW.quantity,allocated,accounted USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER tg_loan_close_equation AFTER INSERT OR UPDATE ON public."InventoryLoan"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.sgi_loan_close_equation();

-- PO-15 (reverse direction): decreasing offered quantity must not invalidate received rows.
CREATE OR REPLACE FUNCTION public.sgi_offer_quantity_floor() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE received numeric;
BEGIN
 SELECT COALESCE(SUM(quantity),0) INTO received FROM public.in_kind_donation_receipt_line WHERE donation_item_id=NEW.id;
 IF NEW.quantity<received THEN
  RAISE EXCEPTION 'Offered quantity (%) cannot be less than quantity received (%)',NEW.quantity,received USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_offer_quantity_floor BEFORE UPDATE OF quantity ON public.in_kind_donation_item
FOR EACH ROW EXECUTE FUNCTION public.sgi_offer_quantity_floor();
