# C5 — Validación inicial de migración V2

**Estado: VERIFIED** para ejecución local PostgreSQL 17 y ejecución manual en Supabase SQL Editor, dentro de los límites documentados abajo.

## Objetivo

Consolidar evidencia posterior a FIX-01 para migración inicial V2, sin modificar SQL, migraciones, esquema, Prisma, Docker, código, scripts ni documentación histórica.

## Hechos verificados

- La migración con FIX-01 pasó verificación de esquema y smoke/rollback de datos en PostgreSQL 17 local, base desechable `sgi_curime_v2_ddl_test2`.
- Conteos verificados en esa ejecución local: **86 tablas**, **46 enums**, **174 claves foráneas**, **44 restricciones CHECK con nombre** y **1 restricción de exclusión**.
- La misma migración se ejecutó manualmente con éxito en Supabase SQL Editor.
- En esa ejecución manual de Supabase se confirmaron los mismos cinco conteos: **86 tablas**, **46 enums**, **174 claves foráneas**, **44 restricciones CHECK con nombre** y **1 restricción de exclusión**.

## Relación con auditoría estática histórica

`reports/STATIC_AUDIT.md` y `reports/STATIC_AUDIT.json` permanecen como evidencia histórica de auditoría estática. Registran **39 reglas CHECK firmes** dentro de su alcance contractual/de auditoría estática.

Los **44 CHECK con nombre** son conteo físico verificado en tiempo de ejecución desde catálogo PostgreSQL. Ambos conteos tienen alcances distintos; este reporte no afirma equivalencia entre reglas CHECK firmes y restricciones CHECK con nombre.

## Decisión preservada

- FIX-01 corrigió predicados de índices parciales con columnas camelCase entrecomilladas. La evidencia previa está en `reports/FIX01_INDEX_PREDICATES.md`.
- Commits C1–C4 existen y no fueron alterados por C5.

## Límite de evidencia

Éxito manual en Supabase SQL Editor y conteos de catálogo no prueban:

- verificación de backup/restore;
- revisión de políticas RLS;
- sincronización de historial de migraciones de Supabase;
- cobertura de producción.

## Pendientes explícitos

1. Verificar backup/restore.
2. Revisar políticas RLS.
3. Sincronizar historial de migraciones de Supabase.

## Fuentes

- `reports/FIX01_INDEX_PREDICATES.md`
- `reports/STATIC_AUDIT.md`
- `reports/STATIC_AUDIT.json`
- Evidencia de ejecución y conteos verificados proporcionada por usuario para C5.
