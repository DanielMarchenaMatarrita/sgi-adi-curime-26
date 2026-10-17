\set ON_ERROR_STOP on

-- Disposable DEV-03B M1 fixture only. No institutional role receives affiliates.read.
INSERT INTO public.roles (name, description, is_active, updated_at)
VALUES ('TEST_AFFILIATES_READ', 'DEV-03B M1 disposable fixture', true, now());

INSERT INTO public.permissions (code, name, description, updated_at)
VALUES ('affiliates.read', 'DEV-03B M1 fixture permission', 'Disposable fixture', now());

INSERT INTO public.user_roles (user_id, role_id)
SELECT 1, id FROM public.roles WHERE name = 'TEST_AFFILIATES_READ';

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM public.roles role
JOIN public.permissions permission ON permission.code = 'affiliates.read'
WHERE role.name = 'TEST_AFFILIATES_READ';

INSERT INTO public.affiliates (full_name, identification, birth_date, address, affiliate_type, affiliation_date, status, updated_at)
VALUES
  ('Affiliate Active', '8-0001-0001', '1990-01-01 00:00:00', 'Fixture address', 'REGULAR', '2020-01-01 00:00:00', 'ACTIVE', now()),
  ('Affiliate Inactive', '8-0001-0002', '1991-01-01 00:00:00', 'Fixture address', null, '2021-01-01 00:00:00', 'INACTIVE', now());
