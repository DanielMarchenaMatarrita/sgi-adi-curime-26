\set ON_ERROR_STOP on

CREATE SCHEMA test_103d_a AUTHORIZATION postgres;
GRANT USAGE ON SCHEMA test_103d_a TO PUBLIC;
CREATE FUNCTION test_103d_a.assert_raises(statement text, expected_state text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE statement;
  RAISE EXCEPTION 'expected SQLSTATE %, statement succeeded: %', expected_state, statement;
EXCEPTION WHEN OTHERS THEN
  IF SQLSTATE <> expected_state THEN
    RAISE EXCEPTION 'expected SQLSTATE %, got % for %', expected_state, SQLSTATE, statement;
  END IF;
END $$;

DO $$
DECLARE role_name text;
BEGIN
  FOREACH role_name IN ARRAY ARRAY['sgi_owner', 'sgi_migrator', 'sgi_auth_runtime', 'sgi_app_runtime'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name AND NOT rolcanlogin AND NOT rolsuper AND NOT rolbypassrls) THEN
      RAISE EXCEPTION 'role invariant failed: %', role_name;
    END IF;
  END LOOP;
  IF NOT pg_has_role('sgi_migrator', 'sgi_owner', 'member') THEN RAISE EXCEPTION 'migrator lacks owner membership'; END IF;
  IF pg_has_role('sgi_auth_runtime', 'sgi_owner', 'member') OR pg_has_role('sgi_app_runtime', 'sgi_owner', 'member') THEN
    RAISE EXCEPTION 'runtime role owns migration role';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND c.relname IN ('Person','Role','Permission','RolePermission','User','UserRole','Session','AuditLog','PasswordResetToken','AccountActivationToken')
      AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)
  ) THEN RAISE EXCEPTION 'initial table RLS FORCE invariant failed'; END IF;
  IF NOT (SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relname='UserRequest') THEN
    RAISE EXCEPTION 'canonical non-phase table RLS interaction changed';
  END IF;
END $$;

SET ROLE sgi_auth_runtime;
DO $$ DECLARE row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'unset lookup GUC exposes User rows'; END IF;
END $$;
BEGIN;
SELECT set_config('sgi.auth_lookup_identifier', 'ana@example.test', true);
SELECT "id", "passwordHash" FROM public."User" WHERE "email" = 'ana@example.test';
UPDATE public."User" SET "failedLoginAttempts" = 1, "updatedAt" = now() WHERE "id" = 1;
COMMIT;
DO $$ BEGIN
  IF NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL THEN RAISE EXCEPTION 'lookup GUC leaked after commit'; END IF;
END $$;
BEGIN;
SELECT set_config('sgi.auth_lookup_identifier', '', true);
DO $$ DECLARE row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'empty lookup GUC exposes User rows'; END IF;
END $$;
ROLLBACK;
BEGIN;
SELECT set_config('sgi.auth_lookup_identifier', 'not-ana@example.test', true);
DO $$ DECLARE row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'mismatched lookup GUC exposes target row'; END IF;
END $$;
ROLLBACK;
BEGIN;
SELECT set_config('sgi.auth_lookup_identifier', 'ana@example.test', true);
ROLLBACK;
DO $$ BEGIN
  IF NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL THEN RAISE EXCEPTION 'lookup GUC leaked after rollback'; END IF;
END $$;
SELECT test_103d_a.assert_raises('SELECT "fullName" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."Session" ("refreshTokenHash", "expiresAt", "userId") VALUES (''x'', now(), 1)', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."AuditLog" ("action", "module", "userId") VALUES (''x'', ''test'', 1)', '42501');
DO $$ BEGIN
  IF pg_has_role(current_user, 'sgi_app_runtime', 'member') THEN RAISE EXCEPTION 'auth runtime can escalate to app runtime'; END IF;
END $$;
BEGIN;
SELECT set_config('sgi.auth_lookup_identifier', 'ana@example.test', true);
SELECT set_config('sgi.actor_user_id', '1', true);
DO $$ DECLARE row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'actor GUC incorrectly widens bootstrap User rows'; END IF;
END $$;
COMMIT;
RESET ROLE;

SET ROLE sgi_app_runtime;
SELECT test_103d_a.assert_raises('SELECT "id" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."AuditLog" ("action", "module", "userId") VALUES (''x'', ''test'', 1)', '42501');
BEGIN;
SELECT set_config('sgi.actor_user_id', '1', true);
INSERT INTO public."AuditLog" ("action", "module", "userId") VALUES ('LOGIN', 'auth', 1);
SELECT test_103d_a.assert_raises('INSERT INTO public."AuditLog" ("action", "module", "userId") VALUES (''x'', ''test'', 2)', '42501');
COMMIT;
DO $$ BEGIN
  IF NULLIF(current_setting('sgi.actor_user_id', true), '') IS NOT NULL THEN RAISE EXCEPTION 'actor GUC leaked after transaction'; END IF;
END $$;
SELECT test_103d_a.assert_raises('UPDATE public."AuditLog" SET "action" = ''changed'' WHERE "id" = 1', '42501');
SELECT test_103d_a.assert_raises('DELETE FROM public."AuditLog" WHERE "id" = 1', '42501');
RESET ROLE;

DO $$
DECLARE role_name text;
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_class c CROSS JOIN LATERAL aclexplode(coalesce(c.relacl, acldefault('r', c.relowner))) a
    JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND c.relname IN ('User','AuditLog') AND a.grantee=0
      AND a.privilege_type IN ('SELECT','INSERT','UPDATE','DELETE')
  ) THEN RAISE EXCEPTION 'PUBLIC has initial-table access'; END IF;
  FOREACH role_name IN ARRAY ARRAY['anon','authenticated'] LOOP
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname=role_name)
       AND (has_table_privilege(role_name, 'public."User"', 'select,insert,update,delete')
         OR has_table_privilege(role_name, 'public."AuditLog"', 'select,update,delete')) THEN
      RAISE EXCEPTION 'anonymous role has table access: %', role_name;
    END IF;
  END LOOP;
END $$;

DROP SCHEMA test_103d_a CASCADE;
