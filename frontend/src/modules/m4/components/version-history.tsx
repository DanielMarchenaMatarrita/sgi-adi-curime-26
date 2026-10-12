import { Clock, GitBranch } from 'lucide-react'
import { BentoCard } from '@/shared/components/shared'
import type { ActaVersion } from '@/modules/m4/types'
import { cn } from '@/shared/lib/utils'

interface VersionHistoryProps {
  versions: ActaVersion[]
  currentVersion: number
}

function VersionHistory({ versions, currentVersion }: VersionHistoryProps) {
  return (
    <BentoCard
      variant="solid"
      header={
        <div className="flex items-center gap-sm">
          <Clock className="h-5 w-5 text-secondary" />
          <span className="font-title-sm text-title-sm text-on-surface">
            Historial de Versiones
          </span>
        </div>
      }
    >
      <div className="relative">
        <div className="absolute left-[15px] top-0 bottom-0 w-0.5 bg-outline-variant/30" />

        <div className="space-y-4">
          {versions.map((version) => {
            const isCurrent = version.version === currentVersion
            return (
              <div
                key={version.version}
                className={cn(
                  'relative flex items-start gap-sm',
                  isCurrent && 'pl-1'
                )}
              >
                <div
                  className={cn(
                    'relative z-10 flex h-8 w-8 shrink-0 items-center justify-center rounded-full border-2',
                    isCurrent
                      ? 'border-primary bg-primary text-white'
                      : 'border-outline-variant bg-surface-container-low text-on-surface-variant'
                  )}
                >
                  <GitBranch className="h-3.5 w-3.5" />
                </div>

                <div
                  className={cn(
                    'min-w-0 flex-1 rounded-lg border p-sm',
                    isCurrent
                      ? 'border-primary/20 bg-primary/5'
                      : 'border-outline-variant/30 bg-surface-container-lowest'
                  )}
                >
                  <div className="flex items-center justify-between">
                    <span
                      className={cn(
                        'text-xs font-bold',
                        isCurrent ? 'text-primary' : 'text-on-surface'
                      )}
                    >
                      Versión {version.version}
                    </span>
                    {isCurrent && (
                      <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[9px] font-bold uppercase tracking-wider text-primary">
                        Actual
                      </span>
                    )}
                  </div>
                  <p className="mt-1 text-xs text-on-surface-variant">
                    {version.description}
                  </p>
                  <div className="mt-2 flex items-center gap-sm text-[10px] text-on-surface-variant">
                    <span>{version.author}</span>
                    <span>·</span>
                    <span>
                      {new Date(version.timestamp).toLocaleDateString('es-CR', {
                        day: '2-digit',
                        month: 'short',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </span>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </BentoCard>
  )
}

export { VersionHistory }