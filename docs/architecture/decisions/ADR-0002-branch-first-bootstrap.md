# ADR-0002 — Incorporación inicial mediante rama dedicada

- **Estado:** Aceptado para el procedimiento de arranque.
- **Fecha:** 2026-10-08.
- **Ámbito:** repositorio nuevo `DanielMarchenaMatarrita/sgi-adi-curime-26` exclusivamente.

## Contexto

El repositorio de rediseño V2 está vacío. Debe protegerse la rama principal de cambios no revisados y conservar la separación respecto del repositorio operativo del equipo.

## Decisión

Inicializar `main` únicamente con un README descriptivo mínimo para establecer la primera referencia Git. A continuación crear `chore/bootstrap-monorepo-v2` y publicar allí la estructura de carpetas, documentación y diagramas en un commit propio. No fusionar a `main` hasta revisar documentación, procedencia, enlaces y diagramas mediante un Pull Request.

## Razones

- Revisión explícita de la primera estructura técnica.
- Historial independiente para el diseño V2.
- Evitar mezcla con implementación o migraciones no autorizadas.
- Mantener el repositorio compartido por el equipo como referencia de lectura, nunca destino de escritura.

## Consideraciones

- La primera inicialización de un repositorio GitHub vacío exige una referencia inicial; un README mínimo en `main` no significa aprobación de la documentación de la rama.
- El script `scripts/bootstrap-monorepo.ps1` valida el destino remoto vacío y detiene la operación si encuentra referencias o un Git local preexistente.
- La publicación de la rama **no** ejecuta pruebas Prisma ni confirma congelamiento de V2.
