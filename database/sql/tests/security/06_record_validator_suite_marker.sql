\set ON_ERROR_STOP on

INSERT INTO public."AuditLog" ("action", "module", "entityId", "userId")
VALUES ('E2E_SUITE_PASS', 'e2e-suite-marker', :'required_validator_suite', 1);
