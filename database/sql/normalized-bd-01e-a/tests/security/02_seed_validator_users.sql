\set ON_ERROR_STOP on

INSERT INTO public.people (first_name, identification, email, updated_at)
VALUES ('Bruno', '1-0001-0002', 'bruno@example.test', now());

INSERT INTO public.users (full_name, identification, email, password_hash, person_id, updated_at)
VALUES ('Bruno Example', '1-0001-0002', 'bruno@example.test', 'test-password-hash', 2, now());
