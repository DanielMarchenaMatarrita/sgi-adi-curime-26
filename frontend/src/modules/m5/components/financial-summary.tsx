import { Wallet, PiggyBank, AlertTriangle, FolderOpen, TrendingUp, BarChart3 } from 'lucide-react'
import { StatCard } from '@/shared/components/shared'
import { ProgressBar } from '@/shared/components/shared'
import type { M5Stats } from '../types'

interface FinancialSummaryProps {
  stats: M5Stats
}

function FinancialSummary({ stats }: FinancialSummaryProps) {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
        <StatCard
          label="Saldo Consolidado"
          value={`₡${stats.consolidatedBalance.toLocaleString('es-CR')}`}
          icon={<Wallet className="h-5 w-5" />}
          color="primary"
          variant="accent"
          trend={{ value: 4.2, label: 'vs mes anterior' }}
        />
        <StatCard
          label="Caja Chica"
          value={`₡${stats.pettyCash.toLocaleString('es-CR')}`}
          icon={<PiggyBank className="h-5 w-5" />}
          color="secondary"
        />
        <StatCard
          label="Compromisos Pendientes"
          value={stats.pendingCommitments}
          icon={<AlertTriangle className="h-5 w-5" />}
          color="tertiary"
        />
        <StatCard
          label="Proyectos Activos"
          value={stats.activeProjects}
          icon={<FolderOpen className="h-5 w-5" />}
          color="success"
        />
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-md">
          <div className="mb-3 flex items-center gap-2">
            <TrendingUp className="h-4 w-4 text-primary" />
            <h3 className="font-title-sm text-title-sm text-on-surface">Donaciones Mensuales</h3>
          </div>
          <p className="font-headline-lg text-headline-lg text-primary">
            ₡{stats.monthlyDonations.toLocaleString('es-CR')}
          </p>
          <p className="mt-1 text-xs text-on-surface-variant">Ingresos por donaciones este mes</p>
        </div>

        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-md">
          <div className="mb-3 flex items-center gap-2">
            <BarChart3 className="h-4 w-4 text-primary" />
            <h3 className="font-title-sm text-title-sm text-on-surface">Ejecución Presupuestaria</h3>
          </div>
          <ProgressBar
            percent={stats.budgetExecution}
            color={stats.budgetExecution > 80 ? 'warning' : 'primary'}
            size="lg"
            showPercent
          />
          <p className="mt-2 text-xs text-on-surface-variant">
            {stats.budgetExecution}% del presupuesto anual ejecutado
          </p>
        </div>
      </div>
    </div>
  )
}

export { FinancialSummary }
