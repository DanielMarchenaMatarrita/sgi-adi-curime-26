import { PieChart, BarChart3, FileSearch } from 'lucide-react'
import { BentoCard, ProgressBar } from '@/shared/components/shared'
import { formatCurrency } from '@/shared/lib/utils'
import type { TransparencyData } from '../types'

interface TransparencyDashboardProps {
  data: TransparencyData
}

export function TransparencyDashboard({ data }: TransparencyDashboardProps) {
  const budgetPercent = Math.round((data.budgetExecuted / data.budgetTotal) * 100)

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/8">
          <BarChart3 className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h3 className="font-display text-lg italic text-on-surface">Transparencia</h3>
          <p className="text-xs text-on-surface-variant">Datos públicos de la asociación</p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <BentoCard variant="solid" accent="primary">
          <div className="space-y-3">
            <div className="flex items-center gap-2">
              <BarChart3 className="h-4 w-4 text-primary" />
              <h4 className="text-xs font-bold uppercase tracking-wider text-on-surface">
                Ejecución Presupuestaria
              </h4>
            </div>
            <div className="flex items-baseline justify-between">
              <span className="font-display text-2xl italic text-primary">{budgetPercent}%</span>
              <span className="text-xs text-on-surface-variant">
                de {formatCurrency(data.budgetTotal)}
              </span>
            </div>
            <ProgressBar percent={budgetPercent} color="primary" size="lg" />
            <p className="text-[10px] text-on-surface-variant/60">
              Ejecutado: {formatCurrency(data.budgetExecuted)}
            </p>
          </div>
        </BentoCard>

        <BentoCard variant="solid" accent="success">
          <div className="space-y-3">
            <div className="flex items-center gap-2">
              <PieChart className="h-4 w-4 text-success" />
              <h4 className="text-xs font-bold uppercase tracking-wider text-on-surface">
                Circularidad de Datos
              </h4>
            </div>
            <div className="flex items-baseline justify-between">
              <span className="font-display text-2xl italic text-success">
                {data.dataCircularity}%
              </span>
              <span className="text-xs text-on-surface-variant">frecuencia de actualización</span>
            </div>
            <ProgressBar percent={data.dataCircularity} color="success" size="lg" />
            <p className="text-[10px] text-on-surface-variant/60">
              Última auditoría: {new Date(data.lastAudit).toLocaleDateString('es-CR')}
            </p>
          </div>
        </BentoCard>
      </div>

      <div className="flex items-center gap-2 rounded-lg bg-surface-container-low px-3 py-2">
        <FileSearch className="h-4 w-4 text-on-surface-variant" />
        <span className="text-xs text-on-surface-variant">
          {data.pendingProjects} proyectos pendientes de aprobación
        </span>
      </div>
    </div>
  )
}
