\set ON_ERROR_STOP on

-- Disposable BE-03C fixtures only. Not an institutional permission catalogue.
INSERT INTO public."Role" ("name", "description", "isActive", "updatedAt")
VALUES
  ('TEST_RBAC_A', 'BE-03C disposable fixture', true, now()),
  ('TEST_RBAC_B', 'BE-03C disposable fixture', true, now()),
  ('TEST_RBAC_INACTIVE', 'BE-03C disposable fixture', false, now()),
  ('TEST_RBAC_OTHER', 'BE-03C disposable fixture', true, now());

INSERT INTO public."Permission" ("code", "name", "description", "updatedAt")
VALUES
  ('test.rbac.a', 'BE-03C A', 'Disposable fixture', now()),
  ('test.rbac.shared', 'BE-03C shared', 'Disposable fixture', now()),
  ('test.rbac.b', 'BE-03C B', 'Disposable fixture', now()),
  ('test.rbac.inactive', 'BE-03C inactive', 'Disposable fixture', now()),
  ('test.rbac.other', 'BE-03C other', 'Disposable fixture', now());

INSERT INTO public."UserRole" ("userId", "roleId")
SELECT 1, role."id" FROM public."Role" role
WHERE role."name" IN ('TEST_RBAC_A', 'TEST_RBAC_B', 'TEST_RBAC_INACTIVE');

INSERT INTO public."UserRole" ("userId", "roleId")
SELECT 2, role."id" FROM public."Role" role
WHERE role."name" = 'TEST_RBAC_OTHER';

-- User 4 is INACTIVE (05 fixture): it intentionally has a role but no effective permissions.
INSERT INTO public."UserRole" ("userId", "roleId")
SELECT 4, role."id" FROM public."Role" role
WHERE role."name" = 'TEST_RBAC_A';

INSERT INTO public."RolePermission" ("roleId", "permissionId")
SELECT role."id", permission."id"
FROM public."Role" role
JOIN public."Permission" permission ON (role."name", permission."code") IN (
  ('TEST_RBAC_A', 'test.rbac.a'),
  ('TEST_RBAC_A', 'test.rbac.shared'),
  ('TEST_RBAC_B', 'test.rbac.b'),
  ('TEST_RBAC_B', 'test.rbac.shared'),
  ('TEST_RBAC_INACTIVE', 'test.rbac.inactive'),
  ('TEST_RBAC_OTHER', 'test.rbac.other')
);
