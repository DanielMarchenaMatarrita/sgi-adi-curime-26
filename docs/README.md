# Portal de documentación SGI ADI Curime 26

**Mapa de lectura y gobierno documental.** La documentación aquí describe arquitectura y decisiones del software; el ERP dispondrá de su propio módulo de documentos institucionales (folios, versiones, permisos).

| Sección | Contenido | Estado |
|---|---|---|
| [Arquitectura](architecture/README.md) | Monorepo, ADR y atlas de diagramas 9.2–9.3 | Borrador versionable |
| [Modelo de datos](../database/docs/README.md) | Baseline V1.1 y consolidación relacional V2 | 9.4B en curso |
| [Procesos](functional/README.md) | Reglas funcionales y trazabilidad | Índice preparado |
| [Seguridad](security/README.md) | RBAC, información sensible, auditoría | Índice preparado |
| [Operación](operations/README.md) | Despliegues y operaciones futuras | Índice preparado |
| [Calidad](quality/README.md) | Controles, pruebas, verificación de fuentes | Índice preparado |

## Reglas de publicación

- Cada documento debe indicar estado (`BORRADOR`, `VALIDADO FUNCIONAL`, `TARGET CONGELADO`, `IMPLEMENTADO`, `VERIFICADO`), procedencia y fecha.
- Los códigos de decisión (FIN-MNT-VAL-02, DOC-VAL-03, etc.) se registran en [decision-register.md](architecture/decisions/decision-register.md).
- Todo diagrama tiene fuente editable (`mermaid`) y vínculos a decisiones; versiones anteriores no se sobrescriben silenciosamente.
- La documentación **nunca** debe presentar una entidad V2 candidata como migración ya ejecutada.
- Evitar duplicar la misma fuente de verdad en varios documentos: enlazar la autoridad y mantener los anexos como snapshots.
