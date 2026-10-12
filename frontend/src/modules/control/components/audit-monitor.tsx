import { Terminal } from 'lucide-react'
import type { AuditLogEntry } from '../types'

const operationBadge: Record<
  AuditLogEntry['operation'],
  { label: string; className: string }
> = {
  CREATE: { label: 'CREATE', className: 'bg-emerald-600 text-white' },
  UPDATE: { label: 'UPDATE', className: 'bg-blue-600 text-white' },
  REJECT: { label: 'REJECT', className: 'bg-red-600 text-white' },
  LOGIN: { label: 'LOGIN', className: 'bg-amber-500 text-white' },
  HEARTBEAT: { label: 'HEARTBEAT', className: 'bg-zinc-500 text-white' },
}

interface AuditMonitorProps {
  entries: AuditLogEntry[]
}

function AuditMonitor({ entries }: AuditMonitorProps) {
  return (
    <div className="rounded-xl border border-outline-variant bg-surface p-6">
      <div className="mb-4 flex items-center gap-2">
        <Terminal className="h-4 w-4 text-primary" />
        <h3 className="font-title-md text-title-md text-on-surface">
          Monitor de Auditoría
        </h3>
      </div>

      <div className="overflow-hidden rounded-lg bg-zinc-950 p-4 font-mono text-xs">
        <div className="mb-2 flex items-center gap-2 border-b border-zinc-800 pb-2 text-zinc-500">
          <span className="h-2.5 w-2.5 rounded-full bg-red-500" />
          <span className="h-2.5 w-2.5 rounded-full bg-amber-500" />
          <span className="h-2.5 w-2.5 rounded-full bg-emerald-500" />
          <span className="ml-2">audit-log --tail --stream</span>
        </div>

        <div className="max-h-64 space-y-1.5 overflow-y-auto">
          {entries.map((entry) => {
            const badge = operationBadge[entry.operation]
            return (
              <div key={entry.id} className="flex items-start gap-3 text-zinc-300">
                <span className="flex-shrink-0 text-zinc-500">{entry.timestamp.slice(11, 19)}</span>
                <span
                  className={`flex-shrink-0 rounded px-1.5 py-0.5 text-[10px] font-bold ${badge.className}`}
                >
                  {badge.label}
                </span>
                <span className="text-zinc-100">{entry.artifact}</span>
                <span className="text-zinc-500">←</span>
                <span className="text-zinc-400">{entry.actor}</span>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}

export { AuditMonitor }
