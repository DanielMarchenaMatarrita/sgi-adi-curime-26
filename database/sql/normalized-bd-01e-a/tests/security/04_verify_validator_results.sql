\set ON_ERROR_STOP on

SELECT set_config('sgi.required_validator_suite', :'required_validator_suite', false);

DO $$
DECLARE
  required_suite text := current_setting('sgi.required_validator_suite');
  suite_pass_count integer;
  suite_fail_count integer;
  committed_count integer;
  rollback_count integer;
  concurrent_a_count integer;
  concurrent_b_count integer;
BEGIN
  SELECT count(*) INTO suite_pass_count
  FROM public.audit_logs
  WHERE action = 'E2E_SUITE_PASS'
    AND module = 'e2e-suite-marker'
    AND entity_id = required_suite
    AND user_id = 1;
  IF suite_pass_count <> 1 THEN
    RAISE EXCEPTION 'expected one successful validator suite marker for %, got %', required_suite, suite_pass_count;
  END IF;

  SELECT count(*) INTO suite_fail_count
  FROM public.audit_logs
  WHERE action = 'E2E_SUITE_FAIL'
    AND module = 'e2e-suite-marker'
    AND entity_id = required_suite;
  IF suite_fail_count <> 0 THEN
    RAISE EXCEPTION 'validator suite % recorded % failure marker(s)', required_suite, suite_fail_count;
  END IF;

  IF required_suite <> 'database.security.integration.e2e-spec.ts' THEN
    RETURN;
  END IF;

  SELECT count(*) INTO committed_count
  FROM public.audit_logs
  WHERE module = 'be-02c-b2'
    AND entity_id = 'committed-marker'
    AND user_id = 1;
  IF committed_count <> 1 THEN
    RAISE EXCEPTION 'expected one committed validator marker, got %', committed_count;
  END IF;

  SELECT count(*) INTO rollback_count
  FROM public.audit_logs
  WHERE module = 'be-02c-b2'
    AND entity_id = 'rollback-marker';
  IF rollback_count <> 0 THEN
    RAISE EXCEPTION 'rollback validator marker was persisted: % row(s)', rollback_count;
  END IF;

  SELECT count(*) INTO concurrent_a_count
  FROM public.audit_logs
  WHERE module = 'be-02c-b2'
    AND entity_id = 'concurrent-actor-1'
    AND user_id = 1;
  SELECT count(*) INTO concurrent_b_count
  FROM public.audit_logs
  WHERE module = 'be-02c-b2'
    AND entity_id = 'concurrent-actor-2'
    AND user_id = 2;
  IF concurrent_a_count <> 1 OR concurrent_b_count <> 1 THEN
    RAISE EXCEPTION 'expected one committed row per concurrent actor, got %, %', concurrent_a_count, concurrent_b_count;
  END IF;
END $$;
