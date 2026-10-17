BEGIN;
SET SESSION AUTHORIZATION sgi_app_validator;
SET LOCAL ROLE sgi_app_runtime;
SELECT set_config('sgi.actor_user_id','2100000041',true);
INSERT INTO public.audit_logs (action,module,entity_type,entity_id,details,user_id) VALUES ('A5_SYNTHETIC_DENIED','A5_VALIDATION','SyntheticFixture','2100000041','{"synthetic":true}'::jsonb,NULL);
ROLLBACK;
