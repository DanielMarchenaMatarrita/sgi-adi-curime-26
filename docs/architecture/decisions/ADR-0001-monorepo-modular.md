# ADR-0001 — Monorepo modular para SGI ADI Curime 26

- **Estado:** Propuesta aceptada como orientación de diseño; publicación e implementación pendientes.
- **Fecha:** 2026-10-08
- **Contexto:** repositorio nuevo, independiente del repositorio compartido por el equipo. Se requiere documentación y futura implementación del SGI V2 con trazabilidad.

## Decisión

Organizar código y documentación en un único monorepositorio con límites explícitos: `apps/web`, `apps/api`, `packages`, `infra`, `docs`. Usar pnpm workspaces como base sencilla **propuesta**. No introducir Nx/Turbo hasta que exista una necesidad observada.

## Consecuencias

- Ventajas: cambios trazables por commit, navegación simple, documentación próxima al código, versiones coordinadas de contratos.
- Riesgos: acoplamiento accidental entre dominios y paquetes compartidos gigantes. Mitigar con API pública por módulos, análisis de dependencias y revisiones.
- Restricción: no copiar datos reales, secretos ni historial innecesario del repositorio del equipo.

## Alternativas no elegidas

Multi-repos separados, Nx y Turborepo desde el primer día. Reevaluar si aparecen necesidades técnicas medibles.
