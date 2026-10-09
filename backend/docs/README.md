# Backend local documentation

## Scope

This directory holds concrete documentation local to future backend implementation.

`backend/README.md` remains component workspace marker; it does not duplicate local documentation.

No NestJS implementation or dependencies exist in this component. Do not scaffold source, modules, dependencies, or database schema here.

Prisma schema has one future location only: `database/prisma/schema.prisma`. Never place Prisma schema in `backend`.
