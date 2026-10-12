\set ON_ERROR_STOP on

-- Disposable DEV-03B M1 fixture only. No institutional role receives affiliates.read.
INSERT INTO public."Role" ("name", "description", "isActive", "updatedAt")
VALUES ('TEST_AFFILIATES_READ', 'DEV-03B M1 disposable fixture', true, now());

INSERT INTO public."Permission" ("code", "name", "description", "updatedAt")
VALUES ('affiliates.read', 'DEV-03B M1 fixture permission', 'Disposable fixture', now());

INSERT INTO public."UserRole" ("userId", "roleId")
SELECT 1, "id" FROM public."Role" WHERE "name" = 'TEST_AFFILIATES_READ';

INSERT INTO public."RolePermission" ("roleId", "permissionId")
SELECT role."id", permission."id"
FROM public."Role" role
JOIN public."Permission" permission ON permission."code" = 'affiliates.read'
WHERE role."name" = 'TEST_AFFILIATES_READ';

INSERT INTO public."Affiliate" ("fullName", "identification", "birthDate", "address", "affiliateType", "affiliationDate", "status", "updatedAt")
VALUES
  ('Affiliate Active', '8-0001-0001', '1990-01-01 00:00:00', 'Fixture address', 'REGULAR', '2020-01-01 00:00:00', 'ACTIVE', now()),
  ('Affiliate Inactive', '8-0001-0002', '1991-01-01 00:00:00', 'Fixture address', null, '2021-01-01 00:00:00', 'INACTIVE', now());
