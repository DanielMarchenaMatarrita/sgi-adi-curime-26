-- Phase 10.3D-A: isolated SQL-first access boundary for initial auth tables.
-- Prerequisites: PostgreSQL 17; canonical migration applied to empty public schema;
-- executor is database superuser or current owner of target relations and has CREATEROLE.
-- Apply after supabase/migrations/20261010000000_sgi_curime_v2_initial.sql.
-- Re-runnable. Does not create LOGIN principals, passwords, SECURITY DEFINER code, or business policies.

BEGIN;

DO $$
DECLARE role_name text;
BEGIN
  FOREACH role_name IN ARRAY ARRAY['sgi_owner', 'sgi_migrator', 'sgi_auth_runtime', 'sgi_app_runtime'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
      EXECUTE format('CREATE ROLE %I NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS INHERIT', role_name);
    END IF;
    EXECUTE format('ALTER ROLE %I NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS INHERIT', role_name);
  END LOOP;
END $$;

-- Only migration operators receive this membership. Provisioned LOGIN principals must
-- be granted sgi_migrator outside this artifact; runtime principals receive exactly one
-- runtime group and never sgi_owner or sgi_migrator.
GRANT sgi_owner TO sgi_migrator;
REVOKE sgi_owner FROM sgi_auth_runtime, sgi_app_runtime;
REVOKE sgi_migrator FROM sgi_auth_runtime, sgi_app_runtime;
REVOKE sgi_auth_runtime FROM sgi_app_runtime;
REVOKE sgi_app_runtime FROM sgi_auth_runtime;

-- Bootstrap executor retains database/schema administration. sgi_owner owns Phase 10.3D-A
-- relations plus M1 Affiliate and their identity sequences; sgi_migrator may SET ROLE sgi_owner for DDL.
ALTER TABLE public.people OWNER TO sgi_owner;
ALTER TABLE public.roles OWNER TO sgi_owner;
ALTER TABLE public.permissions OWNER TO sgi_owner;
ALTER TABLE public.role_permissions OWNER TO sgi_owner;
ALTER TABLE public.users OWNER TO sgi_owner;
ALTER TABLE public.user_roles OWNER TO sgi_owner;
ALTER TABLE public.sessions OWNER TO sgi_owner;
ALTER TABLE public.audit_logs OWNER TO sgi_owner;
ALTER TABLE public.password_reset_tokens OWNER TO sgi_owner;
ALTER TABLE public.account_activation_tokens OWNER TO sgi_owner;
ALTER TABLE public.affiliates OWNER TO sgi_owner;

DO $$
DECLARE seq record;
BEGIN
  FOR seq IN
    SELECT n.nspname, c.relname
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_depend d ON d.objid = c.oid AND d.deptype IN ('a', 'i')
    JOIN pg_class t ON t.oid = d.refobjid
    JOIN pg_namespace tn ON tn.oid = t.relnamespace
    WHERE c.relkind = 'S' AND tn.nspname = 'public'
      AND t.relname IN ('people','roles','permissions','users','sessions','audit_logs','password_reset_tokens','account_activation_tokens','affiliates')
  LOOP
    EXECUTE format('ALTER SEQUENCE %I.%I OWNER TO sgi_owner', seq.nspname, seq.relname);
  END LOOP;
END $$;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, sgi_auth_runtime, sgi_app_runtime;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, sgi_auth_runtime, sgi_app_runtime;
GRANT USAGE ON SCHEMA public TO sgi_owner, sgi_migrator, sgi_auth_runtime, sgi_app_runtime;
GRANT CREATE ON SCHEMA public TO sgi_owner;

-- Defaults protect objects later created by sgi_owner. Explicit grants remain required.
ALTER DEFAULT PRIVILEGES FOR ROLE sgi_owner IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE sgi_owner IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;

-- Canonical migration enables RLS on all public tables. Force only Phase 10.3D-A tables:
-- other canonical tables stay enabled/no-policy and receive no runtime grants until their modules define policies.
ALTER TABLE public.people FORCE ROW LEVEL SECURITY;
ALTER TABLE public.roles FORCE ROW LEVEL SECURITY;
ALTER TABLE public.permissions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.users FORCE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles FORCE ROW LEVEL SECURITY;
ALTER TABLE public.sessions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs FORCE ROW LEVEL SECURITY;
ALTER TABLE public.password_reset_tokens FORCE ROW LEVEL SECURITY;
ALTER TABLE public.account_activation_tokens FORCE ROW LEVEL SECURITY;
ALTER TABLE public.affiliates FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pol_users_select_auth_user_pre_auth_select ON public.users;
CREATE POLICY pol_users_select_auth_user_pre_auth_select ON public.users
  FOR SELECT TO sgi_auth_runtime
  USING (current_user = 'sgi_auth_runtime'
         AND NULLIF(current_setting('sgi.actor_user_id', true), '') IS NULL
         AND NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL
         AND (email = current_setting('sgi.auth_lookup_identifier', true)
              OR identification = current_setting('sgi.auth_lookup_identifier', true)));

DROP POLICY IF EXISTS pol_users_update ON public.users;
CREATE POLICY pol_users_update ON public.users
  FOR UPDATE TO sgi_auth_runtime
  USING (current_user = 'sgi_auth_runtime'
         AND NULLIF(current_setting('sgi.actor_user_id', true), '') IS NULL
         AND NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL
         AND (email = current_setting('sgi.auth_lookup_identifier', true)
              OR identification = current_setting('sgi.auth_lookup_identifier', true)))
  WITH CHECK (current_user = 'sgi_auth_runtime'
              AND NULLIF(current_setting('sgi.actor_user_id', true), '') IS NULL
              AND NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL
              AND (email = current_setting('sgi.auth_lookup_identifier', true)
                   OR identification = current_setting('sgi.auth_lookup_identifier', true)));

-- Auth gets lookup plus only lockout/accounting columns. Token, activation, session and
-- credential mutation lifecycles are intentionally deferred; no grant or policy exists.
GRANT SELECT (id, email, identification, password_hash, status, failed_login_attempts, locked_at)
  ON public.users TO sgi_auth_runtime;
GRANT UPDATE (failed_login_attempts, locked_at, last_login_at, updated_at)
  ON public.users TO sgi_auth_runtime;

-- Application identity reads are deliberately narrower than auth reads. The CASE
-- guards every cast: missing/empty, malformed, non-positive, over-length and
-- int4-overflow GUC values all resolve to false without attempting ::integer.
DROP POLICY IF EXISTS p_103b_app_user_self_select ON public.users;
DROP POLICY IF EXISTS pol_users_select_app_user_self_select ON public.users;
CREATE POLICY pol_users_select_app_user_self_select ON public.users
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND CASE
      WHEN current_setting('sgi.actor_user_id', true) IS NULL THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) NOT BETWEEN 1 AND 10 THEN false
      WHEN current_setting('sgi.actor_user_id', true) !~ '^[1-9][0-9]*$' THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) = 10
           AND current_setting('sgi.actor_user_id', true) > '2147483647' THEN false
      ELSE id = current_setting('sgi.actor_user_id', true)::integer
    END
  );

GRANT SELECT (id, full_name, email, status)
  ON public.users TO sgi_app_runtime;

-- BE-03C: actor-scoped effective-permission traversal. No policy traverses back
-- to its own table: UserRole -> User; Role -> UserRole -> User;
-- RolePermission -> Role -> UserRole -> User; Permission -> RolePermission.
-- Therefore PostgreSQL never evaluates recursive RLS policies. Role and all
-- downstream links require an active role; UserRole requires an active actor.
DROP POLICY IF EXISTS pol_user_roles_select ON public.user_roles;
CREATE POLICY pol_user_roles_select ON public.user_roles
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND CASE
      WHEN current_setting('sgi.actor_user_id', true) IS NULL THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) NOT BETWEEN 1 AND 10 THEN false
      WHEN current_setting('sgi.actor_user_id', true) !~ '^[1-9][0-9]*$' THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) = 10
           AND current_setting('sgi.actor_user_id', true) > '2147483647' THEN false
      ELSE user_id = current_setting('sgi.actor_user_id', true)::integer
           AND EXISTS (
             SELECT 1 FROM public.users actor
             WHERE actor.id = user_roles.user_id AND actor.status = 'ACTIVE'
           )
    END
  );

DROP POLICY IF EXISTS pol_roles_select ON public.roles;
CREATE POLICY pol_roles_select ON public.roles
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND is_active
    AND EXISTS (
      SELECT 1 FROM public.user_roles user_role
      WHERE user_role.role_id = roles.id
    )
  );

DROP POLICY IF EXISTS pol_role_permissions_select ON public.role_permissions;
CREATE POLICY pol_role_permissions_select ON public.role_permissions
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND EXISTS (
      SELECT 1 FROM public.roles role
      WHERE role.id = role_permissions.role_id
    )
  );

DROP POLICY IF EXISTS pol_permissions_select ON public.permissions;
CREATE POLICY pol_permissions_select ON public.permissions
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND EXISTS (
      SELECT 1
      FROM public.role_permissions role_permission
      WHERE role_permission.permission_id = permissions.id
    )
  );

-- Column grants are sufficient for one actor-scoped relation traversal and no
-- catalogue management or writes. Permission code is authorization output.
GRANT SELECT (user_id, role_id) ON public.user_roles TO sgi_app_runtime;
GRANT SELECT (id, is_active) ON public.roles TO sgi_app_runtime;
GRANT SELECT (role_id, permission_id) ON public.role_permissions TO sgi_app_runtime;
GRANT SELECT (id, code) ON public.permissions TO sgi_app_runtime;

-- DEV-03B M1: Affiliate listing is permission-gated. actor_user_id is validated before
-- casting; RBAC is evaluated through existing acyclic actor-scoped policies. No Person
-- privilege is required or granted, and only contract projection columns are selectable.
REVOKE ALL ON public.affiliates FROM PUBLIC, sgi_auth_runtime, sgi_app_runtime;
DROP POLICY IF EXISTS pol_affiliates_select ON public.affiliates;
CREATE POLICY pol_affiliates_select ON public.affiliates
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND CASE
      WHEN current_setting('sgi.actor_user_id', true) IS NULL THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) NOT BETWEEN 1 AND 10 THEN false
      WHEN current_setting('sgi.actor_user_id', true) !~ '^[1-9][0-9]*$' THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) = 10
           AND current_setting('sgi.actor_user_id', true) > '2147483647' THEN false
      ELSE EXISTS (
        SELECT 1
        FROM public.user_roles user_role
        JOIN public.roles role ON role.id = user_role.role_id
        JOIN public.role_permissions role_permission ON role_permission.role_id = role.id
        JOIN public.permissions permission ON permission.id = role_permission.permission_id
        -- Keep planner-visible fallback cast safe even when malformed GUC input reaches
        -- this subquery before CASE short-circuits; outer validation remains authority.
        WHERE user_role.user_id::numeric = NULLIF(
          regexp_replace(current_setting('sgi.actor_user_id', true), '[^0-9].*$', ''), ''
        )::numeric
          AND permission.code = 'affiliates.read'
      )
    END
  );
GRANT SELECT (id, full_name, affiliate_type, affiliation_date, status)
  ON public.affiliates TO sgi_app_runtime;

DROP POLICY IF EXISTS pol_audit_logs_insert ON public.audit_logs;
CREATE POLICY pol_audit_logs_insert ON public.audit_logs
  FOR INSERT TO sgi_app_runtime
  WITH CHECK (
    current_user = 'sgi_app_runtime'
    AND current_setting('sgi.actor_user_id', true) ~ '^[1-9][0-9]*$'
    AND user_id = current_setting('sgi.actor_user_id', true)::integer
  );

-- auth_lookup_identifier is transaction-local request input, not a database identity proof.
-- Raw auth DB credentials remain trusted perimeter. Actor GUC is likewise tracing only.
GRANT INSERT (action, module, entity_type, entity_id, details, ip_address, user_agent, user_id)
  ON public.audit_logs TO sgi_app_runtime;
GRANT USAGE ON SEQUENCE public.seq_audit_logs_id TO sgi_app_runtime;

COMMIT;
