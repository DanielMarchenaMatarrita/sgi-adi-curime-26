# Baseline estructural V1.1 — referencia de lectura

- **49 entidades persistentes**.
- **1 entidad transicional:** `IdentityReconciliationManifest`.
- **77 relaciones maestras congeladas**.
- `Person` = identidad física; `User` = cuenta; `Affiliate` = afiliación.
- `InventoryItem.currentQuantity` = cantidad disponible, no total físico.

Fuentes oficiales en repositorio **solo de lectura** del equipo:
- [Target Model V1.1](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/blob/main/docs/data/v1.1/target-model.md)
- [Integrity Rules V1.1](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/blob/main/docs/data/v1.1/integrity-rules.md)
- [Prisma V1.1](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/blob/main/backend/prisma/schema.prisma)

No afirmar que los backfills históricos se completaron. Los gates `FIN-DON-01`, `FIN-ORIGIN-01`, `INV-LOAN-01` y `INV-LEDGER-01` siguen siendo relevantes hasta verificarse con datos reales.
