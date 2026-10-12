# Design

## Context

See `proposal.md` for motivation and verified facts. Repository evidence already contains the Affiliate Prisma model, NestJS list/detail endpoints, JWT authentication, effective-permission lookup, `PermissionGuard`, transaction-local PostgreSQL actor context, an Affiliate RLS policy in SQL, and React M1 API integration.

The current persistent DEV database remains an external runtime state: repository SQL proves intent, not deployment. Existing `scripts/bootstrap-dev-user.cjs` prepares a synthetic Person/User and DEV-only `affiliates.read` assignment, uses Argon2id, and includes an interactive hidden-password path, but it has not been approved or executed in this change and does not prepare an Affiliate fixture. Existing unrelated working-tree changes must remain untouched.

## Goals / Non-Goals

**Goals:**

- Produce an attributable read-only baseline before any mutation is considered.
- Reconcile actual DEV state with repository contracts without treating repository SQL as deployment evidence.
- Use the smallest safe fixture set and make every mutation explicit, reviewable, repeatable, and approval-gated.
- Validate application authorization and PostgreSQL enforcement independently, then validate the browser path.
- Preserve secrets and institutional data throughout evidence collection.

**Non-Goals:**

- Redesigning Affiliate, IAM, JWT, RLS, API, or frontend architecture.
- Adding entities, endpoints, permissions, UI features, dependencies, migrations, schema changes, or policy changes.
- Repairing a mismatched DEV database automatically; discrepancies are reported and require separate authorization.
- Correcting historical README content unless execution cannot proceed without operational clarification.

## Decisions

### 1. Separate repository intent from DEV deployment evidence

Validation starts with PostgreSQL catalog queries that are read-only and scoped to database identity, role attributes and memberships, table privileges, `relrowsecurity`, `relforcerowsecurity`, and `pg_policies` for the relevant tables. Results are compared with current repository contracts but never inferred from them.

**Rationale:** SQL files and Prisma models cannot prove what is deployed in a persistent database.

**Alternative considered:** Trust successful Prisma connectivity or existing integration tests. Rejected because connectivity and isolated test environments do not prove persistent DEV role, grant, or policy state.

### 2. Use a two-gate execution model

Gate A permits only inspection: Git state, script review, non-secret configuration shape, PostgreSQL catalog reads, and safe record-existence checks. Gate B begins only after a concrete mutable-work plan lists target database identity, target synthetic identifiers, records to reuse/create/update, expected row counts, rollback or cleanup implications, exact allowed file list, exact diff, and Git pre-state, followed by explicit human approval. Git post-state is compared with pre-state; unrelated files are prohibited.

**Rationale:** The user reserved all bootstrap-script changes and database writes for approval.

**Alternative considered:** Treat an idempotent bootstrap as implicitly safe. Rejected because idempotency does not protect against identifier collision, wrong-environment targeting, or institutional-data mutation.

### 3. Prefer reuse, otherwise create isolated synthetic fixtures

Fixture reconciliation classifies candidates as: safe reusable DEV fixture, missing, conflicting, or institutional/unknown. Reuse occurs only for clearly synthetic DEV-owned records that already satisfy the contract. Missing records may be proposed for creation. Conflicts stop execution. Institutional/unknown records are never modified.

Minimum fixture graph:

```text
Person ── User ── UserRole ── DEV-only Role
                                  │
                           RolePermission
                                  │
                         affiliates.read

Synthetic Affiliates ── enough for inspected M1 API limit + 1
```

The existing user bootstrap is the preferred starting point after inspection. The M1 implementation currently declares `PAGE_SIZE = 25`; apply work must re-inspect this value and require more than the then-current API limit before proving pagination. Any Affiliate fixture addition must be narrowly scoped and must not change schema, migrations, or RLS.

**Rationale:** This minimizes writes and preserves current contracts.

**Alternative considered:** Load a broad seed dataset. Rejected because it expands scope, collision risk, and cleanup cost.

### 4. Validate in dependency order with independent security evidence

After approved fixture readiness, validation proceeds:

```text
DB baseline
   ↓
Approved fixture reconciliation
   ↓
POST /api/auth/login
   ↓
GET /api/users/me/permissions
   ↓
GET /api/affiliates (authorized)
   ├── JWT-negative checks (401)
   ├── permission-negative check (403)
   └── PostgreSQL role/context/RLS checks
   ↓
M1 browser verification
   ├── real record rendering
   ├── name/status filters
   └── pagination
```

API authorization and PostgreSQL enforcement receive separate `PASSED`/`FAILED`/`NOT_EXECUTED` results. Browser success cannot substitute for database security evidence, and isolated integration-test success cannot substitute for persistent DEV checks.

**Rationale:** Each layer protects a different boundary and can fail independently.

**Alternative considered:** Validate only through M1. Rejected because UI success does not prove negative authorization or RLS behavior.

### 5. Evidence is sanitized and bound to one environment

Evidence records a non-secret database identity, PostgreSQL server version, timestamp, command or test identifier, expected outcome, observed outcome, and `PASSED`, `FAILED`, or `NOT_EXECUTED`. `PASSED` and `FAILED` require execution evidence; `NOT_EXECUTED` records an unmet prerequisite or approval gate. Passwords, URLs containing credentials, JWT values, hashes, and secret environment values are redacted or omitted. Validation aborts if environment identity changes between baseline and execution.

**Rationale:** Results must be reproducible without leaking credentials or mixing environments.

**Alternative considered:** Store raw console transcripts. Rejected because they can expose secrets and contain unrelated noise.

## Risks / Trade-offs

- **[Catalog access is insufficient for a complete read-only baseline]** → Mark affected checks `NOT_EXECUTED`; request narrowly scoped read permission rather than escalating credentials or guessing.
- **[DEV database differs from repository SQL]** → Report exact drift and stop; policy, grant, role, schema, and migration remediation remain outside this change.
- **[Existing bootstrap targets a conflicting identifier]** → Abort fixture execution; do not update or delete the conflicting record.
- **[Negative permission testing could require another user]** → Prefer an existing clearly synthetic no-permission identity; otherwise propose the smallest isolated negative fixture and place it behind the same approval gate.
- **[Pagination requires more records]** → Reuse safe synthetic data where available; otherwise propose the exact count above the inspected API limit for approval before any fixture write.
- **[Browser verification depends on local tooling]** → Preserve API and build evidence, mark visual checks `NOT_EXECUTED`, and provide exact manual steps for an authorized operator.
- **[Persistent DEV fixtures outlive validation]** → Use unmistakable DEV identifiers and document ownership; cleanup is not automatic because deleting persistent data is a separate destructive action.

## Migration Plan

No migration or deployment is part of this change.

1. Capture Git and environment identity without changing files or database state.
2. Run the read-only DEV baseline and inspect bootstrap behavior.
3. Produce a fixture reconciliation plus exact file/database write set, diff, and Git pre-state.
4. Stop for explicit approval.
5. If approved in a later apply execution, perform only the approved idempotent fixture action.
6. Run API, authorization, PostgreSQL security, and M1 verification; produce sanitized `PASSED`/`FAILED`/`NOT_EXECUTED` evidence.

Rollback is not automatic. If an approved fixture write partially fails, transaction rollback is required where supported. Removal of successfully committed fixtures requires separate explicit approval and must target only records proven to be owned by this DEV fixture.

## Open Questions

- Whether persistent DEV already contains enough safe synthetic Affiliate rows to exceed the M1 API limit; missing capacity requires a separately approved minimal fixture write.
- Whether browser automation is available in the apply environment; manual evidence is acceptable if automation is unavailable.
