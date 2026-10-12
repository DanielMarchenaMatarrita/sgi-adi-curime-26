-- Run after initial migration. Fail loudly if structural invariants differ.
DO $$
DECLARE c_tables int; c_enums int; c_fks int; c_checks int; c_exclude int; c_explicit int;
BEGIN
 SELECT count(*) INTO c_tables FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND c.relkind='r';
 SELECT count(*) INTO c_enums FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace
  WHERE n.nspname='public' AND t.typtype='e';
 SELECT count(*) INTO c_fks FROM pg_constraint k JOIN pg_namespace n ON n.oid=k.connamespace
  WHERE n.nspname='public' AND k.contype='f';
 SELECT count(*) INTO c_checks FROM pg_constraint k JOIN pg_namespace n ON n.oid=k.connamespace
  WHERE n.nspname='public' AND k.contype='c' AND k.conname LIKE 'ck_%';
 SELECT count(*) INTO c_exclude FROM pg_constraint k JOIN pg_namespace n ON n.oid=k.connamespace
  WHERE n.nspname='public' AND k.contype='x';
 SELECT count(*) INTO c_explicit FROM pg_index i JOIN pg_class c ON c.oid=i.indexrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND NOT i.indisprimary;
 IF c_tables<>86 THEN RAISE EXCEPTION 'Expected 86 persistent SGI tables; got %',c_tables; END IF;
 IF c_enums<>46 THEN RAISE EXCEPTION 'Expected 46 enum types; got %',c_enums; END IF;
 IF c_fks<>174 THEN RAISE EXCEPTION 'Expected 174 FKs; got %',c_fks; END IF;
 IF c_checks<44 THEN RAISE EXCEPTION 'Expected at least 44 named ck_ constraints; got %',c_checks; END IF;
 IF c_exclude<>1 THEN RAISE EXCEPTION 'Expected exactly 1 EXCLUDE; got %',c_exclude; END IF;
 IF c_explicit<235 THEN RAISE EXCEPTION 'Expected at least 235 non-PK indexes; got %',c_explicit; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='User' AND column_name='roleId') THEN
  RAISE EXCEPTION 'Legacy User.roleId must not be part of V2 initial schema'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='pk_UserRole') THEN RAISE EXCEPTION 'Missing UserRole PK'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='ex_unavailability_active_period') THEN RAISE EXCEPTION 'Missing resource exclusion'; END IF;
 IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
            WHERE n.nspname='public' AND c.relkind='r' AND NOT c.relrowsecurity) THEN
  RAISE EXCEPTION 'RLS disabled on some public SGI tables'; END IF;
 RAISE NOTICE 'SGI V2 schema PASS: % tables, % enums, % FKs, % named CHECK, % exclusion',
  c_tables,c_enums,c_fks,c_checks,c_exclude;
END $$;

SELECT t.typname AS enum_name FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace
WHERE n.nspname='public' AND t.typtype='e' ORDER BY t.typname;
SELECT c.relname AS table_name FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
