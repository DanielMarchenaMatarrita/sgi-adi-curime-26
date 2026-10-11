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
  FOREACH role_name IN ARRAY ARRAY['sgi_auth_validator', 'sgi_app_validator'] LOOP
    IF NOT EXISTS (
      SELECT 1 FROM pg_roles
      WHERE rolname = role_name AND rolcanlogin AND NOT rolinherit
        AND NOT rolsuper AND NOT rolcreatedb AND NOT rolcreaterole
        AND NOT rolreplication AND NOT rolbypassrls
    ) THEN
      RAISE EXCEPTION 'validator role invariant failed: %', role_name;
    END IF;
  END LOOP;
  IF NOT pg_has_role('sgi_migrator', 'sgi_owner', 'member') THEN RAISE EXCEPTION 'migrator lacks owner membership'; END IF;
  IF pg_has_role('sgi_auth_runtime', 'sgi_owner', 'member') OR pg_has_role('sgi_app_runtime', 'sgi_owner', 'member') THEN
    RAISE EXCEPTION 'runtime role owns migration role';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND c.relname IN ('Person','Role','Permission','RolePermission','User','UserRole','Session','AuditLog','PasswordResetToken','AccountActivationToken','Affiliate')
      AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)
  ) THEN RAISE EXCEPTION 'initial table RLS FORCE invariant failed'; END IF;
  IF NOT (SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relname='UserRequest') THEN
    RAISE EXCEPTION 'canonical non-phase table RLS interaction changed';
  END IF;
  IF NOT (SELECT relrowsecurity AND relforcerowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relname='User') THEN
    RAISE EXCEPTION 'User must keep FORCE ROW LEVEL SECURITY';
  END IF;
  IF NOT (SELECT relrowsecurity AND relforcerowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relname='Affiliate') THEN
    RAISE EXCEPTION 'Affiliate must use FORCE ROW LEVEL SECURITY';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy policy
    JOIN pg_class relation ON relation.oid = policy.polrelid
    JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'public' AND relation.relname = 'User'
      AND policy.polname = 'p_103d_app_user_self_select'
      AND policy.polcmd = 'r'
      AND policy.polroles = ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'sgi_app_runtime')]
  ) THEN RAISE EXCEPTION 'app self-select policy invariant failed'; END IF;
  IF EXISTS (
    SELECT 1 FROM pg_policy policy
    JOIN pg_class relation ON relation.oid = policy.polrelid
    JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'public' AND relation.relname = 'User'
      AND policy.polname = 'p_103b_app_user_self_select'
  ) THEN RAISE EXCEPTION 'legacy app self-select policy remains'; END IF;
  IF EXISTS (
    SELECT 1
    FROM information_schema.column_privileges
    WHERE table_schema = 'public' AND table_name = 'User'
      AND grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT'
      AND column_name NOT IN ('id', 'fullName', 'email', 'status')
  ) OR (SELECT count(*) FROM information_schema.column_privileges
        WHERE table_schema = 'public' AND table_name = 'User'
          AND grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT') <> 4 THEN
    RAISE EXCEPTION 'app User SELECT columns are not minimal';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM information_schema.column_privileges
    WHERE table_schema = 'public' AND table_name = 'User'
      AND grantee = 'sgi_auth_runtime' AND privilege_type = 'SELECT'
      AND column_name NOT IN ('id', 'email', 'identification', 'passwordHash', 'status', 'failedLoginAttempts', 'lockedAt')
  ) OR (SELECT count(*) FROM information_schema.column_privileges
        WHERE table_schema = 'public' AND table_name = 'User'
        AND grantee = 'sgi_auth_runtime' AND privilege_type = 'SELECT') <> 7 THEN
    RAISE EXCEPTION 'auth User SELECT grant changed unexpectedly';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.column_privileges
    WHERE grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT'
      AND (table_schema, table_name, column_name) NOT IN (
        ('public', 'UserRole', 'userId'), ('public', 'UserRole', 'roleId'),
        ('public', 'Role', 'id'), ('public', 'Role', 'isActive'),
        ('public', 'RolePermission', 'roleId'), ('public', 'RolePermission', 'permissionId'),
        ('public', 'Permission', 'id'), ('public', 'Permission', 'code'),
        ('public', 'User', 'id'), ('public', 'User', 'fullName'),
        ('public', 'User', 'email'), ('public', 'User', 'status'),
        ('public', 'Affiliate', 'id'), ('public', 'Affiliate', 'fullName'),
        ('public', 'Affiliate', 'affiliateType'), ('public', 'Affiliate', 'affiliationDate'),
        ('public', 'Affiliate', 'status')
      )
  ) THEN RAISE EXCEPTION 'app SELECT grants exceed BE-03C minimum'; END IF;
  IF (SELECT count(*) FROM information_schema.column_privileges
      WHERE grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT' AND table_schema = 'public' AND table_name = 'UserRole') <> 2
     OR (SELECT count(*) FROM information_schema.column_privileges
      WHERE grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT' AND table_schema = 'public' AND table_name = 'Role') <> 2
     OR (SELECT count(*) FROM information_schema.column_privileges
      WHERE grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT' AND table_schema = 'public' AND table_name = 'RolePermission') <> 2
     OR (SELECT count(*) FROM information_schema.column_privileges
     WHERE grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT' AND table_schema = 'public' AND table_name = 'Permission') <> 2
     OR (SELECT count(*) FROM information_schema.column_privileges
       WHERE grantee = 'sgi_app_runtime' AND privilege_type = 'SELECT' AND table_schema = 'public' AND table_name = 'Affiliate') <> 5 THEN
    RAISE EXCEPTION 'BE-03C SELECT columns are not minimal';
  END IF;
  IF (SELECT count(*) FROM pg_policy policy JOIN pg_class relation ON relation.oid = policy.polrelid
      JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
      WHERE namespace.nspname = 'public' AND policy.polname IN (
        'p_103c_app_user_role_effective_select', 'p_103c_app_role_effective_select',
        'p_103c_app_role_permission_effective_select', 'p_103c_app_permission_effective_select'
      ) AND policy.polcmd = 'r'
        AND policy.polroles = ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'sgi_app_runtime')]) <> 4 THEN
    RAISE EXCEPTION 'BE-03C policy range invariant failed';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy policy
    JOIN pg_class relation ON relation.oid = policy.polrelid
    JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'public' AND relation.relname = 'Affiliate'
      AND policy.polname = 'p_dev03b_app_affiliate_read' AND policy.polcmd = 'r'
      AND policy.polroles = ARRAY[(SELECT oid FROM pg_roles WHERE rolname = 'sgi_app_runtime')]
  ) THEN RAISE EXCEPTION 'DEV-03B Affiliate read policy invariant failed'; END IF;
END $$;

DO $$
BEGIN
  IF current_database() = 'sgi_curime_v2' OR current_database() !~ '^atlas_security_[0-9a-f]{16}$' THEN
    RAISE EXCEPTION 'runner used non-disposable database: %', current_database();
  END IF;
  IF NOT has_database_privilege('postgres', current_database(), 'CONNECT')
     OR NOT has_database_privilege('sgi_auth_validator', current_database(), 'CONNECT')
     OR NOT has_database_privilege('sgi_app_validator', current_database(), 'CONNECT') THEN
    RAISE EXCEPTION 'required disposable database CONNECT grant missing';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM pg_database database_record
    CROSS JOIN LATERAL aclexplode(database_record.datacl) privilege
    WHERE database_record.datname = current_database()
      AND privilege.privilege_type = 'CONNECT'
      AND (
        privilege.grantee = 0
        OR privilege.grantee NOT IN (
          (SELECT oid FROM pg_roles WHERE rolname = 'postgres'),
          (SELECT oid FROM pg_roles WHERE rolname = 'sgi_auth_validator'),
          (SELECT oid FROM pg_roles WHERE rolname = 'sgi_app_validator')
        )
      )
  ) THEN
    RAISE EXCEPTION 'unexpected disposable database CONNECT grantee';
  END IF;
END $$;

\connect - sgi_auth_validator
SELECT test_103d_a.assert_raises('SELECT "id" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."AuditLog" ("action", "module", "userId") VALUES (''x'', ''test'', 1)', '42501');
SELECT test_103d_a.assert_raises('SET ROLE sgi_app_runtime', '42501');
SELECT test_103d_a.assert_raises('SET ROLE sgi_owner', '42501');
SELECT test_103d_a.assert_raises('SET ROLE sgi_migrator', '42501');
SET ROLE sgi_auth_runtime;
DO $$ BEGIN
  IF current_user <> 'sgi_auth_runtime' THEN RAISE EXCEPTION 'auth validator cannot SET ROLE its runtime'; END IF;
END $$;
RESET ROLE;

\connect - sgi_app_validator
SELECT test_103d_a.assert_raises('SELECT "id" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."AuditLog" ("action", "module", "userId") VALUES (''x'', ''test'', 1)', '42501');
SELECT test_103d_a.assert_raises('SET ROLE sgi_auth_runtime', '42501');
SELECT test_103d_a.assert_raises('SET ROLE sgi_owner', '42501');
SELECT test_103d_a.assert_raises('SET ROLE sgi_migrator', '42501');
SET ROLE sgi_app_runtime;
DO $$ BEGIN
  IF current_user <> 'sgi_app_runtime' THEN RAISE EXCEPTION 'app validator cannot SET ROLE its runtime'; END IF;
END $$;
RESET ROLE;

\connect - postgres
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
SELECT test_103d_a.assert_raises('SELECT "code" FROM public."Permission"', '42501');
SELECT test_103d_a.assert_raises('SELECT "roleId" FROM public."UserRole"', '42501');
SELECT test_103d_a.assert_raises('SELECT "id" FROM public."Affiliate"', '42501');
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

SET ROLE sgi_owner;
DO $$ DECLARE row_count integer; permission_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  SELECT count(*) INTO permission_count FROM public."Permission";
  IF row_count <> 0 OR permission_count <> 0 THEN RAISE EXCEPTION 'owner bypassed forced RLS'; END IF;
END $$;
RESET ROLE;

SET ROLE sgi_app_runtime;
DO $$ DECLARE row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'unset app actor GUC exposes User rows'; END IF;
  SELECT count(*) INTO row_count FROM public."Affiliate";
  IF row_count <> 0 THEN RAISE EXCEPTION 'unset app actor GUC exposes Affiliate rows'; END IF;
END $$;
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

\connect - sgi_app_validator
SET ROLE sgi_app_runtime;
DO $$ DECLARE row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'unset actor GUC exposes User rows'; END IF;
END $$;
BEGIN;
SELECT set_config('sgi.actor_user_id', '1', true);
DO $$ DECLARE own_id integer; own_name text; own_email text; own_status "UserStatus"; row_count integer; BEGIN
  SELECT count(*) INTO row_count FROM public."User";
  SELECT "id", "fullName", "email", "status"
    INTO own_id, own_name, own_email, own_status
    FROM public."User";
  IF row_count <> 1 OR own_id <> 1 OR own_name <> 'Ana Example' OR own_email <> 'ana@example.test' OR own_status <> 'ACTIVE' THEN
    RAISE EXCEPTION 'actor 1 cannot read exactly its own permitted User row';
  END IF;
END $$;
SELECT test_103d_a.assert_raises('SELECT "phone" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('SELECT "address" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('SELECT "passwordHash" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('SELECT "personId" FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('SELECT * FROM public."User"', '42501');
SELECT test_103d_a.assert_raises('SELECT "description" FROM public."Role"', '42501');
SELECT test_103d_a.assert_raises('SELECT "name" FROM public."Permission"', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."UserRole" ("userId", "roleId") VALUES (1, 1)', '42501');
SELECT test_103d_a.assert_raises('UPDATE public."Role" SET "isActive" = false WHERE "id" = 1', '42501');
SELECT test_103d_a.assert_raises('DELETE FROM public."RolePermission" WHERE "roleId" = 1', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."Permission" ("code", "name", "updatedAt") VALUES (''no'', ''no'', now())', '42501');
DO $$
DECLARE permission_codes text; role_count integer; role_permission_count integer; user_role_count integer;
BEGIN
  SELECT string_agg(DISTINCT permission."code", ',' ORDER BY permission."code")
    INTO permission_codes
    FROM public."UserRole" user_role
    JOIN public."Role" role ON role."id" = user_role."roleId"
    JOIN public."RolePermission" role_permission ON role_permission."roleId" = role."id"
    JOIN public."Permission" permission ON permission."id" = role_permission."permissionId";
  SELECT count(*) INTO user_role_count FROM public."UserRole";
  SELECT count(*) INTO role_count FROM public."Role";
  SELECT count(*) INTO role_permission_count FROM public."RolePermission";
  IF permission_codes <> 'affiliates.read,test.rbac.a,test.rbac.b,test.rbac.shared'
     OR user_role_count <> 4 OR role_count <> 3 OR role_permission_count <> 5 THEN
    RAISE EXCEPTION 'actor 1 effective permissions, inactive role exclusion, DISTINCT, ordering, or cross-actor isolation failed';
  END IF;
END $$;
DO $$
DECLARE affiliate_count integer; active_name text; affiliate_type text; statuses text;
BEGIN
  SELECT count(*), min("fullName"), max("affiliateType"), string_agg("status"::text, ',' ORDER BY "id")
    INTO affiliate_count, active_name, affiliate_type, statuses
  FROM public."Affiliate";
  IF affiliate_count <> 2 OR active_name <> 'Affiliate Active' OR affiliate_type <> 'REGULAR'
     OR statuses <> 'ACTIVE,INACTIVE' THEN
    RAISE EXCEPTION 'actor 1 cannot read exact DEV-03B Affiliate projection';
  END IF;
END $$;
SELECT test_103d_a.assert_raises('SELECT "identification" FROM public."Affiliate"', '42501');
SELECT test_103d_a.assert_raises('SELECT * FROM public."Affiliate"', '42501');
SELECT test_103d_a.assert_raises('SELECT "id" FROM public."Person"', '42501');
SELECT test_103d_a.assert_raises('INSERT INTO public."Affiliate" ("fullName", "identification", "birthDate", "address", "updatedAt") VALUES (''x'', ''x'', now(), ''x'', now())', '42501');
COMMIT;
DO $$ DECLARE row_count integer; BEGIN
  IF NULLIF(current_setting('sgi.actor_user_id', true), '') IS NOT NULL THEN
    RAISE EXCEPTION 'app actor GUC leaked after self-select transaction';
  END IF;
  SELECT count(*) INTO row_count FROM public."User";
  IF row_count <> 0 THEN RAISE EXCEPTION 'cleared app actor GUC still exposes User rows'; END IF;
END $$;
BEGIN;
SELECT set_config('sgi.actor_user_id', '2', true);
DO $$ DECLARE row_count integer; only_id integer; permission_codes text; affiliate_count integer; BEGIN
  SELECT count(*), min("id") INTO row_count, only_id FROM public."User";
  SELECT string_agg(DISTINCT permission."code", ',' ORDER BY permission."code") INTO permission_codes
  FROM public."UserRole" user_role
  JOIN public."Role" role ON role."id" = user_role."roleId"
  JOIN public."RolePermission" role_permission ON role_permission."roleId" = role."id"
  JOIN public."Permission" permission ON permission."id" = role_permission."permissionId";
  SELECT count(*) INTO affiliate_count FROM public."Affiliate";
  IF row_count <> 1 OR only_id <> 2 OR permission_codes <> 'test.rbac.other' OR affiliate_count <> 0 THEN
    RAISE EXCEPTION 'actor isolation failed: actor 2 reads another User row or permissions';
  END IF;
END $$;
COMMIT;
BEGIN;
SELECT set_config('sgi.actor_user_id', '3', true);
DO $$ DECLARE permission_count integer; BEGIN
  SELECT count(*) INTO permission_count FROM public."Permission";
  IF permission_count <> 0 THEN RAISE EXCEPTION 'active actor without roles has permissions'; END IF;
END $$;
COMMIT;
BEGIN;
SELECT set_config('sgi.actor_user_id', '4', true);
DO $$ DECLARE user_role_count integer; permission_count integer; BEGIN
  SELECT count(*) INTO user_role_count FROM public."UserRole";
  SELECT count(*) INTO permission_count FROM public."Permission";
  IF user_role_count <> 0 OR permission_count <> 0 THEN RAISE EXCEPTION 'inactive actor has RBAC visibility'; END IF;
END $$;
COMMIT;
DO $$ DECLARE actor_value text; row_count integer; BEGIN
  FOREACH actor_value IN ARRAY ARRAY['', 'not-a-number', '-1', '0', '2147483648', repeat('9', 100000)] LOOP
    PERFORM set_config('sgi.actor_user_id', actor_value, true);
    SELECT count(*) INTO row_count FROM public."Permission";
    IF row_count <> 0 THEN RAISE EXCEPTION 'invalid actor GUC exposed RBAC rows: %', left(actor_value, 32); END IF;
    SELECT count(*) INTO row_count FROM public."Affiliate";
    IF row_count <> 0 THEN RAISE EXCEPTION 'invalid actor GUC exposed Affiliate rows: %', left(actor_value, 32); END IF;
  END LOOP;
END $$;
SELECT test_103d_a.assert_raises('SET ROLE sgi_owner', '42501');
DO $$ BEGIN
  IF (SELECT rolbypassrls FROM pg_roles WHERE rolname = current_user) THEN RAISE EXCEPTION 'app runtime bypasses RLS'; END IF;
END $$;
RESET ROLE;

\connect - postgres
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
