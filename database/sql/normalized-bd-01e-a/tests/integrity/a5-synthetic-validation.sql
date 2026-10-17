BEGIN;
DO $$ BEGIN
  IF (SELECT count(*) FROM pg_trigger WHERE tgname IN ('trg_inventory_loan_return_details_return_allocation_limit_event','trg_inventory_loan_shortages_shortage_allocation_limit_event','trg_inventory_loans_loan_close_equation_event') AND tgdeferrable AND tginitdeferred)<>3 THEN
    RAISE EXCEPTION 'deferred_constraint_triggers invariant failed' USING ERRCODE='P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ex_resource_unavailabilities_rule' AND contype='x' AND pg_get_constraintdef(oid,true) LIKE 'EXCLUDE USING gist%') THEN
    RAISE EXCEPTION 'exclude_gist invariant failed' USING ERRCODE='P0001';
  END IF;
  RAISE NOTICE 'PASS deferred_constraint_triggers';
  RAISE NOTICE 'PASS exclude_gist';
END $$;
INSERT INTO public.people (id,first_name,identification,email,updated_at) VALUES (2100000001,'A5 Synthetic','A5-SYNTHETIC-2100000001','a5.synthetic.2100000001@example.invalid',timestamp '2026-01-01 00:00:00');
INSERT INTO public.users (id,full_name,identification,email,password_hash,status,person_id,updated_at) VALUES (2100000001,'A5 Synthetic User','A5-SYNTHETIC-2100000001','a5.synthetic.2100000001@example.invalid','synthetic-not-a-credential','ACTIVE',2100000001,timestamp '2026-01-01 00:00:00');
INSERT INTO public.roles (id,name,description,is_active,updated_at) VALUES (2100000001,'A5_SYNTHETIC_READER','A5 rollback-only synthetic role',true,timestamp '2026-01-01 00:00:00');
INSERT INTO public.permissions (id,code,name,description,updated_at) VALUES (2100000001,'affiliates.read','A5 synthetic affiliate read','A5 rollback-only synthetic permission',timestamp '2026-01-01 00:00:00') ON CONFLICT (code) DO NOTHING;
INSERT INTO public.user_roles (user_id,role_id) VALUES (2100000001,2100000001);
INSERT INTO public.role_permissions (role_id,permission_id) SELECT 2100000001,id FROM public.permissions WHERE code='affiliates.read';
INSERT INTO public.affiliates (id,full_name,identification,birth_date,address,affiliate_type,affiliation_date,status,updated_at) VALUES (2100000001,'A5 Synthetic Affiliate','A5-AFFILIATE-2100000001',timestamp '2000-01-01 00:00:00','Synthetic address','REGULAR',timestamp '2026-01-01 00:00:00','ACTIVE',timestamp '2026-01-01 00:00:00');
SET SESSION AUTHORIZATION sgi_app_validator;
SET LOCAL ROLE sgi_app_runtime;
SELECT set_config('sgi.actor_user_id','2100000001',true);
DO $$ BEGIN
  IF (SELECT count(*) FROM public.users WHERE id=2100000001)<>1 THEN RAISE EXCEPTION 'app_rls_allowed invariant failed' USING ERRCODE='P0001'; END IF;
  IF (SELECT count(*) FROM public.users WHERE id<>2100000001)<>0 THEN RAISE EXCEPTION 'app_rls_denied invariant failed' USING ERRCODE='P0001'; END IF;
  IF (SELECT count(*) FROM public.affiliates WHERE id=2100000001)<>1 THEN RAISE EXCEPTION 'affiliate_rls_allowed invariant failed' USING ERRCODE='P0001'; END IF;
  RAISE NOTICE 'PASS app_rls_allowed';
  RAISE NOTICE 'PASS app_rls_denied';
  RAISE NOTICE 'PASS affiliate_rls_allowed';
END $$;
INSERT INTO public.audit_logs (action,module,entity_type,entity_id,details,user_id) VALUES ('A5_SYNTHETIC_ALLOWED','A5_VALIDATION','SyntheticFixture','2100000001','{"synthetic":true}'::jsonb,2100000001);
SELECT 'PASS app_rls_insert_allowed';
RESET ROLE;
RESET SESSION AUTHORIZATION;
SET SESSION AUTHORIZATION sgi_auth_validator;
SET LOCAL ROLE sgi_auth_runtime;
SELECT set_config('sgi.actor_user_id','',true);
SELECT set_config('sgi.auth_lookup_identifier','a5.synthetic.2100000001@example.invalid',true);
DO $$ BEGIN
  IF (SELECT count(*) FROM public.users WHERE id=2100000001)<>1 THEN RAISE EXCEPTION 'auth_rls_allowed invariant failed' USING ERRCODE='P0001'; END IF;
  RAISE NOTICE 'PASS auth_rls_allowed';
END $$;
SELECT set_config('sgi.auth_lookup_identifier','denied@example.invalid',true);
DO $$ BEGIN
  IF (SELECT count(*) FROM public.users WHERE id=2100000001)<>0 THEN RAISE EXCEPTION 'auth_rls_denied invariant failed' USING ERRCODE='P0001'; END IF;
  RAISE NOTICE 'PASS auth_rls_denied';
END $$;
RESET ROLE;
RESET SESSION AUTHORIZATION;
ROLLBACK;
