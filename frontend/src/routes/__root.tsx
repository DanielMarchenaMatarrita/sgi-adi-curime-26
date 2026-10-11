import { createRootRoute, Outlet } from '@tanstack/react-router'
import { AppProvider } from '@/shared/context/app-context'
import { AuthProvider } from '@/shared/context/auth-context'
import { ErrorFallback } from '@/shared/components/shared/error-fallback'

function RootComponent() {
  return (
    <AuthProvider>
      <AppProvider>
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-[100] focus:rounded-lg focus:bg-primary focus:px-4 focus:py-2 focus:text-sm focus:font-semibold focus:text-white focus:shadow-lg focus:outline-none"
        >
          Saltar al contenido principal
        </a>
        <Outlet />
      </AppProvider>
    </AuthProvider>
  )
}

function RootErrorComponent({ error, reset }: { error: unknown; reset: () => void }) {
  const normalizedError = error instanceof Error ? error : new Error(String(error))
  return <ErrorFallback error={normalizedError} reset={reset} />
}

export const Route = createRootRoute({
  component: RootComponent,
  errorComponent: RootErrorComponent,
})
