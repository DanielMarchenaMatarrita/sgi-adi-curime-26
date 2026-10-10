-- Test fixture only. Run after canonical migration and before forced-RLS security artifact.
-- postgres is canonical bootstrap owner here; this is not a production runtime backdoor.
INSERT INTO public."Person" ("firstName", "identification", "email", "updatedAt")
VALUES ('Ana', '1-0001-0001', 'ana@example.test', now());

INSERT INTO public."User" ("fullName", "identification", "email", "passwordHash", "personId", "updatedAt")
VALUES ('Ana Example', '1-0001-0001', 'ana@example.test', 'test-password-hash', 1, now());
