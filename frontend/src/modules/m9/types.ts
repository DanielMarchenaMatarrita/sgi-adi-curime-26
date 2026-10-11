export type IncidentStatus = 'PENDIENTE' | 'EN_REVISION' | 'APROBADO' | 'RESUELTO'
export type IncidentPriority = 'ALTA' | 'MEDIA' | 'BAJA'

export interface Incident {
  id: string
  ticketId: string
  title: string
  description: string
  location: string
  reportedBy: string
  inspector?: string
  status: IncidentStatus
  priority: IncidentPriority
  createdAt: string
  budget?: number
}

export interface M9Stats {
  pending: number
  inExecution: number
  resolved: number
  maintenanceBudget: number
}
