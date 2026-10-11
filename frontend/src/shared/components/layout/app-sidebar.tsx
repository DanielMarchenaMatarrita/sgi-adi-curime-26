import { useNavigate } from '@tanstack/react-router'
import {
  Trees,
  ChevronLeft,
  ChevronRight,
  Plus,
  LogOut,
} from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import { Button } from '@/shared/components/ui/button'
import { ScrollArea } from '@/shared/components/ui/scroll-area'
import { NavItem } from './nav-item'
import { NAVIGATION, APP_NAME } from '@/app/config/constants'
import { useAuth } from '@/shared/context/auth-context'

interface SidebarContentProps {
  collapsed?: boolean
  onToggle?: () => void
}

function SidebarContent({ collapsed = false, onToggle }: SidebarContentProps) {
  const navigate = useNavigate()
  const { logout } = useAuth()

  function handleLogout() {
    logout()
    void navigate({ to: '/login', replace: true })
  }

  return (
    <>
      {/* Header */}
      <div
        className={cn(
          'flex items-center border-b border-outline-variant/60 transition-all duration-300',
          collapsed ? 'justify-center px-2 h-16' : 'gap-3 px-5 h-16'
        )}
      >
        <div className="relative w-9 h-9 bg-gradient-primary rounded-xl flex items-center justify-center shrink-0 shadow-sm">
          <Trees className="h-[18px] w-18 text-white" strokeWidth={2.5} />
          <div className="absolute inset-0 rounded-xl bg-gradient-to-br from-white/20 to-transparent" />
        </div>
        {!collapsed && (
          <div className="min-w-0 animate-fade-in">
            <h1 className="font-bold text-[15px] text-on-surface tracking-tight leading-tight">
              {APP_NAME}
            </h1>
            <p className="text-[9px] text-on-surface-variant uppercase tracking-[0.2em] font-semibold mt-0.5">
              Ecosistema Confiable
            </p>
          </div>
        )}
      </div>

      {/* Community badge */}
      {!collapsed && (
        <div className="px-3 pt-3 pb-1 animate-fade-in stagger-1">
          <div className="flex items-center gap-3 p-2.5 bg-gradient-primary-subtle rounded-xl border border-primary/8 transition-colors hover:border-primary/15">
            <div className="w-9 h-9 bg-primary/10 rounded-lg flex items-center justify-center shrink-0">
              <Trees className="h-[18px] w-[18px] text-primary" strokeWidth={2} />
            </div>
            <div className="min-w-0">
              <h4 className="text-[11px] font-bold text-on-surface truncate leading-tight">
                Asociación de Desarrollo
              </h4>
              <p className="text-[9px] text-primary font-bold uppercase tracking-[0.15em] mt-0.5">
                ID: ADI-7742
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav aria-label="Menú de navegación">
        <ScrollArea className="flex-1 px-2.5 py-2">
          {NAVIGATION.map((group, groupIndex) => (
            <div key={group.id} className={cn('mb-1', groupIndex > 0 && 'mt-3')}>
              {!collapsed && (
                <h3 className="px-3 py-1.5 text-[9px] font-bold uppercase tracking-[0.2em] text-on-surface-variant/60">
                  {group.label}
                </h3>
              )}
              <div className="flex flex-col gap-0.5">
                {group.items.map((item, itemIndex) => (
                  <NavItem
                    key={item.id}
                    item={item}
                    collapsed={collapsed}
                    staggerIndex={groupIndex * 6 + itemIndex}
                  />
                ))}
              </div>
            </div>
          ))}
        </ScrollArea>
      </nav>

      {/* Collapse toggle */}
      <button
        onClick={onToggle}
        className={cn(
          'flex items-center justify-center shrink-0 transition-all duration-300',
          'border-t border-outline-variant/60',
          collapsed ? 'h-10' : 'h-9 mx-3 mb-1 rounded-xl hover:bg-surface-container-high/60'
        )}
        aria-label={collapsed ? 'Expandir menú de navegación' : 'Colapsar menú de navegación'}
      >
        {collapsed ? (
          <ChevronRight className="h-4 w-4 text-on-surface-variant" />
        ) : (
          <ChevronLeft className="h-4 w-4 text-on-surface-variant" />
        )}
      </button>

      {/* Footer */}
      <div
        className={cn(
          'border-t border-outline-variant/60 transition-all duration-300',
          collapsed ? 'px-2 py-2' : 'px-3 py-3'
        )}
      >
        {!collapsed && (
          <Button
            className="w-full mb-3 bg-gradient-primary hover:opacity-90 text-white shadow-sm transition-all duration-200 hover:shadow-md"
            size="lg"
          >
            <Plus className="h-4 w-4" />
            Nuevo Registro
          </Button>
        )}
        <button
          type="button"
          onClick={handleLogout}
          className={cn(
            'flex w-full items-center gap-3 px-3 py-2 text-left text-sm font-medium rounded-xl transition-all duration-200',
            'text-on-surface-variant hover:bg-tertiary/5 hover:text-tertiary'
          )}
        >
          <LogOut className="h-[18px] w-[18px] shrink-0" />
          {!collapsed && <span>Cerrar Sesión</span>}
        </button>
      </div>
    </>
  )
}

interface AppSidebarProps {
  collapsed?: boolean
  onToggle?: () => void
}

function AppSidebar({ collapsed = false, onToggle }: AppSidebarProps) {
  return (
    <aside
      className={cn(
        'flex flex-col h-full border-r bg-white z-10 flex-shrink-0',
        'bg-surface-container-lowest/95 backdrop-blur-sm',
        'sidebar-gradient-border transition-all duration-300 ease-out',
        collapsed ? 'w-[72px]' : 'w-[272px]'
      )}
      aria-label="Navegación principal"
    >
      <SidebarContent collapsed={collapsed} onToggle={onToggle} />
    </aside>
  )
}

export { AppSidebar, SidebarContent }
export type { AppSidebarProps, SidebarContentProps }
