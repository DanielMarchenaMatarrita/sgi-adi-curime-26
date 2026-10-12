# Spec Delta

## Purpose

Defines the observable safety and evidence contract for proving the DEV Digital Affiliate Registry works end to end without changing approved architecture or institutional data.

## ADDED Requirements

### Requirement: Read-only DEV runtime baseline
The validation process SHALL inspect the selected persistent DEV database without mutation and report the actual database identity, required runtime roles, relevant memberships, Affiliate grants, RLS enablement and enforcement flags, and deployed Affiliate policies.

#### Scenario: Expected security state is deployed
- **WHEN** an authorized operator runs the read-only baseline checks against the selected DEV database
- **THEN** the evidence identifies the database and records PASS for every expected runtime role, grant, RLS flag, and Affiliate policy

#### Scenario: Runtime state differs from repository SQL
- **WHEN** a required role, grant, RLS flag, or Affiliate policy is absent or differs
- **THEN** the evidence records the exact discrepancy as FAIL without applying SQL or changing database state

### Requirement: Bootstrap inspection precedes fixture writes
The validation process MUST inspect existing DEV bootstrap scripts and relevant existing records before proposing or executing fixture writes.

#### Scenario: Existing bootstrap and data are assessed
- **WHEN** fixture preparation is considered
- **THEN** the operator records script safety findings, idempotency assumptions, target identifiers, and whether valid existing data can be reused

### Requirement: Explicit approval gates mutable work
The process MUST NOT modify bootstrap scripts or execute a bootstrap, seed, SQL mutation, or other DEV database write until the exact file list and diff, expected database changes, pre-state Git status, and explicit approval have been recorded.

#### Scenario: Approval has not been granted
- **WHEN** read-only inspection finds missing fixture data or a bootstrap-script safety gap
- **THEN** execution stops after reporting the proposed file and database changes and no file or database write occurs

#### Scenario: Approval is granted
- **WHEN** the authorized reviewer explicitly approves the identified file and database write set
- **THEN** only those approved files and database changes may be executed against the identified persistent DEV database and Git post-state is compared with pre-state

### Requirement: DEV fixture preparation preserves institutional data
Approved fixture preparation SHALL reuse valid existing records where safe and otherwise create clearly synthetic, collision-resistant DEV records without overwriting, deleting, reassigning, or repurposing institutional records or roles.

#### Scenario: Valid reusable data exists
- **WHEN** an existing active DEV identity has the required effective permission and a suitable synthetic Affiliate exists
- **THEN** validation reuses those records without changing them

#### Scenario: Required fixture data is absent
- **WHEN** approved fixture execution finds no safe reusable record
- **THEN** it creates or reuses only the isolated DEV identity, DEV-only authorization links, and synthetic Affiliate needed for validation

#### Scenario: Identifier collision involves non-DEV data
- **WHEN** a target fixture identifier belongs to an institutional or otherwise non-DEV record
- **THEN** fixture preparation fails safely and leaves that record unchanged

### Requirement: Pagination fixture capacity
Fixture preparation SHALL provide enough safe existing or approved synthetic Affiliate records to demonstrate two pages using the M1 API limit inspected at execution time.

#### Scenario: Existing safe records satisfy pagination
- **WHEN** reusable synthetic Affiliate records exceed the inspected M1 API limit
- **THEN** validation uses those records without creating additional Affiliates

#### Scenario: Existing safe records are insufficient
- **WHEN** reusable synthetic Affiliate records do not exceed the inspected M1 API limit
- **THEN** the exact additional synthetic Affiliate count is proposed for explicit approval before any write

### Requirement: Authorized Affiliate runtime path
The validated DEV runtime SHALL authenticate an active DEV user, resolve `affiliates.read` as an effective permission, and return Affiliate list data through `GET /api/affiliates` using the approved response contract.

#### Scenario: Authorized user lists Affiliates
- **WHEN** the active DEV user logs in and calls `GET /api/affiliates` with the issued Bearer token
- **THEN** login returns a valid JWT and the list response is `200` with only `id`, `fullName`, `affiliateType`, `affiliationDate`, and `status` per item

#### Scenario: Valid Affiliate states are returned
- **WHEN** Affiliate list data is returned
- **THEN** every item status is either `ACTIVE` or `INACTIVE`

### Requirement: Effective permission resolution is verified
The validated DEV runtime SHALL return the active user's effective permissions through `GET /api/users/me/permissions` without exposing secrets.

#### Scenario: Authorized user resolves Affiliate permission
- **WHEN** the active DEV user calls `GET /api/users/me/permissions` with the issued Bearer token
- **THEN** the API returns `200`, includes `affiliates.read`, and produces sanitized runtime evidence

### Requirement: Unauthorized Affiliate access is denied
The DEV runtime SHALL enforce both JWT authentication and the `affiliates.read` permission for Affiliate reads.

#### Scenario: Missing or invalid JWT
- **WHEN** a client calls `GET /api/affiliates` without a valid Bearer token
- **THEN** the API returns `401`

#### Scenario: Authenticated user lacks permission
- **WHEN** an authenticated active user without effective `affiliates.read` calls `GET /api/affiliates`
- **THEN** the API returns `403` and no Affiliate data is disclosed

### Requirement: PostgreSQL enforces the runtime security boundary
Affiliate checks SHALL use `sgi_app_runtime` in read-only transactions with sanitized actor context, and PostgreSQL grants plus RLS SHALL deny or hide reads that do not satisfy the approved permission path.

#### Scenario: Authorized actor reads under runtime context
- **WHEN** the backend performs an authorized Affiliate query in a read-only transaction
- **THEN** evidence confirms `current_user` is `sgi_app_runtime`, records the sanitized authorized actor context, and confirms the query succeeds

#### Scenario: Missing or unauthorized actor context is tested
- **WHEN** `sgi_app_runtime` performs a read-only Affiliate query with missing actor context or an actor lacking `affiliates.read`
- **THEN** evidence records sanitized context and PostgreSQL returns no unauthorized Affiliate rows or denies access according to the deployed grants and policy

### Requirement: M1 uses and presents real Affiliate API data
M1 SHALL render Affiliate records obtained from the protected DEV API and SHALL support name filtering, ACTIVE/INACTIVE filtering, and server pagination without substituting frontend mock data.

#### Scenario: Real Affiliate record is displayed
- **WHEN** an authorized user opens M1 after login
- **THEN** the synthetic or safely reused Affiliate returned by the DEV API is visible with the minimum contract fields

#### Scenario: Filters affect API-backed results
- **WHEN** the user changes the name or status filter
- **THEN** M1 requests the corresponding API query and displays matching real results

#### Scenario: Pagination requests another page
- **WHEN** available results exceed one page and the user navigates pages
- **THEN** M1 requests the correct server offset and displays the returned page

### Requirement: Validation evidence is attributable and reproducible
Each acceptance check SHALL record `PASSED`, `FAILED`, or `NOT_EXECUTED`, with a sanitized command or test identifier, timestamp, selected DEV environment identity, and sufficient output to reproduce the conclusion without exposing credentials, passwords, JWTs, or connection secrets.

#### Scenario: Validation report is complete
- **WHEN** runtime validation finishes or stops at a gate
- **THEN** every planned check has `PASSED`, `FAILED`, or `NOT_EXECUTED` status, where only executed checks can be `PASSED` or `FAILED`, with sanitized supporting evidence and a stated next action
