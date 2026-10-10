-- SGI-CURIME V2 — INITIAL PHYSICAL SCHEMA / PostgreSQL 17
-- Generated from user-provided frozen candidate physical dictionary + V2 consolidation.
-- APPLY ONLY TO AN EMPTY public SCHEMA. One transaction: any SQL error rolls back all.
-- Review README.md and test with scripts/run-test-local.ps1 FIRST.
BEGIN;
SET LOCAL search_path = public, extensions, pg_catalog;
SET LOCAL client_min_messages = notice;
SET LOCAL lock_timeout = '15s';
-- SQL Editor may impose a statement timeout; local test uses psql in Docker.

-- Safety: abort BEFORE constructing SGI objects if public already contains application tables.
DO $$ BEGIN
 IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
            WHERE n.nspname='public' AND c.relkind IN ('r','p')) THEN
  RAISE EXCEPTION 'Refusing installation: public schema is not empty' USING ERRCODE='55000';
 END IF;
END $$;

-- ===== MODULE: 00_types.sql =====
-- PostgreSQL 17. New empty PUBLIC schema only.
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;
-- PostgreSQL enums extracted from frozen V1.1 Prisma reference
CREATE TYPE public."RequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE public."UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'BLOCKED');
CREATE TYPE public."AffiliateStatus" AS ENUM ('ACTIVE', 'INACTIVE');
CREATE TYPE public."IdentificationType" AS ENUM ('NATIONAL', 'DIMEX');
CREATE TYPE public."GovernanceTermStatus" AS ENUM ('PLANNED', 'ACTIVE', 'CLOSED', 'CANCELLED');
CREATE TYPE public."AssemblyType" AS ENUM ('ORDINARY', 'EXTRAORDINARY');
CREATE TYPE public."AssemblyStatus" AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
CREATE TYPE public."AssemblyQuorumType" AS ENUM ('FIXED', 'PERCENTAGE');
CREATE TYPE public."AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'JUSTIFIED');
CREATE TYPE public."JustificationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE public."SanctionStatus" AS ENUM ('ACTIVE', 'RESOLVED', 'REVOKED');
CREATE TYPE public."EventStatus" AS ENUM ('SCHEDULED', 'CANCELLED', 'COMPLETED');
CREATE TYPE public."PublicationStatus" AS ENUM ('INTERNAL', 'DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED');
CREATE TYPE public."ReservableResourceStatus" AS ENUM ('ACTIVE', 'INACTIVE');
CREATE TYPE public."ResourcePricingType" AS ENUM ('FREE', 'FIXED');
CREATE TYPE public."ReservationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'CONFIRMED', 'COMPLETED');
CREATE TYPE public."FinancialChargeStatus" AS ENUM ('PENDING', 'PAID', 'CANCELLED');
CREATE TYPE public."PaymentStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED');
CREATE TYPE public."PaymentMethod" AS ENUM ('CASH', 'BANK_TRANSFER', 'SINPE_MOVIL', 'OTHER');
CREATE TYPE public."DonationStatus" AS ENUM ('CONFIRMED', 'CANCELLED');
CREATE TYPE public."DonationMethod" AS ENUM ('CASH', 'BANK_TRANSFER', 'SINPE_MOVIL', 'OTHER');
CREATE TYPE public."FinancialMethod" AS ENUM ('CASH', 'BANK_TRANSFER', 'SINPE_MOVIL', 'CHECK', 'OTHER');
CREATE TYPE public."FinancialMovementType" AS ENUM ('INCOME', 'EXPENSE');
CREATE TYPE public."FinancialMovementSource" AS ENUM ('MANUAL', 'RESERVATION_PAYMENT', 'DONATION');
CREATE TYPE public."FinancialMovementOriginType" AS ENUM ('MANUAL', 'PAYMENT', 'DONATION', 'DISBURSEMENT');
CREATE TYPE public."FinancialMovementStatus" AS ENUM ('POSTED', 'VOIDED');
CREATE TYPE public."ExpenseStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');
CREATE TYPE public."FundingSourceType" AS ENUM ('FONDO_POR_GIRAR', 'IMPUESTO_CEMENTO', 'OWN_FUNDS', 'OTHER');
CREATE TYPE public."InventoryItemStatus" AS ENUM ('ACTIVE', 'INACTIVE');
CREATE TYPE public."InventoryItemCondition" AS ENUM ('GOOD', 'DAMAGED', 'UNDER_REPAIR');
CREATE TYPE public."InventoryMovementType" AS ENUM ('OPENING_BALANCE', 'ENTRY', 'EXIT', 'ADJUSTMENT');
CREATE TYPE public."InventoryLoanStatus" AS ENUM ('ACTIVE', 'RETURNED', 'CANCELLED');
CREATE TYPE public."InstitutionalOrganizationType" AS ENUM ('INTEGRAL', 'SPECIFIC');
CREATE TYPE public."BoardPosition" AS ENUM ('PRESIDENT', 'VICE_PRESIDENT', 'SECRETARY', 'TREASURER', 'VOCAL', 'FISCAL', 'SUPLENTE');
CREATE TYPE public."VolunteerOpportunityStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED', 'COMPLETED', 'CANCELLED');
CREATE TYPE public."VolunteerSessionStatus" AS ENUM ('SCHEDULED', 'COMPLETED', 'CANCELLED');
CREATE TYPE public."VolunteerApplicationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'WITHDRAWN');
CREATE TYPE public."VolunteerParticipationStatus" AS ENUM ('CONFIRMED', 'COMPLETED', 'CANCELLED');
CREATE TYPE public."VolunteerAttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'EXCUSED');
CREATE TYPE public."VentureStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'CLOSED');
CREATE TYPE public."VenturePublicationStatus" AS ENUM ('UNPUBLISHED', 'PUBLISHED');
CREATE TYPE public."VentureRequestPurpose" AS ENUM ('REGISTRATION', 'UPDATE');
CREATE TYPE public."VentureRequestStatus" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'CHANGES_REQUESTED', 'APPROVED', 'REJECTED', 'WITHDRAWN');
CREATE TYPE public."MaintenanceWorkOrderStatus" AS ENUM ('DRAFT', 'AUTHORIZED', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'VERIFIED', 'CLOSED', 'CANCELLED');
CREATE TYPE public."DisbursementPurpose" AS ENUM ('REGULAR', 'ADVANCE', 'SETTLEMENT');
CREATE TYPE public."ExpenseType" AS ENUM ('OPERATING', 'MAINTENANCE', 'EXTRAORDINARY');


-- ===== MODULE: 01_tables.sql =====
-- 82 authoritative dictionary tables (excludes conditional OD-01).
CREATE TABLE public."InstitutionalProfile" (
  "id" integer NOT NULL DEFAULT 1,
  "legalName" text,
  "legalIdentification" text,
  "dinadecoRegistrationCode" text,
  "dinadecoRegion" text,
  "organizationType" "InstitutionalOrganizationType",
  "province" text,
  "canton" text,
  "district" text,
  "locality" text,
  "correspondenceAddress" text,
  "phone" text,
  "telefax" text,
  "email" text,
  "canonicalLegalName" varchar(200),
  "canonicalLegalIdentification" varchar(64),
  "canonicalDinadecoRegistrationCode" varchar(64),
  "canonicalOrganizationType" varchar(100),
  "canonicalRegion" varchar(100),
  "canonicalProvince" varchar(100),
  "canonicalCanton" varchar(100),
  "canonicalDistrict" varchar(100),
  "canonicalPhysicalAddress" varchar(500),
  "canonicalNotificationPhone" varchar(40),
  "canonicalNotificationFax" varchar(40),
  "canonicalNotificationEmail" varchar(254),
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_InstitutionalProfile" PRIMARY KEY ("id")
);

CREATE TABLE public."Person" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "firstName" text,
  "firstSurname" text,
  "secondSurname" text,
  "legacyFullName" text,
  "identification" text,
  "identificationType" "IdentificationType",
  "normalizedIdentification" text,
  "birthDate" timestamp(3) without time zone,
  "email" text,
  "phoneCountryCode" text,
  "phoneNationalNumber" text,
  "address" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Person" PRIMARY KEY ("id")
);

CREATE TABLE public."Role" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Role" PRIMARY KEY ("id")
);

CREATE TABLE public."Permission" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" text NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Permission" PRIMARY KEY ("id")
);

CREATE TABLE public."RolePermission" (
  "roleId" integer NOT NULL,
  "permissionId" integer NOT NULL,
  CONSTRAINT "pk_RolePermission" PRIMARY KEY ("roleId", "permissionId")
);

CREATE TABLE public."User" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "fullName" text NOT NULL,
  "identification" text NOT NULL,
  "email" text NOT NULL,
  "phone" text,
  "address" text,
  "passwordHash" text,
  "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
  "failedLoginAttempts" integer NOT NULL DEFAULT 0,
  "lockedAt" timestamp(3) without time zone,
  "lastLoginAt" timestamp(3) without time zone,
  "personId" integer NOT NULL,
  "identificationType" "IdentificationType",
  "phoneCountryCode" text,
  "phoneNationalNumber" text,
  "subscriptionExpirationDate" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_User" PRIMARY KEY ("id")
);

CREATE TABLE public."Session" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "refreshTokenHash" text NOT NULL,
  "expiresAt" timestamp(3) without time zone NOT NULL,
  "revokedAt" timestamp(3) without time zone,
  "revocationReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "userId" integer NOT NULL,
  CONSTRAINT "pk_Session" PRIMARY KEY ("id")
);

CREATE TABLE public."AuditLog" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "action" text NOT NULL,
  "module" text NOT NULL,
  "entityType" text,
  "entityId" text,
  "details" jsonb,
  "ipAddress" text,
  "userAgent" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "userId" integer,
  CONSTRAINT "pk_AuditLog" PRIMARY KEY ("id")
);

CREATE TABLE public."PasswordResetToken" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "tokenHash" text NOT NULL,
  "expiresAt" timestamp(3) without time zone NOT NULL,
  "usedAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "userId" integer NOT NULL,
  CONSTRAINT "pk_PasswordResetToken" PRIMARY KEY ("id")
);

CREATE TABLE public."AccountActivationToken" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "tokenHash" text NOT NULL,
  "expiresAt" timestamp(3) without time zone NOT NULL,
  "usedAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "userId" integer NOT NULL,
  CONSTRAINT "pk_AccountActivationToken" PRIMARY KEY ("id")
);

CREATE TABLE public."UserRequest" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "fullName" text NOT NULL,
  "identification" text NOT NULL,
  "email" text NOT NULL,
  "phone" text,
  "address" text,
  "reason" text NOT NULL,
  "status" "RequestStatus" NOT NULL DEFAULT 'PENDING',
  "rejectionReason" text,
  "reviewedAt" timestamp(3) without time zone,
  "reviewedById" integer,
  "identificationType" "IdentificationType",
  "phoneCountryCode" text,
  "phoneNationalNumber" text,
  "personId" integer,
  "submittedFullName" text,
  "submittedIdentification" text,
  "submittedIdentificationType" "IdentificationType",
  "submittedEmail" text,
  "submittedPhone" text,
  "submittedPhoneCountryCode" text,
  "submittedPhoneNationalNumber" text,
  "submittedAddress" text,
  "submittedReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_UserRequest" PRIMARY KEY ("id")
);

CREATE TABLE public."Affiliate" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "fullName" text NOT NULL,
  "identification" text NOT NULL,
  "birthDate" timestamp(3) without time zone NOT NULL,
  "gender" text,
  "phone" text,
  "email" text,
  "address" text NOT NULL,
  "occupation" text,
  "workplace" text,
  "affiliateType" text,
  "affiliationDate" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "status" "AffiliateStatus" NOT NULL DEFAULT 'ACTIVE',
  "identificationType" "IdentificationType",
  "phoneCountryCode" text,
  "phoneNationalNumber" text,
  "personId" integer,
  "roleId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Affiliate" PRIMARY KEY ("id")
);

CREATE TABLE public."AffiliateRequest" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "fullName" text NOT NULL,
  "identification" text NOT NULL,
  "birthDate" timestamp(3) without time zone NOT NULL,
  "gender" text,
  "phone" text,
  "email" text,
  "address" text NOT NULL,
  "occupation" text,
  "workplace" text,
  "affiliationReason" text NOT NULL,
  "status" "RequestStatus" NOT NULL DEFAULT 'PENDING',
  "rejectionReason" text,
  "reviewedAt" timestamp(3) without time zone,
  "reviewedById" integer,
  "identificationType" "IdentificationType",
  "phoneCountryCode" text,
  "phoneNationalNumber" text,
  "personId" integer,
  "submittedFullName" text,
  "submittedIdentification" text,
  "submittedIdentificationType" "IdentificationType",
  "submittedBirthDate" timestamp(3) without time zone,
  "submittedGender" text,
  "submittedPhone" text,
  "submittedPhoneCountryCode" text,
  "submittedPhoneNationalNumber" text,
  "submittedEmail" text,
  "submittedAddress" text,
  "submittedOccupation" text,
  "submittedWorkplace" text,
  "submittedAffiliationReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AffiliateRequest" PRIMARY KEY ("id")
);

CREATE TABLE public."AffiliateSanction" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "reason" text NOT NULL,
  "description" text,
  "date" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "status" "SanctionStatus" NOT NULL DEFAULT 'ACTIVE',
  "affiliateId" integer NOT NULL,
  "createdById" integer NOT NULL,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AffiliateSanction" PRIMARY KEY ("id")
);

CREATE TABLE public."GovernancePosition" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" text NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_GovernancePosition" PRIMARY KEY ("id")
);

CREATE TABLE public."BoardTerm" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "institutionalProfileId" integer NOT NULL,
  "startsOn" date NOT NULL,
  "endsOn" date NOT NULL,
  "status" "GovernanceTermStatus",
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_BoardTerm" PRIMARY KEY ("id")
);

CREATE TABLE public."BoardAppointment" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "boardTermId" integer NOT NULL,
  "personId" integer NOT NULL,
  "position" "BoardPosition" NOT NULL,
  "positionId" integer,
  "affiliateId" integer,
  "seatNumber" integer,
  "startsOn" date,
  "endsOn" date,
  "appointedByAssemblyId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_BoardAppointment" PRIMARY KEY ("id")
);

CREATE TABLE public."Assembly" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "title" text NOT NULL,
  "assemblyType" "AssemblyType",
  "type" text,
  "date" timestamp(3) without time zone NOT NULL,
  "scheduledAt" timestamp(3) without time zone,
  "heldAt" timestamp(3) without time zone,
  "place" text NOT NULL,
  "description" text,
  "status" "AssemblyStatus" NOT NULL DEFAULT 'SCHEDULED',
  "quorumType" "AssemblyQuorumType",
  "quorumValue" integer,
  "convocationsLockedAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Assembly" PRIMARY KEY ("id")
);

CREATE TABLE public."AssemblyCall" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "assemblyId" integer NOT NULL,
  "callNumber" integer NOT NULL,
  "scheduledAt" timestamp(3) without time zone NOT NULL,
  "quorumType" "AssemblyQuorumType" NOT NULL,
  "quorumValue" integer NOT NULL,
  "startedAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AssemblyCall" PRIMARY KEY ("id")
);

CREATE TABLE public."AssemblyConvocation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "assemblyId" integer NOT NULL,
  "affiliateId" integer NOT NULL,
  "roleId" integer,
  "roleNameSnapshot" text NOT NULL,
  "governanceMembershipId" integer,
  "positionNameSnapshot" text,
  "convenedAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AssemblyConvocation" PRIMARY KEY ("id")
);

CREATE TABLE public."AssemblyAttendance" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "status" "AttendanceStatus" NOT NULL,
  "registeredAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "observations" text,
  "assemblyId" integer NOT NULL,
  "affiliateId" integer NOT NULL,
  "convocationId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AssemblyAttendance" PRIMARY KEY ("id")
);

CREATE TABLE public."AbsenceJustification" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "reason" text NOT NULL,
  "status" "JustificationStatus" NOT NULL DEFAULT 'PENDING',
  "rejectionReason" text,
  "reviewedAt" timestamp(3) without time zone,
  "assemblyId" integer NOT NULL,
  "affiliateId" integer NOT NULL,
  "attendanceId" integer,
  "reviewedById" integer,
  "decisionNote" text,
  "attachmentOriginalName" text,
  "attachmentMimeType" text,
  "attachmentSize" integer,
  "attachmentUrl" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AbsenceJustification" PRIMARY KEY ("id")
);

CREATE TABLE public."AssemblyMinute" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "assemblyId" integer NOT NULL,
  "content" text NOT NULL,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AssemblyMinute" PRIMARY KEY ("id")
);

CREATE TABLE public."AssemblyResolution" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "assemblyId" integer NOT NULL,
  "title" text NOT NULL,
  "content" text NOT NULL,
  "resolvedAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_AssemblyResolution" PRIMARY KEY ("id")
);

CREATE TABLE public."Event" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "publicId" text NOT NULL DEFAULT gen_random_uuid(),
  "title" text NOT NULL,
  "summary" text NOT NULL,
  "description" text,
  "startAt" timestamp(3) without time zone NOT NULL,
  "endAt" timestamp(3) without time zone,
  "location" text,
  "status" "EventStatus" NOT NULL DEFAULT 'SCHEDULED',
  "publicationStatus" "PublicationStatus" NOT NULL DEFAULT 'DRAFT',
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "initiative_id" integer,
  CONSTRAINT "pk_Event" PRIMARY KEY ("id")
);

CREATE TABLE public."ReservableResource" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "location" text,
  "capacity" integer,
  "status" "ReservableResourceStatus" NOT NULL DEFAULT 'ACTIVE',
  "price" numeric(14,2),
  "currency" text NOT NULL DEFAULT 'CRC',
  "pricingType" "ResourcePricingType" NOT NULL DEFAULT 'FREE',
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "facility_id" integer,
  CONSTRAINT "pk_ReservableResource" PRIMARY KEY ("id")
);

CREATE TABLE public."Reservation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "startAt" timestamp(3) without time zone NOT NULL,
  "endAt" timestamp(3) without time zone NOT NULL,
  "purpose" text NOT NULL,
  "estimatedAttendees" integer,
  "notes" text,
  "status" "ReservationStatus" NOT NULL DEFAULT 'PENDING',
  "approvedAt" timestamp(3) without time zone,
  "rejectionReason" text,
  "cancelledAt" timestamp(3) without time zone,
  "resourceId" integer NOT NULL,
  "requesterUserId" integer NOT NULL,
  "approvedById" integer,
  "eventId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Reservation" PRIMARY KEY ("id")
);

CREATE TABLE public."FinancialAccount" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" text NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "currency" text NOT NULL DEFAULT 'CRC',
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_FinancialAccount" PRIMARY KEY ("id")
);

CREATE TABLE public."FinancialCharge" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "reservationId" integer NOT NULL,
  "amount" numeric(14,2) NOT NULL,
  "currency" text NOT NULL DEFAULT 'CRC',
  "status" "FinancialChargeStatus" NOT NULL DEFAULT 'PENDING',
  "dueAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_FinancialCharge" PRIMARY KEY ("id")
);

CREATE TABLE public."Payment" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "chargeId" integer NOT NULL,
  "movementId" integer,
  "amount" numeric(14,2) NOT NULL,
  "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
  "method" "PaymentMethod" NOT NULL,
  "financialMethod" "FinancialMethod",
  "reference" text,
  "paidAt" timestamp(3) without time zone,
  "recordedById" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Payment" PRIMARY KEY ("id")
);

CREATE TABLE public."FinancialMovement" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "accountId" integer,
  "type" "FinancialMovementType" NOT NULL,
  "source" "FinancialMovementSource" NOT NULL DEFAULT 'MANUAL',
  "sourceId" integer,
  "originType" "FinancialMovementOriginType",
  "amount" numeric(14,2) NOT NULL,
  "currency" text NOT NULL DEFAULT 'CRC',
  "description" text NOT NULL,
  "reference" text,
  "occurredAt" timestamp(3) without time zone NOT NULL,
  "recordedById" integer,
  "status" "FinancialMovementStatus",
  "reversalOfId" integer,
  "voidedAt" timestamp(3) without time zone,
  "voidedById" integer,
  "voidReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "initiative_id" integer,
  "destination_type" varchar(32),
  CONSTRAINT "pk_FinancialMovement" PRIMARY KEY ("id")
);

CREATE TABLE public."Donation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "donorPersonId" integer,
  "donorName" text,
  "donorIdentification" text,
  "amount" numeric(14,2) NOT NULL,
  "currency" text NOT NULL DEFAULT 'CRC',
  "method" "DonationMethod" NOT NULL,
  "financialMethod" "FinancialMethod",
  "reference" text,
  "description" text,
  "receivedAt" timestamp(3) without time zone NOT NULL,
  "status" "DonationStatus" NOT NULL DEFAULT 'CONFIRMED',
  "recordedById" integer NOT NULL,
  "cancelledById" integer,
  "cancelledAt" timestamp(3) without time zone,
  "cancellationReason" text,
  "originalMovementId" integer,
  "reversalMovementId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "donor_id" integer,
  CONSTRAINT "pk_Donation" PRIMARY KEY ("id")
);

CREATE TABLE public."Expense" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "description" text NOT NULL,
  "amount" numeric(14,2) NOT NULL,
  "currency" text NOT NULL DEFAULT 'CRC',
  "incurredAt" timestamp(3) without time zone NOT NULL,
  "status" "ExpenseStatus" NOT NULL DEFAULT 'PENDING',
  "authorizationResolutionId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "maintenance_work_order_id" integer,
  "board_resolution_id" integer,
  "expense_type" varchar(32),
  "maintenance_cost_recognized_at" timestamp(3) without time zone,
  CONSTRAINT "pk_Expense" PRIMARY KEY ("id")
);

CREATE TABLE public."ExpenseDocument" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "expenseId" integer NOT NULL,
  "originalName" text NOT NULL,
  "mimeType" text NOT NULL,
  "size" integer NOT NULL,
  "url" text NOT NULL,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "document_version_id" integer,
  CONSTRAINT "pk_ExpenseDocument" PRIMARY KEY ("id")
);

CREATE TABLE public."Disbursement" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "expenseId" integer NOT NULL,
  "movementId" integer NOT NULL,
  "amount" numeric(14,2) NOT NULL,
  "currency" text NOT NULL DEFAULT 'CRC',
  "method" "FinancialMethod" NOT NULL,
  "reference" text,
  "paidAt" timestamp(3) without time zone NOT NULL,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "purpose" varchar(32) NOT NULL DEFAULT 'REGULAR',
  "settled_at" timestamp(3) without time zone,
  "settled_by_user_id" integer,
  CONSTRAINT "pk_Disbursement" PRIMARY KEY ("id")
);

CREATE TABLE public."FundingAllocation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "expenseId" integer NOT NULL,
  "sourceType" "FundingSourceType" NOT NULL,
  "amount" numeric(14,2) NOT NULL,
  "incomeMovementId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_FundingAllocation" PRIMARY KEY ("id")
);

CREATE TABLE public."InventoryCategory" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "isActive" boolean NOT NULL DEFAULT true,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_InventoryCategory" PRIMARY KEY ("id")
);

CREATE TABLE public."InventoryItem" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" text NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "currentQuantity" integer NOT NULL DEFAULT 0,
  "minimumQuantity" integer NOT NULL DEFAULT 0,
  "unit" text NOT NULL DEFAULT 'unidad',
  "location" text,
  "status" "InventoryItemStatus" NOT NULL DEFAULT 'ACTIVE',
  "condition" "InventoryItemCondition" NOT NULL DEFAULT 'GOOD',
  "categoryId" integer NOT NULL,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_InventoryItem" PRIMARY KEY ("id")
);

CREATE TABLE public."InventoryMovement" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "type" "InventoryMovementType" NOT NULL,
  "quantity" integer NOT NULL,
  "quantityDelta" integer,
  "reason" text NOT NULL,
  "reference" text,
  "notes" text,
  "itemId" integer NOT NULL,
  "createdById" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_InventoryMovement" PRIMARY KEY ("id")
);

CREATE TABLE public."InventoryLoan" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "quantity" integer NOT NULL,
  "borrowerName" text NOT NULL,
  "loanDate" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "expectedReturnDate" timestamp(3) without time zone NOT NULL,
  "returnedAt" timestamp(3) without time zone,
  "status" "InventoryLoanStatus" NOT NULL DEFAULT 'ACTIVE',
  "notes" text,
  "itemId" integer NOT NULL,
  "borrowerAffiliateId" integer,
  "createdById" integer,
  "receivedById" integer,
  "cancelledById" integer,
  "cancelledAt" timestamp(3) without time zone,
  "cancellationReason" text,
  "checkoutMovementId" integer,
  "returnMovementId" integer,
  "cancellationMovementId" integer,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_InventoryLoan" PRIMARY KEY ("id")
);

CREATE TABLE public."VolunteerOpportunity" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "title" text NOT NULL,
  "description" text,
  "location" text,
  "capacity" integer,
  "applicationDeadline" timestamp(3) without time zone,
  "status" "VolunteerOpportunityStatus" NOT NULL DEFAULT 'DRAFT',
  "createdByUserId" integer NOT NULL,
  "publishedAt" timestamp(3) without time zone,
  "closedAt" timestamp(3) without time zone,
  "completedAt" timestamp(3) without time zone,
  "cancelledAt" timestamp(3) without time zone,
  "cancellationReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  "initiative_id" integer,
  CONSTRAINT "pk_VolunteerOpportunity" PRIMARY KEY ("id")
);

CREATE TABLE public."VolunteerSession" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "opportunityId" integer NOT NULL,
  "title" text,
  "description" text,
  "location" text,
  "startAt" timestamp(3) without time zone NOT NULL,
  "endAt" timestamp(3) without time zone NOT NULL,
  "status" "VolunteerSessionStatus" NOT NULL DEFAULT 'SCHEDULED',
  "cancelledAt" timestamp(3) without time zone,
  "cancellationReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_VolunteerSession" PRIMARY KEY ("id")
);

CREATE TABLE public."VolunteerApplication" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "opportunityId" integer NOT NULL,
  "personId" integer,
  "submittedFullName" text NOT NULL,
  "submittedIdentificationType" "IdentificationType",
  "submittedIdentification" text,
  "submittedNormalizedIdentification" text,
  "submittedEmail" text,
  "submittedPhone" text,
  "motivation" text,
  "status" "VolunteerApplicationStatus" NOT NULL DEFAULT 'PENDING',
  "requestedAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "reviewedByUserId" integer,
  "reviewedAt" timestamp(3) without time zone,
  "rejectionReason" text,
  "withdrawnAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_VolunteerApplication" PRIMARY KEY ("id")
);

CREATE TABLE public."VolunteerParticipation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "opportunityId" integer NOT NULL,
  "personId" integer NOT NULL,
  "applicationId" integer NOT NULL,
  "status" "VolunteerParticipationStatus" NOT NULL DEFAULT 'CONFIRMED',
  "confirmedAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "completedAt" timestamp(3) without time zone,
  "cancelledAt" timestamp(3) without time zone,
  "cancellationReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_VolunteerParticipation" PRIMARY KEY ("id")
);

CREATE TABLE public."VolunteerAttendance" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "participationId" integer NOT NULL,
  "sessionId" integer NOT NULL,
  "status" "VolunteerAttendanceStatus" NOT NULL,
  "checkInAt" timestamp(3) without time zone,
  "checkOutAt" timestamp(3) without time zone,
  "creditedHours" numeric(8,2) NOT NULL DEFAULT 0,
  "notes" text,
  "recordedByUserId" integer NOT NULL,
  "recordedAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_VolunteerAttendance" PRIMARY KEY ("id")
);

CREATE TABLE public."Venture" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "name" text NOT NULL,
  "description" text,
  "offerDescription" text,
  "businessPhone" text,
  "businessEmail" text,
  "websiteUrl" text,
  "socialUrl" text,
  "locationText" text,
  "status" "VentureStatus" NOT NULL DEFAULT 'ACTIVE',
  "publicationStatus" "VenturePublicationStatus" NOT NULL DEFAULT 'UNPUBLISHED',
  "incorporatedAt" timestamp(3) without time zone NOT NULL,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_Venture" PRIMARY KEY ("id")
);

CREATE TABLE public."VentureAssociation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "personId" integer NOT NULL,
  "ventureId" integer NOT NULL,
  "startedAt" timestamp(3) without time zone NOT NULL,
  "endedAt" timestamp(3) without time zone,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_VentureAssociation" PRIMARY KEY ("id")
);

CREATE TABLE public."VentureRequest" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "purpose" "VentureRequestPurpose" NOT NULL,
  "status" "VentureRequestStatus" NOT NULL DEFAULT 'SUBMITTED',
  "reconciledPersonId" integer,
  "ventureId" integer,
  "resolvedAt" timestamp(3) without time zone,
  "decisionReason" text,
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updatedAt" timestamp(3) without time zone NOT NULL,
  CONSTRAINT "pk_VentureRequest" PRIMARY KEY ("id")
);

CREATE TABLE public."VentureRequestRevision" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "requestId" integer NOT NULL,
  "revisionNumber" integer NOT NULL,
  "payloadVersion" integer NOT NULL,
  "submittedData" jsonb NOT NULL,
  "submittedAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "createdAt" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_VentureRequestRevision" PRIMARY KEY ("id")
);

CREATE TABLE public."board_session" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "term_id" integer NOT NULL,
  "session_number" integer NOT NULL,
  "scheduled_at" timestamp(3) without time zone,
  "held_at" timestamp(3) without time zone,
  "status" varchar(32) NOT NULL,
  "notes" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_board_session" PRIMARY KEY ("id")
);

CREATE TABLE public."board_minute" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "board_session_id" integer NOT NULL,
  "document_record_id" integer,
  "legacy_content" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_board_minute" PRIMARY KEY ("id")
);

CREATE TABLE public."board_resolution" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "board_session_id" integer NOT NULL,
  "resolution_number" integer NOT NULL,
  "title" text NOT NULL,
  "content" text NOT NULL,
  "resolved_at" timestamp(3) without time zone,
  "document_record_id" integer,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_board_resolution" PRIMARY KEY ("id")
);

CREATE TABLE public."event_revision" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "event_id" integer NOT NULL,
  "revision_number" integer NOT NULL,
  "snapshot" jsonb NOT NULL,
  "submitted_by_user_id" integer,
  "submitted_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_event_revision" PRIMARY KEY ("id")
);

CREATE TABLE public."event_review_decision" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "event_revision_id" integer NOT NULL,
  "membership_id" integer NOT NULL,
  "decided_by_user_id" integer,
  "command_key" varchar(128) COLLATE "C" NOT NULL,
  "result" varchar(32) NOT NULL,
  "reason" text,
  "decided_at" timestamp(3) without time zone NOT NULL,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_event_review_decision" PRIMARY KEY ("id")
);

CREATE TABLE public."event_budget_line" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "event_id" integer NOT NULL,
  "line_number" integer NOT NULL,
  "concept" text NOT NULL,
  "amount" numeric(14,2) NOT NULL,
  "currency" char(3) NOT NULL DEFAULT 'CRC',
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_event_budget_line" PRIMARY KEY ("id")
);

CREATE TABLE public."in_kind_donation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "donor_id" integer,
  "recorded_by_user_id" integer,
  "status" varchar(32) NOT NULL,
  "description" text,
  "offered_at" timestamp(3) without time zone,
  "submitted_at" timestamp(3) without time zone,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_in_kind_donation" PRIMARY KEY ("id")
);

CREATE TABLE public."in_kind_donation_item" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "donation_id" integer NOT NULL,
  "line_number" integer NOT NULL,
  "description" text NOT NULL,
  "quantity" numeric(14,3) NOT NULL,
  "unit" varchar(32) NOT NULL,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_in_kind_donation_item" PRIMARY KEY ("id")
);

CREATE TABLE public."in_kind_donation_decision" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "donation_id" integer NOT NULL,
  "membership_id" integer NOT NULL,
  "board_resolution_id" integer,
  "decided_by_user_id" integer,
  "command_key" varchar(128) COLLATE "C" NOT NULL,
  "result" varchar(32) NOT NULL,
  "decided_at" timestamp(3) without time zone NOT NULL,
  "reason" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_in_kind_donation_decision" PRIMARY KEY ("id")
);

CREATE TABLE public."in_kind_donation_receipt" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "donation_id" integer NOT NULL,
  "receipt_number" integer NOT NULL,
  "received_by_user_id" integer NOT NULL,
  "received_at" timestamp(3) without time zone NOT NULL,
  "status" varchar(32) NOT NULL,
  "document_record_id" integer,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_in_kind_donation_receipt" PRIMARY KEY ("id")
);

CREATE TABLE public."in_kind_donation_receipt_line" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "receipt_id" integer NOT NULL,
  "line_number" integer NOT NULL,
  "donation_item_id" integer NOT NULL,
  "item_id" integer NOT NULL,
  "quantity" numeric(14,3) NOT NULL,
  "condition" varchar(32) NOT NULL,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_in_kind_donation_receipt_line" PRIMARY KEY ("id")
);

CREATE TABLE public."institutional_facility" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" varchar(64) NOT NULL,
  "name" varchar(200) NOT NULL,
  "description" text,
  "parent_facility_id" integer,
  "status" varchar(32) NOT NULL,
  "location" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_institutional_facility" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_stock_lot" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" varchar(64) NOT NULL,
  "item_id" integer NOT NULL,
  "quantity" numeric(14,3) NOT NULL,
  "condition" varchar(32) NOT NULL,
  "status" varchar(32) NOT NULL,
  "notes" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_inventory_stock_lot" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_unit" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "asset_code" varchar(64) NOT NULL,
  "item_id" integer NOT NULL,
  "condition" varchar(32) NOT NULL,
  "status" varchar(32) NOT NULL,
  "serial_number" varchar(128),
  "notes" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_inventory_unit" PRIMARY KEY ("id")
);

CREATE TABLE public."maintenance_incident" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "facility_id" integer,
  "stock_lot_id" integer,
  "unit_id" integer,
  "reported_by_person_id" integer,
  "status" varchar(32) NOT NULL,
  "description" text NOT NULL,
  "reported_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_maintenance_incident" PRIMARY KEY ("id")
);

CREATE TABLE public."maintenance_work_order" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "incident_id" integer,
  "facility_id" integer,
  "stock_lot_id" integer,
  "unit_id" integer,
  "executor_person_id" integer,
  "authorized_by_user_id" integer,
  "initiative_id" integer,
  "document_record_id" integer,
  "status" varchar(32) NOT NULL,
  "scope" text,
  "authorized_at" timestamp(3) without time zone,
  "assigned_at" timestamp(3) without time zone,
  "verified_at" timestamp(3) without time zone,
  "closed_at" timestamp(3) without time zone,
  "verification_evidence" jsonb,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_maintenance_work_order" PRIMARY KEY ("id")
);

CREATE TABLE public."resource_unavailability" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "reservable_resource_id" integer NOT NULL,
  "incident_id" integer,
  "work_order_id" integer,
  "starts_at" timestamp(3) without time zone NOT NULL,
  "ends_at" timestamp(3) without time zone,
  "released_at" timestamp(3) without time zone,
  "released_by_user_id" integer,
  "reason" text NOT NULL,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_resource_unavailability" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_loan_checkout_allocation" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "loan_id" integer NOT NULL,
  "lot_id" integer,
  "unit_id" integer,
  "quantity" numeric(14,3) NOT NULL,
  "checkout_movement_id" integer,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "notes" text,
  CONSTRAINT "pk_inventory_loan_checkout_allocation" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_loan_return" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "loan_id" integer NOT NULL,
  "return_number" integer NOT NULL,
  "received_by_user_id" integer NOT NULL,
  "received_at" timestamp(3) without time zone NOT NULL,
  "status" varchar(32) NOT NULL,
  "notes" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_inventory_loan_return" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_loan_return_detail" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "return_id" integer NOT NULL,
  "checkout_allocation_id" integer NOT NULL,
  "quantity" numeric(14,3) NOT NULL,
  "condition" varchar(32) NOT NULL,
  "available_entry_movement_id" integer,
  "notes" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_inventory_loan_return_detail" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_loan_shortage" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "checkout_allocation_id" integer NOT NULL,
  "quantity" numeric(14,3) NOT NULL,
  "status" varchar(32) NOT NULL,
  "reason" text,
  "detected_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_inventory_loan_shortage" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_loan_shortage_decision" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "shortage_id" integer NOT NULL,
  "membership_id" integer NOT NULL,
  "board_resolution_id" integer,
  "decided_by_user_id" integer,
  "command_key" varchar(128) COLLATE "C" NOT NULL,
  "result" varchar(32) NOT NULL,
  "reason" text,
  "decided_at" timestamp(3) without time zone NOT NULL,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_inventory_loan_shortage_decision" PRIMARY KEY ("id")
);

CREATE TABLE public."initiative" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" varchar(64) NOT NULL,
  "name" varchar(200) NOT NULL,
  "description" text,
  "status" varchar(32),
  "started_at" date,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_initiative" PRIMARY KEY ("id")
);

CREATE TABLE public."document_record" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "series_id" integer,
  "folio_year" integer,
  "folio_sequence" integer,
  "official_registration_request_key" varchar(128),
  "classification" varchar(16) NOT NULL,
  "status" varchar(32) NOT NULL,
  "official_registered_at" timestamp(3) without time zone,
  "voided_at" timestamp(3) without time zone,
  "void_reason" text,
  "title" varchar(300),
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_document_record" PRIMARY KEY ("id")
);

CREATE TABLE public."document_version" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "document_id" integer NOT NULL,
  "version_number" integer NOT NULL,
  "storage_key" varchar(500) NOT NULL,
  "original_name" varchar(255) NOT NULL,
  "mime_type" varchar(127) NOT NULL,
  "size_bytes" integer NOT NULL,
  "checksum_sha256" char(64) NOT NULL,
  "created_by_user_id" integer,
  "rectifies_version_id" integer,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_document_version" PRIMARY KEY ("id")
);

CREATE TABLE public."document_series" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "code" varchar(64) NOT NULL,
  "name" varchar(200) NOT NULL,
  "description" text,
  "is_active" boolean NOT NULL DEFAULT true,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "retired_at" timestamp(3) without time zone,
  CONSTRAINT "pk_document_series" PRIMARY KEY ("id")
);

CREATE TABLE public."donor" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "donor_type" varchar(16) NOT NULL,
  "person_id" integer,
  "legal_name" varchar(300),
  "identification_type" varchar(32) NOT NULL,
  "normalized_identification" varchar(128) NOT NULL,
  "display_name" varchar(300) NOT NULL,
  "verified_at" timestamp(3) without time zone,
  "verification_note" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "archived_at" timestamp(3) without time zone,
  CONSTRAINT "pk_donor" PRIMARY KEY ("id")
);

CREATE TABLE public."expense_document_log" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "expense_document_id" integer NOT NULL,
  "actor_user_id" integer,
  "event_type" varchar(32) NOT NULL,
  "event_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "snapshot" jsonb NOT NULL,
  "reason" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_expense_document_log" PRIMARY KEY ("id")
);

CREATE TABLE public."correspondence" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "document_record_id" integer NOT NULL,
  "direction" varchar(16) NOT NULL,
  "counterparty" text NOT NULL,
  "received_or_sent_at" timestamp(3) without time zone,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_correspondence" PRIMARY KEY ("id")
);

CREATE TABLE public."correspondence_log" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "correspondence_id" integer NOT NULL,
  "actor_user_id" integer,
  "event_type" varchar(32) NOT NULL,
  "event_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  "snapshot" jsonb NOT NULL,
  "reason" text,
  "created_at" timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pk_correspondence_log" PRIMARY KEY ("id")
);

CREATE TABLE public."document_folio_counter" (
  "series_id" integer NOT NULL,
  "folio_year" integer NOT NULL,
  "last_assigned" integer NOT NULL DEFAULT 0,
  CONSTRAINT "pk_document_folio_counter" PRIMARY KEY ("series_id", "folio_year")
);

CREATE TABLE public."inventory_stock_lot_receipt_origin" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "lot_id" integer NOT NULL,
  "receipt_line_id" integer NOT NULL,
  CONSTRAINT "pk_inventory_stock_lot_receipt_origin" PRIMARY KEY ("id")
);

CREATE TABLE public."inventory_unit_receipt_origin" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "unit_id" integer NOT NULL,
  "receipt_line_id" integer NOT NULL,
  CONSTRAINT "pk_inventory_unit_receipt_origin" PRIMARY KEY ("id")
);


-- ===== MODULE: 02_foreign_keys.sql =====
-- 76 baseline FKs (B003 replaced by UserRole) + 81 V2 firm FKs.
ALTER TABLE public."RolePermission" ADD CONSTRAINT "fk_RolePermission_roleId" FOREIGN KEY ("roleId") REFERENCES public."Role" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B001
ALTER TABLE public."RolePermission" ADD CONSTRAINT "fk_RolePermission_permissionId" FOREIGN KEY ("permissionId") REFERENCES public."Permission" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B002
ALTER TABLE public."User" ADD CONSTRAINT "fk_User_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B004
ALTER TABLE public."Session" ADD CONSTRAINT "fk_Session_userId" FOREIGN KEY ("userId") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B005
ALTER TABLE public."AuditLog" ADD CONSTRAINT "fk_AuditLog_userId" FOREIGN KEY ("userId") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B006
ALTER TABLE public."PasswordResetToken" ADD CONSTRAINT "fk_PasswordResetToken_userId" FOREIGN KEY ("userId") REFERENCES public."User" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B007
ALTER TABLE public."AccountActivationToken" ADD CONSTRAINT "fk_AccountActivationToken_userId" FOREIGN KEY ("userId") REFERENCES public."User" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B008
ALTER TABLE public."UserRequest" ADD CONSTRAINT "fk_UserRequest_reviewedById" FOREIGN KEY ("reviewedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B009
ALTER TABLE public."UserRequest" ADD CONSTRAINT "fk_UserRequest_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B010
ALTER TABLE public."Affiliate" ADD CONSTRAINT "fk_Affiliate_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B011
ALTER TABLE public."AffiliateRequest" ADD CONSTRAINT "fk_AffiliateRequest_reviewedById" FOREIGN KEY ("reviewedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B012
ALTER TABLE public."AffiliateRequest" ADD CONSTRAINT "fk_AffiliateRequest_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B013
ALTER TABLE public."AffiliateSanction" ADD CONSTRAINT "fk_AffiliateSanction_affiliateId" FOREIGN KEY ("affiliateId") REFERENCES public."Affiliate" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B014
ALTER TABLE public."AffiliateSanction" ADD CONSTRAINT "fk_AffiliateSanction_createdById" FOREIGN KEY ("createdById") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B015
ALTER TABLE public."BoardAppointment" ADD CONSTRAINT "fk_BoardAppointment_boardTermId" FOREIGN KEY ("boardTermId") REFERENCES public."BoardTerm" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B016
ALTER TABLE public."BoardAppointment" ADD CONSTRAINT "fk_BoardAppointment_positionId" FOREIGN KEY ("positionId") REFERENCES public."GovernancePosition" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B017
ALTER TABLE public."BoardAppointment" ADD CONSTRAINT "fk_BoardAppointment_affiliateId" FOREIGN KEY ("affiliateId") REFERENCES public."Affiliate" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B018
ALTER TABLE public."BoardAppointment" ADD CONSTRAINT "fk_BoardAppointment_appointedByAssemblyId" FOREIGN KEY ("appointedByAssemblyId") REFERENCES public."Assembly" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B019
ALTER TABLE public."AssemblyCall" ADD CONSTRAINT "fk_AssemblyCall_assemblyId" FOREIGN KEY ("assemblyId") REFERENCES public."Assembly" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B020
ALTER TABLE public."AssemblyConvocation" ADD CONSTRAINT "fk_AssemblyConvocation_assemblyId" FOREIGN KEY ("assemblyId") REFERENCES public."Assembly" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B021
ALTER TABLE public."AssemblyConvocation" ADD CONSTRAINT "fk_AssemblyConvocation_affiliateId" FOREIGN KEY ("affiliateId") REFERENCES public."Affiliate" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B022
ALTER TABLE public."AssemblyConvocation" ADD CONSTRAINT "fk_AssemblyConvocation_governanceMembershipId" FOREIGN KEY ("governanceMembershipId") REFERENCES public."BoardAppointment" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B023
ALTER TABLE public."AssemblyAttendance" ADD CONSTRAINT "fk_AssemblyAttendance_convocationId" FOREIGN KEY ("convocationId") REFERENCES public."AssemblyConvocation" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B024
ALTER TABLE public."AbsenceJustification" ADD CONSTRAINT "fk_AbsenceJustification_attendanceId" FOREIGN KEY ("attendanceId") REFERENCES public."AssemblyAttendance" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B025
ALTER TABLE public."AbsenceJustification" ADD CONSTRAINT "fk_AbsenceJustification_reviewedById" FOREIGN KEY ("reviewedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B026
ALTER TABLE public."AssemblyMinute" ADD CONSTRAINT "fk_AssemblyMinute_assemblyId" FOREIGN KEY ("assemblyId") REFERENCES public."Assembly" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B027
ALTER TABLE public."AssemblyResolution" ADD CONSTRAINT "fk_AssemblyResolution_assemblyId" FOREIGN KEY ("assemblyId") REFERENCES public."Assembly" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B028
ALTER TABLE public."Reservation" ADD CONSTRAINT "fk_Reservation_resourceId" FOREIGN KEY ("resourceId") REFERENCES public."ReservableResource" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B029
ALTER TABLE public."Reservation" ADD CONSTRAINT "fk_Reservation_requesterUserId" FOREIGN KEY ("requesterUserId") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B030
ALTER TABLE public."Reservation" ADD CONSTRAINT "fk_Reservation_approvedById" FOREIGN KEY ("approvedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B031
ALTER TABLE public."Reservation" ADD CONSTRAINT "fk_Reservation_eventId" FOREIGN KEY ("eventId") REFERENCES public."Event" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B032
ALTER TABLE public."FinancialCharge" ADD CONSTRAINT "fk_FinancialCharge_reservationId" FOREIGN KEY ("reservationId") REFERENCES public."Reservation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B033
ALTER TABLE public."Payment" ADD CONSTRAINT "fk_Payment_chargeId" FOREIGN KEY ("chargeId") REFERENCES public."FinancialCharge" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B034
ALTER TABLE public."Payment" ADD CONSTRAINT "fk_Payment_movementId" FOREIGN KEY ("movementId") REFERENCES public."FinancialMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B035
ALTER TABLE public."Payment" ADD CONSTRAINT "fk_Payment_recordedById" FOREIGN KEY ("recordedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B036
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "fk_FinancialMovement_accountId" FOREIGN KEY ("accountId") REFERENCES public."FinancialAccount" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B037
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "fk_FinancialMovement_recordedById" FOREIGN KEY ("recordedById") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B038
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "fk_FinancialMovement_voidedById" FOREIGN KEY ("voidedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B039
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "fk_FinancialMovement_reversalOfId" FOREIGN KEY ("reversalOfId") REFERENCES public."FinancialMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B040
ALTER TABLE public."Donation" ADD CONSTRAINT "fk_Donation_donorPersonId" FOREIGN KEY ("donorPersonId") REFERENCES public."Person" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B041
ALTER TABLE public."Donation" ADD CONSTRAINT "fk_Donation_recordedById" FOREIGN KEY ("recordedById") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B042
ALTER TABLE public."Donation" ADD CONSTRAINT "fk_Donation_cancelledById" FOREIGN KEY ("cancelledById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B043
ALTER TABLE public."Donation" ADD CONSTRAINT "fk_Donation_originalMovementId" FOREIGN KEY ("originalMovementId") REFERENCES public."FinancialMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B044
ALTER TABLE public."Expense" ADD CONSTRAINT "fk_Expense_authorizationResolutionId" FOREIGN KEY ("authorizationResolutionId") REFERENCES public."AssemblyResolution" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B045
ALTER TABLE public."ExpenseDocument" ADD CONSTRAINT "fk_ExpenseDocument_expenseId" FOREIGN KEY ("expenseId") REFERENCES public."Expense" ("id") ON DELETE CASCADE ON UPDATE CASCADE; -- B046
ALTER TABLE public."Disbursement" ADD CONSTRAINT "fk_Disbursement_expenseId" FOREIGN KEY ("expenseId") REFERENCES public."Expense" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B047
ALTER TABLE public."Disbursement" ADD CONSTRAINT "fk_Disbursement_movementId" FOREIGN KEY ("movementId") REFERENCES public."FinancialMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B048
ALTER TABLE public."FundingAllocation" ADD CONSTRAINT "fk_FundingAllocation_expenseId" FOREIGN KEY ("expenseId") REFERENCES public."Expense" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B049
ALTER TABLE public."FundingAllocation" ADD CONSTRAINT "fk_FundingAllocation_incomeMovementId" FOREIGN KEY ("incomeMovementId") REFERENCES public."FinancialMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B050
ALTER TABLE public."InventoryItem" ADD CONSTRAINT "fk_InventoryItem_categoryId" FOREIGN KEY ("categoryId") REFERENCES public."InventoryCategory" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B051
ALTER TABLE public."InventoryMovement" ADD CONSTRAINT "fk_InventoryMovement_itemId" FOREIGN KEY ("itemId") REFERENCES public."InventoryItem" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B052
ALTER TABLE public."InventoryMovement" ADD CONSTRAINT "fk_InventoryMovement_createdById" FOREIGN KEY ("createdById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B053
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_itemId" FOREIGN KEY ("itemId") REFERENCES public."InventoryItem" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B054
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_borrowerAffiliateId" FOREIGN KEY ("borrowerAffiliateId") REFERENCES public."Affiliate" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B055
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_createdById" FOREIGN KEY ("createdById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B056
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_receivedById" FOREIGN KEY ("receivedById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B057
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_cancelledById" FOREIGN KEY ("cancelledById") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B058
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_checkoutMovementId" FOREIGN KEY ("checkoutMovementId") REFERENCES public."InventoryMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B059
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_returnMovementId" FOREIGN KEY ("returnMovementId") REFERENCES public."InventoryMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B060
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "fk_InventoryLoan_cancellationMovementId" FOREIGN KEY ("cancellationMovementId") REFERENCES public."InventoryMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B061
ALTER TABLE public."VolunteerOpportunity" ADD CONSTRAINT "fk_VolunteerOpportunity_createdByUserId" FOREIGN KEY ("createdByUserId") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B062
ALTER TABLE public."VolunteerSession" ADD CONSTRAINT "fk_VolunteerSession_opportunityId" FOREIGN KEY ("opportunityId") REFERENCES public."VolunteerOpportunity" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B063
ALTER TABLE public."VolunteerApplication" ADD CONSTRAINT "fk_VolunteerApplication_opportunityId" FOREIGN KEY ("opportunityId") REFERENCES public."VolunteerOpportunity" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B064
ALTER TABLE public."VolunteerApplication" ADD CONSTRAINT "fk_VolunteerApplication_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B065
ALTER TABLE public."VolunteerApplication" ADD CONSTRAINT "fk_VolunteerApplication_reviewedByUserId" FOREIGN KEY ("reviewedByUserId") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B066
ALTER TABLE public."VolunteerParticipation" ADD CONSTRAINT "fk_VolunteerParticipation_opportunityId" FOREIGN KEY ("opportunityId") REFERENCES public."VolunteerOpportunity" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B067
ALTER TABLE public."VolunteerParticipation" ADD CONSTRAINT "fk_VolunteerParticipation_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B068
ALTER TABLE public."VolunteerParticipation" ADD CONSTRAINT "fk_VolunteerParticipation_applicationId" FOREIGN KEY ("applicationId") REFERENCES public."VolunteerApplication" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B069
ALTER TABLE public."VolunteerAttendance" ADD CONSTRAINT "fk_VolunteerAttendance_participationId" FOREIGN KEY ("participationId") REFERENCES public."VolunteerParticipation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B070
ALTER TABLE public."VolunteerAttendance" ADD CONSTRAINT "fk_VolunteerAttendance_sessionId" FOREIGN KEY ("sessionId") REFERENCES public."VolunteerSession" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B071
ALTER TABLE public."VolunteerAttendance" ADD CONSTRAINT "fk_VolunteerAttendance_recordedByUserId" FOREIGN KEY ("recordedByUserId") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B072
ALTER TABLE public."VentureAssociation" ADD CONSTRAINT "fk_VentureAssociation_personId" FOREIGN KEY ("personId") REFERENCES public."Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B073
ALTER TABLE public."VentureAssociation" ADD CONSTRAINT "fk_VentureAssociation_ventureId" FOREIGN KEY ("ventureId") REFERENCES public."Venture" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B074
ALTER TABLE public."VentureRequest" ADD CONSTRAINT "fk_VentureRequest_reconciledPersonId" FOREIGN KEY ("reconciledPersonId") REFERENCES public."Person" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- B075
ALTER TABLE public."VentureRequest" ADD CONSTRAINT "fk_VentureRequest_ventureId" FOREIGN KEY ("ventureId") REFERENCES public."Venture" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B076
ALTER TABLE public."VentureRequestRevision" ADD CONSTRAINT "fk_VentureRequestRevision_requestId" FOREIGN KEY ("requestId") REFERENCES public."VentureRequest" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- B077
ALTER TABLE public."board_session" ADD CONSTRAINT "fk_board_session_term_id" FOREIGN KEY ("term_id") REFERENCES public."BoardTerm" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V001
ALTER TABLE public."board_minute" ADD CONSTRAINT "fk_board_minute_board_session_id" FOREIGN KEY ("board_session_id") REFERENCES public."board_session" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V002
ALTER TABLE public."board_resolution" ADD CONSTRAINT "fk_board_resolution_board_session_id" FOREIGN KEY ("board_session_id") REFERENCES public."board_session" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V003
ALTER TABLE public."event_revision" ADD CONSTRAINT "fk_event_revision_event_id" FOREIGN KEY ("event_id") REFERENCES public."Event" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V006
ALTER TABLE public."event_revision" ADD CONSTRAINT "fk_event_revision_submitted_by_user_id" FOREIGN KEY ("submitted_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V007
ALTER TABLE public."event_review_decision" ADD CONSTRAINT "fk_event_review_decision_event_revision_id" FOREIGN KEY ("event_revision_id") REFERENCES public."event_revision" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V008
ALTER TABLE public."event_review_decision" ADD CONSTRAINT "fk_event_review_decision_membership_id" FOREIGN KEY ("membership_id") REFERENCES public."BoardAppointment" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V009
ALTER TABLE public."event_review_decision" ADD CONSTRAINT "fk_event_review_decision_decided_by_user_id" FOREIGN KEY ("decided_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V010
ALTER TABLE public."event_budget_line" ADD CONSTRAINT "fk_event_budget_line_event_id" FOREIGN KEY ("event_id") REFERENCES public."Event" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V011
ALTER TABLE public."in_kind_donation" ADD CONSTRAINT "fk_in_kind_donation_donor_id" FOREIGN KEY ("donor_id") REFERENCES public."donor" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V012
ALTER TABLE public."in_kind_donation" ADD CONSTRAINT "fk_in_kind_donation_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V013
ALTER TABLE public."in_kind_donation_item" ADD CONSTRAINT "fk_in_kind_donation_item_donation_id" FOREIGN KEY ("donation_id") REFERENCES public."in_kind_donation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V014
ALTER TABLE public."in_kind_donation_decision" ADD CONSTRAINT "fk_in_kind_donation_decision_donation_id" FOREIGN KEY ("donation_id") REFERENCES public."in_kind_donation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V015
ALTER TABLE public."in_kind_donation_decision" ADD CONSTRAINT "fk_in_kind_donation_decision_membership_id" FOREIGN KEY ("membership_id") REFERENCES public."BoardAppointment" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V016
ALTER TABLE public."in_kind_donation_decision" ADD CONSTRAINT "fk_in_kind_donation_decision_board_resolution_id" FOREIGN KEY ("board_resolution_id") REFERENCES public."board_resolution" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V017
ALTER TABLE public."in_kind_donation_decision" ADD CONSTRAINT "fk_in_kind_donation_decision_decided_by_user_id" FOREIGN KEY ("decided_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V018
ALTER TABLE public."in_kind_donation_receipt" ADD CONSTRAINT "fk_in_kind_donation_receipt_donation_id" FOREIGN KEY ("donation_id") REFERENCES public."in_kind_donation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V019
ALTER TABLE public."in_kind_donation_receipt" ADD CONSTRAINT "fk_in_kind_donation_receipt_received_by_user_id" FOREIGN KEY ("received_by_user_id") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V020
ALTER TABLE public."in_kind_donation_receipt_line" ADD CONSTRAINT "fk_in_kind_donation_receipt_line_receipt_id" FOREIGN KEY ("receipt_id") REFERENCES public."in_kind_donation_receipt" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V021
ALTER TABLE public."in_kind_donation_receipt_line" ADD CONSTRAINT "fk_in_kind_donation_receipt_line_donation_item_id" FOREIGN KEY ("donation_item_id") REFERENCES public."in_kind_donation_item" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V022
ALTER TABLE public."in_kind_donation_receipt_line" ADD CONSTRAINT "fk_in_kind_donation_receipt_line_item_id" FOREIGN KEY ("item_id") REFERENCES public."InventoryItem" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V023
ALTER TABLE public."institutional_facility" ADD CONSTRAINT "fk_institutional_facility_parent_facility_id" FOREIGN KEY ("parent_facility_id") REFERENCES public."institutional_facility" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V024
ALTER TABLE public."ReservableResource" ADD CONSTRAINT "fk_ReservableResource_facility_id" FOREIGN KEY ("facility_id") REFERENCES public."institutional_facility" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V025
ALTER TABLE public."inventory_stock_lot" ADD CONSTRAINT "fk_inventory_stock_lot_item_id" FOREIGN KEY ("item_id") REFERENCES public."InventoryItem" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V026
ALTER TABLE public."inventory_stock_lot_receipt_origin" ADD CONSTRAINT "fk_inventory_stock_lot_receipt_origin_lot_id" FOREIGN KEY ("lot_id") REFERENCES public."inventory_stock_lot" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V027
ALTER TABLE public."inventory_stock_lot_receipt_origin" ADD CONSTRAINT "fk_inventory_stock_lot_receipt_origin_receipt_line_id" FOREIGN KEY ("receipt_line_id") REFERENCES public."in_kind_donation_receipt_line" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V028
ALTER TABLE public."inventory_unit" ADD CONSTRAINT "fk_inventory_unit_item_id" FOREIGN KEY ("item_id") REFERENCES public."InventoryItem" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V029
ALTER TABLE public."inventory_unit_receipt_origin" ADD CONSTRAINT "fk_inventory_unit_receipt_origin_unit_id" FOREIGN KEY ("unit_id") REFERENCES public."inventory_unit" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V030
ALTER TABLE public."inventory_unit_receipt_origin" ADD CONSTRAINT "fk_inventory_unit_receipt_origin_receipt_line_id" FOREIGN KEY ("receipt_line_id") REFERENCES public."in_kind_donation_receipt_line" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V031
ALTER TABLE public."maintenance_incident" ADD CONSTRAINT "fk_maintenance_incident_facility_id" FOREIGN KEY ("facility_id") REFERENCES public."institutional_facility" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V032
ALTER TABLE public."maintenance_incident" ADD CONSTRAINT "fk_maintenance_incident_stock_lot_id" FOREIGN KEY ("stock_lot_id") REFERENCES public."inventory_stock_lot" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V033
ALTER TABLE public."maintenance_incident" ADD CONSTRAINT "fk_maintenance_incident_unit_id" FOREIGN KEY ("unit_id") REFERENCES public."inventory_unit" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V034
ALTER TABLE public."maintenance_incident" ADD CONSTRAINT "fk_maintenance_incident_reported_by_person_id" FOREIGN KEY ("reported_by_person_id") REFERENCES public."Person" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V035
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_incident_id" FOREIGN KEY ("incident_id") REFERENCES public."maintenance_incident" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V036
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_facility_id" FOREIGN KEY ("facility_id") REFERENCES public."institutional_facility" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V037
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_stock_lot_id" FOREIGN KEY ("stock_lot_id") REFERENCES public."inventory_stock_lot" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V038
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_unit_id" FOREIGN KEY ("unit_id") REFERENCES public."inventory_unit" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V039
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_executor_person_id" FOREIGN KEY ("executor_person_id") REFERENCES public."Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V040
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_authorized_by_user_id" FOREIGN KEY ("authorized_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V041
ALTER TABLE public."Expense" ADD CONSTRAINT "fk_Expense_maintenance_work_order_id" FOREIGN KEY ("maintenance_work_order_id") REFERENCES public."maintenance_work_order" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V042
ALTER TABLE public."Expense" ADD CONSTRAINT "fk_Expense_board_resolution_id" FOREIGN KEY ("board_resolution_id") REFERENCES public."board_resolution" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V043
ALTER TABLE public."Disbursement" ADD CONSTRAINT "fk_Disbursement_settled_by_user_id" FOREIGN KEY ("settled_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V044
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "fk_resource_unavailability_reservable_resource_id" FOREIGN KEY ("reservable_resource_id") REFERENCES public."ReservableResource" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V045
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "fk_resource_unavailability_incident_id" FOREIGN KEY ("incident_id") REFERENCES public."maintenance_incident" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V046
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "fk_resource_unavailability_work_order_id" FOREIGN KEY ("work_order_id") REFERENCES public."maintenance_work_order" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V047
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "fk_resource_unavailability_released_by_user_id" FOREIGN KEY ("released_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V048
ALTER TABLE public."inventory_loan_checkout_allocation" ADD CONSTRAINT "fk_inventory_loan_checkout_allocation_loan_id" FOREIGN KEY ("loan_id") REFERENCES public."InventoryLoan" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V049
ALTER TABLE public."inventory_loan_checkout_allocation" ADD CONSTRAINT "fk_inventory_loan_checkout_allocation_lot_id" FOREIGN KEY ("lot_id") REFERENCES public."inventory_stock_lot" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V050
ALTER TABLE public."inventory_loan_checkout_allocation" ADD CONSTRAINT "fk_inventory_loan_checkout_allocation_unit_id" FOREIGN KEY ("unit_id") REFERENCES public."inventory_unit" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V051
ALTER TABLE public."inventory_loan_checkout_allocation" ADD CONSTRAINT "fk_inventory_loan_checkout_allocation_checkout_movement_id" FOREIGN KEY ("checkout_movement_id") REFERENCES public."InventoryMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V052
ALTER TABLE public."inventory_loan_return" ADD CONSTRAINT "fk_inventory_loan_return_loan_id" FOREIGN KEY ("loan_id") REFERENCES public."InventoryLoan" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V053
ALTER TABLE public."inventory_loan_return" ADD CONSTRAINT "fk_inventory_loan_return_received_by_user_id" FOREIGN KEY ("received_by_user_id") REFERENCES public."User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V054
ALTER TABLE public."inventory_loan_return_detail" ADD CONSTRAINT "fk_inventory_loan_return_detail_return_id" FOREIGN KEY ("return_id") REFERENCES public."inventory_loan_return" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V055
ALTER TABLE public."inventory_loan_return_detail" ADD CONSTRAINT "fk_inventory_loan_return_detail_checkout_allocation_id" FOREIGN KEY ("checkout_allocation_id") REFERENCES public."inventory_loan_checkout_allocation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V056
ALTER TABLE public."inventory_loan_return_detail" ADD CONSTRAINT "fk_inventory_loan_return_detail_available_entry_movement_id" FOREIGN KEY ("available_entry_movement_id") REFERENCES public."InventoryMovement" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V057
ALTER TABLE public."inventory_loan_shortage" ADD CONSTRAINT "fk_inventory_loan_shortage_checkout_allocation_id" FOREIGN KEY ("checkout_allocation_id") REFERENCES public."inventory_loan_checkout_allocation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V058
ALTER TABLE public."inventory_loan_shortage_decision" ADD CONSTRAINT "fk_inventory_loan_shortage_decision_shortage_id" FOREIGN KEY ("shortage_id") REFERENCES public."inventory_loan_shortage" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V059
ALTER TABLE public."inventory_loan_shortage_decision" ADD CONSTRAINT "fk_inventory_loan_shortage_decision_membership_id" FOREIGN KEY ("membership_id") REFERENCES public."BoardAppointment" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V060
ALTER TABLE public."inventory_loan_shortage_decision" ADD CONSTRAINT "fk_inventory_loan_shortage_decision_board_resolution_id" FOREIGN KEY ("board_resolution_id") REFERENCES public."board_resolution" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V061
ALTER TABLE public."inventory_loan_shortage_decision" ADD CONSTRAINT "fk_inventory_loan_shortage_decision_decided_by_user_id" FOREIGN KEY ("decided_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V062
ALTER TABLE public."Event" ADD CONSTRAINT "fk_Event_initiative_id" FOREIGN KEY ("initiative_id") REFERENCES public."initiative" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V063
ALTER TABLE public."VolunteerOpportunity" ADD CONSTRAINT "fk_VolunteerOpportunity_initiative_id" FOREIGN KEY ("initiative_id") REFERENCES public."initiative" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V064
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_initiative_id" FOREIGN KEY ("initiative_id") REFERENCES public."initiative" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V065
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "fk_FinancialMovement_initiative_id" FOREIGN KEY ("initiative_id") REFERENCES public."initiative" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V066
ALTER TABLE public."document_record" ADD CONSTRAINT "fk_document_record_series_id" FOREIGN KEY ("series_id") REFERENCES public."document_series" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V067
ALTER TABLE public."document_version" ADD CONSTRAINT "fk_document_version_document_id" FOREIGN KEY ("document_id") REFERENCES public."document_record" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V068
ALTER TABLE public."document_version" ADD CONSTRAINT "fk_document_version_created_by_user_id" FOREIGN KEY ("created_by_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V069
ALTER TABLE public."document_version" ADD CONSTRAINT "fk_document_version_rectifies_version_id" FOREIGN KEY ("rectifies_version_id") REFERENCES public."document_version" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V070
ALTER TABLE public."donor" ADD CONSTRAINT "fk_donor_person_id" FOREIGN KEY ("person_id") REFERENCES public."Person" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V071
ALTER TABLE public."Donation" ADD CONSTRAINT "fk_Donation_donor_id" FOREIGN KEY ("donor_id") REFERENCES public."donor" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V072
ALTER TABLE public."expense_document_log" ADD CONSTRAINT "fk_expense_document_log_expense_document_id" FOREIGN KEY ("expense_document_id") REFERENCES public."ExpenseDocument" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V073
ALTER TABLE public."expense_document_log" ADD CONSTRAINT "fk_expense_document_log_actor_user_id" FOREIGN KEY ("actor_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V074
ALTER TABLE public."correspondence" ADD CONSTRAINT "fk_correspondence_document_record_id" FOREIGN KEY ("document_record_id") REFERENCES public."document_record" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V075
ALTER TABLE public."correspondence_log" ADD CONSTRAINT "fk_correspondence_log_correspondence_id" FOREIGN KEY ("correspondence_id") REFERENCES public."correspondence" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V076
ALTER TABLE public."correspondence_log" ADD CONSTRAINT "fk_correspondence_log_actor_user_id" FOREIGN KEY ("actor_user_id") REFERENCES public."User" ("id") ON DELETE SET NULL ON UPDATE CASCADE; -- V077
ALTER TABLE public."board_minute" ADD CONSTRAINT "fk_board_minute_document_record_id" FOREIGN KEY ("document_record_id") REFERENCES public."document_record" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V078
ALTER TABLE public."board_resolution" ADD CONSTRAINT "fk_board_resolution_document_record_id" FOREIGN KEY ("document_record_id") REFERENCES public."document_record" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V079
ALTER TABLE public."in_kind_donation_receipt" ADD CONSTRAINT "fk_in_kind_donation_receipt_document_record_id" FOREIGN KEY ("document_record_id") REFERENCES public."document_record" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V080
ALTER TABLE public."maintenance_work_order" ADD CONSTRAINT "fk_maintenance_work_order_document_record_id" FOREIGN KEY ("document_record_id") REFERENCES public."document_record" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V081
ALTER TABLE public."ExpenseDocument" ADD CONSTRAINT "fk_ExpenseDocument_document_version_id" FOREIGN KEY ("document_version_id") REFERENCES public."document_version" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V082
ALTER TABLE public."document_folio_counter" ADD CONSTRAINT "fk_document_folio_counter_series_id" FOREIGN KEY ("series_id") REFERENCES public."document_series" ("id") ON DELETE RESTRICT ON UPDATE CASCADE; -- V083


-- ===== MODULE: 03_indexes.sql =====
-- 37 BU total unique indexes + 108 BI firm + 31 VU firm + 58 VI firm.
CREATE UNIQUE INDEX "BU01" ON public."Person" ("identificationType", "normalizedIdentification");
CREATE UNIQUE INDEX "BU02" ON public."Role" ("name");
CREATE UNIQUE INDEX "BU03" ON public."Permission" ("code");
CREATE INDEX "BI001" ON public."RolePermission" ("permissionId");
CREATE UNIQUE INDEX "BU04" ON public."User" ("identification");
CREATE UNIQUE INDEX "BU05" ON public."User" ("email");
CREATE UNIQUE INDEX "BU06" ON public."User" ("personId");
CREATE UNIQUE INDEX "BU07" ON public."Session" ("refreshTokenHash");
CREATE INDEX "BI002" ON public."Session" ("userId");
CREATE INDEX "BI003" ON public."Session" ("expiresAt");
CREATE INDEX "BI004" ON public."AuditLog" ("userId");
CREATE INDEX "BI005" ON public."AuditLog" ("action");
CREATE INDEX "BI006" ON public."AuditLog" ("module");
CREATE INDEX "BI007" ON public."AuditLog" ("createdAt");
CREATE UNIQUE INDEX "BU08" ON public."PasswordResetToken" ("tokenHash");
CREATE INDEX "BI008" ON public."PasswordResetToken" ("userId");
CREATE INDEX "BI009" ON public."PasswordResetToken" ("expiresAt");
CREATE UNIQUE INDEX "BU09" ON public."AccountActivationToken" ("tokenHash");
CREATE INDEX "BI010" ON public."AccountActivationToken" ("userId");
CREATE INDEX "BI011" ON public."AccountActivationToken" ("expiresAt");
CREATE INDEX "BI012" ON public."UserRequest" ("identification");
CREATE INDEX "BI013" ON public."UserRequest" ("email");
CREATE INDEX "BI014" ON public."UserRequest" ("status");
CREATE INDEX "BI015" ON public."UserRequest" ("reviewedById");
CREATE INDEX "BI016" ON public."UserRequest" ("personId");
CREATE UNIQUE INDEX "BU10" ON public."Affiliate" ("identification");
CREATE UNIQUE INDEX "BU11" ON public."Affiliate" ("email");
CREATE UNIQUE INDEX "BU12" ON public."Affiliate" ("personId");
CREATE INDEX "BI017" ON public."Affiliate" ("roleId");
CREATE INDEX "BI018" ON public."AffiliateRequest" ("identification");
CREATE INDEX "BI019" ON public."AffiliateRequest" ("email");
CREATE INDEX "BI020" ON public."AffiliateRequest" ("status");
CREATE INDEX "BI021" ON public."AffiliateRequest" ("reviewedById");
CREATE INDEX "BI022" ON public."AffiliateRequest" ("personId");
CREATE INDEX "BI023" ON public."AffiliateSanction" ("affiliateId");
CREATE INDEX "BI024" ON public."AffiliateSanction" ("status");
CREATE INDEX "BI025" ON public."AffiliateSanction" ("date");
CREATE INDEX "BI026" ON public."AffiliateSanction" ("createdById");
CREATE UNIQUE INDEX "BU13" ON public."GovernancePosition" ("code");
CREATE INDEX "BI027" ON public."BoardTerm" ("institutionalProfileId", "startsOn");
CREATE INDEX "BI028" ON public."BoardAppointment" ("boardTermId");
CREATE INDEX "BI029" ON public."BoardAppointment" ("personId");
CREATE INDEX "BI030" ON public."BoardAppointment" ("position", "seatNumber");
CREATE INDEX "BI031" ON public."BoardAppointment" ("positionId");
CREATE INDEX "BI032" ON public."BoardAppointment" ("affiliateId");
CREATE INDEX "BI033" ON public."BoardAppointment" ("appointedByAssemblyId");
CREATE INDEX "BI034" ON public."Assembly" ("date");
CREATE INDEX "BI035" ON public."Assembly" ("scheduledAt");
CREATE INDEX "BI036" ON public."Assembly" ("status");
CREATE UNIQUE INDEX "BU14" ON public."AssemblyCall" ("assemblyId", "callNumber");
CREATE INDEX "BI037" ON public."AssemblyCall" ("scheduledAt");
CREATE UNIQUE INDEX "BU15" ON public."AssemblyConvocation" ("assemblyId", "affiliateId");
CREATE INDEX "BI039" ON public."AssemblyConvocation" ("affiliateId");
CREATE INDEX "BI040" ON public."AssemblyConvocation" ("roleId");
CREATE INDEX "BI041" ON public."AssemblyConvocation" ("governanceMembershipId");
CREATE UNIQUE INDEX "BU16" ON public."AssemblyAttendance" ("convocationId");
CREATE UNIQUE INDEX "BU17" ON public."AssemblyAttendance" ("assemblyId", "affiliateId");
CREATE INDEX "BI042" ON public."AssemblyAttendance" ("assemblyId", "status");
CREATE INDEX "BI043" ON public."AssemblyAttendance" ("affiliateId");
CREATE UNIQUE INDEX "BU18" ON public."AbsenceJustification" ("attendanceId");
CREATE UNIQUE INDEX "BU19" ON public."AbsenceJustification" ("assemblyId", "affiliateId");
CREATE INDEX "BI044" ON public."AbsenceJustification" ("status");
CREATE INDEX "BI045" ON public."AbsenceJustification" ("reviewedById");
CREATE UNIQUE INDEX "BU20" ON public."AssemblyMinute" ("assemblyId");
CREATE INDEX "BI046" ON public."AssemblyResolution" ("assemblyId");
CREATE UNIQUE INDEX "BU21" ON public."Event" ("publicId");
CREATE INDEX "BI047" ON public."Event" ("publicationStatus", "startAt");
CREATE INDEX "BI048" ON public."Event" ("startAt");
CREATE INDEX "BI049" ON public."ReservableResource" ("status");
CREATE INDEX "BI050" ON public."Reservation" ("requesterUserId");
CREATE INDEX "BI051" ON public."Reservation" ("eventId");
CREATE INDEX "BI052" ON public."Reservation" ("status");
CREATE INDEX "BI053" ON public."Reservation" ("resourceId", "startAt", "endAt");
CREATE UNIQUE INDEX "BU22" ON public."FinancialAccount" ("code");
CREATE UNIQUE INDEX "BU23" ON public."FinancialCharge" ("reservationId");
CREATE INDEX "BI054" ON public."FinancialCharge" ("status");
CREATE INDEX "BI055" ON public."FinancialCharge" ("createdAt");
CREATE UNIQUE INDEX "BU24" ON public."Payment" ("movementId");
CREATE INDEX "BI056" ON public."Payment" ("chargeId");
CREATE INDEX "BI057" ON public."Payment" ("status");
CREATE INDEX "BI058" ON public."Payment" ("recordedById");
CREATE INDEX "BI059" ON public."Payment" ("createdAt");
CREATE UNIQUE INDEX "BU25" ON public."FinancialMovement" ("reversalOfId");
CREATE INDEX "BI060" ON public."FinancialMovement" ("accountId");
CREATE INDEX "BI061" ON public."FinancialMovement" ("occurredAt");
CREATE INDEX "BI062" ON public."FinancialMovement" ("type", "occurredAt");
CREATE INDEX "BI063" ON public."FinancialMovement" ("source", "sourceId");
CREATE INDEX "BI064" ON public."FinancialMovement" ("recordedById");
CREATE INDEX "BI065" ON public."FinancialMovement" ("status", "occurredAt");
CREATE UNIQUE INDEX "BU26" ON public."Donation" ("originalMovementId");
CREATE UNIQUE INDEX "BU27" ON public."Donation" ("reversalMovementId");
CREATE INDEX "BI066" ON public."Donation" ("donorPersonId");
CREATE INDEX "BI067" ON public."Donation" ("status");
CREATE INDEX "BI068" ON public."Donation" ("method");
CREATE INDEX "BI069" ON public."Donation" ("receivedAt");
CREATE INDEX "BI070" ON public."Donation" ("recordedById");
CREATE INDEX "BI071" ON public."Donation" ("cancelledById");
CREATE INDEX "BI072" ON public."Donation" ("status", "receivedAt");
CREATE INDEX "BI073" ON public."Expense" ("authorizationResolutionId");
CREATE INDEX "BI074" ON public."Expense" ("status", "incurredAt");
CREATE INDEX "BI075" ON public."ExpenseDocument" ("expenseId");
CREATE UNIQUE INDEX "BU28" ON public."Disbursement" ("movementId");
CREATE INDEX "BI076" ON public."Disbursement" ("expenseId");
CREATE INDEX "BI077" ON public."FundingAllocation" ("expenseId");
CREATE INDEX "BI078" ON public."FundingAllocation" ("incomeMovementId");
CREATE UNIQUE INDEX "BU29" ON public."InventoryCategory" ("name");
CREATE INDEX "BI079" ON public."InventoryCategory" ("isActive");
CREATE UNIQUE INDEX "BU30" ON public."InventoryItem" ("code");
CREATE INDEX "BI080" ON public."InventoryItem" ("categoryId");
CREATE INDEX "BI081" ON public."InventoryItem" ("status");
CREATE INDEX "BI082" ON public."InventoryItem" ("condition");
CREATE INDEX "BI083" ON public."InventoryMovement" ("itemId");
CREATE INDEX "BI084" ON public."InventoryMovement" ("type");
CREATE INDEX "BI085" ON public."InventoryMovement" ("createdById");
CREATE INDEX "BI086" ON public."InventoryMovement" ("createdAt");
CREATE UNIQUE INDEX "BU31" ON public."InventoryLoan" ("checkoutMovementId");
CREATE UNIQUE INDEX "BU32" ON public."InventoryLoan" ("returnMovementId");
CREATE UNIQUE INDEX "BU33" ON public."InventoryLoan" ("cancellationMovementId");
CREATE INDEX "BI087" ON public."InventoryLoan" ("itemId");
CREATE INDEX "BI088" ON public."InventoryLoan" ("status");
CREATE INDEX "BI089" ON public."InventoryLoan" ("borrowerAffiliateId");
CREATE INDEX "BI090" ON public."InventoryLoan" ("createdById");
CREATE INDEX "BI091" ON public."InventoryLoan" ("cancelledById");
CREATE INDEX "BI092" ON public."InventoryLoan" ("expectedReturnDate");
CREATE INDEX "BI093" ON public."VolunteerOpportunity" ("createdByUserId");
CREATE INDEX "BI094" ON public."VolunteerOpportunity" ("status", "applicationDeadline");
CREATE INDEX "BI095" ON public."VolunteerSession" ("opportunityId", "startAt");
CREATE INDEX "BI096" ON public."VolunteerApplication" ("opportunityId", "status");
CREATE INDEX "BI097" ON public."VolunteerApplication" ("personId", "status");
CREATE INDEX "BI098" ON public."VolunteerApplication" ("submittedNormalizedIdentification");
CREATE INDEX "BI099" ON public."VolunteerApplication" ("reviewedByUserId");
CREATE UNIQUE INDEX "BU34" ON public."VolunteerParticipation" ("applicationId");
CREATE UNIQUE INDEX "BU35" ON public."VolunteerParticipation" ("opportunityId", "personId");
CREATE INDEX "BI100" ON public."VolunteerParticipation" ("personId", "status");
CREATE INDEX "BI101" ON public."VolunteerParticipation" ("opportunityId", "status");
CREATE UNIQUE INDEX "BU36" ON public."VolunteerAttendance" ("participationId", "sessionId");
CREATE INDEX "BI102" ON public."VolunteerAttendance" ("sessionId", "status");
CREATE INDEX "BI103" ON public."VolunteerAttendance" ("recordedByUserId");
CREATE INDEX "BI104" ON public."Venture" ("status", "publicationStatus");
CREATE INDEX "BI105" ON public."VentureAssociation" ("personId");
CREATE INDEX "BI106" ON public."VentureAssociation" ("ventureId");
CREATE INDEX "BI107" ON public."VentureRequest" ("reconciledPersonId");
CREATE INDEX "BI108" ON public."VentureRequest" ("ventureId");
CREATE INDEX "BI109" ON public."VentureRequest" ("status", "createdAt");
CREATE UNIQUE INDEX "BU37" ON public."VentureRequestRevision" ("requestId", "revisionNumber");
CREATE UNIQUE INDEX "uq_membership_active_seat" ON public."BoardAppointment" ("boardTermId", "positionId", "seatNumber") WHERE "endsOn" IS NULL;
CREATE UNIQUE INDEX "uq_volunteer_application_pending" ON public."VolunteerApplication" ("opportunityId", "personId") WHERE status='PENDING' AND "personId" IS NOT NULL;
CREATE UNIQUE INDEX "uq_venture_association_open" ON public."VentureAssociation" ("personId", "ventureId") WHERE "endedAt" IS NULL;
CREATE UNIQUE INDEX "uq_board_session_number" ON public."board_session" ("term_id", "session_number");
CREATE UNIQUE INDEX "uq_board_resolution_number" ON public."board_resolution" ("board_session_id", "resolution_number");
CREATE UNIQUE INDEX "uq_event_revision_number" ON public."event_revision" ("event_id", "revision_number");
CREATE UNIQUE INDEX "uq_event_decision_command" ON public."event_review_decision" ("command_key");
CREATE UNIQUE INDEX "uq_event_budget_line" ON public."event_budget_line" ("event_id", "line_number");
CREATE UNIQUE INDEX "uq_inkind_item_line" ON public."in_kind_donation_item" ("donation_id", "line_number");
CREATE UNIQUE INDEX "uq_inkind_decision_command" ON public."in_kind_donation_decision" ("command_key");
CREATE UNIQUE INDEX "uq_inkind_receipt_number" ON public."in_kind_donation_receipt" ("donation_id", "receipt_number");
CREATE UNIQUE INDEX "uq_inkind_receipt_line" ON public."in_kind_donation_receipt_line" ("receipt_id", "line_number");
CREATE UNIQUE INDEX "uq_facility_code" ON public."institutional_facility" ("code");
CREATE UNIQUE INDEX "uq_stock_lot_code" ON public."inventory_stock_lot" ("code");
CREATE UNIQUE INDEX "uq_inventory_unit_asset_code" ON public."inventory_unit" ("asset_code");
CREATE UNIQUE INDEX "uq_checkout_movement" ON public."inventory_loan_checkout_allocation" ("checkout_movement_id");
CREATE UNIQUE INDEX "uq_loan_return_number" ON public."inventory_loan_return" ("loan_id", "return_number");
CREATE UNIQUE INDEX "uq_return_detail_allocation" ON public."inventory_loan_return_detail" ("return_id", "checkout_allocation_id");
CREATE UNIQUE INDEX "uq_return_detail_movement" ON public."inventory_loan_return_detail" ("available_entry_movement_id");
CREATE UNIQUE INDEX "uq_shortage_decision_command" ON public."inventory_loan_shortage_decision" ("command_key");
CREATE UNIQUE INDEX "uq_initiative_code" ON public."initiative" ("code");
CREATE UNIQUE INDEX "uq_document_series_code" ON public."document_series" ("code");
CREATE UNIQUE INDEX "uq_document_folio" ON public."document_record" ("series_id", "folio_year", "folio_sequence");
CREATE UNIQUE INDEX "uq_document_registration_request" ON public."document_record" ("official_registration_request_key");
CREATE UNIQUE INDEX "uq_document_version_number" ON public."document_version" ("document_id", "version_number");
CREATE UNIQUE INDEX "uq_donor_person" ON public."donor" ("person_id");
CREATE UNIQUE INDEX "uq_donor_legal_identity" ON public."donor" ("identification_type", "normalized_identification") WHERE donor_type='ORGANIZATION';
CREATE UNIQUE INDEX "uq_correspondence_document" ON public."correspondence" ("document_record_id");
CREATE UNIQUE INDEX "uq_lot_origin_lot" ON public."inventory_stock_lot_receipt_origin" ("lot_id");
CREATE UNIQUE INDEX "uq_unit_origin_unit" ON public."inventory_unit_receipt_origin" ("unit_id");
CREATE UNIQUE INDEX "uq_disbursement_settlement" ON public."Disbursement" ("expenseId") WHERE purpose='SETTLEMENT';

-- 58 firm V2 explicit BTREE indexes
CREATE INDEX "VI001" ON public."board_minute" ("board_session_id");
CREATE INDEX "VI003" ON public."event_revision" ("submitted_by_user_id");
CREATE INDEX "VI004" ON public."event_review_decision" ("event_revision_id");
CREATE INDEX "VI005" ON public."event_review_decision" ("membership_id");
CREATE INDEX "VI006" ON public."event_review_decision" ("decided_by_user_id");
CREATE INDEX "VI007" ON public."in_kind_donation" ("donor_id");
CREATE INDEX "VI008" ON public."in_kind_donation" ("recorded_by_user_id");
CREATE INDEX "VI009" ON public."in_kind_donation_decision" ("donation_id");
CREATE INDEX "VI010" ON public."in_kind_donation_decision" ("membership_id");
CREATE INDEX "VI011" ON public."in_kind_donation_decision" ("board_resolution_id");
CREATE INDEX "VI012" ON public."in_kind_donation_decision" ("decided_by_user_id");
CREATE INDEX "VI013" ON public."in_kind_donation_receipt" ("received_by_user_id");
CREATE INDEX "VI014" ON public."in_kind_donation_receipt_line" ("donation_item_id");
CREATE INDEX "VI015" ON public."in_kind_donation_receipt_line" ("item_id");
CREATE INDEX "VI016" ON public."institutional_facility" ("parent_facility_id");
CREATE INDEX "VI017" ON public."inventory_stock_lot" ("item_id");
CREATE INDEX "VI018" ON public."inventory_unit" ("item_id");
CREATE INDEX "VI019" ON public."maintenance_incident" ("facility_id");
CREATE INDEX "VI020" ON public."maintenance_incident" ("stock_lot_id");
CREATE INDEX "VI021" ON public."maintenance_incident" ("unit_id");
CREATE INDEX "VI022" ON public."maintenance_incident" ("reported_by_person_id");
CREATE INDEX "VI023" ON public."maintenance_work_order" ("incident_id");
CREATE INDEX "VI024" ON public."maintenance_work_order" ("facility_id");
CREATE INDEX "VI025" ON public."maintenance_work_order" ("stock_lot_id");
CREATE INDEX "VI026" ON public."maintenance_work_order" ("unit_id");
CREATE INDEX "VI027" ON public."maintenance_work_order" ("executor_person_id");
CREATE INDEX "VI028" ON public."maintenance_work_order" ("authorized_by_user_id");
CREATE INDEX "VI029" ON public."maintenance_work_order" ("initiative_id");
CREATE INDEX "VI030" ON public."resource_unavailability" ("incident_id");
CREATE INDEX "VI031" ON public."resource_unavailability" ("work_order_id");
CREATE INDEX "VI032" ON public."resource_unavailability" ("released_by_user_id");
CREATE INDEX "VI033" ON public."inventory_loan_checkout_allocation" ("loan_id");
CREATE INDEX "VI034" ON public."inventory_loan_checkout_allocation" ("lot_id");
CREATE INDEX "VI035" ON public."inventory_loan_checkout_allocation" ("unit_id");
CREATE INDEX "VI036" ON public."inventory_loan_return" ("received_by_user_id");
CREATE INDEX "VI037" ON public."inventory_loan_return_detail" ("checkout_allocation_id");
CREATE INDEX "VI038" ON public."inventory_loan_shortage" ("checkout_allocation_id");
CREATE INDEX "VI039" ON public."inventory_loan_shortage_decision" ("shortage_id");
CREATE INDEX "VI040" ON public."inventory_loan_shortage_decision" ("membership_id");
CREATE INDEX "VI041" ON public."inventory_loan_shortage_decision" ("board_resolution_id");
CREATE INDEX "VI042" ON public."inventory_loan_shortage_decision" ("decided_by_user_id");
CREATE INDEX "VI043" ON public."Event" ("initiative_id");
CREATE INDEX "VI044" ON public."VolunteerOpportunity" ("initiative_id");
CREATE INDEX "VI045" ON public."FinancialMovement" ("initiative_id");
CREATE INDEX "VI046" ON public."document_version" ("created_by_user_id");
CREATE INDEX "VI047" ON public."document_version" ("rectifies_version_id");
CREATE INDEX "VI048" ON public."Donation" ("donor_id");
CREATE INDEX "VI049" ON public."expense_document_log" ("expense_document_id");
CREATE INDEX "VI050" ON public."expense_document_log" ("actor_user_id");
CREATE INDEX "VI051" ON public."correspondence_log" ("correspondence_id");
CREATE INDEX "VI052" ON public."correspondence_log" ("actor_user_id");
CREATE INDEX "VI053" ON public."ExpenseDocument" ("document_version_id");
CREATE INDEX "VI054" ON public."inventory_stock_lot_receipt_origin" ("receipt_line_id");
CREATE INDEX "VI055" ON public."inventory_unit_receipt_origin" ("receipt_line_id");
CREATE INDEX "VI056" ON public."Expense" ("maintenance_work_order_id");
CREATE INDEX "VI057" ON public."Expense" ("board_resolution_id");
CREATE INDEX "VI058" ON public."Disbursement" ("settled_by_user_id");
CREATE INDEX "VI059" ON public."ReservableResource" ("facility_id");


-- ===== MODULE: 04_consolidation.sql =====
-- Consolidation integrated in clean initial migration (not a legacy UPDATE migration).

CREATE TABLE IF NOT EXISTS public."UserRole" (
 "userId" integer NOT NULL REFERENCES public."User"("id") ON DELETE CASCADE,
 "roleId" integer NOT NULL REFERENCES public."Role"("id") ON DELETE RESTRICT,
 CONSTRAINT "pk_UserRole" PRIMARY KEY ("userId", "roleId")
);
CREATE INDEX IF NOT EXISTS "ix_UserRole_roleId" ON public."UserRole"("roleId");

CREATE TABLE IF NOT EXISTS public."VentureManagerAuthorization" (
 "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 "ventureId" integer NOT NULL REFERENCES public."Venture"("id"),
 "personId" integer NOT NULL REFERENCES public."Person"("id"),
 "grantedByUserId" integer NOT NULL REFERENCES public."User"("id"),
 "grantedByMembershipId" integer NOT NULL REFERENCES public."BoardAppointment"("id"),
 "grantReason" text NOT NULL,
 "validFrom" timestamptz NOT NULL DEFAULT now(),
 "validUntil" timestamptz,
 "revokedAt" timestamptz,
 "revokedByUserId" integer REFERENCES public."User"("id"),
 "revocationReason" text,
 "createdAt" timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT "ck_vma_validity" CHECK ("validUntil" IS NULL OR "validUntil" > "validFrom"),
 CONSTRAINT "ck_vma_revocation" CHECK (("revokedAt" IS NULL AND "revokedByUserId" IS NULL AND "revocationReason" IS NULL) OR ("revokedAt" IS NOT NULL AND "revokedByUserId" IS NOT NULL AND nullif(btrim("revocationReason"),'') IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vma_unrevoked" ON public."VentureManagerAuthorization"("ventureId","personId") WHERE "revokedAt" IS NULL;
CREATE INDEX IF NOT EXISTS "ix_vma_person" ON public."VentureManagerAuthorization"("personId");

CREATE TABLE IF NOT EXISTS public."VentureReviewerAuthorization" (
 "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 "userId" integer NOT NULL REFERENCES public."User"("id"),
 "membershipId" integer NOT NULL REFERENCES public."BoardAppointment"("id"),
 "grantedByUserId" integer NOT NULL REFERENCES public."User"("id"),
 "grantReason" text NOT NULL,
 "validFrom" timestamptz NOT NULL DEFAULT now(),
 "validUntil" timestamptz,
 "revokedAt" timestamptz,
 "revokedByUserId" integer REFERENCES public."User"("id"),
 "revocationReason" text,
 "createdAt" timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT "ck_vra_validity" CHECK ("validUntil" IS NULL OR "validUntil" > "validFrom"),
 CONSTRAINT "ck_vra_revocation" CHECK (("revokedAt" IS NULL AND "revokedByUserId" IS NULL AND "revocationReason" IS NULL) OR ("revokedAt" IS NOT NULL AND "revokedByUserId" IS NOT NULL AND nullif(btrim("revocationReason"),'') IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_vra_unrevoked" ON public."VentureReviewerAuthorization"("userId") WHERE "revokedAt" IS NULL;
CREATE INDEX IF NOT EXISTS "ix_vra_membership" ON public."VentureReviewerAuthorization"("membershipId");

CREATE TABLE IF NOT EXISTS public."VentureReviewDecision" (
 "id" bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 "ventureId" integer NOT NULL REFERENCES public."Venture"("id"),
 "revisionId" integer REFERENCES public."VentureRequestRevision"("id"),
 "reviewerUserId" integer NOT NULL REFERENCES public."User"("id"),
 "reviewerMembershipId" integer NOT NULL REFERENCES public."BoardAppointment"("id"),
 "reviewerAuthorizationId" integer NOT NULL REFERENCES public."VentureReviewerAuthorization"("id"),
 "decision" text NOT NULL CHECK ("decision" IN ('APPROVE','REJECT','CHANGES_REQUESTED','REVOKE','SUSPEND','CLOSE','RESTORE')),
 "reason" text NOT NULL CHECK (length(btrim("reason")) > 0),
 "decidedAt" timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT "ck_vrd_revision" CHECK (("decision" IN ('APPROVE','REJECT','CHANGES_REQUESTED') AND "revisionId" IS NOT NULL) OR ("decision" IN ('REVOKE','SUSPEND','CLOSE','RESTORE')))
);
CREATE INDEX IF NOT EXISTS "ix_vrd_revision_time" ON public."VentureReviewDecision"("revisionId","decidedAt" DESC);
CREATE INDEX IF NOT EXISTS "ix_vrd_venture_time" ON public."VentureReviewDecision"("ventureId","decidedAt" DESC);

ALTER TABLE public."Venture" ADD COLUMN IF NOT EXISTS "publishedRequestRevisionId" integer;
-- FK en dos fases para conservar compatibilidad con el DDL base.
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_venture_published_revision') THEN
  ALTER TABLE public."Venture" ADD CONSTRAINT "fk_venture_published_revision" FOREIGN KEY ("publishedRequestRevisionId") REFERENCES public."VentureRequestRevision"("id") ON DELETE RESTRICT;
 END IF;
END $$;
CREATE INDEX IF NOT EXISTS "ix_venture_published_revision" ON public."Venture"("publishedRequestRevisionId");




-- ===== MODULE: 05_checks_exclusion.sql =====
-- Firm CHECK ledger C01-C41 (C27/C39 conditional: not installed).
ALTER TABLE public."InstitutionalProfile" ADD CONSTRAINT "ck_org_singleton" CHECK ("id" = 1); -- C01
ALTER TABLE public."BoardTerm" ADD CONSTRAINT "ck_term_dates" CHECK ("startsOn" < "endsOn"); -- C02
ALTER TABLE public."BoardAppointment" ADD CONSTRAINT "ck_membership_values" CHECK ("seatNumber" > 0 AND ("endsOn" IS NULL OR "endsOn" >= "startsOn")); -- C03
ALTER TABLE public."AssemblyCall" ADD CONSTRAINT "ck_assembly_call_values" CHECK ("callNumber" > 0 AND (("quorumType" = 'FIXED' AND "quorumValue" IS NOT NULL AND "quorumValue" > 0) OR ("quorumType" = 'PERCENTAGE' AND "quorumValue" IS NOT NULL AND "quorumValue" > 0 AND "quorumValue" <= 100))); -- C04
ALTER TABLE public."AbsenceJustification" ADD CONSTRAINT "ck_absence_attachment_metadata" CHECK (("attachmentOriginalName" IS NULL AND "attachmentMimeType" IS NULL AND "attachmentSize" IS NULL AND "attachmentUrl" IS NULL) OR (NULLIF(BTRIM("attachmentOriginalName"),'') IS NOT NULL AND NULLIF(BTRIM("attachmentMimeType"),'') IS NOT NULL AND "attachmentSize" IS NOT NULL AND "attachmentSize" > 0 AND NULLIF(BTRIM("attachmentUrl"),'') IS NOT NULL)); -- C05
ALTER TABLE public."ExpenseDocument" ADD CONSTRAINT "ck_expense_document_size" CHECK ("size" > 0); -- C06
ALTER TABLE public."Reservation" ADD CONSTRAINT "ck_reservation_interval" CHECK ("startAt" < "endAt"); -- C07
ALTER TABLE public."ReservableResource" ADD CONSTRAINT "ck_resource_pricing" CHECK (("pricingType" = 'FREE' AND COALESCE("price",0) = 0) OR ("pricingType" = 'FIXED' AND "price" IS NOT NULL AND "price" > 0 AND NULLIF(BTRIM("currency"),'') IS NOT NULL)); -- C08
ALTER TABLE public."FinancialCharge" ADD CONSTRAINT "ck_charge_amount_positive" CHECK ("amount" > 0); -- C09
ALTER TABLE public."Payment" ADD CONSTRAINT "ck_payment_amount_positive" CHECK ("amount" > 0); -- C10
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "ck_movement_amount_positive" CHECK ("amount" > 0); -- C11
ALTER TABLE public."Donation" ADD CONSTRAINT "ck_donation_amount_positive" CHECK ("amount" > 0); -- C12
ALTER TABLE public."Expense" ADD CONSTRAINT "ck_expense_amount_positive" CHECK ("amount" > 0); -- C13
ALTER TABLE public."Disbursement" ADD CONSTRAINT "ck_disbursement_amount_positive" CHECK ("amount" > 0); -- C14
ALTER TABLE public."FundingAllocation" ADD CONSTRAINT "ck_funding_allocation_amount_positive" CHECK ("amount" > 0); -- C15
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "ck_movement_void" CHECK (("reversalOfId" IS NULL OR "reversalOfId" <> "id") AND ("status" IS DISTINCT FROM 'VOIDED' OR ("voidedAt" IS NOT NULL AND "voidedById" IS NOT NULL AND NULLIF(BTRIM("voidReason"),'') IS NOT NULL))); -- C16
ALTER TABLE public."InventoryMovement" ADD CONSTRAINT "ck_inventory_delta" CHECK ("quantityDelta" IS NULL OR ("quantityDelta" <> 0 AND (("type" = 'ENTRY' AND "quantityDelta" > 0) OR ("type" = 'EXIT' AND "quantityDelta" < 0) OR ("type" = 'OPENING_BALANCE' AND "quantityDelta" > 0) OR "type" = 'ADJUSTMENT'))); -- C17
ALTER TABLE public."InventoryItem" ADD CONSTRAINT "ck_inventory_nonnegative" CHECK ("currentQuantity" >= 0 AND "minimumQuantity" >= 0); -- C18
ALTER TABLE public."InventoryLoan" ADD CONSTRAINT "ck_loan_values" CHECK ("quantity" > 0 AND "expectedReturnDate" >= "loanDate" AND ("returnedAt" IS NULL OR "returnedAt" >= "loanDate") AND ("status" <> 'RETURNED' OR "returnedAt" IS NOT NULL) AND ("status" <> 'CANCELLED' OR "cancelledAt" IS NOT NULL)); -- C19
ALTER TABLE public."VolunteerOpportunity" ADD CONSTRAINT "ck_volunteer_capacity" CHECK ("capacity" IS NULL OR "capacity" > 0); -- C20
ALTER TABLE public."VolunteerSession" ADD CONSTRAINT "ck_volunteer_session_interval" CHECK ("startAt" < "endAt"); -- C21
ALTER TABLE public."VolunteerAttendance" ADD CONSTRAINT "ck_volunteer_attendance_values" CHECK ("creditedHours" >= 0 AND ("checkInAt" IS NULL OR "checkOutAt" IS NULL OR "checkInAt" <= "checkOutAt")); -- C22
ALTER TABLE public."Venture" ADD CONSTRAINT "ck_venture_publication" CHECK ("publicationStatus" <> 'PUBLISHED' OR "status" = 'ACTIVE'); -- C23
ALTER TABLE public."VentureAssociation" ADD CONSTRAINT "ck_venture_association_dates" CHECK ("endedAt" IS NULL OR "endedAt" >= "startedAt"); -- C24
ALTER TABLE public."VentureRequest" ADD CONSTRAINT "ck_venture_request_resolution" CHECK (("purpose" <> 'UPDATE' OR "ventureId" IS NOT NULL) AND ("status" <> 'APPROVED' OR "ventureId" IS NOT NULL) AND ("status" NOT IN ('APPROVED','REJECTED','WITHDRAWN') OR "resolvedAt" IS NOT NULL)); -- C25
ALTER TABLE public."maintenance_incident" ADD CONSTRAINT "ck_incident_target_xor" CHECK (NUM_NONNULLS("facility_id","stock_lot_id","unit_id") = 1); -- C26
ALTER TABLE public."Expense" ADD CONSTRAINT "ck_expense_resolution_xor" CHECK (NUM_NONNULLS("authorizationResolutionId","board_resolution_id") <= 1); -- C28
ALTER TABLE public."FinancialMovement" ADD CONSTRAINT "ck_income_destination" CHECK ("status" IS DISTINCT FROM 'POSTED' OR "type" <> 'INCOME' OR ("destination_type" IS NOT NULL AND (("destination_type" = 'GENERAL_FUND' AND "initiative_id" IS NULL) OR ("destination_type" = 'INITIATIVE' AND "initiative_id" IS NOT NULL)))); -- C29
ALTER TABLE public."inventory_loan_checkout_allocation" ADD CONSTRAINT "ck_checkout_target_quantity" CHECK (NUM_NONNULLS("lot_id","unit_id") = 1 AND "quantity" > 0); -- C30
ALTER TABLE public."inventory_loan_return_detail" ADD CONSTRAINT "ck_return_detail_quantity" CHECK ("quantity" > 0); -- C31
ALTER TABLE public."inventory_loan_shortage" ADD CONSTRAINT "ck_shortage_quantity" CHECK ("quantity" > 0); -- C32
ALTER TABLE public."institutional_facility" ADD CONSTRAINT "ck_facility_not_self_parent" CHECK ("parent_facility_id" IS NULL OR "parent_facility_id" <> "id"); -- C33
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "ck_unavailability_interval" CHECK ("ends_at" IS NULL OR "starts_at" < "ends_at"); -- C34
ALTER TABLE public."document_record" ADD CONSTRAINT "ck_document_folio_shape" CHECK ((NUM_NONNULLS("folio_year","folio_sequence") IN (0,2) AND ("folio_year" IS NULL OR ("folio_year" > 0 AND "folio_sequence" > 0 AND "series_id" IS NOT NULL))) AND ("official_registered_at" IS NULL OR ("series_id" IS NOT NULL AND "folio_year" IS NOT NULL AND "folio_sequence" IS NOT NULL))); -- C35
ALTER TABLE public."document_series" ADD CONSTRAINT "ck_document_series_code" CHECK ("code" COLLATE "C" ~ '^[A-Z0-9]+(-[A-Z0-9]+)*$'); -- C36
ALTER TABLE public."donor" ADD CONSTRAINT "ck_donor_shape" CHECK (("donor_type" = 'PERSON' AND "person_id" IS NOT NULL AND "legal_name" IS NULL) OR ("donor_type" = 'ORGANIZATION' AND "person_id" IS NULL AND NULLIF(BTRIM("legal_name"),'') IS NOT NULL AND NULLIF(BTRIM("normalized_identification"),'') IS NOT NULL)); -- C37
ALTER TABLE public."Disbursement" ADD CONSTRAINT "ck_disbursement_settlement_fields" CHECK (("settled_at" IS NULL AND "settled_by_user_id" IS NULL) OR ("purpose" = 'ADVANCE' AND "settled_at" IS NOT NULL AND "settled_by_user_id" IS NOT NULL)); -- C38
ALTER TABLE public."document_version" ADD CONSTRAINT "ck_document_version_shape" CHECK ("version_number" > 0 AND "size_bytes" > 0 AND "checksum_sha256" COLLATE "C" ~ '^[0-9a-fA-F]{64}$'); -- C40
ALTER TABLE public."document_record" ADD CONSTRAINT "ck_document_classification" CHECK ("classification" IN ('PUBLIC','INTERNAL','RESTRICTED')); -- C41

-- PO-05: exclusive ACTIVE reservations for maintenance unavailability.
-- Baseline ts uses timestamp WITHOUT time zone; tsrange, not tstzrange.
ALTER TABLE public."resource_unavailability" ADD CONSTRAINT "ex_unavailability_active_period"
  EXCLUDE USING gist ("reservable_resource_id" WITH =, tsrange("starts_at", COALESCE("ends_at", 'infinity'::timestamp), '[)') WITH &&)
  WHERE ("released_at" IS NULL);


-- ===== MODULE: 06_integrity_triggers.sql =====
-- SGI-Curime V2: PostgreSQL-only integrity controls. Do not expose these functions through the public API.
-- TX-level authorization, idempotence, lock ordering and policies remain the NestJS service's responsibility.

-- Common immutable row protection for approved decisions, revisions and durable logs.
CREATE OR REPLACE FUNCTION public.sgi_reject_mutation() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
  RAISE EXCEPTION 'SGI immutable record: %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE='23514';
END $$;
CREATE TRIGGER tg_venture_revision_immutable BEFORE UPDATE OR DELETE ON public."VentureRequestRevision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_venture_decision_immutable BEFORE UPDATE OR DELETE ON public."VentureReviewDecision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_document_version_immutable BEFORE UPDATE OR DELETE ON public."document_version" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_expense_doc_log_append_only BEFORE UPDATE OR DELETE ON public."expense_document_log" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_correspondence_log_append_only BEFORE UPDATE OR DELETE ON public."correspondence_log" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_event_decision_append_only BEFORE UPDATE OR DELETE ON public."event_review_decision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_inkind_decision_append_only BEFORE UPDATE OR DELETE ON public."in_kind_donation_decision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();
CREATE TRIGGER tg_shortage_decision_append_only BEFORE UPDATE OR DELETE ON public."inventory_loan_shortage_decision" FOR EACH ROW EXECUTE FUNCTION public.sgi_reject_mutation();

-- PO-06: no cycles in facilities; also local self-parent CHECK C33.
CREATE OR REPLACE FUNCTION public.sgi_facility_no_cycles() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
DECLARE cycle_found boolean;
BEGIN
 IF NEW.parent_facility_id IS NULL THEN RETURN NEW; END IF;
 WITH RECURSIVE ancestors(id,parent_id) AS (
   SELECT f.id, f.parent_facility_id FROM public.institutional_facility f WHERE f.id=NEW.parent_facility_id
   UNION
   SELECT f.id, f.parent_facility_id FROM public.institutional_facility f JOIN ancestors a ON f.id=a.parent_id
 ) SELECT EXISTS(SELECT 1 FROM ancestors WHERE id=NEW.id) INTO cycle_found;
 IF cycle_found THEN RAISE EXCEPTION 'Facility hierarchy cycle detected for id %',NEW.id USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_facility_no_cycles BEFORE INSERT OR UPDATE OF parent_facility_id ON public.institutional_facility
FOR EACH ROW EXECUTE FUNCTION public.sgi_facility_no_cycles();

-- PO-08/09: order target is unambiguous at authorization; divergence requires scope.
CREATE OR REPLACE FUNCTION public.sgi_work_order_integrity() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE inc public.maintenance_incident%ROWTYPE;
BEGIN
 IF NEW.authorized_at IS NOT NULL THEN
  IF num_nonnulls(NEW.facility_id,NEW.stock_lot_id,NEW.unit_id)<>1 THEN
   RAISE EXCEPTION 'Authorized work order requires exactly one target' USING ERRCODE='23514';
  END IF;
  IF NEW.incident_id IS NOT NULL THEN
   SELECT * INTO inc FROM public.maintenance_incident WHERE id=NEW.incident_id;
   IF NOT FOUND THEN RAISE EXCEPTION 'Work order incident missing' USING ERRCODE='23503'; END IF;
   IF NOT (NEW.facility_id IS NOT DISTINCT FROM inc.facility_id AND NEW.stock_lot_id IS NOT DISTINCT FROM inc.stock_lot_id AND NEW.unit_id IS NOT DISTINCT FROM inc.unit_id)
      AND NULLIF(btrim(NEW.scope),'') IS NULL THEN
     RAISE EXCEPTION 'Different maintenance targets require a documented scope' USING ERRCODE='23514';
   END IF;
  END IF;
 END IF;
 IF NEW.assigned_at IS NOT NULL AND NEW.executor_person_id IS NULL THEN
   RAISE EXCEPTION 'Assigned work order requires executor' USING ERRCODE='23514';
 END IF;
 IF NEW.closed_at IS NOT NULL AND (NEW.verified_at IS NULL OR NEW.verified_at>NEW.closed_at OR NEW.verification_evidence IS NULL) THEN
   RAISE EXCEPTION 'Work order close requires verified evidence before closure' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_work_order_integrity BEFORE INSERT OR UPDATE ON public.maintenance_work_order FOR EACH ROW EXECUTE FUNCTION public.sgi_work_order_integrity();

-- PO-10: checkout target must represent the same inventory item as the loan.
CREATE OR REPLACE FUNCTION public.sgi_loan_allocation_item() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE loan_item integer; target_item integer;
BEGIN
 SELECT "itemId" INTO loan_item FROM public."InventoryLoan" WHERE id=NEW.loan_id;
 IF NEW.lot_id IS NOT NULL THEN
  SELECT item_id INTO target_item FROM public.inventory_stock_lot WHERE id=NEW.lot_id;
 ELSE
  SELECT item_id INTO target_item FROM public.inventory_unit WHERE id=NEW.unit_id;
 END IF;
 IF loan_item IS NULL OR target_item IS NULL OR loan_item<>target_item THEN
  RAISE EXCEPTION 'Checkout allocation item does not match loan item' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_loan_allocation_item BEFORE INSERT OR UPDATE OF loan_id, lot_id, unit_id ON public.inventory_loan_checkout_allocation
FOR EACH ROW EXECUTE FUNCTION public.sgi_loan_allocation_item();

-- PO-11: returns and allocations must belong to the same loan.
CREATE OR REPLACE FUNCTION public.sgi_return_detail_loan() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE return_loan integer; allocation_loan integer;
BEGIN
 SELECT loan_id INTO return_loan FROM public.inventory_loan_return WHERE id=NEW.return_id;
 SELECT loan_id INTO allocation_loan FROM public.inventory_loan_checkout_allocation WHERE id=NEW.checkout_allocation_id;
 IF return_loan IS NULL OR allocation_loan IS NULL OR return_loan<>allocation_loan THEN
  RAISE EXCEPTION 'Return detail belongs to a different loan' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_return_detail_loan BEFORE INSERT OR UPDATE OF return_id,checkout_allocation_id ON public.inventory_loan_return_detail
FOR EACH ROW EXECUTE FUNCTION public.sgi_return_detail_loan();

-- PO-12: defer quantity equation check until commit, lock allocation to serialize competing writes.
CREATE OR REPLACE FUNCTION public.sgi_allocation_quantities() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE alloc_id integer; cap numeric; returned numeric; missing numeric;
BEGIN
 alloc_id := CASE WHEN TG_OP='DELETE' THEN OLD.checkout_allocation_id ELSE NEW.checkout_allocation_id END;
 SELECT quantity INTO cap FROM public.inventory_loan_checkout_allocation WHERE id=alloc_id FOR UPDATE;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT COALESCE(SUM(quantity),0) INTO returned FROM public.inventory_loan_return_detail WHERE checkout_allocation_id=alloc_id;
 SELECT COALESCE(SUM(quantity),0) INTO missing FROM public.inventory_loan_shortage WHERE checkout_allocation_id=alloc_id AND status IS DISTINCT FROM 'CANCELLED';
 IF returned + missing > cap THEN
  RAISE EXCEPTION 'Return + shortage (%) exceeds checkout allocation (%)', returned + missing, cap USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER tg_return_allocation_limit AFTER INSERT OR UPDATE OR DELETE ON public.inventory_loan_return_detail
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.sgi_allocation_quantities();
CREATE CONSTRAINT TRIGGER tg_shortage_allocation_limit AFTER INSERT OR UPDATE OR DELETE ON public.inventory_loan_shortage
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.sgi_allocation_quantities();

-- PO-13: origin receipt line must identify the same inventory item as the asset/lot.
CREATE OR REPLACE FUNCTION public.sgi_receipt_origin_match() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE expected_item integer; actual_item integer;
BEGIN
 SELECT item_id INTO expected_item FROM public.in_kind_donation_receipt_line WHERE id=NEW.receipt_line_id;
 IF TG_TABLE_NAME='inventory_stock_lot_receipt_origin' THEN
   SELECT item_id INTO actual_item FROM public.inventory_stock_lot WHERE id=NEW.lot_id;
 ELSE
   SELECT item_id INTO actual_item FROM public.inventory_unit WHERE id=NEW.unit_id;
 END IF;
 IF expected_item IS NULL OR actual_item IS NULL OR expected_item<>actual_item THEN
  RAISE EXCEPTION 'Receipt origin item mismatch' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_lot_receipt_origin_match BEFORE INSERT OR UPDATE ON public.inventory_stock_lot_receipt_origin
FOR EACH ROW EXECUTE FUNCTION public.sgi_receipt_origin_match();
CREATE TRIGGER tg_unit_receipt_origin_match BEFORE INSERT OR UPDATE ON public.inventory_unit_receipt_origin
FOR EACH ROW EXECUTE FUNCTION public.sgi_receipt_origin_match();

-- PO-14/15: offer and receipt must refer to same donation and aggregate received <= offered.
CREATE OR REPLACE FUNCTION public.sgi_receipt_line_integrity() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE offered_donation integer; received_donation integer; offered_quantity numeric; quantity_used numeric;
BEGIN
 SELECT donation_id,quantity INTO offered_donation,offered_quantity
 FROM public.in_kind_donation_item WHERE id=NEW.donation_item_id FOR UPDATE;
 SELECT donation_id INTO received_donation FROM public.in_kind_donation_receipt WHERE id=NEW.receipt_id;
 IF offered_donation IS NULL OR received_donation IS NULL OR offered_donation<>received_donation THEN
  RAISE EXCEPTION 'Receipt line and offer belong to different donations' USING ERRCODE='23514';
 END IF;
 SELECT COALESCE(SUM(quantity),0) INTO quantity_used FROM public.in_kind_donation_receipt_line
 WHERE donation_item_id=NEW.donation_item_id AND id IS DISTINCT FROM NEW.id;
 IF NEW.quantity<=0 OR quantity_used + NEW.quantity>offered_quantity THEN
  RAISE EXCEPTION 'Received quantity exceeds offered quantity' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_receipt_line_integrity BEFORE INSERT OR UPDATE ON public.in_kind_donation_receipt_line
FOR EACH ROW EXECUTE FUNCTION public.sgi_receipt_line_integrity();

-- PO-17: document rectification must point to distinct document and cannot form a cycle.
CREATE OR REPLACE FUNCTION public.sgi_document_rectification_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE origin_document integer; found_cycle boolean;
BEGIN
 IF NEW.rectifies_version_id IS NULL THEN RETURN NEW; END IF;
 IF NEW.rectifies_version_id=NEW.id THEN RAISE EXCEPTION 'Self rectification not allowed' USING ERRCODE='23514'; END IF;
 SELECT document_id INTO origin_document FROM public.document_version WHERE id=NEW.rectifies_version_id;
 IF origin_document=NEW.document_id THEN RAISE EXCEPTION 'Rectification requires a different official document' USING ERRCODE='23514'; END IF;
 WITH RECURSIVE lineage(id,rectifies_version_id) AS (
  SELECT id,rectifies_version_id FROM public.document_version WHERE id=NEW.rectifies_version_id
  UNION
  SELECT v.id,v.rectifies_version_id FROM public.document_version v JOIN lineage l ON v.id=l.rectifies_version_id
 ) SELECT EXISTS(SELECT 1 FROM lineage WHERE id=NEW.id) INTO found_cycle;
 IF found_cycle THEN RAISE EXCEPTION 'Document rectification cycle detected' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_document_rectification_check BEFORE INSERT ON public.document_version
FOR EACH ROW EXECUTE FUNCTION public.sgi_document_rectification_check();

-- PO-18: series.code immutable after first official emission.
CREATE OR REPLACE FUNCTION public.sgi_series_code_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code AND EXISTS (
  SELECT 1 FROM public.document_record WHERE series_id=OLD.id AND official_registered_at IS NOT NULL
 ) THEN RAISE EXCEPTION 'Issued document series code cannot change' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_document_series_code_guard BEFORE UPDATE OF code ON public.document_series
FOR EACH ROW EXECUTE FUNCTION public.sgi_series_code_guard();

-- PO-19: committed official folios cannot be changed or recycled.
CREATE OR REPLACE FUNCTION public.sgi_document_official_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF OLD.official_registered_at IS NOT NULL THEN RAISE EXCEPTION 'Official document cannot be deleted' USING ERRCODE='23514'; END IF;
  RETURN OLD;
 END IF;
 IF OLD.official_registered_at IS NOT NULL AND (
  NEW.series_id IS DISTINCT FROM OLD.series_id OR NEW.folio_year IS DISTINCT FROM OLD.folio_year OR
  NEW.folio_sequence IS DISTINCT FROM OLD.folio_sequence OR NEW.official_registered_at IS DISTINCT FROM OLD.official_registered_at OR
  NEW.official_registration_request_key IS DISTINCT FROM OLD.official_registration_request_key
 ) THEN RAISE EXCEPTION 'Official document folio is immutable' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_document_official_guard BEFORE UPDATE OR DELETE ON public.document_record
FOR EACH ROW EXECUTE FUNCTION public.sgi_document_official_guard();

-- PO-20: monotonic folio counter. Application grants must be restricted to a controlled backend DB principal.
CREATE OR REPLACE FUNCTION public.sgi_folio_counter_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Folio counter cannot be deleted' USING ERRCODE='23514'; END IF;
 IF NEW.last_assigned<0 OR (TG_OP='UPDATE' AND NEW.last_assigned<=OLD.last_assigned) THEN
  RAISE EXCEPTION 'Folio counter may only increase' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_folio_counter_guard BEFORE INSERT OR UPDATE OR DELETE ON public.document_folio_counter
FOR EACH ROW EXECUTE FUNCTION public.sgi_folio_counter_guard();

-- PO-22: immutable economics after a financial movement is posted; VOIDED keeps the ledger row.
CREATE OR REPLACE FUNCTION public.sgi_financial_movement_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF OLD.status IN ('POSTED','VOIDED') THEN RAISE EXCEPTION 'Posted financial movement cannot be deleted' USING ERRCODE='23514'; END IF;
  RETURN OLD;
 END IF;
 IF OLD.status IN ('POSTED','VOIDED') AND (
  NEW."accountId" IS DISTINCT FROM OLD."accountId" OR NEW."amount" IS DISTINCT FROM OLD."amount" OR
  NEW."currency" IS DISTINCT FROM OLD."currency" OR NEW."type" IS DISTINCT FROM OLD."type" OR
  NEW."source" IS DISTINCT FROM OLD."source" OR NEW."sourceId" IS DISTINCT FROM OLD."sourceId" OR
  NEW."originType" IS DISTINCT FROM OLD."originType" OR NEW.initiative_id IS DISTINCT FROM OLD.initiative_id OR
  NEW.destination_type IS DISTINCT FROM OLD.destination_type OR NEW."reversalOfId" IS DISTINCT FROM OLD."reversalOfId"
 ) THEN RAISE EXCEPTION 'Posted financial movement economics are immutable' USING ERRCODE='23514'; END IF;
 IF OLD.status='VOIDED' AND NEW.status IS DISTINCT FROM OLD.status THEN
   RAISE EXCEPTION 'Voided movement cannot be reopened' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_financial_movement_guard BEFORE UPDATE OR DELETE ON public."FinancialMovement"
FOR EACH ROW EXECUTE FUNCTION public.sgi_financial_movement_guard();

-- PO-23: recognition of maintenance expense only after verified work order closure.
CREATE OR REPLACE FUNCTION public.sgi_maintenance_cost_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE work_verified timestamp; work_closed timestamp;
BEGIN
 IF NEW.maintenance_cost_recognized_at IS NULL THEN RETURN NEW; END IF;
 IF NEW.maintenance_work_order_id IS NULL THEN RAISE EXCEPTION 'Maintenance cost requires work order' USING ERRCODE='23514'; END IF;
 SELECT verified_at,closed_at INTO work_verified,work_closed FROM public.maintenance_work_order WHERE id=NEW.maintenance_work_order_id;
 IF work_verified IS NULL OR work_closed IS NULL OR work_closed>NEW.maintenance_cost_recognized_at THEN
  RAISE EXCEPTION 'Maintenance expense may be recognized only after verified closure' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_maintenance_cost_guard BEFORE INSERT OR UPDATE ON public."Expense"
FOR EACH ROW EXECUTE FUNCTION public.sgi_maintenance_cost_guard();


-- PO-12 (completion): returned loan cannot close with unallocated/unaccounted quantity.
-- Runs deferred so checkout/return/shortage rows may be written in one transaction.
CREATE OR REPLACE FUNCTION public.sgi_loan_close_equation() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE allocated numeric; accounted numeric;
BEGIN
 IF NEW.status<>'RETURNED' THEN RETURN NULL; END IF;
 SELECT COALESCE(SUM(quantity),0) INTO allocated FROM public.inventory_loan_checkout_allocation WHERE loan_id=NEW.id;
 SELECT COALESCE(SUM(d.quantity),0) INTO accounted
 FROM public.inventory_loan_return_detail d JOIN public.inventory_loan_checkout_allocation a ON a.id=d.checkout_allocation_id
 WHERE a.loan_id=NEW.id;
 SELECT accounted+COALESCE(SUM(s.quantity),0) INTO accounted
 FROM public.inventory_loan_shortage s JOIN public.inventory_loan_checkout_allocation a ON a.id=s.checkout_allocation_id
 WHERE a.loan_id=NEW.id AND s.status IS DISTINCT FROM 'CANCELLED';
 IF allocated<>NEW.quantity OR accounted<>allocated THEN
  RAISE EXCEPTION 'Cannot close loan %: loan qty %, allocated %, accounted %', NEW.id,NEW.quantity,allocated,accounted USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER tg_loan_close_equation AFTER INSERT OR UPDATE ON public."InventoryLoan"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.sgi_loan_close_equation();

-- PO-15 (reverse direction): decreasing offered quantity must not invalidate received rows.
CREATE OR REPLACE FUNCTION public.sgi_offer_quantity_floor() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE received numeric;
BEGIN
 SELECT COALESCE(SUM(quantity),0) INTO received FROM public.in_kind_donation_receipt_line WHERE donation_item_id=NEW.id;
 IF NEW.quantity<received THEN
  RAISE EXCEPTION 'Offered quantity (%) cannot be less than quantity received (%)',NEW.quantity,received USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER tg_offer_quantity_floor BEFORE UPDATE OF quantity ON public.in_kind_donation_item
FOR EACH ROW EXECUTE FUNCTION public.sgi_offer_quantity_floor();


-- ===== MODULE: 07_venture_publishing.sql =====
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


-- ===== MODULE: 08_security.sql =====
-- New database initialization: expose NO SGI table by default through PostgREST.
-- The backend must use a dedicated privileged connection and authorize access in NestJS.
-- No public/anon/authenticated RLS policies are installed automatically.
DO $$
DECLARE t record;
BEGIN
 FOR t IN SELECT table_name FROM information_schema.tables
          WHERE table_schema='public' AND table_type='BASE TABLE' LOOP
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.table_name);
 END LOOP;
END $$;

-- Revoke direct write access to particularly sensitive objects even when API roles exist.
DO $$
DECLARE role_name text;
BEGIN
 FOR role_name IN SELECT rolname FROM pg_roles WHERE rolname IN ('anon','authenticated') LOOP
  EXECUTE format('REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM %I',role_name);
  EXECUTE format('REVOKE USAGE, UPDATE ON ALL SEQUENCES IN SCHEMA public FROM %I',role_name);
 END LOOP;
END $$;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE USAGE, UPDATE ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;


-- ===== CONTRACT ASSERTIONS (fail => ROLLBACK) =====
-- Run after initial migration. Fail loudly if structural invariants differ.
DO $$
DECLARE c_tables int; c_enums int; c_fks int; c_checks int; c_exclude int; c_explicit int;
BEGIN
 SELECT count(*) INTO c_tables FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND c.relkind='r';
 SELECT count(*) INTO c_enums FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace
  WHERE n.nspname='public' AND t.typtype='e';
 SELECT count(*) INTO c_fks FROM pg_constraint k JOIN pg_namespace n ON n.oid=k.connamespace
  WHERE n.nspname='public' AND k.contype='f';
 SELECT count(*) INTO c_checks FROM pg_constraint k JOIN pg_namespace n ON n.oid=k.connamespace
  WHERE n.nspname='public' AND k.contype='c' AND k.conname LIKE 'ck_%';
 SELECT count(*) INTO c_exclude FROM pg_constraint k JOIN pg_namespace n ON n.oid=k.connamespace
  WHERE n.nspname='public' AND k.contype='x';
 SELECT count(*) INTO c_explicit FROM pg_index i JOIN pg_class c ON c.oid=i.indexrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND NOT i.indisprimary;
 IF c_tables<>86 THEN RAISE EXCEPTION 'Expected 86 persistent SGI tables; got %',c_tables; END IF;
 IF c_enums<>46 THEN RAISE EXCEPTION 'Expected 46 enum types; got %',c_enums; END IF;
 IF c_fks<>174 THEN RAISE EXCEPTION 'Expected 174 FKs; got %',c_fks; END IF;
 IF c_checks<44 THEN RAISE EXCEPTION 'Expected at least 44 named ck_ constraints; got %',c_checks; END IF;
 IF c_exclude<>1 THEN RAISE EXCEPTION 'Expected exactly 1 EXCLUDE; got %',c_exclude; END IF;
 IF c_explicit<235 THEN RAISE EXCEPTION 'Expected at least 235 non-PK indexes; got %',c_explicit; END IF;
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='User' AND column_name='roleId') THEN
  RAISE EXCEPTION 'Legacy User.roleId must not be part of V2 initial schema'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='pk_UserRole') THEN RAISE EXCEPTION 'Missing UserRole PK'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='ex_unavailability_active_period') THEN RAISE EXCEPTION 'Missing resource exclusion'; END IF;
 IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
            WHERE n.nspname='public' AND c.relkind='r' AND NOT c.relrowsecurity) THEN
  RAISE EXCEPTION 'RLS disabled on some public SGI tables'; END IF;
 RAISE NOTICE 'SGI V2 schema PASS: % tables, % enums, % FKs, % named CHECK, % exclusion',
  c_tables,c_enums,c_fks,c_checks,c_exclude;
END $$;

COMMIT;
