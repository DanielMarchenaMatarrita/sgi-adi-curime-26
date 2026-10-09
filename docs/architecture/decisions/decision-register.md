# Registro de decisiones — diseño V2

> **Estado:** matriz de consolidación; fuente de verdad funcional de trabajo basada en acuerdos confirmados. No acredita implementación.

| Código | Decisión validada | Impacto de datos |
|---|---|---|
| FIN-MNT-VAL-01 | Consolidar costo definitivo de mantenimiento tras cierre verificado | `MaintenanceWorkOrder`, `Expense` |
| FIN-MNT-VAL-02 | Anticipo efectivamente desembolsado reduce caja; permanece pendiente de liquidación y no duplica el costo final | `Disbursement`, `FinancialMovement`, `Expense` |
| FIN-VAL-02 | Ingreso confirmado con un solo destino (iniciativa o fondo general); sin partición V2 | `FinancialMovement`, `Initiative` |
| INV-VAL-04 | Préstamos con devoluciones parciales y condiciones por detalle | `InventoryLoanReturn`, `InventoryLoanReturnDetail` |
| INV-VAL-05 | Faltantes requieren resolución; no fingir devoluciones físicas | `InventoryLoanShortage`, `InventoryLoanShortageDecision` |
| DON-INV-VAL-01 | Aceptación de custodia y recepción física llevan al Inventario aunque esté dañado; disponibilidad es distinta de existencia | `InKindDonationReceiptLine`, `InventoryStockLot`, `InventoryUnit` |
| DOC-VAL-01 | Borradores versionables; documentos oficiales/evidencia inmutables y rectificables con historia | `DocumentRecord`, `DocumentVersion` |
| DOC-VAL-02 | Foliación independiente por serie documental | `DocumentSeries` |
| DOC-VAL-03 | Folios por serie y año, con consecutivo anual | `DocumentRecord`, `DocumentSeries` |
| DOC-VAL-04 | Tres niveles PUBLIC/INTERNAL/RESTRICTED; RBAC contextual | `DocumentRecord`, IAM |

## Pendientes de congelamiento lógico

- Finalizar PK/FK y relación exacta de anticipos liquidados a costos definitivos.
- Determinar si `BoardSessionAttendance` amerita tabla separada.
- Determinar si alguna asociación documental necesita tabla específica, sin proliferación innecesaria.
- Validar todas las cardinalidades y sus acciones referenciales antes de migrar.
- Preservar datos y contratos V1.1; no desplegar constraints definitivos antes de gates históricos.

Ver [inventario completo](../../data/target-v2/entity-inventory.md) y [9.4B borrador](../../data/target-v2/9.4B-borrador-relacional.md).
