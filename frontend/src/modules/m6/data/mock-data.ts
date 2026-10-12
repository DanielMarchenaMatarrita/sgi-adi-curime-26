import type { Donation, M6AuditEntry } from '../types'

export const MOCK_DONATION: Donation = {
  id: 'don-001',
  receiptNumber: 'REC-2026-0045',
  donorName: 'COOP. AGRICOLA DEL NORTE',
  taxId: '3-101-123456',
  date: '2026-06-20',
  type: 'MONETARIA',
  concept: 'Donación para proyecto de reforestación comunal',
  amount: 750000,
  treasuryAccount: 'CTA-2026-001',
  status: 'PENDIENTE',
}

export const MOCK_RECEIPT = {
  id: 'rcpt-001',
  donationId: 'don-001',
  number: 'REC-2026-0045',
  issuedDate: '2026-06-20',
  issuedBy: 'Dirección de Tesorería',
  validUntil: '2027-06-20',
  digitalSignature: 'SHA256:a1b2c3d4e5f6...',
}

export const MOCK_M6_AUDIT: M6AuditEntry[] = [
  {
    id: 'aud-001',
    action: 'Donación registrada en sistema',
    timestamp: '2026-06-20T14:32:00',
    actor: 'María López (Tesorería)',
  },
  {
    id: 'aud-002',
    action: 'Comprobante generado automáticamente',
    timestamp: '2026-06-20T14:33:15',
    actor: 'Sistema',
  },
  {
    id: 'aud-003',
    action: 'Revisión pendiente de validación fiscal',
    timestamp: '2026-06-20T15:10:00',
    actor: 'Carlos Ruiz (Fiscal)',
  },
]
