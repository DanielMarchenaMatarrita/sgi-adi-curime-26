import type { Asset, Loan, M8Stats } from '../types'

export const MOCK_ASSETS: Asset[] = [
  {
    id: 'ast-001',
    code: 'ACT-SIL-001',
    name: 'Silla Ergonómica',
    category: 'Mobiliario',
    status: 'DISPONIBLE',
    description: 'Silla ergonómica con soporte lumbar ajustable',
  },
  {
    id: 'ast-002',
    code: 'ACT-PRY-002',
    name: 'Proyector Laser',
    category: 'Equipo Audiovisual',
    status: 'PRESTADO',
    description: 'Proyector láser 4K de alta luminosidad',
  },
  {
    id: 'ast-003',
    code: 'ACT-SIL-003',
    name: 'Silla de Conferencia',
    category: 'Mobiliario',
    status: 'EN_MANTENIMIENTO',
    description: 'Silla giratoria para sala de conferencias',
  },
  {
    id: 'ast-004',
    code: 'ACT-PTY-004',
    name: 'Pantalla de Proyección',
    category: 'Equipo Audiovisual',
    status: 'DISPONIBLE',
    description: 'Pantalla de proyección motorizada 120 pulgadas',
  },
]

export const MOCK_LOANS: Loan[] = [
  {
    id: 'loan-001',
    assetCode: 'ACT-PRY-002',
    assetName: 'Proyector Laser',
    borrower: 'Carlos Mendoza',
    loanDate: '2026-06-18',
    status: 'ACTIVO',
    encryptedId: 'ENC-a7f3e2b1',
  },
  {
    id: 'loan-002',
    assetCode: 'ACT-SIL-001',
    assetName: 'Silla Ergonómica',
    borrower: 'María Fernández',
    loanDate: '2026-06-15',
    returnDate: '2026-06-19',
    status: 'DEVUELTO',
    encryptedId: 'ENC-b4c8d5e9',
  },
  {
    id: 'loan-003',
    assetCode: 'ACT-PTY-004',
    assetName: 'Pantalla de Proyección',
    borrower: 'Roberto Vargas',
    loanDate: '2026-06-10',
    status: 'VENCIDO',
    encryptedId: 'ENC-c2d9f1a8',
  },
]

export const MOCK_M8_STATS: M8Stats = {
  totalAssets: 4,
  onLoan: 1,
  inMaintenance: 1,
}
