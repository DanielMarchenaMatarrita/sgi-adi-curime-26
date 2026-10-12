import { Users, UserCheck, AlertTriangle } from 'lucide-react'
import type { M3Stats } from '@/modules/m3/types'

interface AssemblyStatsProps {
  stats: M3Stats
}

function AssemblyStats({ stats }: AssemblyStatsProps) {
  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
      <div className="flex items-center gap-3 rounded-xl border border-outline-variant bg-surface p-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-container">
          <UserCheck className="h-5 w-5 text-on-primary-container" />
        </div>
        <div>
          <span className="text-label-md text-on-surface-variant">Presentes</span>
          <div className="text-[24px] font-bold text-on-surface">{stats.present}</div>
        </div>
      </div>

      <div className="flex items-center gap-3 rounded-xl border border-outline-variant bg-surface p-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-secondary-container">
          <Users className="h-5 w-5 text-on-secondary-container" />
        </div>
        <div>
          <span className="text-label-md text-on-surface-variant">Asociados Totales</span>
          <div className="text-[24px] font-bold text-on-surface">{stats.totalAssociates}</div>
        </div>
      </div>

      <div className="flex items-center gap-3 rounded-xl border border-outline-variant bg-surface p-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-tertiary-container">
          <AlertTriangle className="h-5 w-5 text-on-tertiary-container" />
        </div>
        <div>
          <span className="text-label-md text-on-surface-variant">Faltantes</span>
          <div className="text-[24px] font-bold text-on-surface">{stats.missing}</div>
        </div>
      </div>
    </div>
  )
}

export { AssemblyStats }
