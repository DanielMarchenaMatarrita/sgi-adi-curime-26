# Evidencias y trazabilidad de aceptación

Para pasar un caso de uso a `estado_qa=VERIFICADO`, el PR debe enlazar un expediente de evidencia que incluya:

1. CU, versión de especificación y decisiones/requisitos aplicables.
2. Ruta React (si aplica), endpoint NestJS y contrato de datos.
3. Permisos RBAC/RLS, casos positivo, sin permisos y sin autenticación cuando corresponda.
4. Evidencia de pruebas unitarias, integración y E2E ejecutadas; ID de ejecución y commit SHA.
5. Resultado de aceptación funcional/manual y responsable autorizado.
6. Ausencia de datos personales o tokens en capturas y logs publicados.

Las pantallas alimentadas por mocks pueden servir de diseño UI, **no** acreditan el caso de uso institucional. Los tests presentes en repositorio no se consideran ejecutados hasta conservar resultados verificables.

## Registro mínimo de trazabilidad

Cada evidencia debe conservar, sin duplicar estados del catálogo, esta relación:

| Campo | Contenido requerido |
|---|---|
| CU | Identificador `CU-XX` y versión de especificación |
| Requisito | RF/RN/CP aplicable, indicando si es propuesta |
| Criterio de aceptación | Identificador y resultado esperado |
| Prueba | Tipo, nombre, comando o ID de ejecución |
| Resultado | `PROPUESTA`, `PASÓ` o `FALLÓ`, con fecha y commit |
| Evidencia | Ruta o URL sanitizada a reporte, log o captura |
| PR | Pull request que implementa o verifica el caso |

## Estados separados

- **Implementación técnica:** se registra únicamente en `catalogo.csv`.
- **Verificación QA:** resultado reproducible de pruebas; no se infiere por existencia de código.
- **Validación funcional:** revisión del flujo y criterios por responsable funcional.
- **Aprobación institucional:** decisión independiente, con responsable y fecha; no equivale a QA verificado.

Las pruebas propuestas deben permanecer marcadas como propuestas hasta contar con resultado y evidencia. No se debe marcar un checklist ni cambiar `estado_qa` por la sola existencia de una prueba escrita.
