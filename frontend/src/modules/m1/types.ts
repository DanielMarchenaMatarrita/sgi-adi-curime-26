import type { AffiliateStatus } from '@/shared/api/contracts'

export interface M1Filters {
  status: AffiliateStatus | 'all'
  search: string
}

export const STATUS_OPTIONS = [
  { value: 'all' as const, label: 'Todos' },
  { value: 'ACTIVE' as const, label: 'Activo' },
  { value: 'INACTIVE' as const, label: 'Inactivo' },
]
