# FIX-01 — Índices parciales con columnas camelCase

**Diagnóstico confirmado por la prueba PostgreSQL 17 del usuario:** fallo `column "endson" does not exist` al crear `uq_membership_active_seat`.

PostgreSQL convierte nombres sin comillas a minúsculas. Las columnas originales fueron creadas entre comillas y conservan mayúsculas internas.

## Correcciones sincronizadas

| Índice | Antes | Ahora |
| --- | --- | --- |
| `uq_membership_active_seat` | `WHERE endsOn IS NULL` | `WHERE "endsOn" IS NULL` |
| `uq_volunteer_application_pending` | `AND personId IS NOT NULL` | `AND "personId" IS NOT NULL` |
| `uq_venture_association_open` | `WHERE endedAt IS NULL` | `WHERE "endedAt" IS NULL` |

Archivos modificados:
- `database/sql/v2/03_indexes.sql`
- `supabase/migrations/20261010000000_sgi_curime_v2_initial.sql`

Los dos archivos se mantienen sincronizados; no ejecutar los módulos por separado luego de ejecutar la migración integrada.

## Estado de prueba
- Prueba inicial real: **FAIL**, tal como reportó el usuario.
- Revisión estática FIX-01: **PASS** (los tres índices están corregidos en ambas copias del SQL).
- Prueba de ejecución FIX-01: **PENDIENTE**. No se ha afirmado que haya pasado.
- La base de prueba fallida se preservó como `sgi_curime_v2_ddl_test`; NO volver a usar ese nombre.

### Repetición de prueba
Desde la raíz del repositorio, luego de extraer este ZIP con `-Force`:

```powershell
pwsh -File .\scripts\run-test-local.ps1 -TestDatabase sgi_curime_v2_ddl_test2
```

Si falla, enviar el **primer mensaje `ERROR:` de PostgreSQL**. No ejecutar aún en Supabase.
