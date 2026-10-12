import {
    createContext,
    useCallback,
    useContext,
    useEffect,
    useMemo,
    useState,
    useRef,
    type ReactNode,
} from 'react'
import { useQueryClient } from '@tanstack/react-query'
import {
    ApiHttpError,
    ApiNetworkError,
    setApiAccessToken,
    setApiUnauthorizedHandler,
} from '@/shared/api/http-client'
import { login as loginRequest } from '@/shared/api/auth'
import { getCurrentUser, getEffectivePermissions } from '@/shared/api/current-user'
import type { CurrentUserResponse } from '@/shared/api/contracts'
import { clearStoredSession, readStoredSession, writeStoredSession } from '@/shared/api/session-storage'

type AuthStatus = 'anonymous' | 'authenticating' | 'restoring' | 'restore-error' | 'authenticated'

interface AuthState {
    status: AuthStatus
    accessToken: string | null
    user: CurrentUserResponse | null
    permissions: string[]
    expiresAt: number | null
    error: string | null
}

interface AuthContextValue extends AuthState {
    login: (email: string, password: string) => Promise<boolean>
    logout: () => void
    retrySessionRestore: () => Promise<void>
}

const initialState: AuthState = {
    status: 'anonymous',
    accessToken: null,
    user: null,
    permissions: [],
    expiresAt: null,
    error: null,
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
    const queryClient = useQueryClient()
    const [state, setState] = useState<AuthState>({ ...initialState, status: 'restoring' })
    const operationRef = useRef(0)
    const activeTokenRef = useRef<string | null>(null)
    const restoredRef = useRef(false)

    const clearSession = useCallback(() => {
        operationRef.current += 1
        activeTokenRef.current = null
        setApiAccessToken(null)
        clearStoredSession()
        setState(initialState)
        queryClient.clear()
    }, [queryClient])

    const logout = clearSession

    useEffect(
        () =>
            setApiUnauthorizedHandler((_path, token) => {
                if (activeTokenRef.current === token) {
                    clearSession()
                }
            }),
        [clearSession],
    )

    useEffect(() => {
        if (
            (state.status !== 'authenticated' && state.status !== 'restore-error') ||
            state.expiresAt === null
        ) {
            return
        }

        const delay = Math.max(0, state.expiresAt - Date.now())
        const timeoutId = window.setTimeout(clearSession, delay)
        return () => window.clearTimeout(timeoutId)
    }, [clearSession, state.expiresAt, state.status])

    const restoreSession = useCallback(async () => {
        const operation = ++operationRef.current
        const stored = readStoredSession()
        if (stored === null) {
            if (operation === operationRef.current) {
                clearSession()
            }
            return
        }

        activeTokenRef.current = stored.accessToken
        setApiAccessToken(stored.accessToken)
        setState({ ...initialState, status: 'restoring', accessToken: stored.accessToken, expiresAt: stored.expiresAt })

        try {
            const [user, permissionsResponse] = await Promise.all([
                getCurrentUser(),
                getEffectivePermissions(),
            ])
            if (operation !== operationRef.current) {
                return
            }

            setState({
                status: 'authenticated',
                accessToken: stored.accessToken,
                user,
                permissions: permissionsResponse.permissions,
                expiresAt: stored.expiresAt,
                error: null,
            })
        } catch (error) {
            if (operation !== operationRef.current) {
                return
            }

            if (error instanceof ApiNetworkError) {
                setState({
                    ...initialState,
                    status: 'restore-error',
                    accessToken: stored.accessToken,
                    expiresAt: stored.expiresAt,
                    error: 'No se pudo restaurar la sesión. Revisa tu conexión e inténtalo de nuevo.',
                })
                return
            }

            clearSession()
        }
    }, [clearSession])

    useEffect(() => {
        if (restoredRef.current) {
            return
        }
        restoredRef.current = true
        void restoreSession()
    }, [restoreSession])

    const login = useCallback(async (email: string, password: string) => {
        const operation = ++operationRef.current
        activeTokenRef.current = null
        setApiAccessToken(null)
        clearStoredSession()
        setState({ ...initialState, status: 'authenticating' })

        try {
            const token = await loginRequest({ email, password })
            if (operation !== operationRef.current) {
                return false
            }
            if (token.tokenType !== 'Bearer' || token.expiresIn <= 0) {
                throw new Error('Invalid session contract')
            }

            const expiresAt = Date.now() + token.expiresIn * 1000
            activeTokenRef.current = token.accessToken
            setApiAccessToken(token.accessToken)
            writeStoredSession({ accessToken: token.accessToken, expiresAt })
            const [user, permissionsResponse] = await Promise.all([
                getCurrentUser(),
                getEffectivePermissions(),
            ])
            if (operation !== operationRef.current) {
                return false
            }
            setState({
                status: 'authenticated',
                accessToken: token.accessToken,
                user,
                permissions: permissionsResponse.permissions,
                expiresAt,
                error: null,
            })
            return true
        } catch (error) {
            if (operation !== operationRef.current) {
                return false
            }
            const message = getLoginErrorMessage(error)
            clearSession()
            setState({ ...initialState, error: message })
            return false
        }
    }, [clearSession])

    const value = useMemo(
        () => ({ ...state, login, logout, retrySessionRestore: restoreSession }),
        [login, logout, restoreSession, state],
    )

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

function getLoginErrorMessage(error: unknown): string {
    if (error instanceof ApiNetworkError) {
        return 'No se pudo conectar con el servicio. Inténtalo de nuevo.'
    }

    if (error instanceof ApiHttpError && error.status === 401) {
        return 'El correo o la contraseña no son válidos.'
    }

    return 'No se pudo iniciar sesión. Inténtalo de nuevo.'
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
    const context = useContext(AuthContext)
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider')
    }
    return context
}
