# Checkpoint 9.4C-C — matriz Prisma / PostgreSQL

**Estado:** CANDIDATO V2. Traducción documental, no schema ni SQL. Autoridad: [constraints PostgreSQL](postgresql-constraints.md), [mapeo Prisma](prisma-mapping.md), [transacciones](transactional-invariants.md).

## Soporte Prisma y huecos deliberados

| Requisito | Prisma schema futuro | PostgreSQL / servicio futuro | Cobertura |
|---|---|---|---|
| 82 PK, nullability, defaults, scalar/native types | `@id`/`@@id`, `?`, `@default`, `@db.*` | identidad/secuencia física se conserva | soportado, 82/82 |
| 158 FKs y acciones | `@relation`, ownership FK, `onDelete`, `onUpdate: Cascade` | nombre, rollout `NOT VALID`/`VALIDATE` | soportado para forma; rollout SQL |
| 63 UQ totales firmes | `@unique`/`@@unique` | nombre/creación concurrente/attach | soportado para forma |
| 5 UQ parciales firmes | no declaración Prisma | VU01–VU03, VU29, VU37 como índice único parcial | PostgreSQL-only |
| 166 índices explícitos aceptados firmes | `@@index` para B-tree declarable | método, concurrencia, selectividad/planes | compartido; migración SQL decide |
| 39 CHECK firmes | no | C01–C26, C28–C41 salvo C27/C39 condicionales | PostgreSQL-only |
| 1 EXCLUDE | no | PO-05, `ex_unavailability_active_period`, GiST + `btree_gist` aprobada | PostgreSQL-only |
| 24 invariantes PO | no | CHECK/UQ parcial/EXCLUDE/trigger/privilegios/TX | PostgreSQL-only, servicio complementa |
| Collation binaria command key | no portable declaration | `COLLATE "C"` para 3 `command_key` | PostgreSQL-only |
| Folio anual / locks / retries | Prisma transaction API no declara protocolo | contador, UQ, locks, isolation; TX-30/31 | service + PostgreSQL |

## Registro PostgreSQL-only completo

| Familia | IDs / alcance | Mecanismo mínimo |
|---|---|---|
| CHECK local firme | C01–C26, C28–C38, C40–C41 (**39**) | named `CHECK`; servicio/API futuro puede validar entrada; Prisma no declara ni sustituye CHECK; PostgreSQL lo impone |
| CHECK condicionado | C27 (ciclo orden), C39 (donante no-DRAFT) (**2**) | no instalar hasta vocabulario aplicable; OD-06 afecta evidencia |
| UQ parcial | VU01, VU02, VU03, VU29, VU37 (**5**) | `UNIQUE ... WHERE`; nunca `@unique` ni constraint attachable |
| UQ condicional | VU05, VU07, VU31–VU34 (**6**) | no instalar: OD-01/02/03 |
| EXCLUDE | PO-05 (**1**) | GiST range activo; `tsrange` mientras timestamp baseline persista; aprobar `btree_gist` |
| Cross-table / lifecycle | PO-06–PO-15, PO-17–PO-24 | triggers mínimos, privilegios y TX; no CHECK falso |
| Immutable / append-only | PO-16, PO-18–PO-22 | trigger + privileges: documento/versión, serie, folio, contador, logs, movimiento económico |
| Command-key collation | F-02: 3 columns / VU09,VU12,VU22 | `varchar(128) COLLATE "C" NOT NULL` + UQ total; canonical comparison in service |

### PO ledger: ownership split

| PO | PostgreSQL last defense | Future NestJS responsibility |
|---|---|---|
| PO-01–04 | CHECK / partial UQ | validate input; translate violations |
| PO-05 | EXCLUDE | serializable reservation/unavailability workflow |
| PO-06 | deferred trigger/recursive validation | facility hierarchy command validation |
| PO-07–08 | CHECK + transition trigger | incident/order state transitions |
| PO-09–15 | triggers, deferred where aggregate | maintenance, loan, intake workflows TX-14–27 |
| PO-16–22 | trigger + privileges | document/log/financial append-only service paths |
| PO-23–24 | trigger/TX + partial UQ | maintenance cost and settlement workflows TX-07/09 |

## Installation and compatibility gaps

1. **Prisma gap:** no schema syntax for CHECK, partial UQ, EXCLUDE, `COLLATE "C"`, trigger, privilege, controlled counter, `NOT VALID` lifecycle, concurrent index installation or constraint naming. All require reviewed PostgreSQL migration SQL after authorization.
2. **Transaction gap:** Prisma `$transaction` cannot itself prove lock order, isolation choice, retry of `40001`/`40P01`, canonical command comparison, aggregate balance or cross-row/cross-table membership. Future NestJS services must implement TX-01..TX-34.
3. **Temporal gap:** baseline uses `timestamp(3) without time zone`; EXCLUDE must use `tsrange`, not `tstzrange`, unless an authorized global retype occurs.
4. **Index gap:** Prisma declarations do not supply production selectivity/plan evidence. Measure 108 baseline accepted + 58 V2 explicit firm indexes before migration. `BI038` stays legacy-preserved/rejected target. `VI001` and VU05 are alternatives.
5. **Data compatibility gap:** all gates remain open: ID-01, GOV-HIST-01, ASM-ATT-01, ASM-DATE-01, RES-STATUS-01, FIN-ORIGIN-01, FIN-DON-01, INV-LEDGER-01, INV-LOAN-01, DOC-HIST-01, DONOR-01, FIN-MNT-01, INV-PHYS-01. No NOT NULL/UQ hardening, removal or invented backfill.
6. **Policy gap:** OD-01 separate; OD-02/03 alter UQ/document associations; OD-04 signature/retention has no fields; OD-06 evidence vocabulary; OD-07 finance policy; OD-08 initiative cycle; OD-09 event materiality. No policy chosen.

## Migration safety boundary

Forward shape only: additive nullable fields → evidenced backfill/quarantine → `NOT VALID` FK/CHECK → validate → authorized hardening. UQ total requires deterministic duplicate/NULL preflight and concurrent unique index; partial UQ stays index; neither supports `NOT VALID`. Rollback is disable/drop only newly added enforcement while retaining columns/data. Any drop, truncate, retype, history removal, key redesign or OD resolution needs separate authorization.
