import type { Assembly, Attendee, M3Stats } from '@/modules/m3/types'

export const MOCK_ASSEMBLY: Assembly = {
  id: 'asm-001',
  name: 'Asamblea Anual de Asociados 2025',
  date: '2025-06-20T09:00:00Z',
  status: 'EN_CURSO',
  totalAssociates: 120,
  presentCount: 48,
  quorumRequired: 61,
}

export const MOCK_ATTENDEES: Attendee[] = [
  {
    id: 'att-001',
    memberName: 'Carlos Mendoza',
    documentNumber: '1-2345-6789',
    timestamp: '2025-06-20T09:12:00Z',
    verifiedBy: 'QR',
  },
  {
    id: 'att-002',
    memberName: 'María Fernández',
    documentNumber: '2-8765-4321',
    timestamp: '2025-06-20T09:15:00Z',
    verifiedBy: 'QR',
  },
  {
    id: 'att-003',
    memberName: 'José Ramírez',
    documentNumber: '1-1122-3344',
    timestamp: '2025-06-20T09:18:00Z',
    verifiedBy: 'MANUAL',
  },
  {
    id: 'att-004',
    memberName: 'Laura Villalobos',
    documentNumber: '3-5566-7788',
    timestamp: '2025-06-20T09:22:00Z',
    verifiedBy: 'QR',
  },
  {
    id: 'att-005',
    memberName: 'Roberto Arias',
    documentNumber: '1-9988-7766',
    timestamp: '2025-06-20T09:25:00Z',
    verifiedBy: 'QR',
  },
  {
    id: 'att-006',
    memberName: 'Ana Beatriz Rojas',
    documentNumber: '2-4433-2211',
    timestamp: '2025-06-20T09:28:00Z',
    verifiedBy: 'QR',
  },
  {
    id: 'att-007',
    memberName: 'Fernando Castillo',
    documentNumber: '1-6677-8899',
    timestamp: '2025-06-20T09:31:00Z',
    verifiedBy: 'MANUAL',
  },
  {
    id: 'att-008',
    memberName: 'Patricia Méndez',
    documentNumber: '3-1212-3434',
    timestamp: '2025-06-20T09:34:00Z',
    verifiedBy: 'QR',
  },
]

export const MOCK_M3_STATS: M3Stats = {
  present: 48,
  totalAssociates: 120,
  delegatesRequired: 61,
  missing: 72,
  quorumPercent: 40,
}
