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

-- Bootstrap executor retains database/schema administration. sgi_owner owns only these
-- ten relations and their identity sequences; sgi_migrator may SET ROLE sgi_owner for DDL.
ALTER TABLE public."Person" OWNER TO sgi_owner;
ALTER TABLE public."Role" OWNER TO sgi_owner;
ALTER TABLE public."Permission" OWNER TO sgi_owner;
ALTER TABLE public."RolePermission" OWNER TO sgi_owner;
ALTER TABLE public."User" OWNER TO sgi_owner;
ALTER TABLE public."UserRole" OWNER TO sgi_owner;
ALTER TABLE public."Session" OWNER TO sgi_owner;
ALTER TABLE public."AuditLog" OWNER TO sgi_owner;
ALTER TABLE public."PasswordResetToken" OWNER TO sgi_owner;
ALTER TABLE public."AccountActivationToken" OWNER TO sgi_owner;
ALTER TABLE public."Affiliate" OWNER TO sgi_owner;

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
      AND t.relname IN ('Person','Role','Permission','User','Session','AuditLog','PasswordResetToken','AccountActivationToken','Affiliate')
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
ALTER TABLE public."Person" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."Role" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."Permission" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."RolePermission" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."User" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."UserRole" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."Session" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."AuditLog" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."PasswordResetToken" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."AccountActivationToken" FORCE ROW LEVEL SECURITY;
ALTER TABLE public."Affiliate" FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_103d_auth_user_pre_auth_select ON public."User";
CREATE POLICY p_103d_auth_user_pre_auth_select ON public."User"
  FOR SELECT TO sgi_auth_runtime
  USING (current_user = 'sgi_auth_runtime'
         AND NULLIF(current_setting('sgi.actor_user_id', true), '') IS NULL
         AND NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL
         AND ("email" = current_setting('sgi.auth_lookup_identifier', true)
              OR "identification" = current_setting('sgi.auth_lookup_identifier', true)));

DROP POLICY IF EXISTS p_103d_auth_user_pre_auth_lock_update ON public."User";
CREATE POLICY p_103d_auth_user_pre_auth_lock_update ON public."User"
  FOR UPDATE TO sgi_auth_runtime
  USING (current_user = 'sgi_auth_runtime'
         AND NULLIF(current_setting('sgi.actor_user_id', true), '') IS NULL
         AND NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL
         AND ("email" = current_setting('sgi.auth_lookup_identifier', true)
              OR "identification" = current_setting('sgi.auth_lookup_identifier', true)))
  WITH CHECK (current_user = 'sgi_auth_runtime'
              AND NULLIF(current_setting('sgi.actor_user_id', true), '') IS NULL
              AND NULLIF(current_setting('sgi.auth_lookup_identifier', true), '') IS NOT NULL
              AND ("email" = current_setting('sgi.auth_lookup_identifier', true)
                   OR "identification" = current_setting('sgi.auth_lookup_identifier', true)));

-- Auth gets lookup plus only lockout/accounting columns. Token, activation, session and
-- credential mutation lifecycles are intentionally deferred; no grant or policy exists.
GRANT SELECT ("id", "email", "identification", "passwordHash", "status", "failedLoginAttempts", "lockedAt")
  ON public."User" TO sgi_auth_runtime;
GRANT UPDATE ("failedLoginAttempts", "lockedAt", "lastLoginAt", "updatedAt")
  ON public."User" TO sgi_auth_runtime;

-- Application identity reads are deliberately narrower than auth reads. The CASE
-- guards every cast: missing/empty, malformed, non-positive, over-length and
-- int4-overflow GUC values all resolve to false without attempting ::integer.
DROP POLICY IF EXISTS p_103b_app_user_self_select ON public."User";
DROP POLICY IF EXISTS p_103d_app_user_self_select ON public."User";
CREATE POLICY p_103d_app_user_self_select ON public."User"
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND CASE
      WHEN current_setting('sgi.actor_user_id', true) IS NULL THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) NOT BETWEEN 1 AND 10 THEN false
      WHEN current_setting('sgi.actor_user_id', true) !~ '^[1-9][0-9]*$' THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) = 10
           AND current_setting('sgi.actor_user_id', true) > '2147483647' THEN false
      ELSE "id" = current_setting('sgi.actor_user_id', true)::integer
    END
  );

GRANT SELECT ("id", "fullName", "email", "status")
  ON public."User" TO sgi_app_runtime;

-- BE-03C: actor-scoped effective-permission traversal. No policy traverses back
-- to its own table: UserRole -> User; Role -> UserRole -> User;
-- RolePermission -> Role -> UserRole -> User; Permission -> RolePermission.
-- Therefore PostgreSQL never evaluates recursive RLS policies. Role and all
-- downstream links require an active role; UserRole requires an active actor.
DROP POLICY IF EXISTS p_103c_app_user_role_effective_select ON public."UserRole";
CREATE POLICY p_103c_app_user_role_effective_select ON public."UserRole"
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND CASE
      WHEN current_setting('sgi.actor_user_id', true) IS NULL THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) NOT BETWEEN 1 AND 10 THEN false
      WHEN current_setting('sgi.actor_user_id', true) !~ '^[1-9][0-9]*$' THEN false
      WHEN length(current_setting('sgi.actor_user_id', true)) = 10
           AND current_setting('sgi.actor_user_id', true) > '2147483647' THEN false
      ELSE "userId" = current_setting('sgi.actor_user_id', true)::integer
           AND EXISTS (
             SELECT 1 FROM public."User" actor
             WHERE actor."id" = "UserRole"."userId" AND actor."status" = 'ACTIVE'
           )
    END
  );

DROP POLICY IF EXISTS p_103c_app_role_effective_select ON public."Role";
CREATE POLICY p_103c_app_role_effective_select ON public."Role"
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND "isActive"
    AND EXISTS (
      SELECT 1 FROM public."UserRole" user_role
      WHERE user_role."roleId" = "Role"."id"
    )
  );

DROP POLICY IF EXISTS p_103c_app_role_permission_effective_select ON public."RolePermission";
CREATE POLICY p_103c_app_role_permission_effective_select ON public."RolePermission"
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND EXISTS (
      SELECT 1 FROM public."Role" role
      WHERE role."id" = "RolePermission"."roleId"
    )
  );

DROP POLICY IF EXISTS p_103c_app_permission_effective_select ON public."Permission";
CREATE POLICY p_103c_app_permission_effective_select ON public."Permission"
  FOR SELECT TO sgi_app_runtime
  USING (
    current_user = 'sgi_app_runtime'
    AND EXISTS (
      SELECT 1
      FROM public."RolePermission" role_permission
      WHERE role_permission."permissionId" = "Permission"."id"
    )
  );

-- Column grants are sufficient for one actor-scoped relation traversal and no
-- catalogue management or writes. Permission code is authorization output.
GRANT SELECT ("userId", "roleId") ON public."UserRole" TO sgi_app_runtime;
GRANT SELECT ("id", "isActive") ON public."Role" TO sgi_app_runtime;
GRANT SELECT ("roleId", "permissionId") ON public."RolePermission" TO sgi_app_runtime;
GRANT SELECT ("id", "code") ON public."Permission" TO sgi_app_runtime;

-- DEV-03B M1: Affiliate listing is permission-gated. actor_user_id is validated before
-- casting; RBAC is evaluated through existing acyclic actor-scoped policies. No Person
-- privilege is required or granted, and only contract projection columns are selectable.
REVOKE ALL ON public."Affiliate" FROM PUBLIC, sgi_auth_runtime, sgi_app_runtime;
DROP POLICY IF EXISTS p_dev03b_app_affiliate_read ON public."Affiliate";
CREATE POLICY p_dev03b_app_affiliate_read ON public."Affiliate"
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
        FROM public."UserRole" user_role
        JOIN public."Role" role ON role."id" = user_role."roleId"
        JOIN public."RolePermission" role_permission ON role_permission."roleId" = role."id"
        JOIN public."Permission" permission ON permission."id" = role_permission."permissionId"
        -- Keep planner-visible fallback cast safe even when malformed GUC input reaches
        -- this subquery before CASE short-circuits; outer validation remains authority.
        WHERE user_role."userId"::numeric = NULLIF(
          regexp_replace(current_setting('sgi.actor_user_id', true), '[^0-9].*$', ''), ''
        )::numeric
          AND permission."code" = 'affiliates.read'
      )
    END
  );
GRANT SELECT ("id", "fullName", "affiliateType", "affiliationDate", "status")
  ON public."Affiliate" TO sgi_app_runtime;

DROP POLICY IF EXISTS p_103d_app_audit_append ON public."AuditLog";
CREATE POLICY p_103d_app_audit_append ON public."AuditLog"
  FOR INSERT TO sgi_app_runtime
  WITH CHECK (
    current_user = 'sgi_app_runtime'
    AND current_setting('sgi.actor_user_id', true) ~ '^[1-9][0-9]*$'
    AND "userId" = current_setting('sgi.actor_user_id', true)::integer
  );

-- auth_lookup_identifier is transaction-local request input, not a database identity proof.
-- Raw auth DB credentials remain trusted perimeter. Actor GUC is likewise tracing only.
GRANT INSERT ("action", "module", "entityType", "entityId", "details", "ipAddress", "userAgent", "userId")
  ON public."AuditLog" TO sgi_app_runtime;
GRANT USAGE ON SEQUENCE public."AuditLog_id_seq" TO sgi_app_runtime;

COMMIT;
