-- New database initialization: expose NO SGI table by default through PostgREST.
-- The backend must use a dedicated privileged connection and authorize access in NestJS.
-- No public/anon/authenticated RLS policies are installed automatically.
DO $$
DECLARE t record;
BEGIN
 FOR t IN SELECT table_name FROM information_schema.tables
          WHERE table_schema='public' AND table_type='BASE TABLE' LOOP
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.table_name);
 END LOOP;
END $$;

-- Revoke direct write access to particularly sensitive objects even when API roles exist.
DO $$
DECLARE role_name text;
BEGIN
 FOR role_name IN SELECT rolname FROM pg_roles WHERE rolname IN ('anon','authenticated') LOOP
  EXECUTE format('REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM %I',role_name);
  EXECUTE format('REVOKE USAGE, UPDATE ON ALL SEQUENCES IN SCHEMA public FROM %I',role_name);
 END LOOP;
END $$;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE USAGE, UPDATE ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
