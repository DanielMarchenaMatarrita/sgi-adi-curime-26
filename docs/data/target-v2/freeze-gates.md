# Criterios para congelar el modelo relacional V2

**Estado:** pendiente, revisión 9.4B–9.4D.

- [ ] Conciliar nominalmente V1.1 (49 persistentes +1 transicional, 77 relaciones) con el Prisma de referencia.
- [ ] Justificar cada candidata V2, detectar fusiones y confirmar la entidad condicional de asistencia a sesiones de Junta.
- [ ] Definir todas las PK, FK, claves candidatas, N:M y opcionalidad; preservar acciones referenciales históricas.
- [ ] Distinguir constraints que resuelve Prisma de los que requieren SQL PostgreSQL y transacciones.
- [ ] Definir cómo se relacionan anticipos, gastos y liquidación sin doble egreso; pruebas de transacción y arqueo.
- [ ] Definir folio único por (serie, año, secuencia); documento oficial versionado y acceso RBAC.
- [ ] Validar integridad de préstamos parciales, faltantes y recepción física de donaciones.
- [ ] Revisar 1FN/2FN/3FN y dependencias funcionales sin duplicar entidades o atributos derivables.
- [ ] Generar `schema.prisma` V2 completo dentro del repositorio independiente, solo tras autorización.
- [ ] Ejecutar `prisma validate` y revisar SQL constraints; documentar fallos o limitaciones.
- [ ] Renderizar/revisar diagramas ER y cotejar que multiplicidades sean equivalentes al modelo lógico.
- [ ] Obtener confirmación explícita antes de congelar V2 y antes de aplicar migraciones.

**No requerido para el freeze de diseño:** ejecutar backfills en base operativa del equipo. Requeridos al migrar datos: gates y reconciliaciones específicas por dominio.
