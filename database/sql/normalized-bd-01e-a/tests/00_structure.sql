\set ON_ERROR_STOP on

DO $$
DECLARE
  v_tables integer;
  v_columns integer;
  v_enums integer;
  v_sequences integer;
  v_constraints integer;
  v_foreign_keys integer;
  v_indexes integer;
  v_triggers integer;
  v_constraint_triggers integer;
  v_policies integer;
BEGIN
  SELECT count(*) INTO v_tables FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
   WHERE n.nspname='public' AND c.relkind='r';
  SELECT count(*) INTO v_columns FROM information_schema.columns
   WHERE table_schema='public' AND table_name IN (SELECT relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r');
  SELECT count(*) INTO v_enums FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace
   WHERE n.nspname='public' AND t.typtype='e';
  SELECT count(*) INTO v_sequences FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
   WHERE n.nspname='public' AND c.relkind='S';
  SELECT count(*) INTO v_constraints FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
   WHERE n.nspname='public' AND c.contype IN ('p','f','c','x');
  SELECT count(*) INTO v_foreign_keys FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
   WHERE n.nspname='public' AND c.contype='f';
  SELECT count(*) INTO v_indexes FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
   WHERE n.nspname='public' AND c.relkind='i';
  SELECT count(*) INTO v_triggers FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace
   WHERE n.nspname='public' AND NOT t.tgisinternal;
  SELECT count(*) INTO v_constraint_triggers FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace
   WHERE n.nspname='public' AND NOT t.tgisinternal AND t.tgconstraint<>0 AND t.tgdeferrable AND t.tginitdeferred;
  SELECT count(*) INTO v_policies FROM pg_policy p JOIN pg_class c ON c.oid=p.polrelid JOIN pg_namespace n ON n.oid=c.relnamespace
   WHERE n.nspname='public';

  IF v_tables<>86 OR v_columns<>922 OR v_enums<>46 OR v_sequences<>82 OR v_constraints<>307
     OR v_foreign_keys<>174 OR v_indexes<>329 OR v_triggers<>30 OR v_constraint_triggers<>3 OR v_policies<>9 THEN
    RAISE EXCEPTION 'structure mismatch tables=% columns=% enums=% sequences=% constraints=% fks=% indexes=% triggers=% deferred=% policies=%',
      v_tables,v_columns,v_enums,v_sequences,v_constraints,v_foreign_keys,v_indexes,v_triggers,v_constraint_triggers,v_policies;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname='btree_gist' AND extversion='1.7') THEN
    RAISE EXCEPTION 'btree_gist 1.7 missing';
  END IF;
  IF (SELECT count(*) FROM pg_constraint WHERE contype='x' AND conname='ex_resource_unavailabilities_rule')<>1 THEN
    RAISE EXCEPTION 'normalized EXCLUDE GiST missing or duplicated';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
             WHERE n.nspname='public' AND c.relkind IN ('r','S','i','v') AND octet_length(c.relname)>63) THEN
    RAISE EXCEPTION 'identifier exceeds PostgreSQL 63-byte limit';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
             WHERE n.nspname='public' AND c.relkind IN ('r','S','i','v') AND c.relname !~ '^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$') THEN
    RAISE EXCEPTION 'non-normalized relation identifier found';
  END IF;
END $$;

SELECT 'PASS BD-01E-A structure' AS result;
