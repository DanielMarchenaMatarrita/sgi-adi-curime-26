export interface StoredSession {
  accessToken: string
  expiresAt: number
}

const SESSION_KEY = 'sgi-curime.auth.session'

export function readStoredSession(now = Date.now()): StoredSession | null {
  try {
    const value: unknown = JSON.parse(sessionStorage.getItem(SESSION_KEY) ?? 'null')
    if (!isStoredSession(value) || value.expiresAt <= now) {
      clearStoredSession()
      return null
    }

    return value
  } catch {
    clearStoredSession()
    return null
  }
}

export function writeStoredSession(session: StoredSession): void {
  try {
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(session))
  } catch {
    // Session persistence can be unavailable; keep current in-memory session usable.
  }
}

export function clearStoredSession(): void {
  try {
    sessionStorage.removeItem(SESSION_KEY)
  } catch {
    // Nothing else can be done when browser storage is unavailable.
  }
}

function isStoredSession(value: unknown): value is StoredSession {
  if (typeof value !== 'object' || value === null) {
    return false
  }

  const candidate = value as Record<string, unknown>
  return (
    typeof candidate.accessToken === 'string' &&
    candidate.accessToken.length > 0 &&
    typeof candidate.expiresAt === 'number' &&
    Number.isFinite(candidate.expiresAt)
  )
}
