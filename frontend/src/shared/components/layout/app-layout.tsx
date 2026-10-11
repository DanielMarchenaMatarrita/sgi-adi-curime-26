import { Outlet, useNavigate } from '@tanstack/react-router'
import { useEffect } from 'react'
import { AppSidebar, SidebarContent } from './app-sidebar'
import { TopBar } from './top-bar'
import { useApp } from '@/shared/context/app-context'
import { useAuth } from '@/shared/context/auth-context'
import { Sheet, SheetContent, SheetTitle } from '@/shared/components/ui/sheet'

export function AppLayout() {
  const navigate = useNavigate()
  const { status } = useAuth()
  const { sidebarCollapsed, toggleSidebar, sidebarMobileOpen, setSidebarMobileOpen } = useApp()

  useEffect(() => {
    if (status === 'anonymous') {
      void navigate({ to: '/login', replace: true })
    }
  }, [navigate, status])

  if (status !== 'authenticated') {
    return <div className="min-h-screen bg-surface" aria-busy="true" />
  }

  return (
    <div className="flex h-screen w-full overflow-hidden bg-slate-50">
      {/* Desktop sidebar — participates in flex flow */}
      <div className="hidden md:flex">
        <AppSidebar
          collapsed={sidebarCollapsed}
          onToggle={toggleSidebar}
        />
      </div>

      {/* Mobile sidebar overlay */}
      <Sheet open={sidebarMobileOpen} onOpenChange={setSidebarMobileOpen}>
        <SheetContent side="left" className="p-0 w-[272px]">
          <SheetTitle className="sr-only">Menú de navegación</SheetTitle>
          <SidebarContent collapsed={false} />
        </SheetContent>
      </Sheet>

      {/* Right container: TopBar + Main scroll area */}
      <div className="flex flex-col flex-1 min-w-0 h-full">
        <TopBar sidebarCollapsed={sidebarCollapsed} />

        <main
          id="main-content"
          role="main"
          className="flex-1 overflow-y-auto p-4 md:p-6"
        >
          <div className="max-w-[1440px] mx-auto">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  )
}
