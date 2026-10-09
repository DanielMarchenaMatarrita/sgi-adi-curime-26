# TARGET V2 — Modelo relacional en consolidación

- [Inventario maestro de entidades](entity-inventory.md): 49 V1.1 + 31 candidatas V2.
- [Borrador 9.4B](9.4B-borrador-relacional.md): diagramas, claves y reglas propuestas.
- [Catálogo lógico 9.4B](logical/entity-catalog.md), [matriz de relaciones](logical/relationship-matrix.md), [matriz de restricciones](logical/constraint-matrix.md) y [decisiones abiertas](logical/open-decisions.md): contrato lógico candidato.
- [Revisión de normalización 9.4C-A](normalization/9.4C-A-review.md): resultado PASS / GO; [dependencias funcionales](normalization/functional-dependencies.md), [matriz](normalization/normalization-matrix.md) y [anomalías](normalization/anomalies-and-resolutions.md).
- [Freeze gates](freeze-gates.md): criterios antes de crear el Prisma final.
- [Registro de decisiones](../../../docs/architecture/decisions/decision-register.md): decisiones confirmadas.
- [Atlas funcional de diagramas 9.2–9.3](../../../docs/architecture/v2/README.md): historia conceptual con checkpoints.

## Principio de trabajo

La verdad actual de V2 es **decisiones confirmadas más propuestas lógicas pendientes**, no una base de datos desplegada. No llamar `CURRENT` a tablas de V2 ni declarar backfills sin evidencia.
