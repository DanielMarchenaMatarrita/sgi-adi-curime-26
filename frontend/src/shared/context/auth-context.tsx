import {
    createContext,
    useCallback,
    useContext,
    useEffect,
    useMemo,
    useState,
    type ReactNode,
} from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { ApiHttpError, ApiNetworkError, setApiUnauthorizedHandler } from '@/shared/api/http-client'
import { login as loginRequest } from '@/shared/api/auth'
import { getCurrentUser } from '@/shared/api/current-user'
import type { CurrentUserResponse } from '@/shared/api/contracts'

type AuthStatus = 'anonymous' | 'authenticating' | 'authenticated'

interface AuthState {
    status: AuthStatus
    accessToken: string | null
    user: CurrentUserResponse | null
    expiresAt: number | null
    error: string | null
}

interface AuthContextValue extends AuthState {
    login: (email: string, password: string) => Promise<boolean>
    logout: () => void
}

const initialState: AuthState = {
    status: 'anonymous',
    accessToken: null,
    user: null,
    expiresAt: null,
    error: null,
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
    const queryClient = useQueryClient()
    const [state, setState] = useState<AuthState>(initialState)

    const logout = useCallback(() => {
        setState(initialState)
        queryClient.clear()
    }, [queryClient])

    useEffect(() => setApiUnauthorizedHandler(logout), [logout])

    useEffect(() => {
        if (state.status !== 'authenticated' || state.expiresAt === null) {
            return
        }

        const delay = Math.max(0, state.expiresAt - Date.now())
        const timeoutId = window.setTimeout(logout, delay)
        return () => window.clearTimeout(timeoutId)
    }, [logout, state.expiresAt, state.status])

    const login = useCallback(async (email: string, password: string) => {
        setState({ ...initialState, status: 'authenticating' })

        try {
            const token = await loginRequest({ email, password })
            if (token.tokenType !== 'Bearer' || token.expiresIn <= 0) {
                throw new Error('Invalid session contract')
            }

            const user = await getCurrentUser(token.accessToken)
            setState({
                status: 'authenticated',
                accessToken: token.accessToken,
                user,
                expiresAt: Date.now() + token.expiresIn * 1000,
                error: null,
            })
            return true
        } catch (error) {
            const message = getLoginErrorMessage(error)
            setState({ ...initialState, error: message })
            return false
        }
    }, [])

    const value = useMemo(
        () => ({ ...state, login, logout }),
        [login, logout, state],
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