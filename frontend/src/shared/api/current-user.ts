import type { CurrentUserResponse, EffectivePermissionsResponse } from './contracts'
import { apiClient, type ApiClient } from './http-client'

export interface CurrentUserService {
  getCurrentUser(): Promise<CurrentUserResponse>
  getEffectivePermissions(): Promise<EffectivePermissionsResponse>
}

export function createCurrentUserService(
  client: ApiClient = apiClient,
): CurrentUserService {
  return {
    getCurrentUser() {
      return client<CurrentUserResponse>('/api/users/me')
    },
    getEffectivePermissions() {
      return client<EffectivePermissionsResponse>('/api/users/me/permissions')
    },
  }
}

export const currentUserService = createCurrentUserService()

export function getCurrentUser(): Promise<CurrentUserResponse> {
  return currentUserService.getCurrentUser()
}

export function getEffectivePermissions(): Promise<EffectivePermissionsResponse> {
  return currentUserService.getEffectivePermissions()
}
