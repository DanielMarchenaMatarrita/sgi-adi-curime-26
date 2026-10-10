-- Disposable DB smoke tests. Every test insert rolls back at the end.
BEGIN;
DO $$
DECLARE person_id integer; venture_id integer; request_id integer; revision_id integer;
        resource_id integer; blocked boolean;
BEGIN
 -- Person -> User one-to-one identity, 1 user may hold N roles but no other user can reuse person.
 INSERT INTO public."Person"("firstName","updatedAt") VALUES('DDL smoke',now()) RETURNING id INTO person_id;
 INSERT INTO public."User"("fullName","identification","email","personId","updatedAt")
 VALUES('DDL smoke','smoke-identity-1','smoke-1@invalid.example',person_id,now());
 blocked:=false;
 BEGIN
  INSERT INTO public."User"("fullName","identification","email","personId","updatedAt")
  VALUES('DDL smoke second','smoke-identity-2','smoke-2@invalid.example',person_id,now());
 EXCEPTION WHEN unique_violation THEN blocked:=true;
 END;
 IF NOT blocked THEN RAISE EXCEPTION 'FAILED User.personId UNIQUE smoke'; END IF;

 -- Publication without approved revision must be denied.
 blocked:=false;
 BEGIN
  INSERT INTO public."Venture"("name","incorporatedAt","updatedAt","publicationStatus")
  VALUES('Smoke rejected publication',now(),now(),'PUBLISHED');
 EXCEPTION WHEN check_violation THEN blocked:=true;
 END;
 IF NOT blocked THEN RAISE EXCEPTION 'FAILED venture approval guard smoke'; END IF;

 -- Revisions are append-only.
 INSERT INTO public."Venture"("name","incorporatedAt","updatedAt")
 VALUES('Smoke venture',now(),now()) RETURNING id INTO venture_id;
 INSERT INTO public."VentureRequest"("purpose","ventureId","updatedAt")
 VALUES('REGISTRATION',venture_id,now()) RETURNING id INTO request_id;
 INSERT INTO public."VentureRequestRevision"("requestId","revisionNumber","payloadVersion","submittedData")
 VALUES(request_id,1,1,'{"title":"smoke"}'::jsonb) RETURNING id INTO revision_id;
 blocked:=false;
 BEGIN
  UPDATE public."VentureRequestRevision" SET "submittedData"='{"title":"mutated"}' WHERE id=revision_id;
 EXCEPTION WHEN check_violation THEN blocked:=true;
 END;
 IF NOT blocked THEN RAISE EXCEPTION 'FAILED revision immutability smoke'; END IF;

 -- Exclusion constraint prevents two active overlapping unavailable time windows.
 INSERT INTO public."ReservableResource"("name","updatedAt") VALUES('Smoke resource',now()) RETURNING id INTO resource_id;
 INSERT INTO public.resource_unavailability(reservable_resource_id,starts_at,ends_at,reason)
 VALUES(resource_id, '2026-10-10 10:00','2026-10-10 13:00','smoke 1');
 blocked:=false;
 BEGIN
  INSERT INTO public.resource_unavailability(reservable_resource_id,starts_at,ends_at,reason)
  VALUES(resource_id,'2026-10-10 12:00','2026-10-10 15:00','smoke 2');
 EXCEPTION WHEN exclusion_violation THEN blocked:=true;
 END;
 IF NOT blocked THEN RAISE EXCEPTION 'FAILED GiST exclusion smoke'; END IF;
 RAISE NOTICE 'SGI V2 data-level smoke PASS: identity, publication, immutability, exclusion';
END $$;
ROLLBACK;
