import { cn } from '@/shared/lib/utils'

interface AuditTimelineItem {
  id: string
  title: string
  description: string
  timestamp: string
  type?: 'create' | 'update' | 'delete' | 'validate' | 'sync' | 'reject' | 'approve'
  uuid?: string
  actor?: string
}

interface AuditTimelineProps {
  items: AuditTimelineItem[]
  variant?: 'dot' | 'vertical' | 'terminal'
  className?: string
}

const typeColorMap = {
  create: 'bg-emerald-500',
  update: 'bg-primary',
  delete: 'bg-red-500',
  validate: 'bg-blue-500',
  sync: 'bg-amber-500',
  reject: 'bg-red-500',
  approve: 'bg-emerald-500',
}

const typeTagMap = {
  create: '[CREATE]',
  update: '[UPDATE]',
  delete: '[DELETE]',
  validate: '[VALIDATE]',
  sync: '[SYNC]',
  reject: '[REJECT]',
  approve: '[APPROVE]',
}

const typeTagColorMap = {
  create: 'text-emerald-400',
  update: 'text-primary',
  delete: 'text-red-400',
  validate: 'text-blue-400',
  sync: 'text-amber-400',
  reject: 'text-red-400',
  approve: 'text-emerald-400',
}

function AuditTimeline({ items, variant = 'vertical', className }: AuditTimelineProps) {
  if (variant === 'terminal') {
    return (
      <div
        className={cn(
          'space-y-2 rounded-lg bg-black/5 p-md font-mono text-xs',
          className
        )}
      >
        {items.map((item, i) => (
          <div
            key={item.id}
            className={cn(
              'flex gap-4 rounded p-1 transition-colors hover:bg-white/5',
              `opacity-${100 - i * 5}`
            )}
            style={{ opacity: Math.max(0.3, 1 - i * 0.05) }}
          >
            <span className="shrink-0 text-on-surface-variant">
              {new Date(item.timestamp).toLocaleTimeString('es-CR', {
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
              })}
            </span>
            <span className={cn('shrink-0', typeTagColorMap[item.type || 'update'])}>
              {typeTagMap[item.type || 'update']}
            </span>
            <span className="truncate text-on-surface">
              {item.title}: {item.description}
            </span>
          </div>
        ))}
      </div>
    )
  }

  if (variant === 'dot') {
    return (
      <div className={cn('space-y-md', className)}>
        {items.map((item) => (
          <div key={item.id} className="flex items-start gap-md">
            <div className="relative mt-1">
              <div
                className={cn(
                  'h-2 w-2 rounded-full ring-4 ring-primary-container/20',
                  typeColorMap[item.type || 'update']
                )}
              />
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-sm font-bold text-on-surface">{item.title}</p>
              <p className="text-xs text-on-surface-variant">{item.description}</p>
              {item.uuid && (
                <p className="mt-1 font-code-sm text-[10px] uppercase text-primary-container">
                  UUID: {item.uuid}
                </p>
              )}
              <p className="mt-0.5 text-[10px] text-on-surface-variant">
                {new Date(item.timestamp).toLocaleString('es-CR')}
              </p>
            </div>
          </div>
        ))}
      </div>
    )
  }

  // vertical (default)
  return (
    <div
      className={cn(
        'relative space-y-lg pl-10 before:absolute before:left-[11px] before:top-2 before:bottom-2 before:w-[2px] before:bg-outline-variant',
        className
      )}
    >
      {items.map((item) => (
        <div key={item.id} className="relative">
          <div
            className={cn(
              'absolute -left-10 top-1 flex h-6 w-6 items-center justify-center rounded-full border-4 border-white shadow-sm',
              typeColorMap[item.type || 'update']
            )}
          >
            <div className="h-2 w-2 rounded-full bg-white" />
          </div>
          <div className="rounded-lg border border-outline-variant/30 bg-surface-container-low p-3">
            <div className="mb-1 flex items-center justify-between">
              <p className="text-xs font-bold uppercase text-primary">{item.title}</p>
              <span className="font-mono text-[10px] text-on-surface-variant">
                {new Date(item.timestamp).toLocaleString('es-CR')}
              </span>
            </div>
            <p className="text-sm text-on-surface">{item.description}</p>
            {item.uuid && (
              <p className="mt-1 font-code-sm text-[10px] uppercase text-primary-container">
                UUID: {item.uuid}
              </p>
            )}
            {item.actor && (
              <p className="mt-0.5 text-[10px] text-on-surface-variant">
                Actor: {item.actor}
              </p>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}

export { AuditTimeline }
export type { AuditTimelineProps, AuditTimelineItem }
