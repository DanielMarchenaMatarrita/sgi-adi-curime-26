# Casos de uso — SGI-Curime V2

**Estado:** registro técnico preliminar, en revisión; no equivale a aprobación de la ADI.
**Línea base funcional:** especificación V0.2 del 15 de octubre de 2026 (155 CU; 15 vistas DCU; 14 módulos M1–M14; 7 macroprocesos).
**Corte de evidencia de implementación:** `main@8e4c76aba82cad8b3a0e492bd8210906213bbbeb` (16 de octubre de 2026).
**Advertencia:** los DCU son vistas del catálogo, no módulos nuevos. Los códigos y títulos se mantienen como en la V0.2.

## Archivos y fuente única

- [`catalogo.csv`](catalogo.csv): **fuente única** del estado de cada uno de los 155 casos y sus evidencias.
- [`checklists/RESUMEN.md`](checklists/RESUMEN.md): reporte **generado**, no editar manualmente.
- [`checklists/DCU-01.md` … `DCU-15.md`](checklists/): checklists **generados** por vista; no editar manualmente.
- [`linea-base.md`](linea-base.md): procedencia, distinción entre especificación, aprobación, implementación y QA.
- [`brechas.md`](brechas.md): decisiones de alcance pendientes de validación.
- [`plantillas/ficha-caso-uso.md`](plantillas/ficha-caso-uso.md): formato para individualizar casos durante el desarrollo.
- [`../../governance/control-documental.md`](../../governance/control-documental.md): procedimiento de gobierno documental.

## Cómo se marca un CU como terminado

Un checkbox solo se marca **[x]** cuando `estado_qa=VERIFICADO`, con evidencias y aceptación registrada. `INTEGRADO` no equivale a `VERIFICADO`. El catálogo distingue:

| Estado de implementación | Interpretación |
|---|---|
| `SIN_FLUJO_ACREDITADO` | Caso en catálogo; no se encontró integración funcional suficiente en el corte revisado. No significa necesariamente que no exista trabajo de diseño o UI. |
| `PARCIAL` | Funcionalidad con una capa o parte del flujo implementada. |
| `INTEGRADO` | Flujo principal con código de backend/frontend y conexión acreditable; QA integral aún puede faltar. |
| `VERIFICADO` | Flujo validado con evidencia de criterios de aceptación y autorización institucional aplicable. |

`estado_qa`: `PENDIENTE` / `EN_REVISION` / `VERIFICADO`. Para completar un caso deben concordar implementación y QA, y existir PR o evidencias enlazadas.

## Flujo de actualización

1. Abrir rama específica; registrar el CU y enlazar issue o PR.
2. Actualizar **solo `catalogo.csv`**: estado, responsable, rutas de evidencia, enlaces GitHub y fecha.
3. Ejecutar `node scripts/docs/generate-use-case-checklists.cjs` en la raíz del repositorio.
4. Comprobar sincronización con `node scripts/docs/generate-use-case-checklists.cjs --check`.
5. Crear PR pequeño; revisar aceptación, seguridad, datos, pruebas y documentación antes de fusionar.

**Confidencialidad:** este repositorio es público; no subir actas privadas, cédulas, información de afiliados, hashes, tokens, contraseñas, minutas internas o Word sin clasificación/autorización.
