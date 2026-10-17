-- SGI-CURIME V2 — INITIAL PHYSICAL SCHEMA / PostgreSQL 17
-- Generated from frozen canonical initial schema. Consolidation is integrated exactly once.
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
CREATE TYPE public.request_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE public.user_status AS ENUM ('ACTIVE', 'INACTIVE', 'BLOCKED');
CREATE TYPE public.affiliate_status AS ENUM ('ACTIVE', 'INACTIVE');
CREATE TYPE public.identification_type AS ENUM ('NATIONAL', 'DIMEX');
CREATE TYPE public.governance_term_status AS ENUM ('PLANNED', 'ACTIVE', 'CLOSED', 'CANCELLED');
CREATE TYPE public.assembly_type AS ENUM ('ORDINARY', 'EXTRAORDINARY');
CREATE TYPE public.assembly_status AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
CREATE TYPE public.assembly_quorum_type AS ENUM ('FIXED', 'PERCENTAGE');
CREATE TYPE public.attendance_status AS ENUM ('PRESENT', 'ABSENT', 'JUSTIFIED');
CREATE TYPE public.justification_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE public.sanction_status AS ENUM ('ACTIVE', 'RESOLVED', 'REVOKED');
CREATE TYPE public.event_status AS ENUM ('SCHEDULED', 'CANCELLED', 'COMPLETED');
CREATE TYPE public.publication_status AS ENUM ('INTERNAL', 'DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED');
CREATE TYPE public.reservable_resource_status AS ENUM ('ACTIVE', 'INACTIVE');
CREATE TYPE public.resource_pricing_type AS ENUM ('FREE', 'FIXED');
CREATE TYPE public.reservation_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'CONFIRMED', 'COMPLETED');
CREATE TYPE public.financial_charge_status AS ENUM ('PENDING', 'PAID', 'CANCELLED');
CREATE TYPE public.payment_status AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED');
CREATE TYPE public.payment_method AS ENUM ('CASH', 'BANK_TRANSFER', 'SINPE_MOVIL', 'OTHER');
CREATE TYPE public.donation_status AS ENUM ('CONFIRMED', 'CANCELLED');
CREATE TYPE public.donation_method AS ENUM ('CASH', 'BANK_TRANSFER', 'SINPE_MOVIL', 'OTHER');
CREATE TYPE public.financial_method AS ENUM ('CASH', 'BANK_TRANSFER', 'SINPE_MOVIL', 'CHECK', 'OTHER');
CREATE TYPE public.financial_movement_type AS ENUM ('INCOME', 'EXPENSE');
CREATE TYPE public.financial_movement_source AS ENUM ('MANUAL', 'RESERVATION_PAYMENT', 'DONATION');
CREATE TYPE public.financial_movement_origin_type AS ENUM ('MANUAL', 'PAYMENT', 'DONATION', 'DISBURSEMENT');
CREATE TYPE public.financial_movement_status AS ENUM ('POSTED', 'VOIDED');
CREATE TYPE public.expense_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');
CREATE TYPE public.funding_source_type AS ENUM ('FONDO_POR_GIRAR', 'IMPUESTO_CEMENTO', 'OWN_FUNDS', 'OTHER');
CREATE TYPE public.inventory_item_status AS ENUM ('ACTIVE', 'INACTIVE');
CREATE TYPE public.inventory_item_condition AS ENUM ('GOOD', 'DAMAGED', 'UNDER_REPAIR');
CREATE TYPE public.inventory_movement_type AS ENUM ('OPENING_BALANCE', 'ENTRY', 'EXIT', 'ADJUSTMENT');
CREATE TYPE public.inventory_loan_status AS ENUM ('ACTIVE', 'RETURNED', 'CANCELLED');
CREATE TYPE public.institutional_organization_type AS ENUM ('INTEGRAL', 'SPECIFIC');
CREATE TYPE public.board_position AS ENUM ('PRESIDENT', 'VICE_PRESIDENT', 'SECRETARY', 'TREASURER', 'VOCAL', 'FISCAL', 'SUPLENTE');
CREATE TYPE public.volunteer_opportunity_status AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED', 'COMPLETED', 'CANCELLED');
CREATE TYPE public.volunteer_session_status AS ENUM ('SCHEDULED', 'COMPLETED', 'CANCELLED');
CREATE TYPE public.volunteer_application_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'WITHDRAWN');
CREATE TYPE public.volunteer_participation_status AS ENUM ('CONFIRMED', 'COMPLETED', 'CANCELLED');
CREATE TYPE public.volunteer_attendance_status AS ENUM ('PRESENT', 'ABSENT', 'EXCUSED');
CREATE TYPE public.venture_status AS ENUM ('ACTIVE', 'SUSPENDED', 'CLOSED');
CREATE TYPE public.venture_publication_status AS ENUM ('UNPUBLISHED', 'PUBLISHED');
CREATE TYPE public.venture_request_purpose AS ENUM ('REGISTRATION', 'UPDATE');
CREATE TYPE public.venture_request_status AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'CHANGES_REQUESTED', 'APPROVED', 'REJECTED', 'WITHDRAWN');
CREATE TYPE public.maintenance_work_order_status AS ENUM ('DRAFT', 'AUTHORIZED', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'VERIFIED', 'CLOSED', 'CANCELLED');
CREATE TYPE public.disbursement_purpose AS ENUM ('REGULAR', 'ADVANCE', 'SETTLEMENT');
CREATE TYPE public.expense_type AS ENUM ('OPERATING', 'MAINTENANCE', 'EXTRAORDINARY');


-- ===== MODULE: 01_tables.sql =====
-- 82 authoritative dictionary tables (excludes conditional OD-01).
CREATE TABLE public.institutional_profiles (
  id integer NOT NULL DEFAULT 1,
  legal_name text,
  legal_identification text,
  dinadeco_registration_code text,
  dinadeco_region text,
  organization_type institutional_organization_type,
  province text,
  canton text,
  district text,
  locality text,
  correspondence_address text,
  phone text,
  telefax text,
  email text,
  canonical_legal_name varchar(200),
  canonical_legal_identification varchar(64),
  canonical_dinadeco_registration_code varchar(64),
  canonical_organization_type varchar(100),
  canonical_region varchar(100),
  canonical_province varchar(100),
  canonical_canton varchar(100),
  canonical_district varchar(100),
  canonical_physical_address varchar(500),
  canonical_notification_phone varchar(40),
  canonical_notification_fax varchar(40),
  canonical_notification_email varchar(254),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_institutional_profiles PRIMARY KEY (id)
);

CREATE TABLE public.people (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  first_name text,
  first_surname text,
  second_surname text,
  legacy_full_name text,
  identification text,
  identification_type identification_type,
  normalized_identification text,
  birth_date timestamp(3) without time zone,
  email text,
  phone_country_code text,
  phone_national_number text,
  address text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_people PRIMARY KEY (id)
);

CREATE TABLE public.roles (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_roles PRIMARY KEY (id)
);

CREATE TABLE public.permissions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_permissions PRIMARY KEY (id)
);

CREATE TABLE public.role_permissions (
  role_id integer NOT NULL,
  permission_id integer NOT NULL,
  CONSTRAINT pk_role_permissions PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE public.users (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  full_name text NOT NULL,
  identification text NOT NULL,
  email text NOT NULL,
  phone text,
  address text,
  password_hash text,
  status user_status NOT NULL DEFAULT 'ACTIVE',
  failed_login_attempts integer NOT NULL DEFAULT 0,
  locked_at timestamp(3) without time zone,
  last_login_at timestamp(3) without time zone,
  person_id integer NOT NULL,
  identification_type identification_type,
  phone_country_code text,
  phone_national_number text,
  subscription_expiration_date timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_users PRIMARY KEY (id)
);

CREATE TABLE public.sessions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  refresh_token_hash text NOT NULL,
  expires_at timestamp(3) without time zone NOT NULL,
  revoked_at timestamp(3) without time zone,
  revocation_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  user_id integer NOT NULL,
  CONSTRAINT pk_sessions PRIMARY KEY (id)
);

CREATE TABLE public.audit_logs (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  action text NOT NULL,
  module text NOT NULL,
  entity_type text,
  entity_id text,
  details jsonb,
  ip_address text,
  user_agent text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  user_id integer,
  CONSTRAINT pk_audit_logs PRIMARY KEY (id)
);

CREATE TABLE public.password_reset_tokens (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  token_hash text NOT NULL,
  expires_at timestamp(3) without time zone NOT NULL,
  used_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  user_id integer NOT NULL,
  CONSTRAINT pk_password_reset_tokens PRIMARY KEY (id)
);

CREATE TABLE public.account_activation_tokens (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  token_hash text NOT NULL,
  expires_at timestamp(3) without time zone NOT NULL,
  used_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  user_id integer NOT NULL,
  CONSTRAINT pk_account_activation_tokens PRIMARY KEY (id)
);

CREATE TABLE public.user_requests (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  full_name text NOT NULL,
  identification text NOT NULL,
  email text NOT NULL,
  phone text,
  address text,
  reason text NOT NULL,
  status request_status NOT NULL DEFAULT 'PENDING',
  rejection_reason text,
  reviewed_at timestamp(3) without time zone,
  reviewed_by_id integer,
  identification_type identification_type,
  phone_country_code text,
  phone_national_number text,
  person_id integer,
  submitted_full_name text,
  submitted_identification text,
  submitted_identification_type identification_type,
  submitted_email text,
  submitted_phone text,
  submitted_phone_country_code text,
  submitted_phone_national_number text,
  submitted_address text,
  submitted_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_user_requests PRIMARY KEY (id)
);

CREATE TABLE public.affiliates (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  full_name text NOT NULL,
  identification text NOT NULL,
  birth_date timestamp(3) without time zone NOT NULL,
  gender text,
  phone text,
  email text,
  address text NOT NULL,
  occupation text,
  workplace text,
  affiliate_type text,
  affiliation_date timestamp(3) without time zone NOT NULL DEFAULT now(),
  status affiliate_status NOT NULL DEFAULT 'ACTIVE',
  identification_type identification_type,
  phone_country_code text,
  phone_national_number text,
  person_id integer,
  role_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_affiliates PRIMARY KEY (id)
);

CREATE TABLE public.affiliate_requests (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  full_name text NOT NULL,
  identification text NOT NULL,
  birth_date timestamp(3) without time zone NOT NULL,
  gender text,
  phone text,
  email text,
  address text NOT NULL,
  occupation text,
  workplace text,
  affiliation_reason text NOT NULL,
  status request_status NOT NULL DEFAULT 'PENDING',
  rejection_reason text,
  reviewed_at timestamp(3) without time zone,
  reviewed_by_id integer,
  identification_type identification_type,
  phone_country_code text,
  phone_national_number text,
  person_id integer,
  submitted_full_name text,
  submitted_identification text,
  submitted_identification_type identification_type,
  submitted_birth_date timestamp(3) without time zone,
  submitted_gender text,
  submitted_phone text,
  submitted_phone_country_code text,
  submitted_phone_national_number text,
  submitted_email text,
  submitted_address text,
  submitted_occupation text,
  submitted_workplace text,
  submitted_affiliation_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_affiliate_requests PRIMARY KEY (id)
);

CREATE TABLE public.affiliate_sanctions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  reason text NOT NULL,
  description text,
  date timestamp(3) without time zone NOT NULL DEFAULT now(),
  status sanction_status NOT NULL DEFAULT 'ACTIVE',
  affiliate_id integer NOT NULL,
  created_by_id integer NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_affiliate_sanctions PRIMARY KEY (id)
);

CREATE TABLE public.governance_positions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_governance_positions PRIMARY KEY (id)
);

CREATE TABLE public.board_terms (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  institutional_profile_id integer NOT NULL,
  starts_on date NOT NULL,
  ends_on date NOT NULL,
  status governance_term_status,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_board_terms PRIMARY KEY (id)
);

CREATE TABLE public.board_appointments (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  board_term_id integer NOT NULL,
  person_id integer NOT NULL,
  position board_position NOT NULL,
  position_id integer,
  affiliate_id integer,
  seat_number integer,
  starts_on date,
  ends_on date,
  appointed_by_assembly_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_board_appointments PRIMARY KEY (id)
);

CREATE TABLE public.assemblies (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  title text NOT NULL,
  assembly_type assembly_type,
  type text,
  date timestamp(3) without time zone NOT NULL,
  scheduled_at timestamp(3) without time zone,
  held_at timestamp(3) without time zone,
  place text NOT NULL,
  description text,
  status assembly_status NOT NULL DEFAULT 'SCHEDULED',
  quorum_type assembly_quorum_type,
  quorum_value integer,
  convocations_locked_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_assemblies PRIMARY KEY (id)
);

CREATE TABLE public.assembly_calls (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  assembly_id integer NOT NULL,
  call_number integer NOT NULL,
  scheduled_at timestamp(3) without time zone NOT NULL,
  quorum_type assembly_quorum_type NOT NULL,
  quorum_value integer NOT NULL,
  started_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_assembly_calls PRIMARY KEY (id)
);

CREATE TABLE public.assembly_convocations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  assembly_id integer NOT NULL,
  affiliate_id integer NOT NULL,
  role_id integer,
  role_name_snapshot text NOT NULL,
  governance_membership_id integer,
  position_name_snapshot text,
  convened_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_assembly_convocations PRIMARY KEY (id)
);

CREATE TABLE public.assembly_attendances (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  status attendance_status NOT NULL,
  registered_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  observations text,
  assembly_id integer NOT NULL,
  affiliate_id integer NOT NULL,
  convocation_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_assembly_attendances PRIMARY KEY (id)
);

CREATE TABLE public.absence_justifications (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  reason text NOT NULL,
  status justification_status NOT NULL DEFAULT 'PENDING',
  rejection_reason text,
  reviewed_at timestamp(3) without time zone,
  assembly_id integer NOT NULL,
  affiliate_id integer NOT NULL,
  attendance_id integer,
  reviewed_by_id integer,
  decision_note text,
  attachment_original_name text,
  attachment_mime_type text,
  attachment_size integer,
  attachment_url text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_absence_justifications PRIMARY KEY (id)
);

CREATE TABLE public.assembly_minutes (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  assembly_id integer NOT NULL,
  content text NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_assembly_minutes PRIMARY KEY (id)
);

CREATE TABLE public.assembly_resolutions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  assembly_id integer NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  resolved_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_assembly_resolutions PRIMARY KEY (id)
);

CREATE TABLE public.events (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  public_id text NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  summary text NOT NULL,
  description text,
  start_at timestamp(3) without time zone NOT NULL,
  end_at timestamp(3) without time zone,
  location text,
  status event_status NOT NULL DEFAULT 'SCHEDULED',
  publication_status publication_status NOT NULL DEFAULT 'DRAFT',
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  initiative_id integer,
  CONSTRAINT pk_events PRIMARY KEY (id)
);

CREATE TABLE public.reservable_resources (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  name text NOT NULL,
  description text,
  location text,
  capacity integer,
  status reservable_resource_status NOT NULL DEFAULT 'ACTIVE',
  price numeric(14,2),
  currency text NOT NULL DEFAULT 'CRC',
  pricing_type resource_pricing_type NOT NULL DEFAULT 'FREE',
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  facility_id integer,
  CONSTRAINT pk_reservable_resources PRIMARY KEY (id)
);

CREATE TABLE public.reservations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  start_at timestamp(3) without time zone NOT NULL,
  end_at timestamp(3) without time zone NOT NULL,
  purpose text NOT NULL,
  estimated_attendees integer,
  notes text,
  status reservation_status NOT NULL DEFAULT 'PENDING',
  approved_at timestamp(3) without time zone,
  rejection_reason text,
  cancelled_at timestamp(3) without time zone,
  resource_id integer NOT NULL,
  requester_user_id integer NOT NULL,
  approved_by_id integer,
  event_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_reservations PRIMARY KEY (id)
);

CREATE TABLE public.financial_accounts (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  currency text NOT NULL DEFAULT 'CRC',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_financial_accounts PRIMARY KEY (id)
);

CREATE TABLE public.financial_charges (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  reservation_id integer NOT NULL,
  amount numeric(14,2) NOT NULL,
  currency text NOT NULL DEFAULT 'CRC',
  status financial_charge_status NOT NULL DEFAULT 'PENDING',
  due_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_financial_charges PRIMARY KEY (id)
);

CREATE TABLE public.payments (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  charge_id integer NOT NULL,
  movement_id integer,
  amount numeric(14,2) NOT NULL,
  status payment_status NOT NULL DEFAULT 'PENDING',
  method payment_method NOT NULL,
  financial_method financial_method,
  reference text,
  paid_at timestamp(3) without time zone,
  recorded_by_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_payments PRIMARY KEY (id)
);

CREATE TABLE public.financial_movements (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  account_id integer,
  type financial_movement_type NOT NULL,
  source financial_movement_source NOT NULL DEFAULT 'MANUAL',
  source_id integer,
  origin_type financial_movement_origin_type,
  amount numeric(14,2) NOT NULL,
  currency text NOT NULL DEFAULT 'CRC',
  description text NOT NULL,
  reference text,
  occurred_at timestamp(3) without time zone NOT NULL,
  recorded_by_id integer,
  status financial_movement_status,
  reversal_of_id integer,
  voided_at timestamp(3) without time zone,
  voided_by_id integer,
  void_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  initiative_id integer,
  destination_type varchar(32),
  CONSTRAINT pk_financial_movements PRIMARY KEY (id)
);

CREATE TABLE public.donations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  donor_person_id integer,
  donor_name text,
  donor_identification text,
  amount numeric(14,2) NOT NULL,
  currency text NOT NULL DEFAULT 'CRC',
  method donation_method NOT NULL,
  financial_method financial_method,
  reference text,
  description text,
  received_at timestamp(3) without time zone NOT NULL,
  status donation_status NOT NULL DEFAULT 'CONFIRMED',
  recorded_by_id integer NOT NULL,
  cancelled_by_id integer,
  cancelled_at timestamp(3) without time zone,
  cancellation_reason text,
  original_movement_id integer,
  reversal_movement_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  donor_id integer,
  CONSTRAINT pk_donations PRIMARY KEY (id)
);

CREATE TABLE public.expenses (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  description text NOT NULL,
  amount numeric(14,2) NOT NULL,
  currency text NOT NULL DEFAULT 'CRC',
  incurred_at timestamp(3) without time zone NOT NULL,
  status expense_status NOT NULL DEFAULT 'PENDING',
  authorization_resolution_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  maintenance_work_order_id integer,
  board_resolution_id integer,
  expense_type varchar(32),
  maintenance_cost_recognized_at timestamp(3) without time zone,
  CONSTRAINT pk_expenses PRIMARY KEY (id)
);

CREATE TABLE public.expense_documents (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  expense_id integer NOT NULL,
  original_name text NOT NULL,
  mime_type text NOT NULL,
  size integer NOT NULL,
  url text NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  document_version_id integer,
  CONSTRAINT pk_expense_documents PRIMARY KEY (id)
);

CREATE TABLE public.disbursements (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  expense_id integer NOT NULL,
  movement_id integer NOT NULL,
  amount numeric(14,2) NOT NULL,
  currency text NOT NULL DEFAULT 'CRC',
  method financial_method NOT NULL,
  reference text,
  paid_at timestamp(3) without time zone NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  purpose varchar(32) NOT NULL DEFAULT 'REGULAR',
  settled_at timestamp(3) without time zone,
  settled_by_user_id integer,
  CONSTRAINT pk_disbursements PRIMARY KEY (id)
);

CREATE TABLE public.funding_allocations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  expense_id integer NOT NULL,
  source_type funding_source_type NOT NULL,
  amount numeric(14,2) NOT NULL,
  income_movement_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_funding_allocations PRIMARY KEY (id)
);

CREATE TABLE public.inventory_categories (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_inventory_categories PRIMARY KEY (id)
);

CREATE TABLE public.inventory_items (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  current_quantity integer NOT NULL DEFAULT 0,
  minimum_quantity integer NOT NULL DEFAULT 0,
  unit text NOT NULL DEFAULT 'unidad',
  location text,
  status inventory_item_status NOT NULL DEFAULT 'ACTIVE',
  condition inventory_item_condition NOT NULL DEFAULT 'GOOD',
  category_id integer NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_inventory_items PRIMARY KEY (id)
);

CREATE TABLE public.inventory_movements (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  type inventory_movement_type NOT NULL,
  quantity integer NOT NULL,
  quantity_delta integer,
  reason text NOT NULL,
  reference text,
  notes text,
  item_id integer NOT NULL,
  created_by_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_movements PRIMARY KEY (id)
);

CREATE TABLE public.inventory_loans (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  quantity integer NOT NULL,
  borrower_name text NOT NULL,
  loan_date timestamp(3) without time zone NOT NULL DEFAULT now(),
  expected_return_date timestamp(3) without time zone NOT NULL,
  returned_at timestamp(3) without time zone,
  status inventory_loan_status NOT NULL DEFAULT 'ACTIVE',
  notes text,
  item_id integer NOT NULL,
  borrower_affiliate_id integer,
  created_by_id integer,
  received_by_id integer,
  cancelled_by_id integer,
  cancelled_at timestamp(3) without time zone,
  cancellation_reason text,
  checkout_movement_id integer,
  return_movement_id integer,
  cancellation_movement_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_inventory_loans PRIMARY KEY (id)
);

CREATE TABLE public.volunteer_opportunities (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  title text NOT NULL,
  description text,
  location text,
  capacity integer,
  application_deadline timestamp(3) without time zone,
  status volunteer_opportunity_status NOT NULL DEFAULT 'DRAFT',
  created_by_user_id integer NOT NULL,
  published_at timestamp(3) without time zone,
  closed_at timestamp(3) without time zone,
  completed_at timestamp(3) without time zone,
  cancelled_at timestamp(3) without time zone,
  cancellation_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  initiative_id integer,
  CONSTRAINT pk_volunteer_opportunities PRIMARY KEY (id)
);

CREATE TABLE public.volunteer_sessions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  opportunity_id integer NOT NULL,
  title text,
  description text,
  location text,
  start_at timestamp(3) without time zone NOT NULL,
  end_at timestamp(3) without time zone NOT NULL,
  status volunteer_session_status NOT NULL DEFAULT 'SCHEDULED',
  cancelled_at timestamp(3) without time zone,
  cancellation_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_volunteer_sessions PRIMARY KEY (id)
);

CREATE TABLE public.volunteer_applications (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  opportunity_id integer NOT NULL,
  person_id integer,
  submitted_full_name text NOT NULL,
  submitted_identification_type identification_type,
  submitted_identification text,
  submitted_normalized_identification text,
  submitted_email text,
  submitted_phone text,
  motivation text,
  status volunteer_application_status NOT NULL DEFAULT 'PENDING',
  requested_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  reviewed_by_user_id integer,
  reviewed_at timestamp(3) without time zone,
  rejection_reason text,
  withdrawn_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_volunteer_applications PRIMARY KEY (id)
);

CREATE TABLE public.volunteer_participations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  opportunity_id integer NOT NULL,
  person_id integer NOT NULL,
  application_id integer NOT NULL,
  status volunteer_participation_status NOT NULL DEFAULT 'CONFIRMED',
  confirmed_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  completed_at timestamp(3) without time zone,
  cancelled_at timestamp(3) without time zone,
  cancellation_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_volunteer_participations PRIMARY KEY (id)
);

CREATE TABLE public.volunteer_attendances (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  participation_id integer NOT NULL,
  session_id integer NOT NULL,
  status volunteer_attendance_status NOT NULL,
  check_in_at timestamp(3) without time zone,
  check_out_at timestamp(3) without time zone,
  credited_hours numeric(8,2) NOT NULL DEFAULT 0,
  notes text,
  recorded_by_user_id integer NOT NULL,
  recorded_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_volunteer_attendances PRIMARY KEY (id)
);

CREATE TABLE public.ventures (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  name text NOT NULL,
  description text,
  offer_description text,
  business_phone text,
  business_email text,
  website_url text,
  social_url text,
  location_text text,
  status venture_status NOT NULL DEFAULT 'ACTIVE',
  publication_status venture_publication_status NOT NULL DEFAULT 'UNPUBLISHED',
  incorporated_at timestamp(3) without time zone NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_ventures PRIMARY KEY (id)
);

CREATE TABLE public.venture_associations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  person_id integer NOT NULL,
  venture_id integer NOT NULL,
  started_at timestamp(3) without time zone NOT NULL,
  ended_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_venture_associations PRIMARY KEY (id)
);

CREATE TABLE public.venture_requests (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  purpose venture_request_purpose NOT NULL,
  status venture_request_status NOT NULL DEFAULT 'SUBMITTED',
  reconciled_person_id integer,
  venture_id integer,
  resolved_at timestamp(3) without time zone,
  decision_reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL,
  CONSTRAINT pk_venture_requests PRIMARY KEY (id)
);

CREATE TABLE public.venture_request_revisions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  request_id integer NOT NULL,
  revision_number integer NOT NULL,
  payload_version integer NOT NULL,
  submitted_data jsonb NOT NULL,
  submitted_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_venture_request_revisions PRIMARY KEY (id)
);

CREATE TABLE public.board_sessions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  term_id integer NOT NULL,
  session_number integer NOT NULL,
  scheduled_at timestamp(3) without time zone,
  held_at timestamp(3) without time zone,
  status varchar(32) NOT NULL,
  notes text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_board_sessions PRIMARY KEY (id)
);

CREATE TABLE public.board_minutes (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  board_session_id integer NOT NULL,
  document_record_id integer,
  legacy_content text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_board_minutes PRIMARY KEY (id)
);

CREATE TABLE public.board_resolutions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  board_session_id integer NOT NULL,
  resolution_number integer NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  resolved_at timestamp(3) without time zone,
  document_record_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_board_resolutions PRIMARY KEY (id)
);

CREATE TABLE public.event_revisions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  event_id integer NOT NULL,
  revision_number integer NOT NULL,
  snapshot jsonb NOT NULL,
  submitted_by_user_id integer,
  submitted_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_event_revisions PRIMARY KEY (id)
);

CREATE TABLE public.event_review_decisions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  event_revision_id integer NOT NULL,
  membership_id integer NOT NULL,
  decided_by_user_id integer,
  command_key varchar(128) COLLATE "C" NOT NULL,
  result varchar(32) NOT NULL,
  reason text,
  decided_at timestamp(3) without time zone NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_event_review_decisions PRIMARY KEY (id)
);

CREATE TABLE public.event_budget_lines (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  event_id integer NOT NULL,
  line_number integer NOT NULL,
  concept text NOT NULL,
  amount numeric(14,2) NOT NULL,
  currency char(3) NOT NULL DEFAULT 'CRC',
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_event_budget_lines PRIMARY KEY (id)
);

CREATE TABLE public.in_kind_donations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  donor_id integer,
  recorded_by_user_id integer,
  status varchar(32) NOT NULL,
  description text,
  offered_at timestamp(3) without time zone,
  submitted_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_in_kind_donations PRIMARY KEY (id)
);

CREATE TABLE public.in_kind_donation_items (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  donation_id integer NOT NULL,
  line_number integer NOT NULL,
  description text NOT NULL,
  quantity numeric(14,3) NOT NULL,
  unit varchar(32) NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_in_kind_donation_items PRIMARY KEY (id)
);

CREATE TABLE public.in_kind_donation_decisions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  donation_id integer NOT NULL,
  membership_id integer NOT NULL,
  board_resolution_id integer,
  decided_by_user_id integer,
  command_key varchar(128) COLLATE "C" NOT NULL,
  result varchar(32) NOT NULL,
  decided_at timestamp(3) without time zone NOT NULL,
  reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_in_kind_donation_decisions PRIMARY KEY (id)
);

CREATE TABLE public.in_kind_donation_receipts (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  donation_id integer NOT NULL,
  receipt_number integer NOT NULL,
  received_by_user_id integer NOT NULL,
  received_at timestamp(3) without time zone NOT NULL,
  status varchar(32) NOT NULL,
  document_record_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_in_kind_donation_receipts PRIMARY KEY (id)
);

CREATE TABLE public.in_kind_donation_receipt_lines (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  receipt_id integer NOT NULL,
  line_number integer NOT NULL,
  donation_item_id integer NOT NULL,
  item_id integer NOT NULL,
  quantity numeric(14,3) NOT NULL,
  condition varchar(32) NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_in_kind_donation_receipt_lines PRIMARY KEY (id)
);

CREATE TABLE public.institutional_facilities (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code varchar(64) NOT NULL,
  name varchar(200) NOT NULL,
  description text,
  parent_facility_id integer,
  status varchar(32) NOT NULL,
  location text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_institutional_facilities PRIMARY KEY (id)
);

CREATE TABLE public.inventory_stock_lots (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code varchar(64) NOT NULL,
  item_id integer NOT NULL,
  quantity numeric(14,3) NOT NULL,
  condition varchar(32) NOT NULL,
  status varchar(32) NOT NULL,
  notes text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_stock_lots PRIMARY KEY (id)
);

CREATE TABLE public.inventory_units (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  asset_code varchar(64) NOT NULL,
  item_id integer NOT NULL,
  condition varchar(32) NOT NULL,
  status varchar(32) NOT NULL,
  serial_number varchar(128),
  notes text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_units PRIMARY KEY (id)
);

CREATE TABLE public.maintenance_incidents (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  facility_id integer,
  stock_lot_id integer,
  unit_id integer,
  reported_by_person_id integer,
  status varchar(32) NOT NULL,
  description text NOT NULL,
  reported_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_maintenance_incidents PRIMARY KEY (id)
);

CREATE TABLE public.maintenance_work_orders (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  incident_id integer,
  facility_id integer,
  stock_lot_id integer,
  unit_id integer,
  executor_person_id integer,
  authorized_by_user_id integer,
  initiative_id integer,
  document_record_id integer,
  status varchar(32) NOT NULL,
  scope text,
  authorized_at timestamp(3) without time zone,
  assigned_at timestamp(3) without time zone,
  verified_at timestamp(3) without time zone,
  closed_at timestamp(3) without time zone,
  verification_evidence jsonb,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_maintenance_work_orders PRIMARY KEY (id)
);

CREATE TABLE public.resource_unavailabilities (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  reservable_resource_id integer NOT NULL,
  incident_id integer,
  work_order_id integer,
  starts_at timestamp(3) without time zone NOT NULL,
  ends_at timestamp(3) without time zone,
  released_at timestamp(3) without time zone,
  released_by_user_id integer,
  reason text NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_resource_unavailabilities PRIMARY KEY (id)
);

CREATE TABLE public.inventory_loan_checkout_allocations (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  loan_id integer NOT NULL,
  lot_id integer,
  unit_id integer,
  quantity numeric(14,3) NOT NULL,
  checkout_movement_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  notes text,
  CONSTRAINT pk_inventory_loan_checkout_allocations PRIMARY KEY (id)
);

CREATE TABLE public.inventory_loan_returns (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  loan_id integer NOT NULL,
  return_number integer NOT NULL,
  received_by_user_id integer NOT NULL,
  received_at timestamp(3) without time zone NOT NULL,
  status varchar(32) NOT NULL,
  notes text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_loan_returns PRIMARY KEY (id)
);

CREATE TABLE public.inventory_loan_return_details (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  return_id integer NOT NULL,
  checkout_allocation_id integer NOT NULL,
  quantity numeric(14,3) NOT NULL,
  condition varchar(32) NOT NULL,
  available_entry_movement_id integer,
  notes text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_loan_return_details PRIMARY KEY (id)
);

CREATE TABLE public.inventory_loan_shortages (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  checkout_allocation_id integer NOT NULL,
  quantity numeric(14,3) NOT NULL,
  status varchar(32) NOT NULL,
  reason text,
  detected_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_loan_shortages PRIMARY KEY (id)
);

CREATE TABLE public.inventory_loan_shortage_decisions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  shortage_id integer NOT NULL,
  membership_id integer NOT NULL,
  board_resolution_id integer,
  decided_by_user_id integer,
  command_key varchar(128) COLLATE "C" NOT NULL,
  result varchar(32) NOT NULL,
  reason text,
  decided_at timestamp(3) without time zone NOT NULL,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_inventory_loan_shortage_decisions PRIMARY KEY (id)
);

CREATE TABLE public.initiatives (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code varchar(64) NOT NULL,
  name varchar(200) NOT NULL,
  description text,
  status varchar(32),
  started_at date,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_initiatives PRIMARY KEY (id)
);

CREATE TABLE public.document_records (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  series_id integer,
  folio_year integer,
  folio_sequence integer,
  official_registration_request_key varchar(128),
  classification varchar(16) NOT NULL,
  status varchar(32) NOT NULL,
  official_registered_at timestamp(3) without time zone,
  voided_at timestamp(3) without time zone,
  void_reason text,
  title varchar(300),
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_document_records PRIMARY KEY (id)
);

CREATE TABLE public.document_versions (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  document_id integer NOT NULL,
  version_number integer NOT NULL,
  storage_key varchar(500) NOT NULL,
  original_name varchar(255) NOT NULL,
  mime_type varchar(127) NOT NULL,
  size_bytes integer NOT NULL,
  checksum_sha256 char(64) NOT NULL,
  created_by_user_id integer,
  rectifies_version_id integer,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_document_versions PRIMARY KEY (id)
);

CREATE TABLE public.document_series (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  code varchar(64) NOT NULL,
  name varchar(200) NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  retired_at timestamp(3) without time zone,
  CONSTRAINT pk_document_series PRIMARY KEY (id)
);

CREATE TABLE public.donors (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  donor_type varchar(16) NOT NULL,
  person_id integer,
  legal_name varchar(300),
  identification_type varchar(32) NOT NULL,
  normalized_identification varchar(128) NOT NULL,
  display_name varchar(300) NOT NULL,
  verified_at timestamp(3) without time zone,
  verification_note text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  archived_at timestamp(3) without time zone,
  CONSTRAINT pk_donors PRIMARY KEY (id)
);

CREATE TABLE public.expense_document_logs (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  expense_document_id integer NOT NULL,
  actor_user_id integer,
  event_type varchar(32) NOT NULL,
  event_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  snapshot jsonb NOT NULL,
  reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_expense_document_logs PRIMARY KEY (id)
);

CREATE TABLE public.correspondences (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  document_record_id integer NOT NULL,
  direction varchar(16) NOT NULL,
  counterparty text NOT NULL,
  received_or_sent_at timestamp(3) without time zone,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  updated_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_correspondences PRIMARY KEY (id)
);

CREATE TABLE public.correspondence_logs (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  correspondence_id integer NOT NULL,
  actor_user_id integer,
  event_type varchar(32) NOT NULL,
  event_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  snapshot jsonb NOT NULL,
  reason text,
  created_at timestamp(3) without time zone NOT NULL DEFAULT now(),
  CONSTRAINT pk_correspondence_logs PRIMARY KEY (id)
);

CREATE TABLE public.document_folio_counters (
  series_id integer NOT NULL,
  folio_year integer NOT NULL,
  last_assigned integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_document_folio_counters PRIMARY KEY (series_id, folio_year)
);

CREATE TABLE public.inventory_stock_lot_receipt_origins (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  lot_id integer NOT NULL,
  receipt_line_id integer NOT NULL,
  CONSTRAINT pk_inventory_stock_lot_receipt_origins PRIMARY KEY (id)
);

CREATE TABLE public.inventory_unit_receipt_origins (
  id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  unit_id integer NOT NULL,
  receipt_line_id integer NOT NULL,
  CONSTRAINT pk_inventory_unit_receipt_origins PRIMARY KEY (id)
);


-- ===== MODULE: 02_foreign_keys.sql =====
-- 76 baseline FKs (B003 replaced by UserRole) + 81 V2 firm FKs.
ALTER TABLE public.role_permissions ADD CONSTRAINT fk_role_permissions_role_id FOREIGN KEY (role_id) REFERENCES public.roles (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B001
ALTER TABLE public.role_permissions ADD CONSTRAINT fk_role_permissions_permission_id FOREIGN KEY (permission_id) REFERENCES public.permissions (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B002
ALTER TABLE public.users ADD CONSTRAINT fk_users_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B004
ALTER TABLE public.sessions ADD CONSTRAINT fk_sessions_user_id FOREIGN KEY (user_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B005
ALTER TABLE public.audit_logs ADD CONSTRAINT fk_audit_logs_user_id FOREIGN KEY (user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B006
ALTER TABLE public.password_reset_tokens ADD CONSTRAINT fk_password_reset_tokens_user_id FOREIGN KEY (user_id) REFERENCES public.users (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B007
ALTER TABLE public.account_activation_tokens ADD CONSTRAINT fk_account_activation_tokens_user_id FOREIGN KEY (user_id) REFERENCES public.users (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B008
ALTER TABLE public.user_requests ADD CONSTRAINT fk_user_requests_reviewed_by_id FOREIGN KEY (reviewed_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B009
ALTER TABLE public.user_requests ADD CONSTRAINT fk_user_requests_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B010
ALTER TABLE public.affiliates ADD CONSTRAINT fk_affiliates_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B011
ALTER TABLE public.affiliate_requests ADD CONSTRAINT fk_affiliate_requests_reviewed_by_id FOREIGN KEY (reviewed_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B012
ALTER TABLE public.affiliate_requests ADD CONSTRAINT fk_affiliate_requests_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B013
ALTER TABLE public.affiliate_sanctions ADD CONSTRAINT fk_affiliate_sanctions_affiliate_id FOREIGN KEY (affiliate_id) REFERENCES public.affiliates (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B014
ALTER TABLE public.affiliate_sanctions ADD CONSTRAINT fk_affiliate_sanctions_created_by_id FOREIGN KEY (created_by_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B015
ALTER TABLE public.board_appointments ADD CONSTRAINT fk_board_appointments_board_term_id FOREIGN KEY (board_term_id) REFERENCES public.board_terms (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B016
ALTER TABLE public.board_appointments ADD CONSTRAINT fk_board_appointments_position_id FOREIGN KEY (position_id) REFERENCES public.governance_positions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B017
ALTER TABLE public.board_appointments ADD CONSTRAINT fk_board_appointments_affiliate_id FOREIGN KEY (affiliate_id) REFERENCES public.affiliates (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B018
ALTER TABLE public.board_appointments ADD CONSTRAINT fk_board_appointments_appointed_by_assembly_id FOREIGN KEY (appointed_by_assembly_id) REFERENCES public.assemblies (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B019
ALTER TABLE public.assembly_calls ADD CONSTRAINT fk_assembly_calls_assembly_id FOREIGN KEY (assembly_id) REFERENCES public.assemblies (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B020
ALTER TABLE public.assembly_convocations ADD CONSTRAINT fk_assembly_convocations_assembly_id FOREIGN KEY (assembly_id) REFERENCES public.assemblies (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B021
ALTER TABLE public.assembly_convocations ADD CONSTRAINT fk_assembly_convocations_affiliate_id FOREIGN KEY (affiliate_id) REFERENCES public.affiliates (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B022
ALTER TABLE public.assembly_convocations ADD CONSTRAINT fk_assembly_convocations_governance_membership_id FOREIGN KEY (governance_membership_id) REFERENCES public.board_appointments (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B023
ALTER TABLE public.assembly_attendances ADD CONSTRAINT fk_assembly_attendances_convocation_id FOREIGN KEY (convocation_id) REFERENCES public.assembly_convocations (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B024
ALTER TABLE public.absence_justifications ADD CONSTRAINT fk_absence_justifications_attendance_id FOREIGN KEY (attendance_id) REFERENCES public.assembly_attendances (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B025
ALTER TABLE public.absence_justifications ADD CONSTRAINT fk_absence_justifications_reviewed_by_id FOREIGN KEY (reviewed_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B026
ALTER TABLE public.assembly_minutes ADD CONSTRAINT fk_assembly_minutes_assembly_id FOREIGN KEY (assembly_id) REFERENCES public.assemblies (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B027
ALTER TABLE public.assembly_resolutions ADD CONSTRAINT fk_assembly_resolutions_assembly_id FOREIGN KEY (assembly_id) REFERENCES public.assemblies (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B028
ALTER TABLE public.reservations ADD CONSTRAINT fk_reservations_resource_id FOREIGN KEY (resource_id) REFERENCES public.reservable_resources (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B029
ALTER TABLE public.reservations ADD CONSTRAINT fk_reservations_requester_user_id FOREIGN KEY (requester_user_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B030
ALTER TABLE public.reservations ADD CONSTRAINT fk_reservations_approved_by_id FOREIGN KEY (approved_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B031
ALTER TABLE public.reservations ADD CONSTRAINT fk_reservations_event_id FOREIGN KEY (event_id) REFERENCES public.events (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B032
ALTER TABLE public.financial_charges ADD CONSTRAINT fk_financial_charges_reservation_id FOREIGN KEY (reservation_id) REFERENCES public.reservations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B033
ALTER TABLE public.payments ADD CONSTRAINT fk_payments_charge_id FOREIGN KEY (charge_id) REFERENCES public.financial_charges (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B034
ALTER TABLE public.payments ADD CONSTRAINT fk_payments_movement_id FOREIGN KEY (movement_id) REFERENCES public.financial_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B035
ALTER TABLE public.payments ADD CONSTRAINT fk_payments_recorded_by_id FOREIGN KEY (recorded_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B036
ALTER TABLE public.financial_movements ADD CONSTRAINT fk_financial_movements_account_id FOREIGN KEY (account_id) REFERENCES public.financial_accounts (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B037
ALTER TABLE public.financial_movements ADD CONSTRAINT fk_financial_movements_recorded_by_id FOREIGN KEY (recorded_by_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B038
ALTER TABLE public.financial_movements ADD CONSTRAINT fk_financial_movements_voided_by_id FOREIGN KEY (voided_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B039
ALTER TABLE public.financial_movements ADD CONSTRAINT fk_financial_movements_reversal_of_id FOREIGN KEY (reversal_of_id) REFERENCES public.financial_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B040
ALTER TABLE public.donations ADD CONSTRAINT fk_donations_donor_person_id FOREIGN KEY (donor_person_id) REFERENCES public.people (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B041
ALTER TABLE public.donations ADD CONSTRAINT fk_donations_recorded_by_id FOREIGN KEY (recorded_by_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B042
ALTER TABLE public.donations ADD CONSTRAINT fk_donations_cancelled_by_id FOREIGN KEY (cancelled_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B043
ALTER TABLE public.donations ADD CONSTRAINT fk_donations_original_movement_id FOREIGN KEY (original_movement_id) REFERENCES public.financial_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B044
ALTER TABLE public.expenses ADD CONSTRAINT fk_expenses_authorization_resolution_id FOREIGN KEY (authorization_resolution_id) REFERENCES public.assembly_resolutions (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B045
ALTER TABLE public.expense_documents ADD CONSTRAINT fk_expense_documents_expense_id FOREIGN KEY (expense_id) REFERENCES public.expenses (id) ON DELETE CASCADE ON UPDATE CASCADE; -- B046
ALTER TABLE public.disbursements ADD CONSTRAINT fk_disbursements_expense_id FOREIGN KEY (expense_id) REFERENCES public.expenses (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B047
ALTER TABLE public.disbursements ADD CONSTRAINT fk_disbursements_movement_id FOREIGN KEY (movement_id) REFERENCES public.financial_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B048
ALTER TABLE public.funding_allocations ADD CONSTRAINT fk_funding_allocations_expense_id FOREIGN KEY (expense_id) REFERENCES public.expenses (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B049
ALTER TABLE public.funding_allocations ADD CONSTRAINT fk_funding_allocations_income_movement_id FOREIGN KEY (income_movement_id) REFERENCES public.financial_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B050
ALTER TABLE public.inventory_items ADD CONSTRAINT fk_inventory_items_category_id FOREIGN KEY (category_id) REFERENCES public.inventory_categories (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B051
ALTER TABLE public.inventory_movements ADD CONSTRAINT fk_inventory_movements_item_id FOREIGN KEY (item_id) REFERENCES public.inventory_items (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B052
ALTER TABLE public.inventory_movements ADD CONSTRAINT fk_inventory_movements_created_by_id FOREIGN KEY (created_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B053
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_item_id FOREIGN KEY (item_id) REFERENCES public.inventory_items (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B054
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_borrower_affiliate_id FOREIGN KEY (borrower_affiliate_id) REFERENCES public.affiliates (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B055
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_created_by_id FOREIGN KEY (created_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B056
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_received_by_id FOREIGN KEY (received_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B057
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_cancelled_by_id FOREIGN KEY (cancelled_by_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B058
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_checkout_movement_id FOREIGN KEY (checkout_movement_id) REFERENCES public.inventory_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B059
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_return_movement_id FOREIGN KEY (return_movement_id) REFERENCES public.inventory_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B060
ALTER TABLE public.inventory_loans ADD CONSTRAINT fk_inventory_loans_cancellation_movement_id FOREIGN KEY (cancellation_movement_id) REFERENCES public.inventory_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B061
ALTER TABLE public.volunteer_opportunities ADD CONSTRAINT fk_volunteer_opportunities_created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B062
ALTER TABLE public.volunteer_sessions ADD CONSTRAINT fk_volunteer_sessions_opportunity_id FOREIGN KEY (opportunity_id) REFERENCES public.volunteer_opportunities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B063
ALTER TABLE public.volunteer_applications ADD CONSTRAINT fk_volunteer_applications_opportunity_id FOREIGN KEY (opportunity_id) REFERENCES public.volunteer_opportunities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B064
ALTER TABLE public.volunteer_applications ADD CONSTRAINT fk_volunteer_applications_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B065
ALTER TABLE public.volunteer_applications ADD CONSTRAINT fk_volunteer_applications_reviewed_by_user_id FOREIGN KEY (reviewed_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B066
ALTER TABLE public.volunteer_participations ADD CONSTRAINT fk_volunteer_participations_opportunity_id FOREIGN KEY (opportunity_id) REFERENCES public.volunteer_opportunities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B067
ALTER TABLE public.volunteer_participations ADD CONSTRAINT fk_volunteer_participations_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B068
ALTER TABLE public.volunteer_participations ADD CONSTRAINT fk_volunteer_participations_application_id FOREIGN KEY (application_id) REFERENCES public.volunteer_applications (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B069
ALTER TABLE public.volunteer_attendances ADD CONSTRAINT fk_volunteer_attendances_participation_id FOREIGN KEY (participation_id) REFERENCES public.volunteer_participations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B070
ALTER TABLE public.volunteer_attendances ADD CONSTRAINT fk_volunteer_attendances_session_id FOREIGN KEY (session_id) REFERENCES public.volunteer_sessions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B071
ALTER TABLE public.volunteer_attendances ADD CONSTRAINT fk_volunteer_attendances_recorded_by_user_id FOREIGN KEY (recorded_by_user_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B072
ALTER TABLE public.venture_associations ADD CONSTRAINT fk_venture_associations_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B073
ALTER TABLE public.venture_associations ADD CONSTRAINT fk_venture_associations_venture_id FOREIGN KEY (venture_id) REFERENCES public.ventures (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B074
ALTER TABLE public.venture_requests ADD CONSTRAINT fk_venture_requests_reconciled_person_id FOREIGN KEY (reconciled_person_id) REFERENCES public.people (id) ON DELETE SET NULL ON UPDATE CASCADE; -- B075
ALTER TABLE public.venture_requests ADD CONSTRAINT fk_venture_requests_venture_id FOREIGN KEY (venture_id) REFERENCES public.ventures (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B076
ALTER TABLE public.venture_request_revisions ADD CONSTRAINT fk_venture_request_revisions_request_id FOREIGN KEY (request_id) REFERENCES public.venture_requests (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- B077
ALTER TABLE public.board_sessions ADD CONSTRAINT fk_board_sessions_term_id FOREIGN KEY (term_id) REFERENCES public.board_terms (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V001
ALTER TABLE public.board_minutes ADD CONSTRAINT fk_board_minutes_board_session_id FOREIGN KEY (board_session_id) REFERENCES public.board_sessions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V002
ALTER TABLE public.board_resolutions ADD CONSTRAINT fk_board_resolutions_board_session_id FOREIGN KEY (board_session_id) REFERENCES public.board_sessions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V003
ALTER TABLE public.event_revisions ADD CONSTRAINT fk_event_revisions_event_id FOREIGN KEY (event_id) REFERENCES public.events (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V006
ALTER TABLE public.event_revisions ADD CONSTRAINT fk_event_revisions_submitted_by_user_id FOREIGN KEY (submitted_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V007
ALTER TABLE public.event_review_decisions ADD CONSTRAINT fk_event_review_decisions_event_revision_id FOREIGN KEY (event_revision_id) REFERENCES public.event_revisions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V008
ALTER TABLE public.event_review_decisions ADD CONSTRAINT fk_event_review_decisions_membership_id FOREIGN KEY (membership_id) REFERENCES public.board_appointments (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V009
ALTER TABLE public.event_review_decisions ADD CONSTRAINT fk_event_review_decisions_decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V010
ALTER TABLE public.event_budget_lines ADD CONSTRAINT fk_event_budget_lines_event_id FOREIGN KEY (event_id) REFERENCES public.events (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V011
ALTER TABLE public.in_kind_donations ADD CONSTRAINT fk_in_kind_donations_donor_id FOREIGN KEY (donor_id) REFERENCES public.donors (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V012
ALTER TABLE public.in_kind_donations ADD CONSTRAINT fk_in_kind_donations_recorded_by_user_id FOREIGN KEY (recorded_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V013
ALTER TABLE public.in_kind_donation_items ADD CONSTRAINT fk_in_kind_donation_items_donation_id FOREIGN KEY (donation_id) REFERENCES public.in_kind_donations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V014
ALTER TABLE public.in_kind_donation_decisions ADD CONSTRAINT fk_in_kind_donation_decisions_donation_id FOREIGN KEY (donation_id) REFERENCES public.in_kind_donations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V015
ALTER TABLE public.in_kind_donation_decisions ADD CONSTRAINT fk_in_kind_donation_decisions_membership_id FOREIGN KEY (membership_id) REFERENCES public.board_appointments (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V016
ALTER TABLE public.in_kind_donation_decisions ADD CONSTRAINT fk_in_kind_donation_decisions_board_resolution_id FOREIGN KEY (board_resolution_id) REFERENCES public.board_resolutions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V017
ALTER TABLE public.in_kind_donation_decisions ADD CONSTRAINT fk_in_kind_donation_decisions_decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V018
ALTER TABLE public.in_kind_donation_receipts ADD CONSTRAINT fk_in_kind_donation_receipts_donation_id FOREIGN KEY (donation_id) REFERENCES public.in_kind_donations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V019
ALTER TABLE public.in_kind_donation_receipts ADD CONSTRAINT fk_in_kind_donation_receipts_received_by_user_id FOREIGN KEY (received_by_user_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V020
ALTER TABLE public.in_kind_donation_receipt_lines ADD CONSTRAINT fk_in_kind_donation_receipt_lines_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.in_kind_donation_receipts (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V021
ALTER TABLE public.in_kind_donation_receipt_lines ADD CONSTRAINT fk_in_kind_donation_receipt_lines_donation_item_id FOREIGN KEY (donation_item_id) REFERENCES public.in_kind_donation_items (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V022
ALTER TABLE public.in_kind_donation_receipt_lines ADD CONSTRAINT fk_in_kind_donation_receipt_lines_item_id FOREIGN KEY (item_id) REFERENCES public.inventory_items (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V023
ALTER TABLE public.institutional_facilities ADD CONSTRAINT fk_institutional_facilities_parent_facility_id FOREIGN KEY (parent_facility_id) REFERENCES public.institutional_facilities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V024
ALTER TABLE public.reservable_resources ADD CONSTRAINT fk_reservable_resources_facility_id FOREIGN KEY (facility_id) REFERENCES public.institutional_facilities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V025
ALTER TABLE public.inventory_stock_lots ADD CONSTRAINT fk_inventory_stock_lots_item_id FOREIGN KEY (item_id) REFERENCES public.inventory_items (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V026
ALTER TABLE public.inventory_stock_lot_receipt_origins ADD CONSTRAINT fk_inventory_stock_lot_receipt_origins_lot_id FOREIGN KEY (lot_id) REFERENCES public.inventory_stock_lots (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V027
ALTER TABLE public.inventory_stock_lot_receipt_origins ADD CONSTRAINT fk_inventory_stock_lot_receipt_origins_receipt_line_id FOREIGN KEY (receipt_line_id) REFERENCES public.in_kind_donation_receipt_lines (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V028
ALTER TABLE public.inventory_units ADD CONSTRAINT fk_inventory_units_item_id FOREIGN KEY (item_id) REFERENCES public.inventory_items (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V029
ALTER TABLE public.inventory_unit_receipt_origins ADD CONSTRAINT fk_inventory_unit_receipt_origins_unit_id FOREIGN KEY (unit_id) REFERENCES public.inventory_units (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V030
ALTER TABLE public.inventory_unit_receipt_origins ADD CONSTRAINT fk_inventory_unit_receipt_origins_receipt_line_id FOREIGN KEY (receipt_line_id) REFERENCES public.in_kind_donation_receipt_lines (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V031
ALTER TABLE public.maintenance_incidents ADD CONSTRAINT fk_maintenance_incidents_facility_id FOREIGN KEY (facility_id) REFERENCES public.institutional_facilities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V032
ALTER TABLE public.maintenance_incidents ADD CONSTRAINT fk_maintenance_incidents_stock_lot_id FOREIGN KEY (stock_lot_id) REFERENCES public.inventory_stock_lots (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V033
ALTER TABLE public.maintenance_incidents ADD CONSTRAINT fk_maintenance_incidents_unit_id FOREIGN KEY (unit_id) REFERENCES public.inventory_units (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V034
ALTER TABLE public.maintenance_incidents ADD CONSTRAINT fk_maintenance_incidents_reported_by_person_id FOREIGN KEY (reported_by_person_id) REFERENCES public.people (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V035
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_incident_id FOREIGN KEY (incident_id) REFERENCES public.maintenance_incidents (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V036
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_facility_id FOREIGN KEY (facility_id) REFERENCES public.institutional_facilities (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V037
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_stock_lot_id FOREIGN KEY (stock_lot_id) REFERENCES public.inventory_stock_lots (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V038
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_unit_id FOREIGN KEY (unit_id) REFERENCES public.inventory_units (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V039
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_executor_person_id FOREIGN KEY (executor_person_id) REFERENCES public.people (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V040
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_authorized_by_user_id FOREIGN KEY (authorized_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V041
ALTER TABLE public.expenses ADD CONSTRAINT fk_expenses_maintenance_work_order_id FOREIGN KEY (maintenance_work_order_id) REFERENCES public.maintenance_work_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V042
ALTER TABLE public.expenses ADD CONSTRAINT fk_expenses_board_resolution_id FOREIGN KEY (board_resolution_id) REFERENCES public.board_resolutions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V043
ALTER TABLE public.disbursements ADD CONSTRAINT fk_disbursements_settled_by_user_id FOREIGN KEY (settled_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V044
ALTER TABLE public.resource_unavailabilities ADD CONSTRAINT fk_resource_unavailabilities_reservable_resource_id FOREIGN KEY (reservable_resource_id) REFERENCES public.reservable_resources (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V045
ALTER TABLE public.resource_unavailabilities ADD CONSTRAINT fk_resource_unavailabilities_incident_id FOREIGN KEY (incident_id) REFERENCES public.maintenance_incidents (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V046
ALTER TABLE public.resource_unavailabilities ADD CONSTRAINT fk_resource_unavailabilities_work_order_id FOREIGN KEY (work_order_id) REFERENCES public.maintenance_work_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V047
ALTER TABLE public.resource_unavailabilities ADD CONSTRAINT fk_resource_unavailabilities_released_by_user_id FOREIGN KEY (released_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V048
ALTER TABLE public.inventory_loan_checkout_allocations ADD CONSTRAINT fk_inventory_loan_checkout_allocations_loan_id FOREIGN KEY (loan_id) REFERENCES public.inventory_loans (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V049
ALTER TABLE public.inventory_loan_checkout_allocations ADD CONSTRAINT fk_inventory_loan_checkout_allocations_lot_id FOREIGN KEY (lot_id) REFERENCES public.inventory_stock_lots (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V050
ALTER TABLE public.inventory_loan_checkout_allocations ADD CONSTRAINT fk_inventory_loan_checkout_allocations_unit_id FOREIGN KEY (unit_id) REFERENCES public.inventory_units (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V051
ALTER TABLE public.inventory_loan_checkout_allocations ADD CONSTRAINT fk_inventory_loan_checkout_allocations_checkout_movement_id FOREIGN KEY (checkout_movement_id) REFERENCES public.inventory_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V052
ALTER TABLE public.inventory_loan_returns ADD CONSTRAINT fk_inventory_loan_returns_loan_id FOREIGN KEY (loan_id) REFERENCES public.inventory_loans (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V053
ALTER TABLE public.inventory_loan_returns ADD CONSTRAINT fk_inventory_loan_returns_received_by_user_id FOREIGN KEY (received_by_user_id) REFERENCES public.users (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V054
ALTER TABLE public.inventory_loan_return_details ADD CONSTRAINT fk_inventory_loan_return_details_return_id FOREIGN KEY (return_id) REFERENCES public.inventory_loan_returns (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V055
ALTER TABLE public.inventory_loan_return_details ADD CONSTRAINT fk_inventory_loan_return_details_checkout_allocation_id FOREIGN KEY (checkout_allocation_id) REFERENCES public.inventory_loan_checkout_allocations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V056
ALTER TABLE public.inventory_loan_return_details ADD CONSTRAINT fk_inventory_loan_return_details_available_entry_movement_id FOREIGN KEY (available_entry_movement_id) REFERENCES public.inventory_movements (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V057
ALTER TABLE public.inventory_loan_shortages ADD CONSTRAINT fk_inventory_loan_shortages_checkout_allocation_id FOREIGN KEY (checkout_allocation_id) REFERENCES public.inventory_loan_checkout_allocations (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V058
ALTER TABLE public.inventory_loan_shortage_decisions ADD CONSTRAINT fk_inventory_loan_shortage_decisions_shortage_id FOREIGN KEY (shortage_id) REFERENCES public.inventory_loan_shortages (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V059
ALTER TABLE public.inventory_loan_shortage_decisions ADD CONSTRAINT fk_inventory_loan_shortage_decisions_membership_id FOREIGN KEY (membership_id) REFERENCES public.board_appointments (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V060
ALTER TABLE public.inventory_loan_shortage_decisions ADD CONSTRAINT fk_inventory_loan_shortage_decisions_board_resolution_id FOREIGN KEY (board_resolution_id) REFERENCES public.board_resolutions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V061
ALTER TABLE public.inventory_loan_shortage_decisions ADD CONSTRAINT fk_inventory_loan_shortage_decisions_decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V062
ALTER TABLE public.events ADD CONSTRAINT fk_events_initiative_id FOREIGN KEY (initiative_id) REFERENCES public.initiatives (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V063
ALTER TABLE public.volunteer_opportunities ADD CONSTRAINT fk_volunteer_opportunities_initiative_id FOREIGN KEY (initiative_id) REFERENCES public.initiatives (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V064
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_initiative_id FOREIGN KEY (initiative_id) REFERENCES public.initiatives (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V065
ALTER TABLE public.financial_movements ADD CONSTRAINT fk_financial_movements_initiative_id FOREIGN KEY (initiative_id) REFERENCES public.initiatives (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V066
ALTER TABLE public.document_records ADD CONSTRAINT fk_document_records_series_id FOREIGN KEY (series_id) REFERENCES public.document_series (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V067
ALTER TABLE public.document_versions ADD CONSTRAINT fk_document_versions_document_id FOREIGN KEY (document_id) REFERENCES public.document_records (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V068
ALTER TABLE public.document_versions ADD CONSTRAINT fk_document_versions_created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V069
ALTER TABLE public.document_versions ADD CONSTRAINT fk_document_versions_rectifies_version_id FOREIGN KEY (rectifies_version_id) REFERENCES public.document_versions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V070
ALTER TABLE public.donors ADD CONSTRAINT fk_donors_person_id FOREIGN KEY (person_id) REFERENCES public.people (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V071
ALTER TABLE public.donations ADD CONSTRAINT fk_donations_donor_id FOREIGN KEY (donor_id) REFERENCES public.donors (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V072
ALTER TABLE public.expense_document_logs ADD CONSTRAINT fk_expense_document_logs_expense_document_id FOREIGN KEY (expense_document_id) REFERENCES public.expense_documents (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V073
ALTER TABLE public.expense_document_logs ADD CONSTRAINT fk_expense_document_logs_actor_user_id FOREIGN KEY (actor_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V074
ALTER TABLE public.correspondences ADD CONSTRAINT fk_correspondences_document_record_id FOREIGN KEY (document_record_id) REFERENCES public.document_records (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V075
ALTER TABLE public.correspondence_logs ADD CONSTRAINT fk_correspondence_logs_correspondence_id FOREIGN KEY (correspondence_id) REFERENCES public.correspondences (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V076
ALTER TABLE public.correspondence_logs ADD CONSTRAINT fk_correspondence_logs_actor_user_id FOREIGN KEY (actor_user_id) REFERENCES public.users (id) ON DELETE SET NULL ON UPDATE CASCADE; -- V077
ALTER TABLE public.board_minutes ADD CONSTRAINT fk_board_minutes_document_record_id FOREIGN KEY (document_record_id) REFERENCES public.document_records (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V078
ALTER TABLE public.board_resolutions ADD CONSTRAINT fk_board_resolutions_document_record_id FOREIGN KEY (document_record_id) REFERENCES public.document_records (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V079
ALTER TABLE public.in_kind_donation_receipts ADD CONSTRAINT fk_in_kind_donation_receipts_document_record_id FOREIGN KEY (document_record_id) REFERENCES public.document_records (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V080
ALTER TABLE public.maintenance_work_orders ADD CONSTRAINT fk_maintenance_work_orders_document_record_id FOREIGN KEY (document_record_id) REFERENCES public.document_records (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V081
ALTER TABLE public.expense_documents ADD CONSTRAINT fk_expense_documents_document_version_id FOREIGN KEY (document_version_id) REFERENCES public.document_versions (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V082
ALTER TABLE public.document_folio_counters ADD CONSTRAINT fk_document_folio_counters_series_id FOREIGN KEY (series_id) REFERENCES public.document_series (id) ON DELETE RESTRICT ON UPDATE CASCADE; -- V083


-- ===== MODULE: 03_indexes.sql =====
-- 37 BU total unique indexes + 108 BI firm + 31 VU firm + 58 VI firm.
CREATE UNIQUE INDEX ux_people_person_identification_type_normalized_identification ON public.people (identification_type, normalized_identification);
CREATE UNIQUE INDEX ux_roles_bu02_role ON public.roles (name);
CREATE UNIQUE INDEX ux_permissions_bu03_permission ON public.permissions (code);
CREATE INDEX ix_role_permissions_bi001_role_permission_permission_id ON public.role_permissions (permission_id);
CREATE UNIQUE INDEX ux_users_bu04_user ON public.users (identification);
CREATE UNIQUE INDEX ux_users_bu05_user ON public.users (email);
CREATE UNIQUE INDEX ux_users_bu06_user_person_id ON public.users (person_id);
CREATE UNIQUE INDEX ux_sessions_bu07_session_refresh_token_hash ON public.sessions (refresh_token_hash);
CREATE INDEX ix_sessions_bi002_session_user_id ON public.sessions (user_id);
CREATE INDEX ix_sessions_bi003_session_expires_at ON public.sessions (expires_at);
CREATE INDEX ix_audit_logs_bi004_audit_log_user_id ON public.audit_logs (user_id);
CREATE INDEX ix_audit_logs_bi005_audit_log ON public.audit_logs (action);
CREATE INDEX ix_audit_logs_bi006_audit_log ON public.audit_logs (module);
CREATE INDEX ix_audit_logs_bi007_audit_log_created_at ON public.audit_logs (created_at);
CREATE UNIQUE INDEX ux_password_reset_tokens_bu08_password_reset_token_token_hash ON public.password_reset_tokens (token_hash);
CREATE INDEX ix_password_reset_tokens_bi008_password_reset_token_user_id ON public.password_reset_tokens (user_id);
CREATE INDEX ix_password_reset_tokens_bi009_password_reset_token_expires_at ON public.password_reset_tokens (expires_at);
CREATE UNIQUE INDEX ux_account_activation_tokens_bu09_account_activation_t_786c9320 ON public.account_activation_tokens (token_hash);
CREATE INDEX ix_account_activation_tokens_bi010_account_activation_63984dfa ON public.account_activation_tokens (user_id);
CREATE INDEX ix_account_activation_tokens_bi011_account_activation_429afc13 ON public.account_activation_tokens (expires_at);
CREATE INDEX ix_user_requests_bi012_user_request ON public.user_requests (identification);
CREATE INDEX ix_user_requests_bi013_user_request ON public.user_requests (email);
CREATE INDEX ix_user_requests_bi014_user_request ON public.user_requests (status);
CREATE INDEX ix_user_requests_bi015_user_request_reviewed_by_id ON public.user_requests (reviewed_by_id);
CREATE INDEX ix_user_requests_bi016_user_request_person_id ON public.user_requests (person_id);
CREATE UNIQUE INDEX ux_affiliates_bu10_affiliate ON public.affiliates (identification);
CREATE UNIQUE INDEX ux_affiliates_bu11_affiliate ON public.affiliates (email);
CREATE UNIQUE INDEX ux_affiliates_bu12_affiliate_person_id ON public.affiliates (person_id);
CREATE INDEX ix_affiliates_bi017_affiliate_role_id ON public.affiliates (role_id);
CREATE INDEX ix_affiliate_requests_bi018_affiliate_request ON public.affiliate_requests (identification);
CREATE INDEX ix_affiliate_requests_bi019_affiliate_request ON public.affiliate_requests (email);
CREATE INDEX ix_affiliate_requests_bi020_affiliate_request ON public.affiliate_requests (status);
CREATE INDEX ix_affiliate_requests_bi021_affiliate_request_reviewed_by_id ON public.affiliate_requests (reviewed_by_id);
CREATE INDEX ix_affiliate_requests_bi022_affiliate_request_person_id ON public.affiliate_requests (person_id);
CREATE INDEX ix_affiliate_sanctions_bi023_affiliate_sanction_affiliate_id ON public.affiliate_sanctions (affiliate_id);
CREATE INDEX ix_affiliate_sanctions_bi024_affiliate_sanction ON public.affiliate_sanctions (status);
CREATE INDEX ix_affiliate_sanctions_bi025_affiliate_sanction ON public.affiliate_sanctions (date);
CREATE INDEX ix_affiliate_sanctions_bi026_affiliate_sanction_created_by_id ON public.affiliate_sanctions (created_by_id);
CREATE UNIQUE INDEX ux_governance_positions_bu13_governance_position ON public.governance_positions (code);
CREATE INDEX ix_board_terms_board_term_institutional_profile_id_starts_on ON public.board_terms (institutional_profile_id, starts_on);
CREATE INDEX ix_board_appointments_bi028_board_appointment_board_term_id ON public.board_appointments (board_term_id);
CREATE INDEX ix_board_appointments_bi029_board_appointment_person_id ON public.board_appointments (person_id);
CREATE INDEX ix_board_appointments_board_appointment_position_seat_number ON public.board_appointments (position, seat_number);
CREATE INDEX ix_board_appointments_bi031_board_appointment_position_id ON public.board_appointments (position_id);
CREATE INDEX ix_board_appointments_bi032_board_appointment_affiliate_id ON public.board_appointments (affiliate_id);
CREATE INDEX ix_board_appointments_bi033_board_appointment_appointe_b1e3f1fc ON public.board_appointments (appointed_by_assembly_id);
CREATE INDEX ix_assemblies_bi034_assembly ON public.assemblies (date);
CREATE INDEX ix_assemblies_bi035_assembly_scheduled_at ON public.assemblies (scheduled_at);
CREATE INDEX ix_assemblies_bi036_assembly ON public.assemblies (status);
CREATE UNIQUE INDEX ux_assembly_calls_assembly_call_assembly_id_call_number ON public.assembly_calls (assembly_id, call_number);
CREATE INDEX ix_assembly_calls_bi037_assembly_call_scheduled_at ON public.assembly_calls (scheduled_at);
CREATE UNIQUE INDEX ux_assembly_convocations_assembly_convocation_assembly_151481d4 ON public.assembly_convocations (assembly_id, affiliate_id);
CREATE INDEX ix_assembly_convocations_bi039_assembly_convocation_af_98434a28 ON public.assembly_convocations (affiliate_id);
CREATE INDEX ix_assembly_convocations_bi040_assembly_convocation_role_id ON public.assembly_convocations (role_id);
CREATE INDEX ix_assembly_convocations_bi041_assembly_convocation_go_bdcfbc0b ON public.assembly_convocations (governance_membership_id);
CREATE UNIQUE INDEX ux_assembly_attendances_bu16_assembly_attendance_convocation_id ON public.assembly_attendances (convocation_id);
CREATE UNIQUE INDEX ux_assembly_attendances_assembly_attendance_assembly_i_02a83488 ON public.assembly_attendances (assembly_id, affiliate_id);
CREATE INDEX ix_assembly_attendances_bi042_assembly_attendance_assembly_id ON public.assembly_attendances (assembly_id, status);
CREATE INDEX ix_assembly_attendances_bi043_assembly_attendance_affiliate_id ON public.assembly_attendances (affiliate_id);
CREATE UNIQUE INDEX ux_absence_justifications_bu18_absence_justification_a_a07fdc7d ON public.absence_justifications (attendance_id);
CREATE UNIQUE INDEX ux_absence_justifications_absence_justification_assemb_5e2cdc82 ON public.absence_justifications (assembly_id, affiliate_id);
CREATE INDEX ix_absence_justifications_bi044_absence_justification ON public.absence_justifications (status);
CREATE INDEX ix_absence_justifications_bi045_absence_justification_82a2bb29 ON public.absence_justifications (reviewed_by_id);
CREATE UNIQUE INDEX ux_assembly_minutes_bu20_assembly_minute_assembly_id ON public.assembly_minutes (assembly_id);
CREATE INDEX ix_assembly_resolutions_bi046_assembly_resolution_assembly_id ON public.assembly_resolutions (assembly_id);
CREATE UNIQUE INDEX ux_events_bu21_event_public_id ON public.events (public_id);
CREATE INDEX ix_events_event_publication_status_start_at ON public.events (publication_status, start_at);
CREATE INDEX ix_events_bi048_event_start_at ON public.events (start_at);
CREATE INDEX ix_reservable_resources_bi049_reservable_resource ON public.reservable_resources (status);
CREATE INDEX ix_reservations_bi050_reservation_requester_user_id ON public.reservations (requester_user_id);
CREATE INDEX ix_reservations_bi051_reservation_event_id ON public.reservations (event_id);
CREATE INDEX ix_reservations_bi052_reservation ON public.reservations (status);
CREATE INDEX ix_reservations_resource_id_start_at_end_at ON public.reservations (resource_id, start_at, end_at);
CREATE UNIQUE INDEX ux_financial_accounts_bu22_financial_account ON public.financial_accounts (code);
CREATE UNIQUE INDEX ux_financial_charges_bu23_financial_charge_reservation_id ON public.financial_charges (reservation_id);
CREATE INDEX ix_financial_charges_bi054_financial_charge ON public.financial_charges (status);
CREATE INDEX ix_financial_charges_bi055_financial_charge_created_at ON public.financial_charges (created_at);
CREATE UNIQUE INDEX ux_payments_bu24_payment_movement_id ON public.payments (movement_id);
CREATE INDEX ix_payments_bi056_payment_charge_id ON public.payments (charge_id);
CREATE INDEX ix_payments_bi057_payment ON public.payments (status);
CREATE INDEX ix_payments_bi058_payment_recorded_by_id ON public.payments (recorded_by_id);
CREATE INDEX ix_payments_bi059_payment_created_at ON public.payments (created_at);
CREATE UNIQUE INDEX ux_financial_movements_bu25_financial_movement_reversal_of_id ON public.financial_movements (reversal_of_id);
CREATE INDEX ix_financial_movements_bi060_financial_movement_account_id ON public.financial_movements (account_id);
CREATE INDEX ix_financial_movements_bi061_financial_movement_occurred_at ON public.financial_movements (occurred_at);
CREATE INDEX ix_financial_movements_bi062_financial_movement_occurred_at ON public.financial_movements (type, occurred_at);
CREATE INDEX ix_financial_movements_bi063_financial_movement_source_id ON public.financial_movements (source, source_id);
CREATE INDEX ix_financial_movements_bi064_financial_movement_recorded_by_id ON public.financial_movements (recorded_by_id);
CREATE INDEX ix_financial_movements_bi065_financial_movement_occurred_at ON public.financial_movements (status, occurred_at);
CREATE UNIQUE INDEX ux_donations_bu26_donation_original_movement_id ON public.donations (original_movement_id);
CREATE UNIQUE INDEX ux_donations_bu27_donation_reversal_movement_id ON public.donations (reversal_movement_id);
CREATE INDEX ix_donations_bi066_donation_donor_person_id ON public.donations (donor_person_id);
CREATE INDEX ix_donations_bi067_donation ON public.donations (status);
CREATE INDEX ix_donations_bi068_donation ON public.donations (method);
CREATE INDEX ix_donations_bi069_donation_received_at ON public.donations (received_at);
CREATE INDEX ix_donations_bi070_donation_recorded_by_id ON public.donations (recorded_by_id);
CREATE INDEX ix_donations_bi071_donation_cancelled_by_id ON public.donations (cancelled_by_id);
CREATE INDEX ix_donations_bi072_donation_received_at ON public.donations (status, received_at);
CREATE INDEX ix_expenses_bi073_expense_authorization_resolution_id ON public.expenses (authorization_resolution_id);
CREATE INDEX ix_expenses_bi074_expense_incurred_at ON public.expenses (status, incurred_at);
CREATE INDEX ix_expense_documents_bi075_expense_document_expense_id ON public.expense_documents (expense_id);
CREATE UNIQUE INDEX ux_disbursements_bu28_disbursement_movement_id ON public.disbursements (movement_id);
CREATE INDEX ix_disbursements_bi076_disbursement_expense_id ON public.disbursements (expense_id);
CREATE INDEX ix_funding_allocations_bi077_funding_allocation_expense_id ON public.funding_allocations (expense_id);
CREATE INDEX ix_funding_allocations_bi078_funding_allocation_income_b8d037da ON public.funding_allocations (income_movement_id);
CREATE UNIQUE INDEX ux_inventory_categories_bu29_inventory_category ON public.inventory_categories (name);
CREATE INDEX ix_inventory_categories_bi079_inventory_category_is_active ON public.inventory_categories (is_active);
CREATE UNIQUE INDEX ux_inventory_items_bu30_inventory_item ON public.inventory_items (code);
CREATE INDEX ix_inventory_items_bi080_inventory_item_category_id ON public.inventory_items (category_id);
CREATE INDEX ix_inventory_items_bi081_inventory_item ON public.inventory_items (status);
CREATE INDEX ix_inventory_items_bi082_inventory_item ON public.inventory_items (condition);
CREATE INDEX ix_inventory_movements_bi083_inventory_movement_item_id ON public.inventory_movements (item_id);
CREATE INDEX ix_inventory_movements_bi084_inventory_movement ON public.inventory_movements (type);
CREATE INDEX ix_inventory_movements_bi085_inventory_movement_created_by_id ON public.inventory_movements (created_by_id);
CREATE INDEX ix_inventory_movements_bi086_inventory_movement_created_at ON public.inventory_movements (created_at);
CREATE UNIQUE INDEX ux_inventory_loans_bu31_inventory_loan_checkout_movement_id ON public.inventory_loans (checkout_movement_id);
CREATE UNIQUE INDEX ux_inventory_loans_bu32_inventory_loan_return_movement_id ON public.inventory_loans (return_movement_id);
CREATE UNIQUE INDEX ux_inventory_loans_bu33_inventory_loan_cancellation_movement_id ON public.inventory_loans (cancellation_movement_id);
CREATE INDEX ix_inventory_loans_bi087_inventory_loan_item_id ON public.inventory_loans (item_id);
CREATE INDEX ix_inventory_loans_bi088_inventory_loan ON public.inventory_loans (status);
CREATE INDEX ix_inventory_loans_bi089_inventory_loan_borrower_affiliate_id ON public.inventory_loans (borrower_affiliate_id);
CREATE INDEX ix_inventory_loans_bi090_inventory_loan_created_by_id ON public.inventory_loans (created_by_id);
CREATE INDEX ix_inventory_loans_bi091_inventory_loan_cancelled_by_id ON public.inventory_loans (cancelled_by_id);
CREATE INDEX ix_inventory_loans_bi092_inventory_loan_expected_return_date ON public.inventory_loans (expected_return_date);
CREATE INDEX ix_volunteer_opportunities_bi093_volunteer_opportunity_26c13492 ON public.volunteer_opportunities (created_by_user_id);
CREATE INDEX ix_volunteer_opportunities_bi094_volunteer_opportunity_9f74f929 ON public.volunteer_opportunities (status, application_deadline);
CREATE INDEX ix_volunteer_sessions_volunteer_session_opportunity_id_start_at ON public.volunteer_sessions (opportunity_id, start_at);
CREATE INDEX ix_volunteer_applications_bi096_volunteer_application_effbd196 ON public.volunteer_applications (opportunity_id, status);
CREATE INDEX ix_volunteer_applications_bi097_volunteer_application_person_id ON public.volunteer_applications (person_id, status);
CREATE INDEX ix_volunteer_applications_bi098_volunteer_application_ba647491 ON public.volunteer_applications (submitted_normalized_identification);
CREATE INDEX ix_volunteer_applications_bi099_volunteer_application_4aa74ebb ON public.volunteer_applications (reviewed_by_user_id);
CREATE UNIQUE INDEX ux_volunteer_participations_bu34_volunteer_participati_f76c99ac ON public.volunteer_participations (application_id);
CREATE UNIQUE INDEX ux_volunteer_participations_volunteer_participation_op_afc9587d ON public.volunteer_participations (opportunity_id, person_id);
CREATE INDEX ix_volunteer_participations_bi100_volunteer_participat_453aa76c ON public.volunteer_participations (person_id, status);
CREATE INDEX ix_volunteer_participations_bi101_volunteer_participat_529c4f7a ON public.volunteer_participations (opportunity_id, status);
CREATE UNIQUE INDEX ux_volunteer_attendances_volunteer_attendance_particip_31ef356c ON public.volunteer_attendances (participation_id, session_id);
CREATE INDEX ix_volunteer_attendances_bi102_volunteer_attendance_session_id ON public.volunteer_attendances (session_id, status);
CREATE INDEX ix_volunteer_attendances_bi103_volunteer_attendance_re_6c9b272c ON public.volunteer_attendances (recorded_by_user_id);
CREATE INDEX ix_ventures_bi104_venture_publication_status ON public.ventures (status, publication_status);
CREATE INDEX ix_venture_associations_bi105_venture_association_person_id ON public.venture_associations (person_id);
CREATE INDEX ix_venture_associations_bi106_venture_association_venture_id ON public.venture_associations (venture_id);
CREATE INDEX ix_venture_requests_bi107_venture_request_reconciled_person_id ON public.venture_requests (reconciled_person_id);
CREATE INDEX ix_venture_requests_bi108_venture_request_venture_id ON public.venture_requests (venture_id);
CREATE INDEX ix_venture_requests_bi109_venture_request_created_at ON public.venture_requests (status, created_at);
CREATE UNIQUE INDEX ux_venture_request_revisions_venture_request_revision_25d523e0 ON public.venture_request_revisions (request_id, revision_number);
CREATE UNIQUE INDEX ux_board_appointments_position_id_seat_number_ends_on ON public.board_appointments (board_term_id, position_id, seat_number) WHERE ends_on IS NULL;
CREATE UNIQUE INDEX ux_volunteer_applications_person_id_volunteer_applicat_005907d2 ON public.volunteer_applications (opportunity_id, person_id) WHERE status='PENDING' AND person_id IS NOT NULL;
CREATE UNIQUE INDEX ux_venture_associations_person_id_venture_id_ended_at ON public.venture_associations (person_id, venture_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX ux_board_sessions_purpose ON public.board_sessions (term_id, session_number);
CREATE UNIQUE INDEX ux_board_resolutions_purpose ON public.board_resolutions (board_session_id, resolution_number);
CREATE UNIQUE INDEX ux_event_revisions_purpose ON public.event_revisions (event_id, revision_number);
CREATE UNIQUE INDEX ux_event_review_decisions_purpose ON public.event_review_decisions (command_key);
CREATE UNIQUE INDEX ux_event_budget_lines_purpose ON public.event_budget_lines (event_id, line_number);
CREATE UNIQUE INDEX ux_in_kind_donation_items_purpose ON public.in_kind_donation_items (donation_id, line_number);
CREATE UNIQUE INDEX ux_in_kind_donation_decisions_purpose ON public.in_kind_donation_decisions (command_key);
CREATE UNIQUE INDEX ux_in_kind_donation_receipts_purpose ON public.in_kind_donation_receipts (donation_id, receipt_number);
CREATE UNIQUE INDEX ux_in_kind_donation_receipt_lines_purpose ON public.in_kind_donation_receipt_lines (receipt_id, line_number);
CREATE UNIQUE INDEX ux_institutional_facilities_purpose ON public.institutional_facilities (code);
CREATE UNIQUE INDEX ux_inventory_stock_lots_purpose ON public.inventory_stock_lots (code);
CREATE UNIQUE INDEX ux_inventory_units_purpose ON public.inventory_units (asset_code);
CREATE UNIQUE INDEX ux_inventory_loan_checkout_allocations_purpose ON public.inventory_loan_checkout_allocations (checkout_movement_id);
CREATE UNIQUE INDEX ux_inventory_loan_returns_purpose ON public.inventory_loan_returns (loan_id, return_number);
CREATE UNIQUE INDEX ux_inventory_loan_return_details_purpose_return_detail_d0453876 ON public.inventory_loan_return_details (return_id, checkout_allocation_id);
CREATE UNIQUE INDEX ux_inventory_loan_return_details_purpose_return_detail_movement ON public.inventory_loan_return_details (available_entry_movement_id);
CREATE UNIQUE INDEX ux_inventory_loan_shortage_decisions_purpose ON public.inventory_loan_shortage_decisions (command_key);
CREATE UNIQUE INDEX ux_initiatives_purpose ON public.initiatives (code);
CREATE UNIQUE INDEX ux_document_series_purpose ON public.document_series (code);
CREATE UNIQUE INDEX ux_document_records_purpose_document_folio ON public.document_records (series_id, folio_year, folio_sequence);
CREATE UNIQUE INDEX ux_document_records_purpose_document_registration_request ON public.document_records (official_registration_request_key);
CREATE UNIQUE INDEX ux_document_versions_purpose ON public.document_versions (document_id, version_number);
CREATE UNIQUE INDEX ux_donors_purpose_donor_person ON public.donors (person_id);
CREATE UNIQUE INDEX ux_donors_purpose_donor_legal_identity ON public.donors (identification_type, normalized_identification) WHERE donor_type='ORGANIZATION';
CREATE UNIQUE INDEX ux_correspondences_purpose ON public.correspondences (document_record_id);
CREATE UNIQUE INDEX ux_inventory_stock_lot_receipt_origins_purpose ON public.inventory_stock_lot_receipt_origins (lot_id);
CREATE UNIQUE INDEX ux_inventory_unit_receipt_origins_purpose ON public.inventory_unit_receipt_origins (unit_id);
CREATE UNIQUE INDEX ux_disbursements_disbursement_expense_id ON public.disbursements (expense_id) WHERE purpose='SETTLEMENT';

-- 58 firm V2 explicit BTREE indexes
CREATE INDEX ix_board_minutes_vi001 ON public.board_minutes (board_session_id);
CREATE INDEX ix_event_revisions_vi003 ON public.event_revisions (submitted_by_user_id);
CREATE INDEX ix_event_review_decisions_vi004 ON public.event_review_decisions (event_revision_id);
CREATE INDEX ix_event_review_decisions_vi005 ON public.event_review_decisions (membership_id);
CREATE INDEX ix_event_review_decisions_vi006 ON public.event_review_decisions (decided_by_user_id);
CREATE INDEX ix_in_kind_donations_vi007 ON public.in_kind_donations (donor_id);
CREATE INDEX ix_in_kind_donations_vi008 ON public.in_kind_donations (recorded_by_user_id);
CREATE INDEX ix_in_kind_donation_decisions_vi009 ON public.in_kind_donation_decisions (donation_id);
CREATE INDEX ix_in_kind_donation_decisions_vi010 ON public.in_kind_donation_decisions (membership_id);
CREATE INDEX ix_in_kind_donation_decisions_vi011 ON public.in_kind_donation_decisions (board_resolution_id);
CREATE INDEX ix_in_kind_donation_decisions_vi012 ON public.in_kind_donation_decisions (decided_by_user_id);
CREATE INDEX ix_in_kind_donation_receipts_vi013 ON public.in_kind_donation_receipts (received_by_user_id);
CREATE INDEX ix_in_kind_donation_receipt_lines_vi014 ON public.in_kind_donation_receipt_lines (donation_item_id);
CREATE INDEX ix_in_kind_donation_receipt_lines_vi015 ON public.in_kind_donation_receipt_lines (item_id);
CREATE INDEX ix_institutional_facilities_vi016 ON public.institutional_facilities (parent_facility_id);
CREATE INDEX ix_inventory_stock_lots_vi017 ON public.inventory_stock_lots (item_id);
CREATE INDEX ix_inventory_units_vi018 ON public.inventory_units (item_id);
CREATE INDEX ix_maintenance_incidents_vi019 ON public.maintenance_incidents (facility_id);
CREATE INDEX ix_maintenance_incidents_vi020 ON public.maintenance_incidents (stock_lot_id);
CREATE INDEX ix_maintenance_incidents_vi021 ON public.maintenance_incidents (unit_id);
CREATE INDEX ix_maintenance_incidents_vi022 ON public.maintenance_incidents (reported_by_person_id);
CREATE INDEX ix_maintenance_work_orders_vi023 ON public.maintenance_work_orders (incident_id);
CREATE INDEX ix_maintenance_work_orders_vi024 ON public.maintenance_work_orders (facility_id);
CREATE INDEX ix_maintenance_work_orders_vi025 ON public.maintenance_work_orders (stock_lot_id);
CREATE INDEX ix_maintenance_work_orders_vi026 ON public.maintenance_work_orders (unit_id);
CREATE INDEX ix_maintenance_work_orders_vi027 ON public.maintenance_work_orders (executor_person_id);
CREATE INDEX ix_maintenance_work_orders_vi028 ON public.maintenance_work_orders (authorized_by_user_id);
CREATE INDEX ix_maintenance_work_orders_vi029 ON public.maintenance_work_orders (initiative_id);
CREATE INDEX ix_resource_unavailabilities_vi030 ON public.resource_unavailabilities (incident_id);
CREATE INDEX ix_resource_unavailabilities_vi031 ON public.resource_unavailabilities (work_order_id);
CREATE INDEX ix_resource_unavailabilities_vi032 ON public.resource_unavailabilities (released_by_user_id);
CREATE INDEX ix_inventory_loan_checkout_allocations_vi033 ON public.inventory_loan_checkout_allocations (loan_id);
CREATE INDEX ix_inventory_loan_checkout_allocations_vi034 ON public.inventory_loan_checkout_allocations (lot_id);
CREATE INDEX ix_inventory_loan_checkout_allocations_vi035 ON public.inventory_loan_checkout_allocations (unit_id);
CREATE INDEX ix_inventory_loan_returns_vi036 ON public.inventory_loan_returns (received_by_user_id);
CREATE INDEX ix_inventory_loan_return_details_vi037 ON public.inventory_loan_return_details (checkout_allocation_id);
CREATE INDEX ix_inventory_loan_shortages_vi038 ON public.inventory_loan_shortages (checkout_allocation_id);
CREATE INDEX ix_inventory_loan_shortage_decisions_vi039 ON public.inventory_loan_shortage_decisions (shortage_id);
CREATE INDEX ix_inventory_loan_shortage_decisions_vi040 ON public.inventory_loan_shortage_decisions (membership_id);
CREATE INDEX ix_inventory_loan_shortage_decisions_vi041 ON public.inventory_loan_shortage_decisions (board_resolution_id);
CREATE INDEX ix_inventory_loan_shortage_decisions_vi042 ON public.inventory_loan_shortage_decisions (decided_by_user_id);
CREATE INDEX ix_events_vi043_event ON public.events (initiative_id);
CREATE INDEX ix_volunteer_opportunities_vi044_volunteer_opportunity ON public.volunteer_opportunities (initiative_id);
CREATE INDEX ix_financial_movements_vi045_financial_movement ON public.financial_movements (initiative_id);
CREATE INDEX ix_document_versions_vi046 ON public.document_versions (created_by_user_id);
CREATE INDEX ix_document_versions_vi047 ON public.document_versions (rectifies_version_id);
CREATE INDEX ix_donations_vi048_donation ON public.donations (donor_id);
CREATE INDEX ix_expense_document_logs_vi049 ON public.expense_document_logs (expense_document_id);
CREATE INDEX ix_expense_document_logs_vi050 ON public.expense_document_logs (actor_user_id);
CREATE INDEX ix_correspondence_logs_vi051 ON public.correspondence_logs (correspondence_id);
CREATE INDEX ix_correspondence_logs_vi052 ON public.correspondence_logs (actor_user_id);
CREATE INDEX ix_expense_documents_vi053_expense_document ON public.expense_documents (document_version_id);
CREATE INDEX ix_inventory_stock_lot_receipt_origins_vi054 ON public.inventory_stock_lot_receipt_origins (receipt_line_id);
CREATE INDEX ix_inventory_unit_receipt_origins_vi055 ON public.inventory_unit_receipt_origins (receipt_line_id);
CREATE INDEX ix_expenses_vi056_expense ON public.expenses (maintenance_work_order_id);
CREATE INDEX ix_expenses_vi057_expense ON public.expenses (board_resolution_id);
CREATE INDEX ix_disbursements_vi058_disbursement ON public.disbursements (settled_by_user_id);
CREATE INDEX ix_reservable_resources_vi059_reservable_resource ON public.reservable_resources (facility_id);


-- ===== MODULE: 04_consolidation.sql =====
-- Consolidation integrated in clean initial migration (not a legacy UPDATE migration).

CREATE TABLE IF NOT EXISTS public.user_roles (
 user_id integer NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
 role_id integer NOT NULL REFERENCES public.roles(id) ON DELETE RESTRICT,
 CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id)
);
CREATE INDEX IF NOT EXISTS ix_user_roles_ix_user_role_role_id_user_role_role_id ON public.user_roles(role_id);

CREATE TABLE IF NOT EXISTS public.venture_manager_authorizations (
 id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 venture_id integer NOT NULL REFERENCES public.ventures(id),
 person_id integer NOT NULL REFERENCES public.people(id),
 granted_by_user_id integer NOT NULL REFERENCES public.users(id),
 granted_by_membership_id integer NOT NULL REFERENCES public.board_appointments(id),
 grant_reason text NOT NULL,
 valid_from timestamptz NOT NULL DEFAULT now(),
 valid_until timestamptz,
 revoked_at timestamptz,
 revoked_by_user_id integer REFERENCES public.users(id),
 revocation_reason text,
 created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT ck_venture_manager_authorizations_rule_vma_validity CHECK (valid_until IS NULL OR valid_until > valid_from),
 CONSTRAINT ck_venture_manager_authorizations_rule_vma_revocation CHECK ((revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL) OR (revoked_at IS NOT NULL AND revoked_by_user_id IS NOT NULL AND nullif(btrim(revocation_reason),'') IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_venture_manager_authorizations_venture_id_person_id_0e9236e0 ON public.venture_manager_authorizations(venture_id,person_id) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_venture_manager_authorizations_venture_manager_auth_1ee50861 ON public.venture_manager_authorizations(person_id);

CREATE TABLE IF NOT EXISTS public.venture_reviewer_authorizations (
 id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 user_id integer NOT NULL REFERENCES public.users(id),
 membership_id integer NOT NULL REFERENCES public.board_appointments(id),
 granted_by_user_id integer NOT NULL REFERENCES public.users(id),
 grant_reason text NOT NULL,
 valid_from timestamptz NOT NULL DEFAULT now(),
 valid_until timestamptz,
 revoked_at timestamptz,
 revoked_by_user_id integer REFERENCES public.users(id),
 revocation_reason text,
 created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT ck_venture_reviewer_authorizations_rule_vra_validity CHECK (valid_until IS NULL OR valid_until > valid_from),
 CONSTRAINT ck_venture_reviewer_authorizations_rule_vra_revocation CHECK ((revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL) OR (revoked_at IS NOT NULL AND revoked_by_user_id IS NOT NULL AND nullif(btrim(revocation_reason),'') IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_venture_reviewer_authorizations_venture_reviewer_au_5c5fca06 ON public.venture_reviewer_authorizations(user_id) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_venture_reviewer_authorizations_venture_reviewer_au_6fa02c0b ON public.venture_reviewer_authorizations(membership_id);

CREATE TABLE IF NOT EXISTS public.venture_review_decisions (
 id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 venture_id integer NOT NULL REFERENCES public.ventures(id),
 revision_id integer REFERENCES public.venture_request_revisions(id),
 reviewer_user_id integer NOT NULL REFERENCES public.users(id),
 reviewer_membership_id integer NOT NULL REFERENCES public.board_appointments(id),
 reviewer_authorization_id integer NOT NULL REFERENCES public.venture_reviewer_authorizations(id),
 decision text NOT NULL CHECK (decision IN ('APPROVE','REJECT','CHANGES_REQUESTED','REVOKE','SUSPEND','CLOSE','RESTORE')),
 reason text NOT NULL CHECK (length(btrim(reason)) > 0),
 decided_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT ck_venture_review_decisions_rule_vrd_revision CHECK ((decision IN ('APPROVE','REJECT','CHANGES_REQUESTED') AND revision_id IS NOT NULL) OR (decision IN ('REVOKE','SUSPEND','CLOSE','RESTORE')))
);
CREATE INDEX IF NOT EXISTS ix_venture_review_decisions_venture_review_decision_re_8d3e1935 ON public.venture_review_decisions(revision_id,decided_at DESC);
CREATE INDEX IF NOT EXISTS ix_venture_review_decisions_venture_review_decision_ve_3fea05a1 ON public.venture_review_decisions(venture_id,decided_at DESC);

ALTER TABLE public.ventures ADD COLUMN IF NOT EXISTS published_request_revision_id integer;
-- FK en dos fases para conservar compatibilidad con el DDL base.
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_ventures_published_request_revision_id') THEN
  ALTER TABLE public.ventures ADD CONSTRAINT fk_ventures_published_request_revision_id FOREIGN KEY (published_request_revision_id) REFERENCES public.venture_request_revisions(id) ON DELETE RESTRICT;
 END IF;
END $$;
CREATE INDEX IF NOT EXISTS ix_ventures_venture_published_request_revision_id ON public.ventures(published_request_revision_id);




-- ===== MODULE: 05_checks_exclusion.sql =====
-- Firm CHECK ledger C01-C41 (C27/C39 conditional: not installed).
ALTER TABLE public.institutional_profiles ADD CONSTRAINT ck_institutional_profiles_rule CHECK (id = 1); -- C01
ALTER TABLE public.board_terms ADD CONSTRAINT ck_board_terms_rule CHECK (starts_on < ends_on); -- C02
ALTER TABLE public.board_appointments ADD CONSTRAINT ck_board_appointments_rule CHECK (seat_number > 0 AND (ends_on IS NULL OR ends_on >= starts_on)); -- C03
ALTER TABLE public.assembly_calls ADD CONSTRAINT ck_assembly_calls_rule CHECK (call_number > 0 AND ((quorum_type = 'FIXED' AND quorum_value IS NOT NULL AND quorum_value > 0) OR (quorum_type = 'PERCENTAGE' AND quorum_value IS NOT NULL AND quorum_value > 0 AND quorum_value <= 100))); -- C04
ALTER TABLE public.absence_justifications ADD CONSTRAINT ck_absence_justifications_rule CHECK ((attachment_original_name IS NULL AND attachment_mime_type IS NULL AND attachment_size IS NULL AND attachment_url IS NULL) OR (NULLIF(BTRIM(attachment_original_name),'') IS NOT NULL AND NULLIF(BTRIM(attachment_mime_type),'') IS NOT NULL AND attachment_size IS NOT NULL AND attachment_size > 0 AND NULLIF(BTRIM(attachment_url),'') IS NOT NULL)); -- C05
ALTER TABLE public.expense_documents ADD CONSTRAINT ck_expense_documents_rule CHECK (size > 0); -- C06
ALTER TABLE public.reservations ADD CONSTRAINT ck_reservations_rule CHECK (start_at < end_at); -- C07
ALTER TABLE public.reservable_resources ADD CONSTRAINT ck_reservable_resources_rule CHECK ((pricing_type = 'FREE' AND COALESCE(price,0) = 0) OR (pricing_type = 'FIXED' AND price IS NOT NULL AND price > 0 AND NULLIF(BTRIM(currency),'') IS NOT NULL)); -- C08
ALTER TABLE public.financial_charges ADD CONSTRAINT ck_financial_charges_rule CHECK (amount > 0); -- C09
ALTER TABLE public.payments ADD CONSTRAINT ck_payments_rule CHECK (amount > 0); -- C10
ALTER TABLE public.financial_movements ADD CONSTRAINT ck_financial_movements_rule_movement_amount_positive CHECK (amount > 0); -- C11
ALTER TABLE public.donations ADD CONSTRAINT ck_donations_rule CHECK (amount > 0); -- C12
ALTER TABLE public.expenses ADD CONSTRAINT ck_expenses_rule_expense_amount_positive CHECK (amount > 0); -- C13
ALTER TABLE public.disbursements ADD CONSTRAINT ck_disbursements_rule_disbursement_amount_positive CHECK (amount > 0); -- C14
ALTER TABLE public.funding_allocations ADD CONSTRAINT ck_funding_allocations_rule CHECK (amount > 0); -- C15
ALTER TABLE public.financial_movements ADD CONSTRAINT ck_financial_movements_rule_movement_void CHECK ((reversal_of_id IS NULL OR reversal_of_id <> id) AND (status IS DISTINCT FROM 'VOIDED' OR (voided_at IS NOT NULL AND voided_by_id IS NOT NULL AND NULLIF(BTRIM(void_reason),'') IS NOT NULL))); -- C16
ALTER TABLE public.inventory_movements ADD CONSTRAINT ck_inventory_movements_rule CHECK (quantity_delta IS NULL OR (quantity_delta <> 0 AND ((type = 'ENTRY' AND quantity_delta > 0) OR (type = 'EXIT' AND quantity_delta < 0) OR (type = 'OPENING_BALANCE' AND quantity_delta > 0) OR type = 'ADJUSTMENT'))); -- C17
ALTER TABLE public.inventory_items ADD CONSTRAINT ck_inventory_items_rule CHECK (current_quantity >= 0 AND minimum_quantity >= 0); -- C18
ALTER TABLE public.inventory_loans ADD CONSTRAINT ck_inventory_loans_rule CHECK (quantity > 0 AND expected_return_date >= loan_date AND (returned_at IS NULL OR returned_at >= loan_date) AND (status <> 'RETURNED' OR returned_at IS NOT NULL) AND (status <> 'CANCELLED' OR cancelled_at IS NOT NULL)); -- C19
ALTER TABLE public.volunteer_opportunities ADD CONSTRAINT ck_volunteer_opportunities_rule CHECK (capacity IS NULL OR capacity > 0); -- C20
ALTER TABLE public.volunteer_sessions ADD CONSTRAINT ck_volunteer_sessions_rule CHECK (start_at < end_at); -- C21
ALTER TABLE public.volunteer_attendances ADD CONSTRAINT ck_volunteer_attendances_rule CHECK (credited_hours >= 0 AND (check_in_at IS NULL OR check_out_at IS NULL OR check_in_at <= check_out_at)); -- C22
ALTER TABLE public.ventures ADD CONSTRAINT ck_ventures_rule CHECK (publication_status <> 'PUBLISHED' OR status = 'ACTIVE'); -- C23
ALTER TABLE public.venture_associations ADD CONSTRAINT ck_venture_associations_rule CHECK (ended_at IS NULL OR ended_at >= started_at); -- C24
ALTER TABLE public.venture_requests ADD CONSTRAINT ck_venture_requests_rule CHECK ((purpose <> 'UPDATE' OR venture_id IS NOT NULL) AND (status <> 'APPROVED' OR venture_id IS NOT NULL) AND (status NOT IN ('APPROVED','REJECTED','WITHDRAWN') OR resolved_at IS NOT NULL)); -- C25
ALTER TABLE public.maintenance_incidents ADD CONSTRAINT ck_maintenance_incidents_rule CHECK (NUM_NONNULLS(facility_id,stock_lot_id,unit_id) = 1); -- C26
ALTER TABLE public.expenses ADD CONSTRAINT ck_expenses_rule_expense_resolution_xor CHECK (NUM_NONNULLS(authorization_resolution_id,board_resolution_id) <= 1); -- C28
ALTER TABLE public.financial_movements ADD CONSTRAINT ck_financial_movements_rule_income_destination CHECK (status IS DISTINCT FROM 'POSTED' OR type <> 'INCOME' OR (destination_type IS NOT NULL AND ((destination_type = 'GENERAL_FUND' AND initiative_id IS NULL) OR (destination_type = 'INITIATIVE' AND initiative_id IS NOT NULL)))); -- C29
ALTER TABLE public.inventory_loan_checkout_allocations ADD CONSTRAINT ck_inventory_loan_checkout_allocations_rule CHECK (NUM_NONNULLS(lot_id,unit_id) = 1 AND quantity > 0); -- C30
ALTER TABLE public.inventory_loan_return_details ADD CONSTRAINT ck_inventory_loan_return_details_rule CHECK (quantity > 0); -- C31
ALTER TABLE public.inventory_loan_shortages ADD CONSTRAINT ck_inventory_loan_shortages_rule CHECK (quantity > 0); -- C32
ALTER TABLE public.institutional_facilities ADD CONSTRAINT ck_institutional_facilities_rule CHECK (parent_facility_id IS NULL OR parent_facility_id <> id); -- C33
ALTER TABLE public.resource_unavailabilities ADD CONSTRAINT ck_resource_unavailabilities_rule CHECK (ends_at IS NULL OR starts_at < ends_at); -- C34
ALTER TABLE public.document_records ADD CONSTRAINT ck_document_records_rule_document_folio_shape CHECK ((NUM_NONNULLS(folio_year,folio_sequence) IN (0,2) AND (folio_year IS NULL OR (folio_year > 0 AND folio_sequence > 0 AND series_id IS NOT NULL))) AND (official_registered_at IS NULL OR (series_id IS NOT NULL AND folio_year IS NOT NULL AND folio_sequence IS NOT NULL))); -- C35
ALTER TABLE public.document_series ADD CONSTRAINT ck_document_series_rule CHECK (code COLLATE "C" ~ '^[A-Z0-9]+(-[A-Z0-9]+)*$'); -- C36
ALTER TABLE public.donors ADD CONSTRAINT ck_donors_rule CHECK ((donor_type = 'PERSON' AND person_id IS NOT NULL AND legal_name IS NULL) OR (donor_type = 'ORGANIZATION' AND person_id IS NULL AND NULLIF(BTRIM(legal_name),'') IS NOT NULL AND NULLIF(BTRIM(normalized_identification),'') IS NOT NULL)); -- C37
ALTER TABLE public.disbursements ADD CONSTRAINT ck_disbursements_rule_disbursement_settlement_fields CHECK ((settled_at IS NULL AND settled_by_user_id IS NULL) OR (purpose = 'ADVANCE' AND settled_at IS NOT NULL AND settled_by_user_id IS NOT NULL)); -- C38
ALTER TABLE public.document_versions ADD CONSTRAINT ck_document_versions_rule CHECK (version_number > 0 AND size_bytes > 0 AND checksum_sha256 COLLATE "C" ~ '^[0-9a-fA-F]{64}$'); -- C40
ALTER TABLE public.document_records ADD CONSTRAINT ck_document_records_rule_document_classification CHECK (classification IN ('PUBLIC','INTERNAL','RESTRICTED')); -- C41

-- PO-05: exclusive ACTIVE reservations for maintenance unavailability.
-- Baseline ts uses timestamp WITHOUT time zone; tsrange, not tstzrange.
ALTER TABLE public.resource_unavailabilities ADD CONSTRAINT ex_resource_unavailabilities_rule
  EXCLUDE USING gist (reservable_resource_id WITH =, tsrange(starts_at, COALESCE(ends_at, 'infinity'::timestamp), '[)') WITH &&)
  WHERE (released_at IS NULL);


-- ===== MODULE: 06_integrity_triggers.sql =====
-- SGI-Curime V2: PostgreSQL-only integrity controls. Do not expose these functions through the public API.
-- TX-level authorization, idempotence, lock ordering and policies remain the NestJS service's responsibility.

-- Common immutable row protection for approved decisions, revisions and durable logs.
CREATE OR REPLACE FUNCTION public.fn_reject_mutation() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
  RAISE EXCEPTION 'SGI immutable record: %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE='23514';
END $$;
CREATE TRIGGER trg_venture_request_revisions_venture_revision_immutable_event BEFORE UPDATE OR DELETE ON public.venture_request_revisions FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_venture_review_decisions_venture_decision_immutable_event BEFORE UPDATE OR DELETE ON public.venture_review_decisions FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_document_versions_document_version_immutable_event BEFORE UPDATE OR DELETE ON public.document_versions FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_expense_document_logs_expense_doc_log_append_only_event BEFORE UPDATE OR DELETE ON public.expense_document_logs FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_correspondence_logs_correspondence_log_append_only_event BEFORE UPDATE OR DELETE ON public.correspondence_logs FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_event_review_decisions_event_decision_append_only_event BEFORE UPDATE OR DELETE ON public.event_review_decisions FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_in_kind_donation_decisions_inkind_decision_append_5d4914ff BEFORE UPDATE OR DELETE ON public.in_kind_donation_decisions FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();
CREATE TRIGGER trg_inventory_loan_shortage_decisions_shortage_decisio_369b8766 BEFORE UPDATE OR DELETE ON public.inventory_loan_shortage_decisions FOR EACH ROW EXECUTE FUNCTION public.fn_reject_mutation();

-- PO-06: no cycles in facilities; also local self-parent CHECK C33.
CREATE OR REPLACE FUNCTION public.fn_facility_no_cycles() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
DECLARE cycle_found boolean;
BEGIN
 IF NEW.parent_facility_id IS NULL THEN RETURN NEW; END IF;
 WITH RECURSIVE ancestors(id,parent_id) AS (
   SELECT f.id, f.parent_facility_id FROM public.institutional_facilities f WHERE f.id=NEW.parent_facility_id
   UNION
   SELECT f.id, f.parent_facility_id FROM public.institutional_facilities f JOIN ancestors a ON f.id=a.parent_id
 ) SELECT EXISTS(SELECT 1 FROM ancestors WHERE id=NEW.id) INTO cycle_found;
 IF cycle_found THEN RAISE EXCEPTION 'Facility hierarchy cycle detected for id %',NEW.id USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_institutional_facilities_facility_no_cycles_event BEFORE INSERT OR UPDATE OF parent_facility_id ON public.institutional_facilities
FOR EACH ROW EXECUTE FUNCTION public.fn_facility_no_cycles();

-- PO-08/09: order target is unambiguous at authorization; divergence requires scope.
CREATE OR REPLACE FUNCTION public.fn_work_order_integrity() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE inc public.maintenance_incidents%ROWTYPE;
BEGIN
 IF NEW.authorized_at IS NOT NULL THEN
  IF num_nonnulls(NEW.facility_id,NEW.stock_lot_id,NEW.unit_id)<>1 THEN
   RAISE EXCEPTION 'Authorized work order requires exactly one target' USING ERRCODE='23514';
  END IF;
  IF NEW.incident_id IS NOT NULL THEN
   SELECT * INTO inc FROM public.maintenance_incidents WHERE id=NEW.incident_id;
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
CREATE TRIGGER trg_maintenance_work_orders_work_order_integrity_event BEFORE INSERT OR UPDATE ON public.maintenance_work_orders FOR EACH ROW EXECUTE FUNCTION public.fn_work_order_integrity();

-- PO-10: checkout target must represent the same inventory item as the loan.
CREATE OR REPLACE FUNCTION public.fn_loan_allocation_item() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE loan_item integer; target_item integer;
BEGIN
 SELECT item_id INTO loan_item FROM public.inventory_loans WHERE id=NEW.loan_id;
 IF NEW.lot_id IS NOT NULL THEN
  SELECT item_id INTO target_item FROM public.inventory_stock_lots WHERE id=NEW.lot_id;
 ELSE
  SELECT item_id INTO target_item FROM public.inventory_units WHERE id=NEW.unit_id;
 END IF;
 IF loan_item IS NULL OR target_item IS NULL OR loan_item<>target_item THEN
  RAISE EXCEPTION 'Checkout allocation item does not match loan item' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_inventory_loan_checkout_allocations_loan_allocatio_9125f3c0 BEFORE INSERT OR UPDATE OF loan_id, lot_id, unit_id ON public.inventory_loan_checkout_allocations
FOR EACH ROW EXECUTE FUNCTION public.fn_loan_allocation_item();

-- PO-11: returns and allocations must belong to the same loan.
CREATE OR REPLACE FUNCTION public.fn_return_detail_loan() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE return_loan integer; allocation_loan integer;
BEGIN
 SELECT loan_id INTO return_loan FROM public.inventory_loan_returns WHERE id=NEW.return_id;
 SELECT loan_id INTO allocation_loan FROM public.inventory_loan_checkout_allocations WHERE id=NEW.checkout_allocation_id;
 IF return_loan IS NULL OR allocation_loan IS NULL OR return_loan<>allocation_loan THEN
  RAISE EXCEPTION 'Return detail belongs to a different loan' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_inventory_loan_return_details_return_detail_loan_event BEFORE INSERT OR UPDATE OF return_id,checkout_allocation_id ON public.inventory_loan_return_details
FOR EACH ROW EXECUTE FUNCTION public.fn_return_detail_loan();

-- PO-12: defer quantity equation check until commit, lock allocation to serialize competing writes.
CREATE OR REPLACE FUNCTION public.fn_allocation_quantities() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE alloc_id integer; cap numeric; returned numeric; missing numeric;
BEGIN
 alloc_id := CASE WHEN TG_OP='DELETE' THEN OLD.checkout_allocation_id ELSE NEW.checkout_allocation_id END;
 SELECT quantity INTO cap FROM public.inventory_loan_checkout_allocations WHERE id=alloc_id FOR UPDATE;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT COALESCE(SUM(quantity),0) INTO returned FROM public.inventory_loan_return_details WHERE checkout_allocation_id=alloc_id;
 SELECT COALESCE(SUM(quantity),0) INTO missing FROM public.inventory_loan_shortages WHERE checkout_allocation_id=alloc_id AND status IS DISTINCT FROM 'CANCELLED';
 IF returned + missing > cap THEN
  RAISE EXCEPTION 'Return + shortage (%) exceeds checkout allocation (%)', returned + missing, cap USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_inventory_loan_return_details_return_allocation_limit_event AFTER INSERT OR UPDATE OR DELETE ON public.inventory_loan_return_details
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.fn_allocation_quantities();
CREATE CONSTRAINT TRIGGER trg_inventory_loan_shortages_shortage_allocation_limit_event AFTER INSERT OR UPDATE OR DELETE ON public.inventory_loan_shortages
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.fn_allocation_quantities();

-- PO-13: origin receipt line must identify the same inventory item as the asset/lot.
CREATE OR REPLACE FUNCTION public.fn_receipt_origin_match() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE expected_item integer; actual_item integer;
BEGIN
 SELECT item_id INTO expected_item FROM public.in_kind_donation_receipt_lines WHERE id=NEW.receipt_line_id;
 IF TG_TABLE_NAME='inventory_stock_lot_receipt_origins' THEN
   SELECT item_id INTO actual_item FROM public.inventory_stock_lots WHERE id=NEW.lot_id;
 ELSE
   SELECT item_id INTO actual_item FROM public.inventory_units WHERE id=NEW.unit_id;
 END IF;
 IF expected_item IS NULL OR actual_item IS NULL OR expected_item<>actual_item THEN
  RAISE EXCEPTION 'Receipt origin item mismatch' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_inventory_stock_lot_receipt_origins_lot_receipt_or_2ee547d2 BEFORE INSERT OR UPDATE ON public.inventory_stock_lot_receipt_origins
FOR EACH ROW EXECUTE FUNCTION public.fn_receipt_origin_match();
CREATE TRIGGER trg_inventory_unit_receipt_origins_unit_receipt_origin_3dad1a4c BEFORE INSERT OR UPDATE ON public.inventory_unit_receipt_origins
FOR EACH ROW EXECUTE FUNCTION public.fn_receipt_origin_match();

-- PO-14/15: offer and receipt must refer to same donation and aggregate received <= offered.
CREATE OR REPLACE FUNCTION public.fn_receipt_line_integrity() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE offered_donation integer; received_donation integer; offered_quantity numeric; quantity_used numeric;
BEGIN
 SELECT donation_id,quantity INTO offered_donation,offered_quantity
 FROM public.in_kind_donation_items WHERE id=NEW.donation_item_id FOR UPDATE;
 SELECT donation_id INTO received_donation FROM public.in_kind_donation_receipts WHERE id=NEW.receipt_id;
 IF offered_donation IS NULL OR received_donation IS NULL OR offered_donation<>received_donation THEN
  RAISE EXCEPTION 'Receipt line and offer belong to different donations' USING ERRCODE='23514';
 END IF;
 SELECT COALESCE(SUM(quantity),0) INTO quantity_used FROM public.in_kind_donation_receipt_lines
 WHERE donation_item_id=NEW.donation_item_id AND id IS DISTINCT FROM NEW.id;
 IF NEW.quantity<=0 OR quantity_used + NEW.quantity>offered_quantity THEN
  RAISE EXCEPTION 'Received quantity exceeds offered quantity' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_in_kind_donation_receipt_lines_receipt_line_integrity_event BEFORE INSERT OR UPDATE ON public.in_kind_donation_receipt_lines
FOR EACH ROW EXECUTE FUNCTION public.fn_receipt_line_integrity();

-- PO-17: document rectification must point to distinct document and cannot form a cycle.
CREATE OR REPLACE FUNCTION public.fn_document_rectification_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
DECLARE origin_document integer; found_cycle boolean;
BEGIN
 IF NEW.rectifies_version_id IS NULL THEN RETURN NEW; END IF;
 IF NEW.rectifies_version_id=NEW.id THEN RAISE EXCEPTION 'Self rectification not allowed' USING ERRCODE='23514'; END IF;
 SELECT document_id INTO origin_document FROM public.document_versions WHERE id=NEW.rectifies_version_id;
 IF origin_document=NEW.document_id THEN RAISE EXCEPTION 'Rectification requires a different official document' USING ERRCODE='23514'; END IF;
 WITH RECURSIVE lineage(id,rectifies_version_id) AS (
  SELECT id,rectifies_version_id FROM public.document_versions WHERE id=NEW.rectifies_version_id
  UNION
  SELECT v.id,v.rectifies_version_id FROM public.document_versions v JOIN lineage l ON v.id=l.rectifies_version_id
 ) SELECT EXISTS(SELECT 1 FROM lineage WHERE id=NEW.id) INTO found_cycle;
 IF found_cycle THEN RAISE EXCEPTION 'Document rectification cycle detected' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_document_versions_document_rectification_check_event BEFORE INSERT ON public.document_versions
FOR EACH ROW EXECUTE FUNCTION public.fn_document_rectification_check();

-- PO-18: series.code immutable after first official emission.
CREATE OR REPLACE FUNCTION public.fn_series_code_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog, public AS $$
BEGIN
 IF NEW.code IS DISTINCT FROM OLD.code AND EXISTS (
  SELECT 1 FROM public.document_records WHERE series_id=OLD.id AND official_registered_at IS NOT NULL
 ) THEN RAISE EXCEPTION 'Issued document series code cannot change' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_document_series_document_series_code_guard_event BEFORE UPDATE OF code ON public.document_series
FOR EACH ROW EXECUTE FUNCTION public.fn_series_code_guard();

-- PO-19: committed official folios cannot be changed or recycled.
CREATE OR REPLACE FUNCTION public.fn_document_official_guard() RETURNS trigger
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
CREATE TRIGGER trg_document_records_document_official_guard_event BEFORE UPDATE OR DELETE ON public.document_records
FOR EACH ROW EXECUTE FUNCTION public.fn_document_official_guard();

-- PO-20: monotonic folio counter. Application grants must be restricted to a controlled backend DB principal.
CREATE OR REPLACE FUNCTION public.fn_folio_counter_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Folio counter cannot be deleted' USING ERRCODE='23514'; END IF;
 IF NEW.last_assigned<0 OR (TG_OP='UPDATE' AND NEW.last_assigned<=OLD.last_assigned) THEN
  RAISE EXCEPTION 'Folio counter may only increase' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_document_folio_counters_folio_counter_guard_event BEFORE INSERT OR UPDATE OR DELETE ON public.document_folio_counters
FOR EACH ROW EXECUTE FUNCTION public.fn_folio_counter_guard();

-- PO-22: immutable economics after a financial movement is posted; VOIDED keeps the ledger row.
CREATE OR REPLACE FUNCTION public.fn_financial_movement_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF OLD.status IN ('POSTED','VOIDED') THEN RAISE EXCEPTION 'Posted financial movement cannot be deleted' USING ERRCODE='23514'; END IF;
  RETURN OLD;
 END IF;
 IF OLD.status IN ('POSTED','VOIDED') AND (
  NEW.account_id IS DISTINCT FROM OLD.account_id OR NEW.amount IS DISTINCT FROM OLD.amount OR
  NEW.currency IS DISTINCT FROM OLD.currency OR NEW.type IS DISTINCT FROM OLD.type OR
  NEW.source IS DISTINCT FROM OLD.source OR NEW.source_id IS DISTINCT FROM OLD.source_id OR
  NEW.origin_type IS DISTINCT FROM OLD.origin_type OR NEW.initiative_id IS DISTINCT FROM OLD.initiative_id OR
  NEW.destination_type IS DISTINCT FROM OLD.destination_type OR NEW.reversal_of_id IS DISTINCT FROM OLD.reversal_of_id
 ) THEN RAISE EXCEPTION 'Posted financial movement economics are immutable' USING ERRCODE='23514'; END IF;
 IF OLD.status='VOIDED' AND NEW.status IS DISTINCT FROM OLD.status THEN
   RAISE EXCEPTION 'Voided movement cannot be reopened' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_financial_movements_financial_movement_guard_event BEFORE UPDATE OR DELETE ON public.financial_movements
FOR EACH ROW EXECUTE FUNCTION public.fn_financial_movement_guard();

-- PO-23: recognition of maintenance expense only after verified work order closure.
CREATE OR REPLACE FUNCTION public.fn_maintenance_cost_guard() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE work_verified timestamp; work_closed timestamp;
BEGIN
 IF NEW.maintenance_cost_recognized_at IS NULL THEN RETURN NEW; END IF;
 IF NEW.maintenance_work_order_id IS NULL THEN RAISE EXCEPTION 'Maintenance cost requires work order' USING ERRCODE='23514'; END IF;
 SELECT verified_at,closed_at INTO work_verified,work_closed FROM public.maintenance_work_orders WHERE id=NEW.maintenance_work_order_id;
 IF work_verified IS NULL OR work_closed IS NULL OR work_closed>NEW.maintenance_cost_recognized_at THEN
  RAISE EXCEPTION 'Maintenance expense may be recognized only after verified closure' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_expenses_maintenance_cost_guard_event BEFORE INSERT OR UPDATE ON public.expenses
FOR EACH ROW EXECUTE FUNCTION public.fn_maintenance_cost_guard();


-- PO-12 (completion): returned loan cannot close with unallocated/unaccounted quantity.
-- Runs deferred so checkout/return/shortage rows may be written in one transaction.
CREATE OR REPLACE FUNCTION public.fn_loan_close_equation() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE allocated numeric; accounted numeric;
BEGIN
 IF NEW.status<>'RETURNED' THEN RETURN NULL; END IF;
 SELECT COALESCE(SUM(quantity),0) INTO allocated FROM public.inventory_loan_checkout_allocations WHERE loan_id=NEW.id;
 SELECT COALESCE(SUM(d.quantity),0) INTO accounted
 FROM public.inventory_loan_return_details d JOIN public.inventory_loan_checkout_allocations a ON a.id=d.checkout_allocation_id
 WHERE a.loan_id=NEW.id;
 SELECT accounted+COALESCE(SUM(s.quantity),0) INTO accounted
 FROM public.inventory_loan_shortages s JOIN public.inventory_loan_checkout_allocations a ON a.id=s.checkout_allocation_id
 WHERE a.loan_id=NEW.id AND s.status IS DISTINCT FROM 'CANCELLED';
 IF allocated<>NEW.quantity OR accounted<>allocated THEN
  RAISE EXCEPTION 'Cannot close loan %: loan qty %, allocated %, accounted %', NEW.id,NEW.quantity,allocated,accounted USING ERRCODE='23514';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER trg_inventory_loans_loan_close_equation_event AFTER INSERT OR UPDATE ON public.inventory_loans
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.fn_loan_close_equation();

-- PO-15 (reverse direction): decreasing offered quantity must not invalidate received rows.
CREATE OR REPLACE FUNCTION public.fn_offer_quantity_floor() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE received numeric;
BEGIN
 SELECT COALESCE(SUM(quantity),0) INTO received FROM public.in_kind_donation_receipt_lines WHERE donation_item_id=NEW.id;
 IF NEW.quantity<received THEN
  RAISE EXCEPTION 'Offered quantity (%) cannot be less than quantity received (%)',NEW.quantity,received USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_in_kind_donation_items_offer_quantity_floor_event BEFORE UPDATE OF quantity ON public.in_kind_donation_items
FOR EACH ROW EXECUTE FUNCTION public.fn_offer_quantity_floor();


-- ===== MODULE: 07_venture_publishing.sql =====
-- Venture approval workflow. It reuses immutable VentureRequestRevision snapshots.
-- No grant is inferred from VentureAssociation.

-- A reviewer delegation must point to their own institutional appointment.
CREATE OR REPLACE FUNCTION public.fn_reviewer_authorization_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE holder_person integer; appointment_person integer;
BEGIN
 SELECT person_id INTO holder_person FROM public.users WHERE id=NEW.user_id;
 SELECT person_id INTO appointment_person FROM public.board_appointments WHERE id=NEW.membership_id;
 IF holder_person IS NULL OR appointment_person IS NULL OR holder_person<>appointment_person THEN
  RAISE EXCEPTION 'Reviewer authorization requires matching user and board appointment person' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_venture_reviewer_authorizations_reviewer_authoriza_1935a010 BEFORE INSERT OR UPDATE OF user_id,membership_id
ON public.venture_reviewer_authorizations FOR EACH ROW EXECUTE FUNCTION public.fn_reviewer_authorization_check();

-- Grants may be issued only by the User who actually holds the referenced appointment.
CREATE OR REPLACE FUNCTION public.fn_manager_authorization_check() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE grantor_person integer; appointment_person integer;
BEGIN
 SELECT person_id INTO grantor_person FROM public.users WHERE id=NEW.granted_by_user_id;
 SELECT person_id INTO appointment_person FROM public.board_appointments WHERE id=NEW.granted_by_membership_id;
 IF grantor_person IS NULL OR appointment_person IS NULL OR grantor_person<>appointment_person THEN
  RAISE EXCEPTION 'Venture management grant issuer does not hold the referenced appointment' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_venture_manager_authorizations_manager_authorizati_59edf03f BEFORE INSERT OR UPDATE OF granted_by_user_id,granted_by_membership_id
ON public.venture_manager_authorizations FOR EACH ROW EXECUTE FUNCTION public.fn_manager_authorization_check();

-- A review decision requires a matching, live delegation and a current Board appointment.
CREATE OR REPLACE FUNCTION public.fn_venture_decision_validate() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE grant_rec public.venture_reviewer_authorizations%ROWTYPE;
        person_id integer; member_person integer; member_start timestamp; member_end timestamp;
        term_status text; term_start timestamp; term_end timestamp;
        req_venture integer; decision_time timestamp;
BEGIN
 SELECT * INTO grant_rec FROM public.venture_reviewer_authorizations WHERE id=NEW.reviewer_authorization_id FOR SHARE;
 IF NOT FOUND OR grant_rec.user_id<>NEW.reviewer_user_id OR grant_rec.membership_id<>NEW.reviewer_membership_id THEN
  RAISE EXCEPTION 'Review decision has no matching reviewer grant' USING ERRCODE='23514';
 END IF;
 IF grant_rec.revoked_at IS NOT NULL OR NEW.decided_at < grant_rec.valid_from OR
    (grant_rec.valid_until IS NOT NULL AND NEW.decided_at >= grant_rec.valid_until) THEN
  RAISE EXCEPTION 'Reviewer authorization is not active at decision time' USING ERRCODE='23514';
 END IF;
 decision_time := NEW.decided_at AT TIME ZONE 'UTC';
 SELECT u.person_id INTO person_id FROM public.users u WHERE u.id=NEW.reviewer_user_id;
 SELECT a.person_id,a.starts_on,a.ends_on,t.status::text,t.starts_on,t.ends_on
 INTO member_person,member_start,member_end,term_status,term_start,term_end
 FROM public.board_appointments a JOIN public.board_terms t ON t.id=a.board_term_id
 WHERE a.id=NEW.reviewer_membership_id;
 IF person_id IS NULL OR person_id IS DISTINCT FROM member_person OR
    member_start IS NULL OR term_start IS NULL OR term_end IS NULL OR
    decision_time < member_start OR (member_end IS NOT NULL AND decision_time > member_end) OR
    decision_time < term_start OR decision_time > term_end OR term_status IS DISTINCT FROM 'ACTIVE' THEN
  RAISE EXCEPTION 'Reviewer does not have a competent active appointment' USING ERRCODE='23514';
 END IF;
 IF NEW.revision_id IS NOT NULL THEN
  SELECT vr.venture_id INTO req_venture FROM public.venture_request_revisions rev
  JOIN public.venture_requests vr ON vr.id=rev.request_id WHERE rev.id=NEW.revision_id;
  IF req_venture IS DISTINCT FROM NEW.venture_id THEN
   RAISE EXCEPTION 'Reviewed revision does not belong to venture' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_venture_review_decisions_venture_decision_validate_event BEFORE INSERT ON public.venture_review_decisions
FOR EACH ROW EXECUTE FUNCTION public.fn_venture_decision_validate();

-- A published venture must point to its own APPROVED revision; latest pending version is not public.
CREATE OR REPLACE FUNCTION public.fn_published_revision_validate() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
DECLARE req_venture integer; approved boolean;
BEGIN
 IF NEW.publication_status='PUBLISHED' THEN
  IF NEW.status<>'ACTIVE' OR NEW.published_request_revision_id IS NULL THEN
   RAISE EXCEPTION 'Published venture requires ACTIVE status and a published revision' USING ERRCODE='23514';
  END IF;
  SELECT vr.venture_id INTO req_venture
  FROM public.venture_request_revisions rev JOIN public.venture_requests vr ON vr.id=rev.request_id
  WHERE rev.id=NEW.published_request_revision_id;
  IF req_venture IS DISTINCT FROM NEW.id THEN
   RAISE EXCEPTION 'Published revision does not belong to venture' USING ERRCODE='23514';
  END IF;
  SELECT EXISTS(SELECT 1 FROM public.venture_review_decisions d
    WHERE d.venture_id=NEW.id AND d.revision_id=NEW.published_request_revision_id AND d.decision='APPROVE') INTO approved;
  IF NOT approved THEN RAISE EXCEPTION 'Published revision has no recorded approval' USING ERRCODE='23514'; END IF;
 END IF;
 IF TG_OP='UPDATE' AND OLD.publication_status='PUBLISHED' AND NEW.publication_status='PUBLISHED' THEN
  IF (NEW.name,NEW.description,NEW.offer_description,NEW.business_phone,NEW.business_email,NEW.website_url,NEW.social_url,NEW.location_text)
     IS DISTINCT FROM
     (OLD.name,OLD.description,OLD.offer_description,OLD.business_phone,OLD.business_email,OLD.website_url,OLD.social_url,OLD.location_text)
     AND NEW.published_request_revision_id IS NOT DISTINCT FROM OLD.published_request_revision_id THEN
   RAISE EXCEPTION 'Published content cannot change without a newly approved revision' USING ERRCODE='23514';
  END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_ventures_published_revision_validate_event BEFORE INSERT OR UPDATE ON public.ventures
FOR EACH ROW EXECUTE FUNCTION public.fn_published_revision_validate();

-- Revocation, suspension and closure remove publication in the same transaction as decision insertion.
CREATE OR REPLACE FUNCTION public.fn_venture_decision_unpublish() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog,public AS $$
BEGIN
 IF NEW.decision IN ('REVOKE','SUSPEND','CLOSE') THEN
  UPDATE public.ventures v SET
   publication_status='UNPUBLISHED',
   status=CASE NEW.decision WHEN 'CLOSE' THEN 'CLOSED'::public.venture_status
                            WHEN 'SUSPEND' THEN 'SUSPENDED'::public.venture_status ELSE v.status END
  WHERE v.id=NEW.venture_id;
 ELSIF NEW.decision='RESTORE' THEN
  UPDATE public.ventures SET status='ACTIVE',publication_status='UNPUBLISHED' WHERE id=NEW.venture_id;
 END IF;
 RETURN NULL;
END $$;
CREATE TRIGGER trg_venture_review_decisions_venture_decision_unpublish_event AFTER INSERT ON public.venture_review_decisions
FOR EACH ROW EXECUTE FUNCTION public.fn_venture_decision_unpublish();

-- Strict public projection: serve only the approved JSON snapshot, never draft fields on Venture.
CREATE VIEW public.vw_approved_venture_snapshot WITH (security_invoker=true) AS
 SELECT v.id AS venture_id, v.published_request_revision_id AS revision_id,
        rev.submitted_data AS published_data, rev.submitted_at AS submitted_at
 FROM public.ventures v JOIN public.venture_request_revisions rev ON rev.id=v.published_request_revision_id
 WHERE v.status='ACTIVE' AND v.publication_status='PUBLISHED';


-- ===== BD-01E-A: explicit normalized identity-sequence names =====
ALTER SEQUENCE public.absence_justifications_id_seq RENAME TO seq_absence_justifications_id;
ALTER SEQUENCE public.account_activation_tokens_id_seq RENAME TO seq_account_activation_tokens_id;
ALTER SEQUENCE public.affiliate_requests_id_seq RENAME TO seq_affiliate_requests_id;
ALTER SEQUENCE public.affiliate_sanctions_id_seq RENAME TO seq_affiliate_sanctions_id;
ALTER SEQUENCE public.affiliates_id_seq RENAME TO seq_affiliates_id;
ALTER SEQUENCE public.assembly_attendances_id_seq RENAME TO seq_assembly_attendances_id;
ALTER SEQUENCE public.assembly_calls_id_seq RENAME TO seq_assembly_calls_id;
ALTER SEQUENCE public.assembly_convocations_id_seq RENAME TO seq_assembly_convocations_id;
ALTER SEQUENCE public.assembly_minutes_id_seq RENAME TO seq_assembly_minutes_id;
ALTER SEQUENCE public.assembly_resolutions_id_seq RENAME TO seq_assembly_resolutions_id;
ALTER SEQUENCE public.assemblies_id_seq RENAME TO seq_assemblies_id;
ALTER SEQUENCE public.audit_logs_id_seq RENAME TO seq_audit_logs_id;
ALTER SEQUENCE public.board_appointments_id_seq RENAME TO seq_board_appointments_id;
ALTER SEQUENCE public.board_terms_id_seq RENAME TO seq_board_terms_id;
ALTER SEQUENCE public.disbursements_id_seq RENAME TO seq_disbursements_id;
ALTER SEQUENCE public.donations_id_seq RENAME TO seq_donations_id;
ALTER SEQUENCE public.events_id_seq RENAME TO seq_events_id;
ALTER SEQUENCE public.expense_documents_id_seq RENAME TO seq_expense_documents_id;
ALTER SEQUENCE public.expenses_id_seq RENAME TO seq_expenses_id;
ALTER SEQUENCE public.financial_accounts_id_seq RENAME TO seq_financial_accounts_id;
ALTER SEQUENCE public.financial_charges_id_seq RENAME TO seq_financial_charges_id;
ALTER SEQUENCE public.financial_movements_id_seq RENAME TO seq_financial_movements_id;
ALTER SEQUENCE public.funding_allocations_id_seq RENAME TO seq_funding_allocations_id;
ALTER SEQUENCE public.governance_positions_id_seq RENAME TO seq_governance_positions_id;
ALTER SEQUENCE public.inventory_categories_id_seq RENAME TO seq_inventory_categories_id;
ALTER SEQUENCE public.inventory_items_id_seq RENAME TO seq_inventory_items_id;
ALTER SEQUENCE public.inventory_loans_id_seq RENAME TO seq_inventory_loans_id;
ALTER SEQUENCE public.inventory_movements_id_seq RENAME TO seq_inventory_movements_id;
ALTER SEQUENCE public.password_reset_tokens_id_seq RENAME TO seq_password_reset_tokens_id;
ALTER SEQUENCE public.payments_id_seq RENAME TO seq_payments_id;
ALTER SEQUENCE public.permissions_id_seq RENAME TO seq_permissions_id;
ALTER SEQUENCE public.people_id_seq RENAME TO seq_people_id;
ALTER SEQUENCE public.reservable_resources_id_seq RENAME TO seq_reservable_resources_id;
ALTER SEQUENCE public.reservations_id_seq RENAME TO seq_reservations_id;
ALTER SEQUENCE public.roles_id_seq RENAME TO seq_roles_id;
ALTER SEQUENCE public.sessions_id_seq RENAME TO seq_sessions_id;
ALTER SEQUENCE public.user_requests_id_seq RENAME TO seq_user_requests_id;
ALTER SEQUENCE public.users_id_seq RENAME TO seq_users_id;
ALTER SEQUENCE public.venture_associations_id_seq RENAME TO seq_venture_associations_id;
ALTER SEQUENCE public.venture_manager_authorizations_id_seq RENAME TO seq_venture_manager_authorizations_id;
ALTER SEQUENCE public.venture_request_revisions_id_seq RENAME TO seq_venture_request_revisions_id;
ALTER SEQUENCE public.venture_requests_id_seq RENAME TO seq_venture_requests_id;
ALTER SEQUENCE public.venture_review_decisions_id_seq RENAME TO seq_venture_review_decisions_id;
ALTER SEQUENCE public.venture_reviewer_authorizations_id_seq RENAME TO seq_venture_reviewer_authorizations_id;
ALTER SEQUENCE public.ventures_id_seq RENAME TO seq_ventures_id;
ALTER SEQUENCE public.volunteer_applications_id_seq RENAME TO seq_volunteer_applications_id;
ALTER SEQUENCE public.volunteer_attendances_id_seq RENAME TO seq_volunteer_attendances_id;
ALTER SEQUENCE public.volunteer_opportunities_id_seq RENAME TO seq_volunteer_opportunities_id;
ALTER SEQUENCE public.volunteer_participations_id_seq RENAME TO seq_volunteer_participations_id;
ALTER SEQUENCE public.volunteer_sessions_id_seq RENAME TO seq_volunteer_sessions_id;
ALTER SEQUENCE public.board_minutes_id_seq RENAME TO seq_board_minutes_id;
ALTER SEQUENCE public.board_resolutions_id_seq RENAME TO seq_board_resolutions_id;
ALTER SEQUENCE public.board_sessions_id_seq RENAME TO seq_board_sessions_id;
ALTER SEQUENCE public.correspondences_id_seq RENAME TO seq_correspondences_id;
ALTER SEQUENCE public.correspondence_logs_id_seq RENAME TO seq_correspondence_logs_id;
ALTER SEQUENCE public.document_records_id_seq RENAME TO seq_document_records_id;
ALTER SEQUENCE public.document_series_id_seq RENAME TO seq_document_series_id;
ALTER SEQUENCE public.document_versions_id_seq RENAME TO seq_document_versions_id;
ALTER SEQUENCE public.donors_id_seq RENAME TO seq_donors_id;
ALTER SEQUENCE public.event_budget_lines_id_seq RENAME TO seq_event_budget_lines_id;
ALTER SEQUENCE public.event_review_decisions_id_seq RENAME TO seq_event_review_decisions_id;
ALTER SEQUENCE public.event_revisions_id_seq RENAME TO seq_event_revisions_id;
ALTER SEQUENCE public.expense_document_logs_id_seq RENAME TO seq_expense_document_logs_id;
ALTER SEQUENCE public.in_kind_donation_decisions_id_seq RENAME TO seq_in_kind_donation_decisions_id;
ALTER SEQUENCE public.in_kind_donations_id_seq RENAME TO seq_in_kind_donations_id;
ALTER SEQUENCE public.in_kind_donation_items_id_seq RENAME TO seq_in_kind_donation_items_id;
ALTER SEQUENCE public.in_kind_donation_receipts_id_seq RENAME TO seq_in_kind_donation_receipts_id;
ALTER SEQUENCE public.in_kind_donation_receipt_lines_id_seq RENAME TO seq_in_kind_donation_receipt_lines_id;
ALTER SEQUENCE public.initiatives_id_seq RENAME TO seq_initiatives_id;
ALTER SEQUENCE public.institutional_facilities_id_seq RENAME TO seq_institutional_facilities_id;
ALTER SEQUENCE public.inventory_loan_checkout_allocations_id_seq RENAME TO seq_inventory_loan_checkout_allocations_id;
ALTER SEQUENCE public.inventory_loan_return_details_id_seq RENAME TO seq_inventory_loan_return_details_id;
ALTER SEQUENCE public.inventory_loan_returns_id_seq RENAME TO seq_inventory_loan_returns_id;
ALTER SEQUENCE public.inventory_loan_shortage_decisions_id_seq RENAME TO seq_inventory_loan_shortage_decisions_id;
ALTER SEQUENCE public.inventory_loan_shortages_id_seq RENAME TO seq_inventory_loan_shortages_id;
ALTER SEQUENCE public.inventory_stock_lots_id_seq RENAME TO seq_inventory_stock_lots_id;
ALTER SEQUENCE public.inventory_stock_lot_receipt_origins_id_seq RENAME TO seq_inventory_stock_lot_receipt_origins_id;
ALTER SEQUENCE public.inventory_units_id_seq RENAME TO seq_inventory_units_id;
ALTER SEQUENCE public.inventory_unit_receipt_origins_id_seq RENAME TO seq_inventory_unit_receipt_origins_id;
ALTER SEQUENCE public.maintenance_incidents_id_seq RENAME TO seq_maintenance_incidents_id;
ALTER SEQUENCE public.maintenance_work_orders_id_seq RENAME TO seq_maintenance_work_orders_id;
ALTER SEQUENCE public.resource_unavailabilities_id_seq RENAME TO seq_resource_unavailabilities_id;

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
 IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='role_id') THEN
  RAISE EXCEPTION 'Legacy User.roleId must not be part of V2 initial schema'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='pk_user_roles') THEN RAISE EXCEPTION 'Missing UserRole PK'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conname='ex_resource_unavailabilities_rule') THEN RAISE EXCEPTION 'Missing resource exclusion'; END IF;
 IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
            WHERE n.nspname='public' AND c.relkind='r' AND NOT c.relrowsecurity) THEN
  RAISE EXCEPTION 'RLS disabled on some public SGI tables'; END IF;
 RAISE NOTICE 'SGI V2 schema PASS: % tables, % enums, % FKs, % named CHECK, % exclusion',
  c_tables,c_enums,c_fks,c_checks,c_exclude;
END $$;

COMMIT;
