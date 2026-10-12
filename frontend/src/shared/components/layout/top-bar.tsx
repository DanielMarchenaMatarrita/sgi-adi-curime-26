import { useState, useEffect } from 'react'
import { Link } from '@tanstack/react-router'
import {
  Search,
  Database,
  Bell,
  Settings,
  ChevronRight,
  Command,
  Check,
  Menu,
} from 'lucide-react'
import { Avatar, AvatarFallback } from '@/shared/components/ui/avatar'
import { APP_NAME } from '@/app/config/constants'
import { useApp } from '@/shared/context/app-context'
import { GlobalSearch } from '@/shared/components/shared/global-search'
import { cn } from '@/shared/lib/utils'

interface BreadcrumbItem {
  label: string
  path?: string
}

interface TopBarProps {
  breadcrumbs?: BreadcrumbItem[]
  sidebarCollapsed?: boolean
}

export function TopBar({ breadcrumbs = [] }: TopBarProps) {
  const { currentUser, unreadCount, notifications, markNotificationRead, markAllRead, toggleSidebarMobile } = useApp()
  const [searchOpen, setSearchOpen] = useState(false)
  const [notifOpen, setNotifOpen] = useState(false)

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setSearchOpen(true)
      }
    }
    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [])

  return (
    <>
      <header
        role="banner"
        className={cn(
          'flex items-center justify-between shrink-0',
          'bg-surface/80 backdrop-blur-xl border-b border-outline-variant/50',
          'h-16 px-4 md:px-6'
        )}
      >
        {/* Left: hamburger + app name + search trigger */}
        <div className="flex items-center gap-4">
          <button
            onClick={toggleSidebarMobile}
            className="md:hidden min-w-[44px] min-h-[44px] flex items-center justify-center rounded-xl hover:bg-surface-container-high/60 transition-all duration-150"
            aria-label="Abrir menú de navegación"
          >
            <Menu className="h-5 w-5 text-on-surface-variant" />
          </button>
          <span className="hidden lg:block font-display text-xl text-primary/80 italic tracking-tight select-none">
            {APP_NAME}
          </span>

          {/* Search trigger */}
          <button
            onClick={() => setSearchOpen(true)}
            className={cn(
              'hidden md:flex items-center gap-2.5 rounded-xl border transition-all duration-200',
              'bg-surface-container-low/80 border-outline-variant/50 hover:border-primary/20 hover:bg-surface-container-high/50',
              'pl-3.5 pr-4 py-2 text-sm text-on-surface-variant w-72'
            )}
          >
            <Search className="h-4 w-4 shrink-0 text-on-surface-variant/60" />
            <span className="flex-1 text-left">Búsqueda global...</span>
            <kbd className="flex items-center gap-0.5 text-[10px] font-semibold bg-surface-container-highest/80 text-on-surface-variant/60 px-1.5 py-0.5 rounded-md border border-outline-variant/50">
              <Command className="h-2.5 w-2.5" />K
            </kbd>
          </button>
        </div>

        {/* Breadcrumbs */}
        {breadcrumbs.length > 0 && (
          <nav className="hidden lg:flex items-center gap-1 text-sm text-on-surface-variant" aria-label="Migas de pan">
            {breadcrumbs.map((crumb, index) => (
              <span key={index} className="flex items-center gap-1">
                {index > 0 && <ChevronRight className="h-3 w-3 text-outline-variant" />}
                {crumb.path ? (
                  <Link
                    to={crumb.path}
                    className="hover:text-primary transition-colors duration-150"
                  >
                    {crumb.label}
                  </Link>
                ) : (
                  <span className="text-on-surface font-medium">{crumb.label}</span>
                )}
              </span>
            ))}
          </nav>
        )}

        {/* Right: actions + user */}
        <div className="flex items-center gap-1">
          <button
            className="p-2 hover:bg-surface-container-high/60 transition-all duration-150 rounded-xl"
            title="Base de Datos"
          >
            <Database className="h-[18px] w-[18px] text-on-surface-variant" />
          </button>

          {/* Notifications */}
          <div className="relative">
            <button
              onClick={() => setNotifOpen(!notifOpen)}
              className="relative p-2 hover:bg-surface-container-high/60 transition-all duration-150 rounded-xl"
              title="Notificaciones"
            >
              <Bell className="h-[18px] w-[18px] text-on-surface-variant" />
              {unreadCount > 0 && (
                <span className="absolute -top-0.5 -right-0.5 min-w-[18px] h-[18px] bg-tertiary text-white text-[9px] font-bold rounded-full flex items-center justify-center px-1 shadow-sm animate-scale-in">
                  {unreadCount}
                </span>
              )}
            </button>

            {/* Notification dropdown */}
            {notifOpen && (
              <>
                <div
                  className="fixed inset-0 z-40"
                  onClick={() => setNotifOpen(false)}
                />
                <div className="absolute right-0 top-full mt-2 w-80 bg-surface-container-lowest rounded-2xl border border-outline-variant/50 shadow-xl z-50 animate-fade-in-down overflow-hidden">
                  <div className="flex items-center justify-between px-4 py-3 border-b border-outline-variant/50">
                    <h3 className="text-sm font-bold text-on-surface">Notificaciones</h3>
                    {unreadCount > 0 && (
                      <button
                        onClick={() => { markAllRead(); setNotifOpen(false); }}
                        className="text-xs text-primary font-semibold hover:underline"
                      >
                        Marcar todo leído
                      </button>
                    )}
                  </div>
                  <div className="max-h-80 overflow-y-auto">
                    {notifications.length === 0 ? (
                      <div className="px-4 py-8 text-center text-sm text-on-surface-variant">
                        Sin notificaciones
                      </div>
                    ) : (
                      notifications.map((notif) => (
                        <button
                          key={notif.id}
                          onClick={() => { markNotificationRead(notif.id); setNotifOpen(false); }}
                          className={cn(
                            'w-full flex items-start gap-3 px-4 py-3 text-left transition-colors hover:bg-surface-container-high/50',
                            !notif.read && 'bg-primary/[0.03]'
                          )}
                        >
                          <div
                            className={cn(
                              'mt-0.5 w-2 h-2 rounded-full shrink-0',
                              notif.read ? 'bg-transparent' : (
                                notif.type === 'success' ? 'bg-success' :
                                  notif.type === 'warning' ? 'bg-warning' :
                                    notif.type === 'error' ? 'bg-tertiary' : 'bg-info'
                              )
                            )}
                          />
                          <div className="flex-1 min-w-0">
                            <p className={cn('text-sm leading-tight', !notif.read ? 'font-semibold text-on-surface' : 'text-on-surface-variant')}>
                              {notif.title}
                            </p>
                            <p className="text-xs text-on-surface-variant mt-0.5 line-clamp-2">
                              {notif.message}
                            </p>
                          </div>
                          {!notif.read && (
                            <Check className="h-4 w-4 text-primary shrink-0 mt-0.5" />
                          )}
                        </button>
                      ))
                    )}
                  </div>
                </div>
              </>
            )}
          </div>

          <button
            className="p-2 hover:bg-surface-container-high/60 transition-all duration-150 rounded-xl"
            title="Configuración"
          >
            <Settings className="h-[18px] w-[18px] text-on-surface-variant" />
          </button>

          <div className="h-8 w-px bg-outline-variant/50 mx-2" />

          <div className="flex items-center gap-2.5">
            <div className="text-right hidden md:block">
              <p className="text-sm font-semibold text-on-surface leading-tight">
                {currentUser?.name}
              </p>
              <p className="text-[10px] text-on-surface-variant uppercase tracking-wider font-medium">
                Sesión activa
              </p>
            </div>
            <Avatar className="h-9 w-9 border-2 border-primary/15 shadow-sm transition-all duration-200 hover:border-primary/30 hover:shadow-glow">
              <AvatarFallback className="bg-gradient-primary text-white text-xs font-bold">
                {currentUser?.initials}
              </AvatarFallback>
            </Avatar>
          </div>
        </div>
      </header>

      <GlobalSearch open={searchOpen} onOpenChange={setSearchOpen} />
    </>
  )
}
