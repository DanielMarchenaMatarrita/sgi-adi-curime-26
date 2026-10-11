import { Clock, PlayCircle, CheckCircle2, Banknote } from 'lucide-react'
import type { M9Stats } from '../types'

function StatCard({
  icon: Icon,
  label,
  value,
  color,
}: {
  icon: typeof Clock
  label: string
  value: number | string
  color: string
}) {
  return (
    <div className="flex items-center gap-4 rounded-xl border border-slate-200 bg-white px-5 py-4 shadow-sm">
      <div className={`flex h-12 w-12 items-center justify-center rounded-lg ${color}`}>
        <Icon className="h-6 w-6 text-white" />
      </div>
      <div>
        <p className="text-2xl font-bold text-slate-800">{value}</p>
        <p className="text-sm text-slate-500">{label}</p>
      </div>
    </div>
  )
}

export function IncidentStats({ stats }: { stats: M9Stats }) {
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard icon={Clock} label="Pendientes" value={stats.pending} color="bg-slate-500" />
      <StatCard icon={PlayCircle} label="En Ejecución" value={stats.inExecution} color="bg-blue-500" />
      <StatCard icon={CheckCircle2} label="Resueltas" value={stats.resolved} color="bg-green-500" />
      <StatCard
        icon={Banknote}
        label="Presupuesto Mantención"
        value={`$${stats.maintenanceBudget.toLocaleString()}`}
        color="bg-amber-500"
      />
    </div>
  )
}
