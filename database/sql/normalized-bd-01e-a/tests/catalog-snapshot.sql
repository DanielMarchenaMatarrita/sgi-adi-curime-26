\set ON_ERROR_STOP on
\pset tuples_only on
\pset format unaligned

WITH
relations AS (
  SELECT n.nspname AS schema_name, c.relname AS object_name, c.relkind,
         pg_get_userbyid(c.relowner) AS owner_name, c.relrowsecurity, c.relforcerowsecurity,
         COALESCE((SELECT jsonb_agg(a::text ORDER BY a::text) FROM unnest(c.relacl) a), '[]'::jsonb) AS acl
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND c.relkind IN ('r','S','v')
), columns AS (
  SELECT n.nspname AS schema_name, c.relname AS table_name, a.attnum AS ordinal_position,
         a.attname AS column_name, format_type(a.atttypid,a.atttypmod) AS data_type,
         a.attnotnull AS not_null, a.attidentity AS identity_kind, a.attgenerated AS generated_kind,
         pg_get_expr(d.adbin,d.adrelid,true) AS default_expression,
         CASE WHEN a.attcollation=0 THEN NULL ELSE coll.collname END AS collation_name
  FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid JOIN pg_namespace n ON n.oid=c.relnamespace
  LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
  LEFT JOIN pg_collation coll ON coll.oid=a.attcollation
  WHERE n.nspname='public' AND c.relkind='r' AND a.attnum>0 AND NOT a.attisdropped
), constraints AS (
  SELECT n.nspname AS schema_name, r.relname AS table_name, c.conname AS constraint_name,
         c.contype, c.condeferrable, c.condeferred, c.convalidated,
         pg_get_constraintdef(c.oid,true) AS definition
  FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
  LEFT JOIN pg_class r ON r.oid=c.conrelid
  WHERE n.nspname='public' AND c.contype IN ('p','u','f','c','x')
), indexes AS (
  SELECT n.nspname AS schema_name, t.relname AS table_name, i.relname AS index_name,
         x.indisunique, x.indisprimary, x.indisvalid, x.indisready,
         pg_get_indexdef(i.oid) AS definition
  FROM pg_index x JOIN pg_class i ON i.oid=x.indexrelid JOIN pg_class t ON t.oid=x.indrelid
  JOIN pg_namespace n ON n.oid=i.relnamespace WHERE n.nspname='public'
), triggers AS (
  SELECT n.nspname AS schema_name, c.relname AS table_name, t.tgname AS trigger_name,
         t.tgenabled, t.tgdeferrable, t.tginitdeferred, t.tgconstraint<>0 AS is_constraint,
         pg_get_triggerdef(t.oid,true) AS definition
  FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND NOT t.tgisinternal
), policies AS (
  SELECT n.nspname AS schema_name, c.relname AS table_name, p.polname AS policy_name,
         p.polcmd, p.polpermissive,
         COALESCE((SELECT jsonb_agg(r.rolname ORDER BY r.rolname) FROM unnest(p.polroles) role_oid JOIN pg_roles r ON r.oid=role_oid), '[]'::jsonb) AS roles,
         pg_get_expr(p.polqual,p.polrelid,true) AS using_expression,
         pg_get_expr(p.polwithcheck,p.polrelid,true) AS check_expression
  FROM pg_policy p JOIN pg_class c ON c.oid=p.polrelid JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public'
), enum_values AS (
  SELECT n.nspname AS schema_name, t.typname AS enum_name, e.enumsortorder, e.enumlabel
  FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace JOIN pg_enum e ON e.enumtypid=t.oid
  WHERE n.nspname='public'
), routines AS (
  SELECT n.nspname AS schema_name, p.proname AS routine_name,
         pg_get_function_identity_arguments(p.oid) AS identity_arguments,
         p.prokind, p.prosecdef, p.provolatile, pg_get_userbyid(p.proowner) AS owner_name,
         pg_get_functiondef(p.oid) AS definition,
         COALESCE((SELECT jsonb_agg(a::text ORDER BY a::text) FROM unnest(p.proacl) a), '[]'::jsonb) AS acl
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE n.nspname='public' AND NOT EXISTS (
    SELECT 1 FROM pg_depend d JOIN pg_extension e ON e.oid=d.refobjid
    WHERE d.classid='pg_proc'::regclass AND d.objid=p.oid AND d.deptype='e'
  )
), extensions AS (
  SELECT e.extname, e.extversion, n.nspname AS schema_name
  FROM pg_extension e JOIN pg_namespace n ON n.oid=e.extnamespace
  WHERE e.extname IN ('plpgsql','btree_gist')
), roles AS (
  SELECT rolname, rolcanlogin, rolinherit, rolsuper, rolcreatedb, rolcreaterole, rolreplication, rolbypassrls
  FROM pg_roles WHERE rolname LIKE 'sgi\_%' ESCAPE '\'
), memberships AS (
  SELECT member.rolname AS member_name, granted.rolname AS granted_role,
         m.admin_option, m.inherit_option, m.set_option
  FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles granted ON granted.oid=m.roleid
  WHERE member.rolname LIKE 'sgi\_%' ESCAPE '\' OR granted.rolname LIKE 'sgi\_%' ESCAPE '\'
)
SELECT jsonb_build_object(
  'extensions', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY extname) FROM extensions x),'[]'::jsonb),
  'relations', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,object_name) FROM relations x),'[]'::jsonb),
  'columns', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,table_name,ordinal_position) FROM columns x),'[]'::jsonb),
  'constraints', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,table_name,constraint_name) FROM constraints x),'[]'::jsonb),
  'indexes', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,table_name,index_name) FROM indexes x),'[]'::jsonb),
  'triggers', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,table_name,trigger_name) FROM triggers x),'[]'::jsonb),
  'policies', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,table_name,policy_name) FROM policies x),'[]'::jsonb),
  'enum_values', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,enum_name,enumsortorder) FROM enum_values x),'[]'::jsonb),
  'routines', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY schema_name,routine_name,identity_arguments) FROM routines x),'[]'::jsonb),
  'roles', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY rolname) FROM roles x),'[]'::jsonb),
  'memberships', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY member_name,granted_role) FROM memberships x),'[]'::jsonb)
)::text;
