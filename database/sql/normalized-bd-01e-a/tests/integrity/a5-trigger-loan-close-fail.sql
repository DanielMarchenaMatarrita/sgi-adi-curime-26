BEGIN;
INSERT INTO public.inventory_categories (id,name,is_active,updated_at) VALUES (2100000013,'A5 Close Category',true,timestamp '2026-01-01 00:00:00');
INSERT INTO public.inventory_items (id,code,name,current_quantity,minimum_quantity,unit,status,condition,category_id,updated_at) VALUES (2100000013,'A5-CLOSE-ITEM','A5 Close Item',1,0,'unidad','ACTIVE','GOOD',2100000013,timestamp '2026-01-01 00:00:00');
INSERT INTO public.inventory_loans (id,quantity,borrower_name,loan_date,expected_return_date,returned_at,status,item_id,updated_at) VALUES (2100000013,1,'A5 Synthetic Borrower',timestamp '2026-01-01 00:00:00',timestamp '2026-01-02 00:00:00',timestamp '2026-01-02 00:00:00','RETURNED',2100000013,timestamp '2026-01-02 00:00:00');
SET CONSTRAINTS trg_inventory_loans_loan_close_equation_event IMMEDIATE;
ROLLBACK;
