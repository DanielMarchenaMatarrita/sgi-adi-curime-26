import type { ReactNode } from 'react'
import { useAuth } from '@/shared/context/auth-context'

type AuthStatus = 'anonymous' | 'authenticating' | 'restoring' | 'restore-error' | 'authenticated'

export type PermissionAccessState =
    | 'session-unavailable'
    | 'session-loading'
    | 'session-restoring'
    | 'permissions-loading'
    | 'allowed'
    | 'denied'

export interface PermissionAccess {
    state: PermissionAccessState
    isAllowed: boolean
}

export interface PermissionSnapshot {
    status: AuthStatus
    permissions: readonly string[]
}

export interface PermissionGateProps {
    requiredPermissions: readonly string[]
    children: ReactNode
    pending?: ReactNode
    denied?: ReactNode
    sessionUnavailable?: ReactNode
}

/**
 * Checks every required permission against effective permissions from AuthProvider.
 * Empty requirements are allowed, so callers can compose optional permission lists.
 */
export function hasAllPermissions(
    effectivePermissions: readonly string[],
    requiredPermissions: readonly string[],
): boolean {
    const effectivePermissionSet = new Set(effectivePermissions)
    return requiredPermissions.every((permission) => effectivePermissionSet.has(permission))
}

/**
 * Resolves session and authorization state without performing I/O.
 */
export function getPermissionAccess(
    { status, permissions }: PermissionSnapshot,
    requiredPermissions: readonly string[],
): PermissionAccess {
    if (status === 'anonymous' || status === 'restore-error') {
        return { state: 'session-unavailable', isAllowed: false }
    }

    if (status === 'restoring') {
        return { state: 'session-restoring', isAllowed: false }
    }

    if (status === 'authenticating') {
        return { state: 'permissions-loading', isAllowed: false }
    }

    if (status !== 'authenticated') {
        return { state: 'session-loading', isAllowed: false }
    }

    return hasAllPermissions(permissions, requiredPermissions)
        ? { state: 'allowed', isAllowed: true }
        : { state: 'denied', isAllowed: false }
}

/**
 * Reads only effective permissions and session state already held by AuthProvider.
 */
export function usePermissionAccess(requiredPermissions: readonly string[]): PermissionAccess {
    const { status, permissions } = useAuth()
    return getPermissionAccess({ status, permissions }, requiredPermissions)
}

/**
 * Declarative guard for route content, modules, or actions. It does not alter navigation.
 */
export function PermissionGate({
    requiredPermissions,
    children,
    pending = null,
    denied = null,
    sessionUnavailable = null,
}: PermissionGateProps) {
    const access = usePermissionAccess(requiredPermissions)

    if (access.state === 'allowed') {
        return children
    }

    if (access.state === 'denied') {
        return denied
    }

    if (access.state === 'session-unavailable') {
        return sessionUnavailable
    }

    return pending
}
