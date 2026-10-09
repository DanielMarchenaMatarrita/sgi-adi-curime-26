# Pendientes y límites — fase 9.3D

## Invariantes preservadas

- `FinancialMovement` contabiliza dinero; recibir una donación en especie no crea un movimiento monetario artificial.
- Alta física al aceptar custodia, incluso en estado dañado o pendiente de inspección.
- Disponibilidad no equivale a posesión física; reparaciones y devoluciones dañadas no aumentan disponibilidad por sí solas.
- Préstamos parciales: cantidad original = devuelta físicamente + faltante resuelto + pendiente; sin duplicar la salida del préstamo por pérdida.
- La revisión presidencial de Donaciones no es requisito general de aprobación de cada egreso ordinario.
- Autorización de `MaintenanceWorkOrder` no equivale a autorización de gasto.
- Reservas aprobadas afectadas por mantenimiento no se cancelan automáticamente.

## Pendientes de diseño lógico / validación institucional

1. `Expense.authorizationResolutionId` V1.1 referencia `AssemblyResolution`; distinguirlo de acuerdos de Junta y delegaciones operativas.
2. Fijar controles de competencias y umbrales de gastos, faltantes y aceptación urgente; no inventar importes.
3. Definir enlaces tipados de `DocumentRecord` a `BoardMinute`, `BoardResolution`, `InKindDonationReceipt`, `Expense`, `MaintenanceWorkOrder` y otros objetos; analizar `ExpenseDocument` existente para evitar duplicación.
4. Determinar catálogo de clasificación documental, foliado por serie, custodia, acceso, correcciones, firmas y políticas de retención; la numeración no confiere por sí sola validez legal.
5. Verificar originalidad de diagramas anteriores (9.2A–9.2C) antes de declararlos equivalentes a versiones de trabajo históricas.
6. Validar restricciones `CHECK`, `UNIQUE`, parcial, integridad transaccional, y los gates `INV-LEDGER-01`, `INV-LOAN-01`, `FIN-DON-01` antes de migrar.
7. Precisar la representación patrimonial contable de donaciones en especie; **no** asimilarla a un ingreso de caja.
8. Definir tratamiento de desaparición de bloqueos por seguridad: expiración estimada no implica habilitación sin verificación.
9. Fijar documentación que debe exigirse por tipo/riesgo e importancia de mantenimiento (MNT-VAL-05).
10. Resolver si `InventoryLoanReturnDetail` exige además una capa de movimientos para restauración posterior a reparación; no usar cantidad cero en `InventoryMovement`.

## Alcance negativo

No incluye DDL, migraciones, commits, automatismos de recurrencia de mantenimiento, `EventFinancialAllocation` por fraccionamiento de ingresos, ni distribuciones especializadas a beneficiarios diferidas a V3.
