\set ON_ERROR_STOP on

DO $$
BEGIN
  IF (SELECT count(*) FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE n.nspname='public' AND NOT t.tgisinternal AND t.tgconstraint<>0
        AND t.tgdeferrable AND t.tginitdeferred)<>3 THEN
    RAISE EXCEPTION 'three INITIALLY DEFERRED constraint triggers required';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint c JOIN pg_class r ON r.oid=c.conrelid
    WHERE r.relname='resource_unavailabilities' AND c.contype='x'
      AND pg_get_constraintdef(c.oid,true) LIKE 'EXCLUDE USING gist%'
      AND pg_get_constraintdef(c.oid,true) LIKE '%released_at IS NULL%'
  ) THEN RAISE EXCEPTION 'EXCLUDE GiST definition changed'; END IF;
  IF EXISTS (
    SELECT 1 FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND NOT t.tgisinternal AND NOT t.tgenabled::text IN ('O','A','R')
  ) THEN RAISE EXCEPTION 'disabled user trigger found'; END IF;
END $$;

SELECT 'PASS BD-01E-A integrity catalog' AS result;
