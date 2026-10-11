export interface HealthResponse {
  status: 'ok'
}

export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  accessToken: string
  tokenType: 'Bearer'
  expiresIn: number
}

export type UserStatus = 'ACTIVE' | 'INACTIVE' | 'BLOCKED'

export interface CurrentUserResponse {
  id: number
  fullName: string
  email: string
  status: UserStatus
}

export interface EffectivePermissionsResponse {
  permissions: string[]
}

export type AffiliateStatus = 'ACTIVE' | 'INACTIVE'

export interface AffiliateListItem {
  id: number
  fullName: string
  affiliateType: string | null
  affiliationDate: string
  status: AffiliateStatus
}

export interface ListAffiliatesResponse {
  items: AffiliateListItem[]
  limit: number
  offset: number
  total: number
}

export interface ApiErrorResponse {
  statusCode: number
  timestamp: string
  path: string
  message: string | string[]
}
