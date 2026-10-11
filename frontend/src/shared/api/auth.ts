import type {
  LoginRequest,
  LoginResponse,
} from './contracts'
import { apiClient, type ApiClient } from './http-client'

export interface AuthService {
  login(credentials: LoginRequest): Promise<LoginResponse>
}

export function createAuthService(client: ApiClient = apiClient): AuthService {
  return {
    login(credentials) {
      return client<LoginResponse>('/api/auth/login', {
        method: 'POST',
        body: credentials,
      })
    },
  }
}

export const authService = createAuthService()

export function login(credentials: LoginRequest): Promise<LoginResponse> {
  return authService.login(credentials)
}

export { getCurrentUser } from './current-user'
