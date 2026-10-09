# Baseline estructural V1.1 — evidencia de referencia

- **49 entidades persistentes**.
- **1 entidad transicional:** `IdentityReconciliationManifest`.
- **77 relaciones maestras congeladas**.
- `Person` = identidad física; `User` = cuenta; `Affiliate` = afiliación.
- `InventoryItem.currentQuantity` = cantidad disponible, no total físico.

## Fuente autoritativa y revisión fijada

- Repositorio autoritativo **solo de lectura:** <https://github.com/matiasfarrierzuniga-rgb/SGI-Curime.git>.
- Revisión fijada: [`e8e2beb33eea8c1207fe77fe65dbd3228362bc5f`](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/tree/e8e2beb33eea8c1207fe77fe65dbd3228362bc5f), observada como `main` HEAD el 2026-10-08.
- Fuentes: [Target Model V1.1](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/blob/e8e2beb33eea8c1207fe77fe65dbd3228362bc5f/docs/data/v1.1/target-model.md), [Integrity Rules V1.1](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/blob/e8e2beb33eea8c1207fe77fe65dbd3228362bc5f/docs/data/v1.1/integrity-rules.md) y [Prisma V1.1](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/blob/e8e2beb33eea8c1207fe77fe65dbd3228362bc5f/backend/prisma/schema.prisma).

## Verificación estructural ejecutada reportada

La evidencia entregada para esta consolidación registra:

1. Descarga HTTP del [`schema.prisma` raw fijado](https://raw.githubusercontent.com/matiasfarrierzuniga-rgb/SGI-Curime/e8e2beb33eea8c1207fe77fe65dbd3228362bc5f/backend/prisma/schema.prisma): **200**.
2. Conteo con regex `/^model\s+(\w+)\s*\{/gm`: **50 modelos** totales.
3. `IdentityReconciliationManifest`: exactamente **1**; por tanto, **49** modelos al excluir la entidad transicional.
4. Campos propietarios de relación detectados por `@relation(... fields: [...])`: **78** totales; uno pertenece a `IdentityReconciliationManifest`, por tanto **77** relaciones persistentes/maestras.
5. `docs/data/v1.1/target-model.md` declara independientemente `TARGET_PERSISTENT_ENTITIES=49`, `TRANSITIONAL_ENTITIES=1` y `MASTER_RELATIONSHIPS=77`.

Esto verifica **conteos estructurales de fuentes** en la revisión fijada. No verifica conciliación ni backfills de datos históricos, tampoco implementación V2. No se usa ni cita como autoridad ningún clon local con remoto distinto.

No afirmar que los backfills históricos se completaron. Los gates `FIN-DON-01`, `FIN-ORIGIN-01`, `INV-LOAN-01` y `INV-LEDGER-01` siguen siendo relevantes hasta verificarse con datos reales.
