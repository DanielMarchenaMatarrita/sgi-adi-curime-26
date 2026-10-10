-- Venture approval workflow. It reuses immutable VentureRequestRevision snapshots.
-- No grant is inferred from VentureAssociation.

-- A reviewer delegation must point to their own institutional appointment.
CREATE OR REPLACE FUNCTION public.sgi_reviewer_authorization_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE holder_person integer; appointment_person integer;
BEGIN
 SELECT "personId" INTO holder_person FROM public."User" WHERE id=NEW."userId";
 SELECT "personId" INTO appointment_person FROM public."BoardAppointment" WHERE id=NEW."membershipId";
 IF holder_person IS NULL OR appointment_person IS NULL OR holder_person<>appointment_person THEN
  RAISE EXCEPTION 'Reviewer authorization requires matching user and board appointment person' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_reviewer_authorization_check BEFORE INSERT OR UPDATE OF "userId","membershipId"
ON public."VentureReviewerAuthorization" FOR EACH ROW EXECUTE FUNCTION public.sgi_reviewer_authorization_check();

-- Grants may be issued only by the User who actually holds the referenced appointment.
CREATE OR REPLACE FUNCTION public.sgi_manager_authorization_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE grantor_person integer; appointment_person integer;
BEGIN
 SELECT "personId" INTO grantor_person FROM public."User" WHERE id=NEW."grantedByUserId";
 SELECT "personId" INTO appointment_person FROM public."BoardAppointment" WHERE id=NEW."grantedByMembershipId";
 IF grantor_person IS NULL OR appointment_person IS NULL OR grantor_person<>appointment_person THEN
  RAISE EXCEPTION 'Venture management grant issuer does not hold the referenced appointment' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_manager_authorization_check BEFORE INSERT OR UPDATE OF "grantedByUserId","grantedByMembershipId"
ON public."VentureManagerAuthorization" FOR EACH ROW EXECUTE FUNCTION public.sgi_manager_authorization_check();

-- A review decision requires a matching, live delegation and a current Board appointment.
CREATE OR REPLACE FUNCTION public.sgi_venture_decision_validate() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE grant_rec public."VentureReviewerAuthorization"%ROWTYPE;
        person_id integer; member_person integer; member_start timestamp; member_end timestamp;
        term_status text; term_start timestamp; term_end timestamp;
        req_venture integer; decision_time timestamp;
BEGIN
 SELECT * INTO grant_rec FROM public."VentureReviewerAuthorization" WHERE id=NEW."reviewerAuthorizationId" FOR SHARE;
 IF NOT FOUND OR grant_rec."userId"<>NEW."reviewerUserId" OR grant_rec."membershipId"<>NEW."reviewerMembershipId" THEN
  RAISE EXCEPTION 'Review decision has no matching reviewer grant' USING ERRCODE='23514';
 END IF;
 IF grant_rec."revokedAt" IS NOT NULL OR NEW."decidedAt" < grant_rec."validFrom" OR
    (grant_rec."validUntil" IS NOT NULL AND NEW."decidedAt" >= grant_rec."validUntil") THEN
  RAISE EXCEPTION 'Reviewer authorization is not active at decision time' USING ERRCODE='23514';
 END IF;
 decision_time := NEW."decidedAt" AT TIME ZONE 'UTC';
 SELECT u."personId" INTO person_id FROM public."User" u WHERE u.id=NEW."reviewerUserId";
 SELECT a."personId",a."startsOn",a."endsOn",t.status::text,t."startsOn",t."endsOn"
 INTO member_person,member_start,member_end,term_status,term_start,term_end
 FROM public."BoardAppointment" a JOIN public."BoardTerm" t ON t.id=a."boardTermId"
 WHERE a.id=NEW."reviewerMembershipId";
 IF person_id IS NULL OR person_id IS DISTINCT FROM member_person OR
    member_start IS NULL OR term_start IS NULL OR term_end IS NULL OR
    decision_time < member_start OR (member_end IS NOT NULL AND decision_time > member_end) OR
    decision_time < term_start OR decision_time > term_end OR term_status IS DISTINCT FROM 'ACTIVE' THEN
  RAISE EXCEPTION 'Reviewer does not have a competent active appointment' USING ERRCODE='23514';
 END IF;
 IF NEW."revisionId" IS NOT NULL THEN
  SELECT vr."ventureId" INTO req_venture FROM public."VentureRequestRevision" rev
  JOIN public."VentureRequest" vr ON vr.id=rev."requestId" WHERE rev.id=NEW."revisionId";
  IF req_venture IS DISTINCT FROM NEW."ventureId" THEN
   RAISE EXCEPTION 'Reviewed revision does not belong to venture' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_venture_decision_validate BEFORE INSERT ON public."VentureReviewDecision"
FOR EACH ROW EXECUTE FUNCTION public.sgi_venture_decision_validate();

-- A published venture must point to its own APPROVED revision; latest pending version is not public.
CREATE OR REPLACE FUNCTION public.sgi_published_revision_validate() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE req_venture integer; approved boolean;
BEGIN
 IF NEW."publicationStatus"='PUBLISHED' THEN
  IF NEW.status<>'ACTIVE' OR NEW."publishedRequestRevisionId" IS NULL THEN
   RAISE EXCEPTION 'Published venture requires ACTIVE status and a published revision' USING ERRCODE='23514';
  END IF;
  SELECT vr."ventureId" INTO req_venture
  FROM public."VentureRequestRevision" rev JOIN public."VentureRequest" vr ON vr.id=rev."requestId"
  WHERE rev.id=NEW."publishedRequestRevisionId";
  IF req_venture IS DISTINCT FROM NEW.id THEN
   RAISE EXCEPTION 'Published revision does not belong to venture' USING ERRCODE='23514';
  END IF;
  SELECT EXISTS(SELECT 1 FROM public."VentureReviewDecision" d
    WHERE d."ventureId"=NEW.id AND d."revisionId"=NEW."publishedRequestRevisionId" AND d.decision='APPROVE') INTO approved;
  IF NOT approved THEN RAISE EXCEPTION 'Published revision has no recorded approval' USING ERRCODE='23514'; END IF;
 END IF;
 IF TG_OP='UPDATE' AND OLD."publicationStatus"='PUBLISHED' AND NEW."publicationStatus"='PUBLISHED' THEN
  IF (NEW."name",NEW."description",NEW."offerDescription",NEW."businessPhone",NEW."businessEmail",NEW."websiteUrl",NEW."socialUrl",NEW."locationText")
     IS DISTINCT FROM
     (OLD."name",OLD."description",OLD."offerDescription",OLD."businessPhone",OLD."businessEmail",OLD."websiteUrl",OLD."socialUrl",OLD."locationText")
     AND NEW."publishedRequestRevisionId" IS NOT DISTINCT FROM OLD."publishedRequestRevisionId" THEN
   RAISE EXCEPTION 'Published content cannot change without a newly approved revision' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_published_revision_validate BEFORE INSERT OR UPDATE ON public."Venture"
FOR EACH ROW EXECUTE FUNCTION public.sgi_published_revision_validate();

-- Revocation, suspension and closure remove publication in the same transaction as decision insertion.
CREATE OR REPLACE FUNCTION public.sgi_venture_decision_unpublish() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF NEW.decision IN ('REVOKE','SUSPEND','CLOSE') THEN
  UPDATE public."Venture" v SET
   "publicationStatus"='UNPUBLISHED',
   status=CASE NEW.decision WHEN 'CLOSE' THEN 'CLOSED'::public."VentureStatus"
                            WHEN 'SUSPEND' THEN 'SUSPENDED'::public."VentureStatus" ELSE v.status END
  WHERE v.id=NEW."ventureId";
 ELSIF NEW.decision='RESTORE' THEN
  UPDATE public."Venture" SET status='ACTIVE',"publicationStatus"='UNPUBLISHED' WHERE id=NEW."ventureId";
 END IF;
 RETURN NULL;
END $$;
CREATE TRIGGER tg_venture_decision_unpublish AFTER INSERT ON public."VentureReviewDecision"
FOR EACH ROW EXECUTE FUNCTION public.sgi_venture_decision_unpublish();

-- Strict public projection: serve only the approved JSON snapshot, never draft fields on Venture.
CREATE VIEW public.sgi_approved_venture_snapshot WITH (security_invoker=true) AS
 SELECT v.id AS venture_id, v."publishedRequestRevisionId" AS revision_id,
        rev."submittedData" AS published_data, rev."submittedAt" AS submitted_at
 FROM public."Venture" v JOIN public."VentureRequestRevision" rev ON rev.id=v."publishedRequestRevisionId"
 WHERE v.status='ACTIVE' AND v."publicationStatus"='PUBLISHED';
