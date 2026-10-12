\set ON_ERROR_STOP on

DO $$
BEGIN
  IF current_database() = 'sgi_curime_v2' OR current_database() !~ '^atlas_security_[0-9a-f]{16}$' THEN
    RAISE EXCEPTION 'validator fixture requires generated disposable database, got %', current_database();
  END IF;
END $$;

DO $$
DECLARE
  role_name text;
  member_name text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgi_auth_validator') THEN
    CREATE ROLE sgi_auth_validator LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgi_app_validator') THEN
    CREATE ROLE sgi_app_validator LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
  ALTER ROLE sgi_auth_validator LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  ALTER ROLE sgi_app_validator LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;

  -- Test principals have exactly one direct runtime membership. Remove any prior direct
  -- membership before granting its explicitly non-inherited, SET ROLE-enabled replacement.
  FOR role_name, member_name IN
    SELECT granted_role.rolname, member_role.rolname
    FROM pg_auth_members membership
    JOIN pg_roles granted_role ON granted_role.oid = membership.roleid
    JOIN pg_roles member_role ON member_role.oid = membership.member
    WHERE member_role.rolname IN ('sgi_auth_validator', 'sgi_app_validator')
  LOOP
    EXECUTE format('REVOKE %I FROM %I', role_name, member_name);
  END LOOP;
END $$;

GRANT sgi_auth_runtime TO sgi_auth_validator WITH INHERIT FALSE, SET TRUE;
GRANT sgi_app_runtime TO sgi_app_validator WITH INHERIT FALSE, SET TRUE;

DO $$
BEGIN
  EXECUTE format('REVOKE CONNECT ON DATABASE %I FROM PUBLIC', current_database());
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO postgres, sgi_auth_validator, sgi_app_validator', current_database());
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgi_auth_validator' AND rolcanlogin AND NOT rolinherit AND NOT rolsuper AND NOT rolcreatedb AND NOT rolcreaterole AND NOT rolreplication AND NOT rolbypassrls) THEN
    RAISE EXCEPTION 'auth validator privilege invariant failed';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgi_app_validator' AND rolcanlogin AND NOT rolinherit AND NOT rolsuper AND NOT rolcreatedb AND NOT rolcreaterole AND NOT rolreplication AND NOT rolbypassrls) THEN
    RAISE EXCEPTION 'app validator privilege invariant failed';
  END IF;
  IF (SELECT count(*) FROM pg_auth_members membership JOIN pg_roles member_role ON member_role.oid = membership.member WHERE member_role.rolname = 'sgi_auth_validator') <> 1
     OR (SELECT count(*) FROM pg_auth_members membership JOIN pg_roles member_role ON member_role.oid = membership.member WHERE member_role.rolname = 'sgi_app_validator') <> 1
     OR NOT EXISTS (
       SELECT 1 FROM pg_auth_members membership
       JOIN pg_roles member_role ON member_role.oid = membership.member
       JOIN pg_roles granted_role ON granted_role.oid = membership.roleid
       WHERE member_role.rolname = 'sgi_auth_validator' AND granted_role.rolname = 'sgi_auth_runtime'
         AND NOT membership.admin_option AND NOT membership.inherit_option AND membership.set_option
     )
     OR NOT EXISTS (
       SELECT 1 FROM pg_auth_members membership
       JOIN pg_roles member_role ON member_role.oid = membership.member
       JOIN pg_roles granted_role ON granted_role.oid = membership.roleid
       WHERE member_role.rolname = 'sgi_app_validator' AND granted_role.rolname = 'sgi_app_runtime'
         AND NOT membership.admin_option AND NOT membership.inherit_option AND membership.set_option
     ) THEN
    RAISE EXCEPTION 'validator exact runtime membership invariant failed';
  END IF;
END $$;
