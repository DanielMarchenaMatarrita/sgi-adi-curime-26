# Política de gestión documental — SGI-Curime V2

**Propuesta de ingeniería** · 2026-10-16 · aprobación del equipo y ADI pendiente.

## Reparto de responsabilidades

- **GitHub (registro técnico versionado):** código, ADR, especificaciones funcionales sanitizadas, catálogo de CU, estado y evidencia vinculada a PR/issues/commits. Las decisiones técnicas se revisan mediante PR.
- **Google Drive (repositorio de colaboración institucional):** Word, actas, formularios, minutas, documentos sujetos a firmas/revisión y otros originales, con permisos según clasificación.
- **Vínculo:** los Markdown de GitHub registran nombre, versión, responsable, estado y URL del documento oficial en Drive cuando el acceso corresponda. No duplicar dos listas editables de progreso.

## Identificación y estados

Cada documento registra: título, código, versión, fecha, autor o equipo, fuente, alcance, clasificación (`PUBLIC`, `INTERNAL`, `RESTRICTED`), estado de aprobación y relación con casos/ADR.
Estados documentales: `BORRADOR` → `EN_REVISION` → `VALIDADO_FUNCIONAL` → `APROBADO` → `OBSOLETO` (con referencia a sucesor). **Documentación aprobada** no es sinónimo de **funcionalidad implementada**.

## Cambios y revisión

- Una rama y un PR por cambio coherente; no acumular todo en un solo commit.
- Cambios de alcance alteran catálogo/versiones solo con trazabilidad de decisión.
- Cambios de estados de CU requieren evidencia concreta de implementación y QA.
- La fuente editable del diagrama se conserva en Git; la imagen es derivada.
- Documentos que contienen datos de asociados o deliberaciones institucionales no van al repositorio público sin autorización expresa y sanitización.
- No subir `.env.local`, credenciales, sesiones, capturas con tokens ni datos personales reales.

## Estructura de Drive sugerida (sin creación automática)

`SGI - ADI Curime / Documentación / V2 / 01-Gobierno / 02-Requisitos / 03-Diseno / 04-Pruebas / 05-Operacion / 06-Entregables / 99-Historico`

Conservar las carpetas y documentos existentes. Evitar duplicar los originales: crear referencias por URL en vez de copias sin control.
