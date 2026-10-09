# Registro de decisiones — diseño V2

> **Estado:** matriz de consolidación; fuente de verdad funcional de trabajo basada en acuerdos confirmados. No acredita implementación.

> **Límite de procedencia:** algunos snapshots confirman conjuntos de códigos (`DON-VAL-04..08`, `INV-VAL-01..03`, `MNT-VAL-01..05`) sin conservar las fichas externas originales que vinculaban cada código con una oración aislada. Las filas siguientes trazan esos códigos a las reglas y diagramas preservados; no añaden estados, cardinalidades ni semántica más granular que la fuente enlazada.

| Código | Decisión validada | Impacto de datos | Fuente directa |
|---|---|---|---|
| DON-VAL-04 | Oferta de donación en especie y recepción física son hechos distintos | `InKindDonation`, `InKindDonationReceipt` | [9.2C](../v2/checkpoints/9.2C-donaciones.md) |
| DON-VAL-05 | La aceptación requiere autoridad institucional competente | `InKindDonationDecision`, `GovernanceMembership` | [9.2C](../v2/checkpoints/9.2C-donaciones.md) |
| DON-VAL-06 | La recepción puede ser parcial o total y conserva detalle físico | `InKindDonationReceipt`, `InKindDonationReceiptLine` | [9.2C](../v2/checkpoints/9.2C-donaciones.md) |
| DON-VAL-07 | La aceptación urgente por Presidencia exige competencia previa válida e información posterior a Junta | `InKindDonationDecision`, `BoardResolution` | [9.2C](../v2/checkpoints/9.2C-donaciones.md) |
| DON-VAL-08 | Una donación en especie no crea un ingreso monetario ficticio | `InKindDonation`, `FinancialMovement` | [9.2C](../v2/checkpoints/9.2C-donaciones.md) |
| DON-INV-VAL-01 | Aceptación de custodia y recepción física llevan al Inventario aunque el bien esté dañado; disponibilidad es distinta de existencia | `InKindDonationReceiptLine`, `InventoryStockLot`, `InventoryUnit` | [9.3C](../v2/checkpoints/9.3C-conciliacion.md) |
| INV-VAL-01 | Inventario físico distingue artículos, lotes y unidades individualizadas | `InventoryItem`, `InventoryStockLot`, `InventoryUnit` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| INV-VAL-02 | Instalaciones y bienes físicos pueden originar incidencias de mantenimiento | `InstitutionalFacility`, `InventoryStockLot`, `InventoryUnit`, `MaintenanceIncident` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| INV-VAL-03 | Existencia física y disponibilidad operativa son conceptos distintos | `InventoryItem`, `ResourceUnavailability` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| INV-VAL-04 | Préstamos admiten devoluciones parciales y condiciones por detalle | `InventoryLoanReturn`, `InventoryLoanReturnDetail` | [9.3C](../v2/checkpoints/9.3C-conciliacion.md) |
| INV-VAL-05 | Faltantes requieren resolución; no fingir devoluciones físicas | `InventoryLoanShortage`, `InventoryLoanShortageDecision` | [9.3C](../v2/checkpoints/9.3C-conciliacion.md) |
| MNT-VAL-01 | Una orden autorizada tiene un único objeto físico principal; puede ser preventiva y no tener incidencia | `MaintenanceIncident`, `MaintenanceWorkOrder` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| MNT-VAL-02 | La orden identifica un ejecutor principal al asignarse, aunque esa persona no tenga cuenta `User` | `MaintenanceWorkOrder`, `Person` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| MNT-VAL-03 | Autorización operativa y autorización financiera son controles diferentes | `MaintenanceWorkOrder`, `Expense` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| MNT-VAL-04 | Una incidencia u orden puede bloquear temporalmente un recurso; el bloqueo no cancela reservas aprobadas automáticamente | `ResourceUnavailability`, `Reservation` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| MNT-VAL-05 | Verificación de aptitud y evidencia proporcional preceden la restitución y cierre; nivel documental por riesgo permanece por formalizar | `MaintenanceWorkOrder`, `ResourceUnavailability` | [9.2D](../v2/checkpoints/9.2D-mantenimiento.md) |
| FIN-VAL-01 | Tesorería registra y confirma egresos ordinarios sin aprobación individual obligatoria de Presidencia; Fiscalía supervisa | `Expense`, `Disbursement`, `FinancialMovement` | [9.3A](../v2/checkpoints/9.3A-finanzas.md) |
| FIN-VAL-02 | Ingreso confirmado con un solo destino —iniciativa o fondo general—; sin partición V2 | `FinancialMovement`, `Initiative` | [9.3B](../v2/checkpoints/9.3B-iniciativas.md) |
| FIN-VAL-03 | `Initiative` agrupa obras, eventos o actividades sin duplicarlos; fondo general no es una iniciativa ficticia | `Initiative`, `Event`, `VolunteerOpportunity` | [9.3B](../v2/checkpoints/9.3B-iniciativas.md) |
| FIN-MNT-VAL-01 | **Opción B:** reconocer el costo definitivo de mantenimiento únicamente después del cierre verificado | `MaintenanceWorkOrder`, `Expense` | [9.4B §1–2](../../../database/docs/target-v2/9.4B-borrador-relacional.md) |
| FIN-MNT-VAL-02 | Registrar el anticipo cuando se desembolsa efectivamente: reduce caja y queda pendiente de liquidación, sin duplicar la salida al reconocer el costo final | `Disbursement`, `FinancialMovement`, `Expense` | [9.4B §1–2](../../../database/docs/target-v2/9.4B-borrador-relacional.md) |
| INT-01 | Cada `Disbursement` referencia exactamente un `FinancialMovement`; un movimiento puede existir sin desembolso y admite como máximo un `Disbursement` | `Disbursement`, `FinancialMovement` | [9.3A](../v2/checkpoints/9.3A-finanzas.md) |
| DOC-VAL-01 | Borradores versionables; documentos oficiales/evidencia inmutables y rectificables con historia | `DocumentRecord`, `DocumentVersion` | [9.3D](../v2/checkpoints/9.3D-documentos.md) |
| DOC-VAL-02 | Foliación independiente por serie documental | `DocumentSeries` | [9.3D](../v2/checkpoints/9.3D-documentos.md) |
| DOC-VAL-03 | Folios por serie y año, con consecutivo anual | `DocumentRecord`, `DocumentSeries` | [9.3D](../v2/checkpoints/9.3D-documentos.md) |
| DOC-VAL-04 | Tres niveles `PUBLIC`/`INTERNAL`/`RESTRICTED`; RBAC contextual | `DocumentRecord`, IAM | [9.3D](../v2/checkpoints/9.3D-documentos.md) |

`FIN-MNT-VAL-01` usa “cierre verificado” como **gate de negocio**: la verificación satisfactoria habilita el cierre y solo entonces procede el reconocimiento definitivo. Los estados candidatos `VERIFIED` y `CLOSED` no se declaran equivalentes ni se fijan aquí transiciones de enum. En particular, una marca de verificación aislada no anticipa el reconocimiento. `FIN-MNT-VAL-02` conserva separado el hecho de caja: el anticipo se registra al desembolso real y permanece pendiente de liquidación.

## Pendientes de congelamiento lógico

- La relación lógica exacta de anticipos liquidados a costos definitivos queda resuelta por el contrato 9.4B: la liquidación usa el mismo `Expense.id`, moneda común, conciliación atómica, `settledAt` y `settledByUserId`, como máximo un `SETTLEMENT` residual y ninguna salida de caja duplicada. Permanecen pendientes los detalles físicos (índices, triggers y transacciones) para 9.4C.
- Determinar si `BoardSessionAttendance` amerita tabla separada.
- Determinar si alguna asociación documental necesita tabla específica, sin proliferación innecesaria.
- Validar todas las cardinalidades y sus acciones referenciales antes de migrar.
- Preservar datos y contratos V1.1; no desplegar constraints definitivos antes de gates históricos.

Ver [inventario completo](../../../database/docs/target-v2/entity-inventory.md) y [9.4B borrador](../../../database/docs/target-v2/9.4B-borrador-relacional.md).
