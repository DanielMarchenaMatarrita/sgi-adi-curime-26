import { createContext, useContext, useState, useCallback, type ReactNode } from 'react'
import { useAuth } from './auth-context'

export type UserRole = 'admin' | 'tesorero' | 'vecino' | 'auditor'

export interface CurrentUser {
  id: string
  name: string
  initials: string
  email: string
}

export interface Notification {
  id: string
  title: string
  message: string
  type: 'info' | 'success' | 'warning' | 'error'
  read: boolean
  timestamp: string
  moduleId?: string
}

interface AppState {
  currentUser: CurrentUser | null
  sidebarCollapsed: boolean
  sidebarMobileOpen: boolean
  notifications: Notification[]
  unreadCount: number
  activeModule: string | null
}

interface AppContextValue extends AppState {
  setSidebarCollapsed: (collapsed: boolean) => void
  toggleSidebar: () => void
  setSidebarMobileOpen: (open: boolean) => void
  toggleSidebarMobile: () => void
  setActiveModule: (moduleId: string | null) => void
  addNotification: (notification: Omit<Notification, 'id' | 'read' | 'timestamp'>) => void
  markNotificationRead: (id: string) => void
  markAllRead: () => void
}

const AppContext = createContext<AppContextValue | null>(null)

export function AppProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth()
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const [sidebarMobileOpen, setSidebarMobileOpen] = useState(false)
  const [activeModule, setActiveModule] = useState<string | null>(null)
  const [notifications, setNotifications] = useState<Notification[]>([
    {
      id: 'notif-001',
      title: 'Nuevo miembro registrado',
      message: 'María Elena Vargas fue añadida al padrón digital',
      type: 'success',
      read: false,
      timestamp: '2026-06-20T14:32:00Z',
      moduleId: 'm1',
    },
    {
      id: 'notif-002',
      title: 'Acta pendiente de firma',
      message: 'Acta #2026-047 requiere firmas de 2 miembros más',
      type: 'warning',
      read: false,
      timestamp: '2026-06-20T13:15:00Z',
      moduleId: 'm4',
    },
    {
      id: 'notif-003',
      title: 'Incidencia reportada',
      message: 'Fuga de agua en Salón Comunal detectada',
      type: 'error',
      read: false,
      timestamp: '2026-06-20T12:48:00Z',
      moduleId: 'm9',
    },
  ])

  const toggleSidebar = useCallback(() => {
    setSidebarCollapsed((prev) => !prev)
  }, [])

  const toggleSidebarMobile = useCallback(() => {
    setSidebarMobileOpen((prev) => !prev)
  }, [])

  const addNotification = useCallback(
    (notif: Omit<Notification, 'id' | 'read' | 'timestamp'>) => {
      const newNotif: Notification = {
        ...notif,
        id: `notif-${Date.now()}`,
        read: false,
        timestamp: new Date().toISOString(),
      }
      setNotifications((prev) => [newNotif, ...prev])
    },
    []
  )

  const markNotificationRead = useCallback((id: string) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    )
  }, [])

  const markAllRead = useCallback(() => {
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })))
  }, [])

  const unreadCount = notifications.filter((n) => !n.read).length
  const currentUser = user === null ? null : {
    id: String(user.id),
    name: user.fullName,
    initials: getInitials(user.fullName),
    email: user.email,
  }

  const value: AppContextValue = {
    currentUser,
    sidebarCollapsed,
    sidebarMobileOpen,
    notifications,
    unreadCount,
    activeModule,
    setSidebarCollapsed,
    toggleSidebar,
    setSidebarMobileOpen,
    toggleSidebarMobile,
    setActiveModule,
    addNotification,
    markNotificationRead,
    markAllRead,
  }

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

function getInitials(fullName: string): string {
  return fullName
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? '')
    .join('')
}

export function useApp() {
  const context = useContext(AppContext)
  if (!context) {
    throw new Error('useApp must be used within an AppProvider')
  }
  return context
}
