export type DonationType = 'MONETARIA' | 'EN_ESPECIE'
export type ReceiptStatus = 'VALIDADO' | 'PENDIENTE' | 'ANULADO'

export interface Donation {
  id: string
  receiptNumber: string
  donorName: string
  taxId: string
  date: string
  type: DonationType
  concept: string
  amount: number
  treasuryAccount: string
  status: ReceiptStatus
}

export interface M6AuditEntry {
  id: string
  action: string
  timestamp: string
  actor: string
}
