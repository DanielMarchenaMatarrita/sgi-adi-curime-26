# Convenciones del atlas

## Identidad y trazabilidad de diagramas

Cada diagrama tiene código `D-<checkpoint>-<n>`, un título, tipo, referencias de decisiones y estado. Ej.: `D-9.3C-02`.

- `BASELINE V1.1`: entidad o regla existente en el Target V1.1.
- `CONFIRMADO FUNCIONAL`: decisión expresamente tomada en los checkpoints; estructura física aún pendiente.
- `CANDIDATO CONCEPTUAL`: representación del modelo que necesita prueba lógica antes de Prisma.
- `PENDIENTE`: autoridad, cardinalidad, transición o entidad por validar.
- `REDIBUJADO`: reconstrucción gráfica a partir de acuerdos; no certifica identidad con un dibujo anterior.

## Convenciones gráficas

- `erDiagram`: entidades y asociaciones principales; multiplicidad conceptual, no necesariamente esquema SQL directo.
- `flowchart`: secuencias de negocio y decisiones; una flecha no representa necesariamente FK ni evento asíncrono.
- `stateDiagram-v2`: ciclo de vida, solo cuando la transición se ha confirmado.
- Mantener diagrama cerca de tabla de reglas y explicación textual.
- No mezclar `BoardResolution` con `AssemblyResolution` ni `Donation` monetaria con `InKindDonation`.
- Evitar una relación polimórfica `entityType + entityId` sin FK en documentos sensibles.
- Mantener las fuentes `.md`/Mermaid editables; SVG, HTML o PNG serán derivados, nunca la única fuente.

## Ficha de checkpoint

1. Propósito y alcance.
2. Identificación de diagramas (código, tipo, estado).
3. Diagrama(s) y narrativa.
4. Entidades afectadas y relaciones.
5. Decisiones aceptadas con códigos de validación.
6. Invariantes y casos límite.
7. Brechas frente a V1.1.
8. Pendientes para modelo lógico.
9. Referencias y versión.

No atribuir permisos reales a un `Role` por nombre solamente: autorización informática y designación institucional deben comprobarse por separado.
