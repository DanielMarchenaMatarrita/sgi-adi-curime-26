# Tasks

## 1. Read-Only Runtime Baseline

- [x] 1.1 Capture branch, working-tree state, PostgreSQL server version, database name, host/port identity, and non-secret runtime connection roles; verify evidence identifies the persistent DEV environment without exposing credentials or modifying files/data
- [x] 1.2 Run read-only PostgreSQL catalog checks for `sgi_auth_runtime`, `sgi_app_runtime`, relevant memberships, Affiliate privileges, `relrowsecurity`, `relforcerowsecurity`, and deployed Affiliate policies; verify each expected item has sanitized `PASSED`/`FAILED` evidence and no write statement was executed
- [x] 1.3 Inspect existing DEV bootstrap scripts and their target Prisma constraints, identifiers, environment guards, secret handling, transaction behavior, and idempotency; verify findings explicitly cover collision handling and preservation of institutional roles/records
- [x] 1.4 Query only the minimum metadata needed to classify existing DEV user, role, permission, role-link, and Affiliate candidates as reusable, missing, conflicting, or institutional/unknown; verify no sensitive values or institutional record contents are copied into evidence
- [x] 1.5 Inspect the current M1 API limit, then produce the exact proposed fixture write set, including target identifiers, rows reused/created/updated, count exceeding that limit for two pages, repeat-run behavior, and cleanup implications; verify every proposed mutation is synthetic and no institutional record would be overwritten, deleted, reassigned, or repurposed

## 2. Human Approval Gate

- [ ] 2.1 Present baseline discrepancies plus exact allowed file list, diff, Git pre-state, and fixture database write set to the authorized reviewer, then stop until explicit approval is recorded; verify no bootstrap-script change, bootstrap, seed, SQL mutation, other database write, or unrelated file modification occurs before approval

## 3. Approved Fixture Implementation

- [ ] 3.1 After approval, make only the minimal approved bootstrap-script adjustment needed for the Affiliate fixture or unresolved safety gap; verify syntax/type checks pass, the diff matches the approved file list, and Git post-state has no schema, migration, RLS, API-contract, unrelated-file, or institutional-role changes
- [x] 3.2 Execute only the approved fixture action against the previously identified persistent DEV database using secure password input; verify the active DEV identity, DEV-only role linkage, effective `affiliates.read`, and enough synthetic Affiliates to exceed the inspected M1 API limit exist without printing secrets
- [ ] 3.3 Repeat the approved fixture action to prove idempotency; verify stable target identities/links, no duplicate fixture rows, no additional role assignments, and unchanged institutional records

## 4. API and Authorization Verification

- [ ] 4.1 Call `POST /api/auth/login` with the approved DEV identity; verify `200`, Bearer token contract, positive expiry, and sanitized evidence that omits password and JWT value
- [ ] 4.2 Call `GET /api/users/me/permissions` with the issued token; verify `200`, effective `affiliates.read`, and sanitized runtime evidence
- [ ] 4.3 Call `GET /api/affiliates` with the issued token and exercise status, name, limit, and offset parameters; verify `200`, pagination metadata, minimum projection only, valid `ACTIVE`/`INACTIVE` states, and expected fixture visibility
- [x] 4.4 Exercise missing-token and invalid-token Affiliate requests; verify `401` and no Affiliate data disclosure
- [ ] 4.5 Exercise an approved existing synthetic authenticated identity without `affiliates.read`, or an explicitly approved minimal negative fixture if none exists; verify `403` and no Affiliate data disclosure

## 5. PostgreSQL Runtime Security Verification

- [x] 5.1 Observe an authorized backend Affiliate read through `sgi_app_runtime` in a read-only transaction; verify evidence identifies `current_user`, sanitized authorized actor context, and successful RLS-filtered access without exposing connection secrets
- [x] 5.2 Use `sgi_app_runtime` in read-only transactions with missing actor context and an actor lacking `affiliates.read`; verify evidence identifies `current_user`, sanitized context, and PostgreSQL denial or absence of unauthorized Affiliate rows according to grants and RLS
- [x] 5.3 Re-run the relevant focused PostgreSQL/Prisma security and Affiliate integration checks against their intended validation environment; verify `PASSED` or record exact `FAILED`/`NOT_EXECUTED` evidence without applying migrations or policy changes

## 6. M1 Integration Verification

- [x] 6.1 Run `pnpm --dir frontend run build`; verify `PASSED` with no new TypeScript or bundling errors
- [ ] 6.2 Log in through the frontend and open M1; verify the real API-backed Affiliate appears with ID, name, affiliate type, affiliation date, and status, and verify no mock source supplies the displayed row
- [ ] 6.3 Exercise name and ACTIVE/INACTIVE filters in M1; verify network requests carry the expected query parameters and rendered results match API responses
- [ ] 6.4 Exercise server pagination using records that exceed the inspected M1 API limit; verify offset changes and the returned second page renders, otherwise record `NOT_EXECUTED` with the exact unmet data prerequisite and no unapproved rows
- [x] 6.5 Produce the final sanitized acceptance matrix with `PASSED`/`FAILED`/`NOT_EXECUTED` per requirement, commands or test identifiers, timestamp, environment identity, evidence summary, and next action; verify no password, JWT, hash, or credential-bearing URL appears
