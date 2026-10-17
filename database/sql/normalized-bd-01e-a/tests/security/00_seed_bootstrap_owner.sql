-- Test fixture only. Run after canonical migration and before forced-RLS security artifact.
-- postgres is canonical bootstrap owner here; this is not a production runtime backdoor.
\set ON_ERROR_STOP on

INSERT INTO public.people (first_name, identification, email, updated_at)
VALUES ('Ana', '1-0001-0001', 'ana@example.test', now());

INSERT INTO public.users (full_name, identification, email, password_hash, person_id, updated_at)
VALUES ('Ana Example', '1-0001-0001', 'ana@example.test', 'test-password-hash', 1, now());
