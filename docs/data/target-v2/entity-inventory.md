# Matriz maestra de entidades — SGI V2

> **Estado:** consolidación preliminar 9.4A/9.4B. Los recuentos son de candidatas por nombre, **no** total definitivo de tablas a construir.

## Base persistente V1.1: 49

| Dominio | Cantidad | Entidades |
|---|---:|---|
| Organización | 1 | `OrganizationProfile` |
| Identidad/acceso | 10 | `Person`, `Role`, `Permission`, `RolePermission`, `User`, `Session`, `AuditLog`, `PasswordResetToken`, `AccountActivationToken`, `UserRequest` |
| Afiliación | 3 | `Affiliate`, `AffiliateRequest`, `AffiliateSanction` |
| Gobernanza | 3 | `GovernancePosition`, `GovernanceTerm`, `GovernanceMembership` |
| Asambleas | 7 | `Assembly`, `AssemblyCall`, `AssemblyConvocation`, `AssemblyAttendance`, `AbsenceJustification`, `AssemblyMinute`, `AssemblyResolution` |
| Eventos y reservas | 3 | `Event`, `ReservableResource`, `Reservation` |
| Finanzas y donaciones | 9 | `FinancialAccount`, `FinancialCharge`, `Payment`, `FinancialMovement`, `Donation`, `Expense`, `ExpenseDocument`, `Disbursement`, `FundingAllocation` |
| Inventario | 4 | `InventoryCategory`, `InventoryItem`, `InventoryMovement`, `InventoryLoan` |
| Voluntariado | 5 | `VolunteerOpportunity`, `VolunteerSession`, `VolunteerApplication`, `VolunteerParticipation`, `VolunteerAttendance` |
| Emprendimiento | 4 | `Venture`, `VentureAssociation`, `VentureRequest`, `VentureRequestRevision` |

**Entidad transicional aparte:** `IdentityReconciliationManifest` (no contabiliza dentro de 49).

## Entidades candidatas V2: 31

| Dominio | Cantidad | Entidades |
|---|---:|---|
| Gobernanza | 4 | `BoardSession`, `BoardMinute`, `BoardResolution`, `BoardSessionAttendance` |
| Eventos | 3 | `EventRevision`, `EventReviewDecision`, `EventBudgetLine` |
| Donaciones en especie | 5 | `InKindDonation`, `InKindDonationItem`, `InKindDonationDecision`, `InKindDonationReceipt`, `InKindDonationReceiptLine` |
| Inventario y mantenimiento | 11 | `InstitutionalFacility`, `InventoryStockLot`, `InventoryUnit`, `MaintenanceIncident`, `MaintenanceWorkOrder`, `ResourceUnavailability`, `InventoryLoanCheckoutAllocation`, `InventoryLoanReturn`, `InventoryLoanReturnDetail`, `InventoryLoanShortage`, `InventoryLoanShortageDecision` |
| Iniciativas | 1 | `Initiative` |
| Documentación | 3 | `DocumentRecord`, `DocumentVersion`, `DocumentSeries` |
| Resoluciones 9.4B | 4 | `Donor`, `ExpenseDocumentLog`, `Correspondence`, `CorrespondenceLog` |

- **30 candidatas principales**; **1 condicionada**: `BoardSessionAttendance`.
- Escenario si se aprueban e implementan todas las principales: **79 persistentes** (49+30), sin descontar fusiones o redefiniciones.
- Con la condicionada: **80 persistentes**. Ninguna de estas cifras está congelada.
- Entidades diferidas/excluidas: `EventFinancialAllocation`, `MaintenancePlan`, `MaintenanceWorkAssignment`, `InKindDistribution`, `InKindDistributionItem`.

## Reglas de conciliación antes del freeze

1. Revisar duplicados semánticos (`AssetLoan` vs `InventoryLoan`; `FundDestination` vs `Initiative`).
2. Comprobar FK y acciones referenciales, particularmente `ExpenseDocument` y autorizaciones en `Expense`.
3. Separar entradas físicas de disponibilidad en inventario y desembolsos de reconocimiento de costos.
4. Verificar catálogo completo de relaciones V1.1 (77) contra nuevas relaciones V2 y sustituciones; **no sumar filas a ciegas**.
5. Validar el `schema.prisma` objetivo y SQL complementario en la copia independiente antes de llamar al modelo "congelado".
