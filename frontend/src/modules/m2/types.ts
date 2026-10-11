import type { BaseEntity } from '@/shared/types/common'

export type CredentialStatus = 'VERIFICADO' | 'PENDIENTE' | 'REVOCADO'
export type EncryptionType = 'AES-256' | 'PENDING'
export type M2TabFilter = 'all' | 'pending'

export interface Credential extends BaseEntity {
  memberId: string
  firstName: string
  lastName: string
  photoUrl: string
  uuid: string
  activeId: string
  status: CredentialStatus
  encryption: EncryptionType
  token: string
  lastRotation: string
}

export interface M2Filters {
  tab: M2TabFilter
  search: string
}

export interface M2Stats {
  totalRegistered: number
  monthlyIncrease: number
  activeCredentialsPercent: number
  tokensIssued: number
  dataIntegrityPercent: number
}

export interface M2AuditEntry {
  id: string
  action: string
  timestamp: string
  actor: string
  color: 'primary' | 'secondary' | 'tertiary'
}

export const CREDENTIAL_STATUS_OPTIONS = [
  { value: 'all' as const, label: 'Todos' },
  { value: 'VERIFICADO' as const, label: 'Verificado' },
  { value: 'PENDIENTE' as const, label: 'Pendiente' },
  { value: 'REVOCADO' as const, label: 'Revocado' },
]

export const TAB_OPTIONS = [
  { value: 'all' as const, label: 'Todos los Asociados' },
  { value: 'pending' as const, label: 'Pendientes QR' },
] as const
