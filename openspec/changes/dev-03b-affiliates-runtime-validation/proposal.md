# Proposal

## Why

DEV-03B has implemented database, API, authorization, and React components, but the current persistent DEV environment has not been proven to contain the required runtime roles, grants, RLS policy deployment, authorized user, effective permission assignment, or Affiliate fixture. Operational validation is needed now to distinguish implemented code from verified end-to-end behavior before M1 is accepted.

## What Changes

- Establish read-only checks for the actual PostgreSQL 17 DEV state, including runtime roles, role membership, grants, enabled and forced RLS, deployed Affiliate policies, and required relations.
- Inspect existing DEV bootstrap scripts and data before proposing or approving any database write.
- Define a minimal, repeatable DEV fixture strategy that reuses valid records and otherwise creates only one isolated DEV user identity, one DEV-only role assignment, the `affiliates.read` permission link, and enough clearly synthetic Affiliate records for two pages under the inspected M1 API limit.
- Require an explicit approval gate before bootstrap-script changes, bootstrap execution, or any DEV database write; never overwrite or repurpose institutional records.
- Validate the complete runtime path: login, effective permission resolution, permitted Affiliate listing, denied access without permission, PostgreSQL runtime security, and M1 rendering with filters and pagination.
- Collect measurable, reproducible evidence for each acceptance criterion while preserving current API, schema, migration, and RLS contracts.
- Keep implementation tasks and verification tasks separate. Historical README corrections remain out of scope unless execution becomes impossible without correcting operational instructions.

### Verified Facts

- PostgreSQL 17 and Prisma 6 are configured, and the Prisma schema defines Affiliate as the primary registry entity with `ACTIVE` and `INACTIVE` states.
- NestJS implements `GET /api/affiliates` and `GET /api/affiliates/:id`, guarded by JWT, `PermissionGuard`, and `affiliates.read`.
- SQL artifacts define runtime roles, restricted grants, transaction-local actor context, and an Affiliate RLS SELECT policy.
- React M1 calls the real Affiliate API through React Query; no M1 frontend mock source was detected.

### Runtime Uncertainties

- Whether the persistent DEV database has the expected runtime roles, memberships, grants, RLS flags, and Affiliate policy deployed.
- Whether a safe authorized DEV user, effective `affiliates.read` assignment, and usable Affiliate record already exist.
- Whether the current bootstrap scripts are fully safe and repeatable against existing DEV data.
- Whether login through M1 reaches and renders real protected Affiliate data with working filters and pagination.

### Required Actions

- Run approved read-only database inspection first and retain sanitized evidence.
- Reconcile existing data and scripts against the fixture requirements.
- Present any proposed write plan and obtain explicit approval before executing it.
- After approved fixture preparation, run API, negative authorization, database security, and browser-level M1 verification.

### Acceptance Criteria

- Read-only evidence confirms expected PostgreSQL roles, grants, RLS status, and Affiliate policy deployment, or identifies each exact discrepancy without changing it.
- Approved fixture handling is repeatable, does not overwrite institutional records, and yields an active DEV user with effective `affiliates.read` plus at least one synthetic Affiliate when valid reusable data is absent.
- Login returns a valid JWT; effective permissions include `affiliates.read`; permitted Affiliate listing returns only contract fields and valid states.
- A valid authenticated user lacking `affiliates.read` receives `403` from `GET /api/affiliates`, while missing or invalid JWT receives `401`.
- Runtime database access uses the intended restricted role and actor context, with RLS and grants preventing unauthorized Affiliate reads.
- M1 renders real API data and demonstrates status filtering, name filtering, and server pagination without mocks.
- Evidence records commands or test identifiers, sanitized outputs, timestamps/environment identity, and `PASSED`, `FAILED`, or `NOT_EXECUTED` per criterion.

## Capabilities

### New Capabilities

- `affiliate-registry-runtime-readiness`: Defines safe DEV environment inspection, approval-gated fixture preparation, end-to-end Affiliate registry validation, and required acceptance evidence.

### Modified Capabilities

None.

## Impact

- Planning and later execution may inspect PostgreSQL catalog state, existing bootstrap scripts, NestJS integration paths, and React M1 behavior.
- No new entity, endpoint, dependency, migration, schema change, RLS policy change, or API contract change is introduced.
- Any later bootstrap-script change or DEV fixture write remains separately approval-gated, uses an approved exact file list and diff, and is limited to synthetic DEV data or reuse of already valid records.
- Existing unrelated Git changes remain untouched.
