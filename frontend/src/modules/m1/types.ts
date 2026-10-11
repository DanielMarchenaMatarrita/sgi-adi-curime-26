import type { BaseEntity, Gender, DocumentType } from '@/shared/types/common'

export type MemberStatus = 'VIGENTE' | 'PENDIENTE' | 'SUSPENDIDO'

export interface Member extends BaseEntity {
  firstName: string
  lastName: string
  documentType: DocumentType
  documentNumber: string
  dateOfBirth: string
  gender: Gender
  phone: string
  email: string
  district: string
  address: string
  status: MemberStatus
  electoralValidation: boolean
  assemblyParticipation: number
  notes: string
}

export type AgeRange = 'all' | '18-30' | '31-50' | '50+'
export type DistrictFilter = 'all' | 'Curime Central' | 'Quebrada Grande' | 'Barrio San Jose'

export interface M1Filters {
  ageRange: AgeRange
  status: MemberStatus | 'all'
  district: DistrictFilter
  search: string
}

export const DISTRICTS = ['Curime Central', 'Quebrada Grande', 'Barrio San Jose'] as const

export const AGE_RANGES = [
  { value: 'all' as const, label: 'Todos los rangos' },
  { value: '18-30' as const, label: '18 - 30 años' },
  { value: '31-50' as const, label: '31 - 50 años' },
  { value: '50+' as const, label: '50+ años' },
]

export const STATUS_OPTIONS = [
  { value: 'all' as const, label: 'Todos' },
  { value: 'VIGENTE' as const, label: 'Vigente' },
  { value: 'PENDIENTE' as const, label: 'Pendiente' },
  { value: 'SUSPENDIDO' as const, label: 'Suspendido' },
]

export const DISTRICT_OPTIONS = [
  { value: 'all' as const, label: 'Todos los distritos' },
  ...DISTRICTS.map((d) => ({ value: d as DistrictFilter, label: d })),
]
