import type { AffiliateStatus, ListAffiliatesResponse } from './contracts'
import { apiClient, type ApiClient } from './http-client'

export interface ListAffiliatesParams {
  limit: number
  offset: number
  status?: AffiliateStatus
  q?: string
}

export function getAffiliates(
  params: ListAffiliatesParams,
  client: ApiClient = apiClient,
): Promise<ListAffiliatesResponse> {
  const searchParams = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })

  if (params.status !== undefined) {
    searchParams.set('status', params.status)
  }

  const query = params.q?.trim()
  if (query) {
    searchParams.set('q', query)
  }

  return client<ListAffiliatesResponse>(`/api/affiliates?${searchParams.toString()}`)
}
