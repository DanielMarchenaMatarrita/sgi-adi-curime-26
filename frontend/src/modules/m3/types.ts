export type AssemblyStatus = 'EN_CURSO' | 'FINALIZADA' | 'PENDIENTE'

export interface Assembly {
  id: string
  name: string
  date: string
  status: AssemblyStatus
  totalAssociates: number
  presentCount: number
  quorumRequired: number
}

export interface Attendee {
  id: string
  memberName: string
  documentNumber: string
  timestamp: string
  verifiedBy: 'QR' | 'MANUAL'
}

export interface M3Stats {
  present: number
  totalAssociates: number
  delegatesRequired: number
  missing: number
  quorumPercent: number
}
