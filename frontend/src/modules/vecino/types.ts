import type { UUID } from '@/shared/types/common'

export type AccessLevel = 'basico' | 'verificado' | 'vip'

export interface VecinoProfile {
  id: UUID
  fullName: string
  district: string
  community: string
  memberSince: string
  accessLevel: AccessLevel
  annualContributions: number
  outstandingBalance: number
  solvencyIssued: boolean
}

export interface QuickAction {
  id: string
  label: string
  description: string
  icon: string
  href: string
}

export interface TransparencyData {
  budgetExecuted: number
  budgetTotal: number
  dataCircularity: number
  lastAudit: string
  pendingProjects: number
}

export interface VecinoEvent {
  id: UUID
  title: string
  date: string
  time: string
  location: string
  type: 'asamblea' | 'voluntariado' | 'taller' | 'comunitario'
}

export interface MarketplaceProduct {
  id: UUID
  name: string
  vendor: string
  price: number
  currency: string
  imageUrl: string
  rating: number
  reviewCount: number
  category: string
}
