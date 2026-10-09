# backend — API (reservado)

Área prevista para NestJS, Prisma y PostgreSQL. **No hay API ni migraciones inicializadas aún.**

No crear `schema.prisma` definitivo hasta superar los freeze gates de 9.4B/9.4C/9.4D. Toda migración posterior debe preservar la integridad histórica documentada.

`database/prisma/schema.prisma` será única ubicación autoritativa prevista para esquema Prisma; no duplicarlo en `backend`.
