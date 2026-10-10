\set ON_ERROR_STOP on

DO $$
DECLARE
  committed_count integer;
  rollback_count integer;
  concurrent_a_count integer;
  concurrent_b_count integer;
BEGIN
  SELECT count(*) INTO committed_count
  FROM public."AuditLog"
  WHERE "module" = 'be-02c-b2'
    AND "entityId" = 'committed-marker'
    AND "userId" = 1;
  IF committed_count <> 1 THEN
    RAISE EXCEPTION 'expected one committed validator marker, got %', committed_count;
  END IF;

  SELECT count(*) INTO rollback_count
  FROM public."AuditLog"
  WHERE "module" = 'be-02c-b2'
    AND "entityId" = 'rollback-marker';
  IF rollback_count <> 0 THEN
    RAISE EXCEPTION 'rollback validator marker was persisted: % row(s)', rollback_count;
  END IF;

  SELECT count(*) INTO concurrent_a_count
  FROM public."AuditLog"
  WHERE "module" = 'be-02c-b2'
    AND "entityId" = 'concurrent-actor-1'
    AND "userId" = 1;
  SELECT count(*) INTO concurrent_b_count
  FROM public."AuditLog"
  WHERE "module" = 'be-02c-b2'
    AND "entityId" = 'concurrent-actor-2'
    AND "userId" = 2;
  IF concurrent_a_count <> 1 OR concurrent_b_count <> 1 THEN
    RAISE EXCEPTION 'expected one committed row per concurrent actor, got %, %', concurrent_a_count, concurrent_b_count;
  END IF;
END $$;
