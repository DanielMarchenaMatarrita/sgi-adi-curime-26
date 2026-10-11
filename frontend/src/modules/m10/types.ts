export type BusinessCategory = 'TODOS' | 'ALIMENTACION' | 'SERVICIOS' | 'ARTESANIA' | 'TURISMO' | 'TECNOLOGIA' | 'EDUCACION'
export type BusinessStatus = 'ACTIVO' | 'VENCIDO' | 'PENDIENTE_RENOVACION'

export interface Business {
  id: string
  name: string
  category: BusinessCategory
  ownerName: string
  memberId: string
  status: BusinessStatus
  description: string
  lastActivity: string
  verified: boolean
}

export interface M10Stats {
  totalBusinesses: number
  activeBusinesses: number
  pendingRenewal: number
}
