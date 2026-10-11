import { History } from 'lucide-react'
import type { M6AuditEntry } from '../types'

interface DonationAuditProps {
  entries: M6AuditEntry[]
}

export function DonationAudit({ entries }: DonationAuditProps) {
  return (
    <div className="rounded-xl border border-border bg-card p-6 shadow-sm">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
          <History className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h3 className="font-heading text-base font-semibold text-foreground">
            Auditoría Reciente
          </h3>
          <p className="text-xs text-muted-foreground">Registro de actividades del módulo</p>
        </div>
      </div>

      <div className="relative ml-3 border-l-2 border-border pl-6">
        {entries.map((entry) => (
          <div key={entry.id} className="relative mb-6 last:mb-0">
            <div className="absolute -left-[31px] top-0.5 h-3 w-3 rounded-full border-2 border-primary bg-card" />
            <div className="space-y-1">
              <p className="text-sm font-medium text-foreground">{entry.action}</p>
              <div className="flex items-center gap-3 text-xs text-muted-foreground">
                <span>{entry.actor}</span>
                <span>·</span>
                <time>{new Date(entry.timestamp).toLocaleString('es-CR')}</time>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
