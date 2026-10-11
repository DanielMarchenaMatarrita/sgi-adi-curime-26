import { queryOptions, useQuery } from '@tanstack/react-query'
import type { HealthResponse } from './contracts'
import { apiClient } from './http-client'

export const healthQueryKey = ['health'] as const

export function getHealth(): Promise<HealthResponse> {
  return apiClient<HealthResponse>('/api/health')
}

export function healthQueryOptions() {
  return queryOptions({
    queryKey: healthQueryKey,
    queryFn: getHealth,
    staleTime: 30_000,
  })
}

export function useHealthQuery() {
  return useQuery(healthQueryOptions())
}
