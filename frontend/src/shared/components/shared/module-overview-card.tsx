import { Link } from '@tanstack/react-router'
import { ChevronRight } from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import type { ModuleSummary } from '@/shared/data/module-summaries'

const STATUS_STYLES: Record<ModuleSummary['status'], { border: string; bg: string; dot: string; label: string }> = {
  healthy: { border: 'border-l-primary', bg: 'bg-primary/5', dot: 'bg-primary', label: 'Operativo' },
  warning: { border: 'border-l-amber-500', bg: 'bg-amber-500/5', dot: 'bg-amber-500', label: 'Alerta' },
  critical: { border: 'border-l-tertiary', bg: 'bg-tertiary/5', dot: 'bg-tertiary', label: 'Crítico' },
}

interface ModuleOverviewCardProps {
  summary: ModuleSummary
}

export function ModuleOverviewCard({ summary }: ModuleOverviewCardProps) {
  const statusStyle = STATUS_STYLES[summary.status]

  return (
    <Link
      to={summary.route}
      className={cn(
        'block border-l-4 rounded-lg bg-surface border border-outline-variant p-4 hover:shadow-md transition-all duration-200 group',
        statusStyle.border
      )}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <h4 className="font-title-sm text-title-sm text-on-surface">{summary.moduleName}</h4>
          <div className="flex items-center gap-1">
            <span className={cn('w-2 h-2 rounded-full', statusStyle.dot)} />
            <span className="text-[10px] font-medium uppercase text-on-surface-variant">{statusStyle.label}</span>
          </div>
        </div>
        <ChevronRight className="h-4 w-4 text-on-surface-variant group-hover:text-primary transition-colors" />
      </div>

      <div className="grid grid-cols-2 gap-2">
        {summary.metrics.map((metric) => (
          <div key={metric.label}>
            <div className="text-lg font-bold text-on-surface">{metric.value}</div>
            <div className="text-[10px] text-on-surface-variant uppercase tracking-wide">{metric.label}</div>
          </div>
        ))}
      </div>

      <div className="mt-3 pt-3 border-t border-outline-variant text-[10px] text-on-surface-variant">
        Última actividad: {new Date(summary.lastActivity).toLocaleString('es-CR')}
      </div>
    </Link>
  )
}
