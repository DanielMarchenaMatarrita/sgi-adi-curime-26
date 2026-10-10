# Checkpoint 9.4B — decisiones institucionales abiertas

**Propósito:** separar decisiones humanas aún pendientes de decisiones ya validadas y de refinamientos físicos de 9.4C.

**Regla:** una decisión aprobada no se reabre. La ausencia de respuesta no autoriza política por defecto. Impactos de migración/DDL, nombres de constraints, índices, triggers, backfill, rollback y estrategia física pertenecen a 9.4C, salvo que aquí se indique una dependencia lógica.

## Resumen de clasificación

| ID | Clasificación | Pregunta institucional pendiente |
|---|---|---|
| OD-01 | **GENUINAMENTE ABIERTA — aprobación institucional** | Sí: asistencia individual estructurada de Junta. |
| OD-02 | **GENUINAMENTE ABIERTA — aprobación institucional** | Sí: identidad institucional única de acta o múltiples actas. |
| OD-03 | **PARCIALMENTE RESUELTA — refinamiento físico 9.4C** | Sí: matriz por trámite de obligatoriedad de `DocumentRecord`. |
| OD-04 | **GENUINAMENTE ABIERTA — aprobación institucional** | Sí: validación formal, autoridades y conservación. |
| OD-05 | **RESUELTA POR DECISIÓN VALIDADA** | No. |
| OD-06 | **PARCIALMENTE RESUELTA — refinamiento físico 9.4C** | Sí: niveles de riesgo, contenido mínimo y verificador. |
| OD-07 | **GENUINAMENTE ABIERTA — aprobación institucional** | Sí: extraordinarios, controles y caja chica. |
| OD-08 | **GENUINAMENTE ABIERTA — aprobación institucional** | Sí: estados, transiciones y cambio de destino. |
| OD-09 | **PARCIALMENTE RESUELTA — refinamiento físico 9.4C** | Sí: matriz de campos materiales y disparadores de revisión. |
| OD-10 | **RESUELTA POR DECISIÓN VALIDADA** | No. |

**Nota de alcance:** decisiones aprobadas están excluidas de aprobaciones humanas abiertas. Los pendientes de 9.4C no son nuevas políticas: concretan físicamente o aplican límites ya confirmados.

## OD-01 — Registro individual de asistencia a Junta

**Clasificación:** **GENUINAMENTE ABIERTA — aprobación institucional**

**Evidencia:** [9.2A](../../../../docs/architecture/v2/checkpoints/9.2A-gobernanza.md), [registro de decisiones](../../../../docs/architecture/decisions/decision-register.md).

**Límite confirmado:** no está aprobada una entidad `BoardSessionAttendance` ni su ausencia. No alterar cardinalidades de Junta mientras la institución no decida.

**Pregunta restante:** ¿la institución requiere registrar y consultar asistencia individual estructurada de cada miembro en cada sesión de Junta, autorizando `BoardSessionAttendance`?

**Impacto 9.4C:** si se aprueba, definir PK/FK, UQ `(boardSessionId, membershipId)`, estados, correcciones e índices. Si no, mantener asistencia en acta/documento.

## OD-02 — Ciclo institucional de actas de Asamblea y Junta

**Clasificación:** **GENUINAMENTE ABIERTA — aprobación institucional**

**Evidencia:** `ASM-R12`, [9.2A](../../../../docs/architecture/v2/checkpoints/9.2A-gobernanza.md), [9.3D](../../../../docs/architecture/v2/checkpoints/9.3D-documentos.md).

**Límite confirmado:** `DocumentVersion` conserva borradores, correcciones e historia; esto no decide si cada sesión/asamblea tiene una sola identidad de acta o varias identidades lógicas.

**Pregunta restante:** ¿cada Asamblea o sesión de Junta tiene una sola identidad institucional de acta, con correcciones y borradores como versiones, o puede tener varias actas institucionales distintas?

**Impacto 9.4C:** la respuesta fija cardinalidad de `AssemblyMinute`/`BoardMinute`, UQ de la relación padre y reglas de pertenencia de versiones. No imponer 1:1 ni 1:N antes de aprobación.

## OD-03 — Expedientes que exigen documento oficial tipado

**Clasificación:** **PARCIALMENTE RESUELTA — refinamiento físico 9.4C**

**Evidencia:** `DOC-VAL-01..04`, [9.3D](../../../../docs/architecture/v2/checkpoints/9.3D-documentos.md).

**Límite confirmado:** versionado, historia, documentos oficiales/evidencia inmutables, rectificación histórica, foliación por serie/año y RBAC contextual están validados. No está validado que todos los trámites exijan el mismo documento.

**Pregunta restante:** para acta de Asamblea, acta de Junta, acuerdo de Junta, recibo de donación en especie y cierre de mantenimiento, ¿`DocumentRecord` oficial es obligatorio, opcional o no aplica en cada caso?

**Impacto 9.4C:** la matriz aprobada definirá FKs/asociaciones, nulabilidad condicionada, validaciones por tipo/estado y backfill. La elección física FK tipada vs asociación tipada queda para 9.4C después de la matriz.

## OD-04 — Firma/validación formal y conservación documental

**Clasificación:** **GENUINAMENTE ABIERTA — aprobación institucional**

**Evidencia:** temas pendientes de [9.3D](../../../../docs/architecture/v2/checkpoints/9.3D-documentos.md).

**Límite confirmado:** documentos oficiales son inmutables y rectificables con historia; no se ha aprobado método de firma, validación formal ni retención.

**Pregunta restante:** ¿qué clases requieren firma digital, aprobación interna auditada o solo archivo; quién puede validar; y cuál es el plazo de conservación?

**Impacto 9.4C:** definir actor, fecha, método, estado, metadatos de firma, política de retención y prohibiciones de eliminación. No inferir requisitos legales desde el esquema.

## OD-05 — Tratamiento de folios anulados

**Clasificación:** **RESUELTA POR DECISIÓN VALIDADA**

**Evidencia:** `DOC-VAL-02/03`, [9.3D](../../../../docs/architecture/v2/checkpoints/9.3D-documentos.md).

**Límite confirmado:** el folio completo es una cadena inmutable y nunca se reutiliza, incluso si queda anulado; se conserva la razón de anulación. La unicidad física permanece exactamente en `(seriesId, folioYear, folioSequence)`; no existe unicidad por folio global.

**Pregunta restante:** no existe pregunta institucional abierta.

**Impacto 9.4C:** únicamente implementar esta decisión: folio visible derivado determinísticamente del código canónico e inmutable de la serie, año y secuencia, sin string de folio separado editable ni persistido; constraint compuesto exacto `(seriesId, folioYear, folioSequence)`, asignación anual concurrente, estado/razón de anulación y auditoría, preservando inmutabilidad y no reutilización. No convertir estos detalles en alternativas de política.

## OD-06 — Evidencia de mantenimiento proporcional al riesgo

**Clasificación:** **PARCIALMENTE RESUELTA — refinamiento físico 9.4C**

**Evidencia:** `MNT-VAL-05`, [9.2D](../../../../docs/architecture/v2/checkpoints/9.2D-mantenimiento.md), registro de decisiones.

**Límite confirmado:** la evidencia de mantenimiento siempre es digital; su cantidad y contenido son proporcionales al riesgo; la verificación de aptitud precede restitución y cierre. No reabrir si la evidencia puede ser digital.

**Pregunta restante:** ¿qué niveles de riesgo reconoce la institución, qué evidencia mínima exige cada nivel y qué verificador competente puede cerrar cada orden?

**Impacto 9.4C:** traducir niveles, contenido, verificador, vínculos y gate de cierre a entidades, constraints y validaciones. No elegir evidencia uniforme ni permitir evidencia no digital por defecto.

## OD-07 — Autorización financiera extraordinaria y caja chica

**Clasificación:** **GENUINAMENTE ABIERTA — aprobación institucional**

**Evidencia:** `FIN-VAL-01`, [9.3A](../../../../docs/architecture/v2/checkpoints/9.3A-finanzas.md), borrador 9.4B.

**Límite confirmado:** Tesorería puede confirmar egresos ordinarios sin aprobación presidencial individual obligatoria; Fiscalía supervisa. No inventar montos ni categorías extraordinarias.

**Pregunta restante:** ¿qué montos, monedas, categorías o condiciones hacen extraordinario un egreso; qué doble control/acuerdo exige; y cuáles son los límites de caja chica?

**Impacto 9.4C:** versionar política, moneda, vigencia, autoridades, umbrales, categorías y controles; mantener separados `Expense`, `Disbursement` y `FinancialMovement`.

## OD-08 — Ciclo y cambio de destino de `Initiative`

**Clasificación:** **GENUINAMENTE ABIERTA — aprobación institucional**

**Evidencia:** `FIN-VAL-02/03`, [9.3B](../../../../docs/architecture/v2/checkpoints/9.3B-iniciativas.md).

**Límite confirmado:** un ingreso confirmado tiene un solo destino —`Initiative` o fondo general— y no se particiona en V2; fondo general no es una iniciativa ficticia. El destino confirmado no se cambia silenciosamente.

**Pregunta restante:** ¿qué estados y transiciones tiene una `Initiative`, quién los autoriza y puede cambiarse el destino de un ingreso confirmado o debe corregirse mediante operación auditada?

**Impacto 9.4C:** definir estados, transiciones, autoridad, auditoría y reglas de corrección; preservar unicidad de destino y no reintroducir `FundDestination` ni fraccionamiento.

## OD-09 — Cambios a eventos después de aprobación

**Clasificación:** **PARCIALMENTE RESUELTA — refinamiento físico 9.4C**

**Evidencia:** [9.2B](../../../../docs/architecture/v2/checkpoints/9.2B-eventos.md).

**Límite confirmado:** cambios de evento requieren aprobación presidencial y registro de auditoría. `EventRevision` es distinto de `EventReviewDecision`; no asumir que un `User` con rol genérico acredita autoridad.

**Pregunta restante:** no se pregunta si la aprobación o auditoría son necesarias. Solo falta aprobar/refinar la matriz exacta de campos materiales y el disparador de nueva `EventRevision`/`EventReviewDecision`.

**Impacto 9.4C:** modelar revisión, decisión presidencial, actor competente, timestamps, auditoría y trigger/regla para campos materiales. No eliminar aprobación presidencial ni permitir cambios aprobados sin rastro.

## OD-10 — Identificación jurídica de donantes

**Clasificación:** **RESUELTA POR DECISIÓN VALIDADA**

**Evidencia:** borrador 9.4B, [9.2C](../../../../docs/architecture/v2/checkpoints/9.2C-donaciones.md), decisiones preservadas sobre identidades.

**Límite confirmado:** los donantes deben ser identificables, pero no necesitan una cuenta `User`. `Donor` permanece distinto de `Person`, `User` y `Affiliate`; no se permiten alternativas de anonimato.

**Pregunta restante:** no existe pregunta institucional abierta sobre identificación o anonimato.

**Impacto 9.4C:** definir campos físicos de identidad, vínculo a persona/organización, verificación y auditoría, sin imponer cardinalidad de cuenta `User` ni permitir donante anónimo. Mantener separados oferta, recepción y decisión de donación.

## Decisiones aprobadas excluidas de aprobaciones abiertas

Estas decisiones no deben reaparecer como OD: `Expense 1:N Disbursement`; cada `Disbursement` tiene exactamente un `FinancialMovement` y `movementId` único; costo definitivo de mantenimiento solo tras cierre verificado; anticipos reducen caja al desembolso y no duplican salida; `Initiative` como destino válido junto con fondo general sin partición; `Person`, `User`, `Affiliate` y `Donor` son conceptos distintos; donación en especie no crea ingreso monetario ficticio; folio completo inmutable, no reutilizable y único exactamente por `(seriesId, folioYear, folioSequence)`.

## Pendientes técnicos de 9.4C sin nueva decisión institucional

- nombres de constraints, índices, tipos SQL y triggers;
- orden de migración/backfill, rollback y `VALIDATE`;
- derivación de versión vigente y garantía de pertenencia a `currentVersionId`;
- implementación física de asociaciones documentales después de OD-03;
- campos de identidad y verificación de `Donor` después de OD-10;
- matriz física de campos materiales de eventos después de OD-09;
- índices de rendimiento y contador anual de folio.

Todos deben preservar [la matriz de restricciones](constraint-matrix.md) y las decisiones confirmadas anteriores.
