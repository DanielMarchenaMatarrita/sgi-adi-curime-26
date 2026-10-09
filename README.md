# SGI · ADI Curime 26

> **Estado:** diseño de arquitectura y modelo relacional V2, **sin aplicación funcional desplegada**.
> **Repositorio independiente:** este proyecto NO es el repositorio operativo del equipo SGI-Curime.

Sistema de Gestión Integral de la Asociación de Desarrollo Integral de Curime. Este monorepositorio reúne el futuro producto (portal público y ERP institucional), el backend, contratos compartidos, infraestructura y la documentación técnica versionada.

## Empezar por aquí

- [Portal de documentación](docs/README.md)
- [Arquitectura del monorepo](docs/architecture/README.md)
- [Atlas de diagramas por checkpoint](docs/architecture/v2/README.md)
- [Inventario de entidades V1.1 y candidatas V2](database/docs/target-v2/entity-inventory.md)
- [Borrador relacional 9.4B](database/docs/target-v2/9.4B-borrador-relacional.md)
- [Registro de decisiones](docs/architecture/decisions/decision-register.md)
- [Condiciones para congelar el diseño](database/docs/target-v2/freeze-gates.md)

## Estructura

```text
frontend/               # Portal y ERP; React, TypeScript, Vite, Tailwind (futuro)
backend/                # API; NestJS (futuro). No contiene schema.prisma
database/               # Workspace de datos; futuro schema: prisma/schema.prisma
  docs/                 # Baseline V1.1, modelo V2, ERD, reglas y freeze gates
docs/                   # Arquitectura, ADR, atlas, documentación transversal
  architecture/         # ADR, vistas de arquitectura, atlas y checkpoints
  functional/           # Requerimientos, procesos y reglas de negocio
  security/             # Privacidad y autorización
  operations/           # Operación, respaldo y despliegue
  quality/              # Estrategia de verificación y evidencias
packages/               # Librerías compartidas solo cuando haya necesidad real
infra/                  # Docker y despliegue (futuro)
scripts/                # Automatización controlada de repositorio
.github/                # Automatización GitHub cuando exista
.opencode/              # Evidencia operativa de ejecución y reportes de agentes
```

Documentación local de componentes: [frontend](frontend/README.md), [backend](backend/README.md) y [datos](database/README.md). La documentación transversal y los ADR permanecen bajo [docs/](docs/README.md).

## Tecnología propuesta

Monorepo con **pnpm workspaces**, sin exigir Nx ni Turborepo al inicio. Frontend previsto: React + TypeScript + Vite + Tailwind CSS; backend previsto: NestJS + Prisma + PostgreSQL. **No se han instalado ni inicializado estas aplicaciones**: los directorios contienen marcadores explicativos.

## Convenciones del diseño

1. La línea base V1.1 cuenta con 49 entidades persistentes, 1 transicional y 77 relaciones maestras congeladas.
2. V2 identifica 31 entidades candidatas (30 principales y 1 condicional); **no** equivale a 31 tablas aprobadas.
3. Los documentos históricos del atlas pueden representar decisiones reconstruidas; el [registro de decisiones](docs/architecture/decisions/decision-register.md) indica el estado más reciente.
4. El esquema Prisma V2 final, el DDL y las migraciones requieren completar las validaciones de 9.4B a 9.4D.
5. No importar automáticamente módulos del repositorio principal, secretos, datos reales ni historiales de usuarios.

## Fuente de referencia de lectura

Repositorio V1.1 autoritativo y solo de lectura: [SGI-Curime](https://github.com/matiasfarrierzuniga-rgb/SGI-Curime/tree/e8e2beb33eea8c1207fe77fe65dbd3228362bc5f), revisión `e8e2beb33eea8c1207fe77fe65dbd3228362bc5f` (`main` HEAD observado 2026-10-08). **No es destino de cambios de este proyecto.**

## Publicación inicial con revisión

El bootstrap original exigía un remoto vacío y una carpeta extraída sin `.git`; la rama `chore/bootstrap-monorepo-v2` ya fue publicada, por lo que **no debe repetirse contra el remoto inicializado**. Como referencia controlada para un arranque autorizado desde cero, aplica la [política de rama dedicada](docs/architecture/decisions/ADR-0002-branch-first-bootstrap.md) y usa exactamente:

```powershell
pwsh -File .\scripts\bootstrap-monorepo.ps1 -RemoteUrl 'https://github.com/DanielMarchenaMatarrita/sgi-adi-curime-26.git' -WorkBranch 'chore/bootstrap-monorepo-v2'
```

El script conserva los parámetros `-RemoteUrl` y `-WorkBranch`, pero exige igualdad exacta y sensible a mayúsculas con los valores aprobados de la invocación anterior. Rechaza cualquier otro valor antes de ejecutar Git o mutar la raíz de trabajo. En un arranque autorizado, la operación deja solo un README inicial en `main` y sube el resto a `chore/bootstrap-monorepo-v2`; no crea ni fusiona un Pull Request.
