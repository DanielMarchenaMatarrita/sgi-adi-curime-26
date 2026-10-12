export type UUID = string

export interface AuditEntry {
  id: UUID
  timestamp: string
  actor: string
  action: string
  details: string
  previousHash: string
  currentHash: string
}

export type ModuleId =
  | 'm1'
  | 'm2'
  | 'm3'
  | 'm4'
  | 'm5'
  | 'm6'
  | 'm7'
  | 'm8'
  | 'm9'
  | 'm10'
  | 'm11'
  | 'vecino'
  | 'control'

export type MemberStatus = 'activo' | 'pendiente' | 'inactivo' | 'suspendido'

export type Gender = 'M' | 'F' | 'O'

export type DocumentType = 'cedula' | 'dimex' | 'nite'

export interface BaseEntity {
  id: UUID
  createdAt: string
  updatedAt: string
}

export interface ApiResponse<T> {
  success: boolean
  data: T
  error?: string
  timestamp: string
}

export interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
  totalPages: number
}
