# Instrucciones para agentes — SGI ADI Curime 26

## Alcance y seguridad del repositorio

- Este es el **repositorio de rediseño independiente**. Nunca escribir en el repositorio SGI-Curime del equipo por implicación.
- Antes de cualquier cambio: inspeccionar rama, estado de Git, archivos relacionados y fuentes de verdad. No asumir código ni rutas inexistentes.
- No realizar `push`, merge, rebase, reset, migraciones ni commits sin autorización específica.
- No ejecutar migraciones sobre entornos remotos ni introducir secretos reales.
- Mantener clara la distinción `BASELINE V1.1`, `DECISIÓN VALIDADA`, `CANDIDATO V2`, `IMPLEMENTADO`, `VERIFICADO`.
- Preservar PK/FK e historia V1.1 y documentar gates de reconciliación antes de imponer restricciones obligatorias.
- Priorizar incrementos focales y pruebas necesarias; evitar suites costosas sin motivo.
- Documentar cambios estructurales como ADR y actualizar diagramas solo cuando haya una decisión o cambio confirmado.

## Responsabilidades

- Terra coordina el diseño; Atlas examina BD/Prisma/PostgreSQL; Forge backend; Pixel frontend; Sentinel validación cuando se requiera.
- No abrir trabajos de frontend/backend mientras el modelo relacional V2 no esté congelado y autorizado.

## Orquestación eficiente

- Terra ejecuta tareas simples y de coordinación directamente.
- Delegar a Atlas, Forge o Pixel solo cuando se requiera especialización; preferir un especialista por tarea.
- Usar múltiples agentes solo ante dependencias reales entre dominios; evitar delegación recursiva, revisiones repetidas y handoffs innecesarios.
- Sentinel solo para cambios de alto riesgo o solicitud explícita; no forma parte del flujo rutinario.
- Scribe no se invoca automáticamente. Documentación solo por responsable, tras confirmación del usuario.
- Pulse es opcional; no usar para trabajo rutinario.
- Reutilizar análisis, checkpoints y evidencia existente. Validar de forma focal según riesgo; evitar suites completas durante desarrollo sin necesidad.
- Reportes breves: cambios, validación, bloqueos y siguiente acción.

## Organización

- `docs/architecture/decisions/`: decisiones arquitectónicas formales.
- `docs/architecture/v2/`: diagramas/checkpoints (incluye redibujos históricos debidamente etiquetados).
- `database/docs/baseline-v1.1/`: contratos históricos, como **referencia**, no copia automática del esquema vivo.
- `database/docs/target-v2/`: inventario, ERD, restricciones, borradores y freeze gates.
- `docs/`: arquitectura, ADR, atlas, documentación funcional, seguridad, operaciones y calidad transversal.
- `frontend/README.md` y `backend/README.md`: marcadores documentales locales de componentes; no crear documentación local vacía.
- `docs/functional/`: reglas institucionales confirmadas y propuestas pendientes.

## Límites técnicos

- Monorepo pnpm workspace; no asumir Turbo, Nx, event bus ni microservicios sin justificación.
- No afirmar que datos históricos están conciliados solo porque exista una FK en Prisma.
- Los anticipos disminuyen caja cuando se desembolsan; costo definitivo de mantenimiento solo tras cierre verificado. Nunca duplicar salida monetaria.
- Documentación institucional del ERP (`DocumentRecord`) es distinta de documentación técnica versionada en Git.
