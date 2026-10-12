import type { Acta, ActaVersion, BoardSignature, M4Stats } from '@/modules/m4/types'

export const MOCK_ACTA: Acta = {
  id: 'acta-001',
  title: 'Acta de Asamblea General Ordinaria',
  sessionNumber: 'AG-2026-003',
  date: '2026-06-20',
  status: 'BORRADOR',
  content: `ASOCIACIÓN DE DESARROLLO COMUNAL DE CURIME
ASAMBLEA GENERAL ORDINARIA
ACTA N° 003-2026

FECHA: 20 de junio de 2026
HORA: 9:00 a.m.
LUGAR: Salón Comunal de Curime

1. CONVOCATORIA
La sesión fue convocada oportunamente por el Consejo Directivo, de acuerdo con los estatutos vigentes.

2. QUÓRUM
Se verificó la asistencia del 68% de los asociados inscritos, cumpliéndose con el quórum legal requerido para la válida constitución de la Asamblea.

3. ORDEN DEL DÍA
a) Aprobación del acta anterior
b) Informe de gestión del Consejo Directivo
c) Aprobación del plan de trabajo 2026-2027
d) Elección de comisiones
e) Temas varios

4. DESARROLLO DE LA SESIÓN
El Presidente de la Asamblea dio inicio a la sesión a las 9:15 a.m., dando paso a la lectura y aprobación del acta anterior.

5. ACUERDOS
- Se aprueba el informe de gestión por 75% de los votos
- Se aprueba el plan de trabajo con modificaciones menores
- Se eligen las comisiones según propuesta presentada

6. CIERRE
La sesión fue clausurada a las 12:30 p.m.

Firmado electrónicamente en plataforma SGI-CURIME.`,
  integrityHash: 'SHA-256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  version: 3,
}

export const MOCK_VERSIONS: ActaVersion[] = [
  {
    version: 1,
    timestamp: '2026-06-20T09:30:00Z',
    author: 'María Picado',
    description: 'Borrador inicial del acta',
  },
  {
    version: 2,
    timestamp: '2026-06-20T10:45:00Z',
    author: 'Carlos Ruiz',
    description: 'Corrección de quórum y acuerdos',
  },
  {
    version: 3,
    timestamp: '2026-06-20T11:20:00Z',
    author: 'Valeria Espinoza',
    description: 'Versión final para revisión',
  },
]

export const MOCK_SIGNATURES: BoardSignature[] = [
  {
    memberName: 'María Picado',
    role: 'Presidenta',
    documentNumber: '1-2345-6789',
    status: 'FIRMADO',
    signedAt: '2026-06-20T11:30:00Z',
  },
  {
    memberName: 'Carlos Ruiz',
    role: 'Vicepresidente',
    documentNumber: '2-3456-7890',
    status: 'PENDIENTE',
  },
  {
    memberName: 'Valeria Espinoza',
    role: 'Secretaria',
    documentNumber: '3-4567-8901',
    status: 'PENDIENTE',
  },
]

export const MOCK_M4_STATS: M4Stats = {
  treesSaved: 1247,
  totalActas: 42,
  pendingSignatures: 5,
}