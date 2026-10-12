import { TrendingUp } from 'lucide-react'
import type { M2Stats } from '@/modules/m2/types'

interface IdentityStatsProps {
  stats: M2Stats
}

function IdentityStats({ stats }: IdentityStatsProps) {
  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-4">
      <div className="flex flex-col gap-1 rounded-xl border border-outline-variant bg-surface p-4">
        <span className="text-label-md text-on-surface-variant">Total Registrados</span>
        <span className="text-[28px] font-bold text-primary">
          {stats.totalRegistered.toLocaleString('es-CR')}
        </span>
        <div className="flex items-center text-[12px] font-medium text-primary">
          <TrendingUp className="mr-1 h-4 w-4" />
          +{stats.monthlyIncrease} este mes
        </div>
      </div>

      <div className="flex flex-col gap-1 rounded-xl border border-outline-variant bg-surface p-4">
        <span className="text-label-md text-on-surface-variant">Credenciales Activas</span>
        <span className="text-[28px] font-bold text-on-surface">{stats.activeCredentialsPercent}%</span>
        <div className="h-1 w-full overflow-hidden rounded-full bg-surface-container-highest">
          <div
            className="h-full rounded-full bg-primary transition-all"
            style={{ width: `${stats.activeCredentialsPercent}%` }}
          />
        </div>
      </div>

      <div className="flex flex-col gap-1 rounded-xl border border-outline-variant bg-surface p-4">
        <span className="text-label-md text-on-surface-variant">Tokens Emitidos</span>
        <span className="text-[28px] font-bold text-on-surface">
          {stats.tokensIssued.toLocaleString('es-CR')}
        </span>
        <span className="text-[11px] text-on-surface-variant">Rotación cada 24 horas</span>
      </div>

      <div className="flex flex-col gap-1 rounded-xl border border-outline-variant bg-surface p-4">
        <span className="text-label-md text-on-surface-variant">Integridad de Datos</span>
        <span className="text-[28px] font-bold text-primary">{stats.dataIntegrityPercent}%</span>
        <div className="flex items-center gap-1">
          <span className="h-2 w-2 animate-pulse rounded-full bg-primary" />
          <span className="text-[12px] font-medium text-primary">Verificado por Red ADI</span>
        </div>
      </div>
    </div>
  )
}

export { IdentityStats }
