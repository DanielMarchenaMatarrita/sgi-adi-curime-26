# BD-01E-A — esquema PostgreSQL 17 normalizado

Estado: **IMPLEMENTADO** como conjunto limpio independiente. No modifica ni migra la base original.

## Conjunto canónico y orden

1. `00_schema.sql`: transacción única para esquema vacío; 46 enums, 86 tablas, 922 columnas, 174 FK, 329 índices, 30 triggers, tres constraint triggers diferibles, un EXCLUDE GiST, vista y RLS habilitado. Integra consolidación una sola vez; no ejecutar `04_consolidation.sql` ni `90_v2_amendments.sql` después.
2. `01_runtime_security.sql`: roles sin LOGIN, owners/grants, FORCE RLS en 11 relaciones y nueve políticas.
3. `tests/00_structure.sql`.
4. `tests/01_integrity_catalog.sql` y pruebas transaccionales de `tests/integrity/`.
5. Fixtures y aserciones de `tests/security/`.

`equivalence-matrix.csv` conserva 1.982 objetos BD-01D y agrega 46 tipos enum. `identifier-map.csv` ofrece reemplazo compacto. Objetos `btree_gist` quedan `excluded` y conservan nombres de extensión. Candidatos BD-01D duplicados o mayores de 63 bytes reciben sufijo semántico o sufijo SHA-256 estable de ocho caracteres; columna `adjustment` registra cada caso.

## Reconstrucción segura

Desde raíz:

```powershell
pwsh -File database/sql/normalized-bd-01e-a/rebuild-postgres17.ps1
```

Runner crea contenedor PostgreSQL 17 aislado, sin puerto ni volumen, aplica conjunto y pruebas, y elimina solo ese contenedor etiquetado. No acepta URL externa, no ejecuta `DROP DATABASE`, `DROP SCHEMA` ni `TRUNCATE`.

## Consumidores

Prisma conserva API `PascalCase`/`camelCase` mediante `@@map`, `@map` y nombres físicos normalizados. Backend/tests con SQL literal no pertenecen al alcance BD: cambios exactos están en `backend-sql-literal-handoff.csv`; deben aplicarse coordinadamente antes de apuntar aplicación al esquema normalizado.

## Reversión

Artefacto solo instala en `public` vacío. Reversión operacional: descartar entorno aislado completo. No existe ni se autoriza reverse DDL sobre base original.
