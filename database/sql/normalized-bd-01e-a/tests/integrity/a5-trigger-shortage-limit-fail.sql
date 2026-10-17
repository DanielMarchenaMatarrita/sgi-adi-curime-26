BEGIN;
INSERT INTO public.inventory_categories (id,name,is_active,updated_at) VALUES (2100000012,'A5 Shortage Category',true,timestamp '2026-01-01 00:00:00');
INSERT INTO public.inventory_items (id,code,name,current_quantity,minimum_quantity,unit,status,condition,category_id,updated_at) VALUES (2100000012,'A5-SHORTAGE-ITEM','A5 Shortage Item',1,0,'unidad','ACTIVE','GOOD',2100000012,timestamp '2026-01-01 00:00:00');
INSERT INTO public.inventory_loans (id,quantity,borrower_name,loan_date,expected_return_date,status,item_id,updated_at) VALUES (2100000012,1,'A5 Synthetic Borrower',timestamp '2026-01-01 00:00:00',timestamp '2026-01-02 00:00:00','ACTIVE',2100000012,timestamp '2026-01-01 00:00:00');
INSERT INTO public.inventory_stock_lots (id,code,item_id,quantity,condition,status) VALUES (2100000012,'A5-SHORTAGE-LOT',2100000012,1.000,'GOOD','AVAILABLE');
INSERT INTO public.inventory_loan_checkout_allocations (id,loan_id,lot_id,quantity) VALUES (2100000012,2100000012,2100000012,1.000);
INSERT INTO public.inventory_loan_shortages (id,checkout_allocation_id,quantity,status,reason) VALUES (2100000012,2100000012,2.000,'OPEN','A5 synthetic over-allocation');
SET CONSTRAINTS trg_inventory_loan_shortages_shortage_allocation_limit_event IMMEDIATE;
ROLLBACK;
