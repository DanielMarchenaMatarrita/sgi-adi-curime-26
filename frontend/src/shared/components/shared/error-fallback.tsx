import { AlertTriangleIcon, RefreshCwIcon } from 'lucide-react'
import { Button } from '@/shared/components/ui/button'

interface ErrorFallbackProps {
  error: Error
  reset: () => void
}

function ErrorFallback({ error, reset }: ErrorFallbackProps) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <div className="w-full max-w-md rounded-2xl border border-outline-variant bg-surface-container-low p-8 text-center shadow-lg">
        <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-error-container">
          <AlertTriangleIcon className="h-7 w-7 text-error" />
        </div>
        <h1 className="font-heading text-xl font-semibold text-on-surface">
          Algo salió mal
        </h1>
        <p className="mt-2 text-sm text-on-surface-variant">
          Ha ocurrido un error inesperado. Por favor, intenta de nuevo.
        </p>
        {import.meta.env.DEV && (
          <pre className="mt-4 max-h-32 overflow-auto rounded-lg bg-surface-container-highest p-3 text-left text-xs text-on-surface-variant">
            {error.message}
            {'\n'}
            {error.stack}
          </pre>
        )}
        <Button
          onClick={reset}
          className="mt-6"
          aria-label="Reintentar operación"
        >
          <RefreshCwIcon className="mr-2 h-4 w-4" />
          Reintentar
        </Button>
      </div>
    </div>
  )
}

export { ErrorFallback }
export type { ErrorFallbackProps }
