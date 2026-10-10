\set ON_ERROR_STOP on

INSERT INTO public."Person" ("firstName", "identification", "email", "updatedAt")
VALUES ('Bruno', '1-0001-0002', 'bruno@example.test', now());

INSERT INTO public."User" ("fullName", "identification", "email", "passwordHash", "personId", "updatedAt")
VALUES ('Bruno Example', '1-0001-0002', 'bruno@example.test', 'test-password-hash', 2, now());
