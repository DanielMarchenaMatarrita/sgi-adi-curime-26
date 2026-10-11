import type { ApiErrorResponse } from './contracts'

type ResponseType = 'json' | 'none'

export interface ApiRequestOptions extends Omit<RequestInit, 'body'> {
  body?: unknown
  responseType?: ResponseType
}

export interface ApiClient {
  <T>(path: string, options?: ApiRequestOptions): Promise<T>
}

type ApiUnauthorizedHandler = (path: string) => void

let unauthorizedHandler: ApiUnauthorizedHandler | undefined

export function setApiUnauthorizedHandler(
  handler: ApiUnauthorizedHandler | undefined,
): () => void {
  unauthorizedHandler = handler
  return () => {
    if (unauthorizedHandler === handler) {
      unauthorizedHandler = undefined
    }
  }
}

export class ApiHttpError extends Error {
  readonly status: number
  readonly response: ApiErrorResponse | undefined

  constructor(status: number, response?: ApiErrorResponse) {
    super(`HTTP request failed with status ${status}`)
    this.name = 'ApiHttpError'
    this.status = status
    this.response = response
  }
}

export class ApiNetworkError extends Error {
  readonly cause: unknown

  constructor(cause: unknown) {
    super('Network request failed')
    this.name = 'ApiNetworkError'
    this.cause = cause
  }
}

export class ApiParseError extends Error {
  readonly status: number
  readonly cause: unknown

  constructor(status: number, cause: unknown) {
    super('API response could not be parsed as JSON')
    this.name = 'ApiParseError'
    this.status = status
    this.cause = cause
  }
}

export function normalizeApiBaseUrl(value: string | undefined): string {
  return (value ?? '').trim().replace(/\/+$/, '')
}

export function composeApiUrl(baseUrl: string, path: string): string {
  const normalizedBaseUrl = normalizeApiBaseUrl(baseUrl)
  const normalizedPath = `/${path.replace(/^\/+/, '')}`

  return `${normalizedBaseUrl}${normalizedPath}`
}

export function createApiClient(
  baseUrl: string = import.meta.env.VITE_API_BASE_URL ?? '',
): ApiClient {
  return async function request<T>(
    path: string,
    options: ApiRequestOptions = {},
  ): Promise<T> {
    const { body, headers, responseType = 'json', ...requestInit } = options
    const requestHeaders = new Headers(headers)

    if (body !== undefined && !requestHeaders.has('Content-Type')) {
      requestHeaders.set('Content-Type', 'application/json')
    }

    let response: Response

    try {
      response = await fetch(composeApiUrl(baseUrl, path), {
        ...requestInit,
        headers: requestHeaders,
        body: body === undefined ? undefined : JSON.stringify(body),
      })
    } catch (error) {
      throw new ApiNetworkError(error)
    }

    if (responseType === 'none' && response.ok) {
      return undefined as T
    }

    const responseBody = await parseJsonResponse(response)

    if (!response.ok) {
      if (response.status === 401 && !path.startsWith('/api/auth/')) {
        unauthorizedHandler?.(path)
      }

      throw new ApiHttpError(
        response.status,
        isApiErrorResponse(responseBody) ? responseBody : undefined,
      )
    }

    if (responseBody === undefined) {
      throw new ApiParseError(
        response.status,
        new SyntaxError('Expected a JSON response body'),
      )
    }

    return responseBody as T
  }
}

async function parseJsonResponse(response: Response): Promise<unknown> {
  let text: string

  try {
    text = await response.text()
  } catch (error) {
    throw new ApiNetworkError(error)
  }

  if (text === '') {
    return undefined
  }

  try {
    return JSON.parse(text) as unknown
  } catch (error) {
    throw new ApiParseError(response.status, error)
  }
}

function isApiErrorResponse(value: unknown): value is ApiErrorResponse {
  if (typeof value !== 'object' || value === null) {
    return false
  }

  const candidate = value as Record<string, unknown>

  return (
    typeof candidate.statusCode === 'number' &&
    typeof candidate.timestamp === 'string' &&
    typeof candidate.path === 'string' &&
    (typeof candidate.message === 'string' ||
      (Array.isArray(candidate.message) &&
        candidate.message.every((item) => typeof item === 'string')))
  )
}

export const apiClient = createApiClient()
