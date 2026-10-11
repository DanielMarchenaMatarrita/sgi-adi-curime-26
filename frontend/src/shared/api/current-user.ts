import type { CurrentUserResponse } from './contracts'
import { apiClient, type ApiClient } from './http-client'

export interface CurrentUserService {
  getCurrentUser(accessToken: string): Promise<CurrentUserResponse>
}

export function createCurrentUserService(
  client: ApiClient = apiClient,
): CurrentUserService {
  return {
    getCurrentUser(accessToken) {
      return client<CurrentUserResponse>('/api/users/me', {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      })
    },
  }
}

export const currentUserService = createCurrentUserService()

export function getCurrentUser(accessToken: string): Promise<CurrentUserResponse> {
  return currentUserService.getCurrentUser(accessToken)
}
