\set ON_ERROR_STOP on

INSERT INTO public.audit_logs (action, module, entity_id, user_id)
VALUES ('E2E_SUITE_PASS', 'e2e-suite-marker', :'required_validator_suite', 1);
