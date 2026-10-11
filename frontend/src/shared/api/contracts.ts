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

export interface ApiErrorResponse {
  statusCode: number
  timestamp: string
  path: string
  message: string | string[]
}
