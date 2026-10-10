# Auditoría estática de migración inicial — SGI-Curime V2

**Resultado: PASS estático / PENDIENTE PostgreSQL 17 real.**

- 82 tablas físicas del diccionario + 4 tablas consolidación = **86** tablas.
- 887 columnas en 82 tablas: 888 de contrato candidato menos 1 columna `User.roleId` eliminada por acuerdo; 4 tablas extra y `Venture.publishedRequestRevisionId` después.
- 46 tipos enum.
- 157 FK base (76 de 77 baseline, excluye `User.roleId`, más 81 V2 firmes) + 17 FK consolidación = **174 FK objetivo**.
- 37 unique BU baseline + 31 unique VU firmes = 68 índices únicos base. + 2 únicos parciales de autorizaciones.
- 108 índices baseline explícitos y 58 índices V2 explícitos = **166 índices explícitos base**.
- 39 CHECK físicos firmes, 1 restricción EXCLUDE con `btree_gist`.
- Controles de inmutabilidad, jerarquías, revisión y publicación, integridad documental, de donaciones e inventario incorporados mediante triggers.
- RLS activo para todas las tablas de SGI; sin políticas abiertas para clientes web.
- Validación estática: referencias de 157 FK base, 39 CHECK, nombres únicos de índices, funciones de triggers, cierre de comillas y bloques SQL.

## Qué NO demuestra esta auditoría

No dispongo de un proceso PostgreSQL 17 ni acceso autorizado al PostgreSQL de Supabase desde este entorno.
No he ejecutado el SQL en ningún servidor: errores de compilación PL/pgSQL, operadores, permisos y datos solo pueden detectarse en la prueba de ejecución real.
Quedan reglas transaccionales del contrato (TX-01..TX-34) que requieren implementación en NestJS; algunos checks condicionales C27 y C39 esperan definición de vocabularios oficiales y **no se instalaron**.
La política de idempotencia, permisos IAM para actos institucionales, locks bajo concurrencia y la protección del contador mediante funciones/roles dedicados también requieren validación de backend.
`User` conserva campos legacy de contacto/identificación por compatibilidad con baseline física; `Person` es la identidad canónica y la consolidación elimina `User.roleId`.

**Requisito: ejecutar `scripts/run-test-local.ps1` sobre una base desechable antes de usar Supabase.**
