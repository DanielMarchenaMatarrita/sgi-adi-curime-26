# Matriz de diagramas y decisiones V2

| ID | Checkpoint | Diagrama | Tipo | Validación/decisión | Estado |
|---|---|---|---|---|---|
| D-ADR-0001-01 | Arquitectura general | Monorepo modular de alto nivel | Flujo | ADR-0001 | Objetivo aceptado; implementación parcial |
| D-ATLAS-01 | Atlas V2 | Responsabilidades funcionales transversales | Flujo conceptual | 9.2A/9.2B, DON-INV-VAL-01, MNT-VAL-04, FIN-VAL-01..03, FIN-MNT-VAL-01/02, DOC-VAL-01..04 | Redibujado; responsabilidades confirmadas, sin contrato de implementación |
| D-9.2A-01 | Gobernanza | Sesiones, actas y acuerdos | ER | 9.2A | Redibujado, candidato |
| D-9.2A-02 | Gobernanza | Decisión colegiada | Flujo | 9.2A | Redibujado, candidato |
| D-9.2B-01 | Eventos | Revisión y presupuesto | ER | 9.2B | Redibujado, candidato |
| D-9.2B-02 | Eventos | Aprobación de revisión | Flujo | 9.2B | Redibujado, candidato |
| D-9.2C-01 | Donaciones | Oferta, decisión, recepción y stock | ER | DON-VAL-04/05/06, DON-INV-VAL-01 | Redibujado, candidato |
| D-9.2C-02 | Donaciones | Oferta a custodia | Flujo | DON-VAL-04/05/06/07, DON-INV-VAL-01 | Redibujado, confirmado funcional |
| D-9.2D-01 | Inventario/Mantenimiento | Activos, incidencias y órdenes | ER | INV-VAL-01/02/03, MNT-VAL-01/02/03/04 | Confirmado funcional, candidato |
| D-9.2D-02 | Reservas/Mantenimiento | Bloqueo por mantenimiento | Flujo | MNT-VAL-02/03/04/05 | Confirmado funcional, candidato |
| D-9.3A-01 | Tesorería | Órganos y egresos | ER | FIN-VAL-01, INT-01 | Confirmado funcional, candidato |
| D-9.3A-02 | Tesorería | Confirmación de egreso ordinario | Flujo | FIN-VAL-01 | Confirmado funcional |
| D-9.3B-01 | Iniciativas | Iniciativa y destino financiero | ER | FIN-VAL-02/03 | Confirmado funcional, candidato |
| D-9.3B-02 | Iniciativas | Ingreso a destino único | Flujo | FIN-VAL-02/03 | Confirmado funcional |
| D-9.3C-01 | Préstamos | Devoluciones y faltantes | ER | INV-VAL-04/05 | Confirmado funcional, candidato |
| D-9.3C-02 | Préstamos | Conciliación de cantidades | Flujo | INV-VAL-04/05 | Confirmado funcional |
| D-9.3C-03 | Donaciones/Inventario | Recepción y existencias | Flujo | DON-INV-VAL-01 | Confirmado funcional |
| D-9.3D-01 | Documentos ERP | Archivos compartidos y propietarios de dominio | Conceptual | DOC-VAL-01..04 | Snapshot histórico redibujado; decisiones funcionales confirmadas, estructura candidata |
| D-9.3D-02 | Documentos ERP | Registro, validación y vinculación de evidencia | Flujo | DOC-VAL-01..04 | Snapshot histórico redibujado; decisiones funcionales confirmadas, estructura candidata |
| D-9.4B-01 | Borrador relacional | FIN-MNT | ER | FIN-MNT-VAL-01/02, FIN-VAL-01, INT-01 | Candidato conceptual; no congelado |
| D-9.4B-02 | Borrador relacional | Inventario y donaciones | ER | DON-VAL-04..08, DON-INV-VAL-01, INV-VAL-01..05 | Candidato conceptual; no congelado |
| D-9.4B-03 | Borrador relacional | Documentos institucionales | ER | DOC-VAL-01..04 | Candidato conceptual; no congelado |
| D-9.4B-FOL-01 | 9.4B foliación | Series, contador técnico, documentos y versiones | ER documental Mermaid | DOC-VAL-01..04, OD-05 | Candidato/contrato no congelado; `DocumentFolioCounter` técnico fuera de 31 candidatas |

Cada ID es una referencia estable para tablas de decisión, tickets y futuros diagramas UML físicos. Al reemplazar un diagrama redibujado por su original exacto, conservar el ID y actualizar su procedencia.
