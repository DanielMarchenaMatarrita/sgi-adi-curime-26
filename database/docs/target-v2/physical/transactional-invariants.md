# Checkpoint 9.4C-B — invariantes transaccionales

**Estado:** CANDIDATO V2; contrato de transacción PostgreSQL/Prisma futuro, no implementación. Autoridad funcional: [matriz lógica](../logical/constraint-matrix.md). Constraints de última defensa: [diseño PostgreSQL](postgresql-constraints.md).

## Protocolo común

- Transacciones escriben filas de dominio, ledger y logs como unidad. Dinero e inventario nunca usan read-modify-write sin lock.
- Orden de lock global: cuenta/movimiento → gasto → desembolso; artículo → préstamo → allocation → retorno/faltante; serie/año → documento → versión. IDs ascendentes dentro de cada clase. Evita deadlocks.
- `READ COMMITTED` con `SELECT ... FOR UPDATE` basta cuando se identifica fila serializadora. Reservas/no-overlap y cierres agregados usan `SERIALIZABLE` o constraint de exclusión. Reintentar `40001`/`40P01` con misma clave idempotente.
- Idempotencia durable exacta: folio usa `official_registration_request_key`; recepción usa `(donation_id,receipt_number)`; retorno usa `(loan_id,return_number)`; desembolso usa `movementId` UQ y settlement usa UQ parcial por gasto. Las tres decisiones nuevas usan `command_key varchar(128) COLLATE "C" NOT NULL` + UQ persistida por tabla. No se añade tabla inbox especulativa.

## Registro exacto — 34 invariantes

| ID | Operación atómica | Locks / validación / idempotencia |
|---|---|---|
| TX-01 | Crear reserva | Lock recurso; validar activo, duración y conflicto; `SERIALIZABLE`; no aprobar si indisponibilidad activa. |
| TX-02 | Confirmar pago | Lock cargo y movimiento; igualar monto/moneda; origen singular `PAYMENT`; UQ `movementId` hace reintento inocuo. |
| TX-03 | Confirmar donación monetaria | Lock donación/movimiento; origen `DONATION`, monto/moneda iguales; una sola relación original. |
| TX-04 | Confirmar desembolso | Lock gasto; crear movimiento `EXPENSE/DISBURSEMENT` y desembolso juntos; UQ `movementId`; nunca movimiento huérfano comprometido. |
| TX-05 | Pago parcial/múltiple | Lock gasto y desembolsos; validar moneda y límites aplicables; no imponer `Expense.amount = suma` en estados no finales. |
| TX-06 | Pagar anticipo | Crear única salida de caja al pago con `purpose=ADVANCE`; no diferir movimiento hasta cierre. |
| TX-07 | Liquidar anticipo | Lock gasto y desembolsos; `A=Σ ADVANCE` efectivo no anulado, `C=Expense.amount`; marcar avances pendientes; crear `SETTLEMENT`+movimiento solo si `C-A>0`. UQ parcial serializa. |
| TX-08 | Exceso de anticipo | Si `A>C`, abortar settlement negativo y registrar excepción; devolución/reversión usa proceso monetario auditado separado. |
| TX-09 | Reconocer costo mantenimiento | Lock orden y gasto; exigir cierre posterior a verificación satisfactoria; set condicional `maintenance_cost_recognized_at IS NULL`; reintento cambia cero filas. |
| TX-10 | Void/reversión | Lock movimiento; nunca delete/update económico; marcar void o crear compensación enlazada; no reutilizar movimiento. |
| TX-11 | Funding allocation | Lock ingreso y allocations; validar ingreso, moneda, disponibilidad y suma; no confundir uso posterior con destino inicial. |
| TX-12 | Confirmar destino de ingreso | Lock movimiento; exactamente `GENERAL_FUND` sin iniciativa o `INITIATIVE` con iniciativa; sin split. Corrección futura depende OD-08. |
| TX-13 | Decisión institucional | Buscar primero `command_key`; si existe, comparar comando canónico y devolver misma fila sin revalidar contra estado institucional posterior. Si no existe: lock membership, comprobar vigencia/competencia e insertar. Carrera UQ relee y compara. Clave no incluye parent y no limita múltiples decisiones legítimas. |
| TX-14 | Someter donación en especie | Lock oferta; exigir donante y ≥1 ítem; transición DRAFT→no-DRAFT; no crear movimiento monetario. |
| TX-15 | Recibir donación en especie | Lock oferta/ítems/recepciones; misma donación, cantidades acumuladas ≤ aprobadas, ≥1 línea al confirmar; clave natural de recibo. |
| TX-16 | Alta física desde recepción | Lock línea y artículo; crear lote/unidad y origen tipado; mismo artículo; partición múltiple documentada; nunca fabricar procedencia histórica. |
| TX-17 | Habilitar disponibilidad | Crear `InventoryMovement ENTRY` y aumentar `currentQuantity` en misma TX solo si apto; bien dañado conserva existencia sin disponibilidad. |
| TX-18 | Movimiento de inventario | Lock `InventoryItem`; insertar ledger firmado y actualizar saldo por delta; saldo nunca negativo; gate `INV-LEDGER-01`. |
| TX-19 | Checkout de préstamo | Lock préstamo/artículo/targets; allocations suman cantidad, targets XOR y mismo item; movimiento de salida no se reutiliza. |
| TX-20 | Confirmar devolución parcial | Lock préstamo, allocations y retorno; ≥1 detalle; cada detalle pertenece al préstamo; cantidades no superan pendiente. |
| TX-21 | Retorno apto | Crear como máximo un ENTRY por detalle mediante UQ; aumentar disponibilidad una vez. |
| TX-22 | Retorno no apto | Registrar existencia/condición sin ENTRY ni aumento de disponibilidad; mantenimiento puede bloquear recurso. |
| TX-23 | Declarar faltante | Lock allocation; cantidad ≤ pendiente y disjunta de retornos; no crear salida adicional ni devolución ficticia. |
| TX-24 | Resolver faltante | Lock faltante y authority membership; insertar decisión con `command_key` UQ según TX-13; cierre administrativo no incrementa inventario; decisión append-only. |
| TX-25 | Reconciliar préstamo | Bajo mismos locks verificar `prestada = devuelta física + faltante resuelto + pendiente`; cierre solo con pendiente cero. |
| TX-26 | Autorizar orden mantenimiento | Lock orden/target/incidencia; exactamente un target; preventiva admite incidencia nula; si target difiere de incidencia, `scope` explícito/auditado hasta decisión más estricta. |
| TX-27 | Asignar/cerrar orden | Asignación exige ejecutor `Person`; cierre exige verificación/evidencia según OD-06, aptitud y ausencia de restricciones restantes. |
| TX-28 | Bloquear/liberar recurso | Constraint temporal evita overlap incompatible; detectar reservas afectadas sin cancelarlas; liberar solo si no queda causa activa. |
| TX-29 | Crear revisión/decisión de evento | Lock evento; siguiente número local; snapshot append-only; campos materiales exactos dependen OD-09. Decisión referencia revisión exacta y usa `command_key` UQ según TX-13. |
| TX-30 | Emitir folio | Lock fila contador mediante upsert por serie/año; incrementar y asignar triple + fecha + estado + request key en misma TX. UQ triple y request key cierran carrera. |
| TX-31 | Reintentar/anular folio | Misma request key devuelve documento comprometido sin incrementar. Rollback no consume; folio comprometido luego anulado queda ocupado y conserva razón. |
| TX-32 | Crear/rectificar versión | Lock documento; número siguiente; archivo/checksum inmutables. Rectificación oficial crea otro documento/folio y referencia versión origen; validar anticiclo y documento distinto. |
| TX-33 | Agregar log documental | Insert con actor/fecha/snapshot en misma TX del hecho; roles ordinarios sin UPDATE/DELETE. |
| TX-34 | Reconciliar identidad/donante | Crear vínculos solo con evidencia; preservar snapshots; no fabricar `Person`, `Donor`, procedencia ni documento para satisfacer NOT NULL. |

## Folio: secuencia PostgreSQL autorizada

1. Buscar por `official_registration_request_key`; si existe, devolver mismo resultado.
2. Validar serie activa/código canónico y lock lógico de documento borrador.
3. Upsert `document_folio_counter(series_id,folio_year)` con incremento atómico y `RETURNING last_assigned`.
4. Actualizar documento solo si aún no foliado; fijar triple, request key, estado oficial y timestamp.
5. Insertar primera versión oficial/evidencia cuando trámite la exige; OD-03 decide obligatoriedad por trámite.
6. Commit. Conflicto UQ/request key: releer resultado; no segundo incremento comprometido.

No usar secuencia global: rompería independencia serie/año. No prometer numeración sin huecos por anulaciones comprometidas. No persistir string visible; derivar `series.code || '-' || year || '-' || lpad(sequence,6,'0')`.

## Decisiones: protocolo durable F-02

Aplica a `event_review_decision`, `in_kind_donation_decision` e `inventory_loan_shortage_decision`:

1. Cliente genera clave opaca, no vacía y estable de hasta 128 caracteres por intención lógica; mismo retry conserva bytes exactos. Scope es endpoint/tipo de decisión: UQ vive dentro de cada tabla.
2. Servicio busca por `command_key` antes de validar estado mutable. Si existe, compara comando canónico persistido y aplica pasos 6–7.
3. Si no existe, valida autoridad, bloquea membership/parent requeridos y ejecuta `INSERT` con `command_key NOT NULL`; `decided_at` se fija una vez por servidor y no forma parte del comando de retry.
4. UQ por tabla serializa carreras. En `23505` de UQ command, releer por `command_key` dentro de una nueva transacción/estado no abortado; nunca reintentar segundo insert ciego.
5. Comparación canónica exacta usa todos los inputs persistidos, excluyendo PK/timestamps de servidor: evento = `(event_revision_id,membership_id,decided_by_user_id,result,reason)`; donación = `(donation_id,membership_id,board_resolution_id,decided_by_user_id,result,reason)`; faltante = `(shortage_id,membership_id,board_resolution_id,decided_by_user_id,result,reason)`. `NULL` y string vacío son distintos; no se recorta ni cambia mayúsculas.
6. Si tupla coincide, devolver fila existente; cero inserts/updates nuevos, aunque autoridad o estado hayan cambiado después de decisión original.
7. Si difiere, abortar como reutilización inválida de clave; nunca reinterpretar comando.
8. Segunda decisión legítima sobre mismo parent usa clave nueva. No existe UQ por parent, `(parent,membership)` ni estado; cardinalidad 1:N permanece.

Este es refinamiento físico de idempotencia, no decisión institucional ni nueva entidad.

## Gates de migración y reconciliación

| Gate | Forward seguro | Evidencia de salida | Rollback/forward-fix |
|---|---|---|---|
| `ID-01` | columnas/FK nullable → backfill → validate → NOT NULL | cobertura User/Affiliate, duplicados decididos, cuarentena | quitar NOT NULL/constraint; conservar mapping y manifiesto |
| `GOV-HIST-01` | poblar cargos/afiliados y vínculos | mapping y snapshots completos | dejar nullable; nunca fabricar historia |
| `ASM-ATT-01` | poblar parents de asistencia/justificación | huérfanos cero o cuarentena aprobada | mantener campos legacy y FKs nullable |
| `ASM-DATE-01` | derivar `heldAt` con procedencia | fechas/estados verificados | mantener legacy `date` |
| `RES-STATUS-01` | lectores duales, backfill, corte | cero usos/filas legacy | volver lector; no borrar enum/columna |
| `FIN-ORIGIN-01` | clasificar y enlazar pagos | monto/moneda/origen singular | dejar `movementId` nullable y source legacy |
| `FIN-DON-01` | enlazar donaciones/movimientos | matching y reversión revisados | mantener columnas legacy |
| `INV-LEDGER-01` | opening balance + delta firmado | saldos reconciliados/no negativos | desactivar enforcement, no borrar ledger |
| `INV-LOAN-01` | poblar allocations/detalles solo con evidencia | reporte loan↔movement y excepciones | conservar vínculos agregados legacy |
| `DOC-HIST-01` | inventario de archivos, checksum, mapping | hashes/metadatos y excepciones aprobados | metadata legacy sigue autoridad |
| `DONOR-01` | deduplicar Donor y poblar FK | cobertura/excepciones/snapshots | `donor_id` nullable; no retirar `donorPersonId` |
| `FIN-MNT-01` | clasificar purpose y conciliación | sumas, moneda, cierre y excepciones | reporting legacy; no duplicar movimientos |
| `INV-PHYS-01` | inventariar lotes/unidades/allocations | existencia conciliada | mantener opcionalidad; no fabricar físicos |

## Decisiones preservadas

- **OD-01:** no crear tabla condicionada hasta aprobación.
- **OD-02:** no imponer una identidad de acta por sesión/asamblea.
- **OD-03:** vínculos documentales permanecen nullable/condicionados.
- **OD-04:** sin campos ni política inventada de firma/retención.
- **OD-07:** sin umbrales, monedas ni doble control inventados.
- **OD-08:** destino único sí; estados/corrección de iniciativa no inventados.
- Además, OD-06 y OD-09 siguen como refinamientos pendientes. OD-05 y OD-10 permanecen resueltas, no se reabren.
