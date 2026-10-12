import { CircleDollarSign, Clock, CheckCircle2, TrendingUp, Users } from 'lucide-react'
import type { ControlStats } from '../types'

interface FinancialChartProps {
  stats: ControlStats
}

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat('es-CR', {
    style: 'currency',
    currency: 'CRC',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount)
}

function FinancialChart({ stats }: FinancialChartProps) {
  const cards = [
    {
      label: 'Disponible',
      value: formatCurrency(stats.availableFunds),
      icon: <CircleDollarSign className="h-5 w-5 text-emerald-600" />,
      bg: 'bg-emerald-50',
    },
    {
      label: 'Pendiente',
      value: formatCurrency(stats.pendingFunds),
      icon: <Clock className="h-5 w-5 text-amber-500" />,
      bg: 'bg-amber-50',
    },
    {
      label: 'Ejecutado',
      value: formatCurrency(stats.executedFunds),
      icon: <CheckCircle2 className="h-5 w-5 text-blue-600" />,
      bg: 'bg-blue-50',
    },
    {
      label: 'Cumplimiento DINADECO',
      value: `${stats.dinadecoCompliance}%`,
      icon: <TrendingUp className="h-5 w-5 text-primary" />,
      bg: 'bg-primary/10',
    },
    {
      label: 'Participación Ciudadana',
      value: `${stats.civilParticipation}%`,
      icon: <Users className="h-5 w-5 text-violet-600" />,
      bg: 'bg-violet-50',
    },
  ]

  return (
    <div className="rounded-xl border border-outline-variant bg-surface p-6">
      <h3 className="mb-1 font-title-md text-title-md text-on-surface">
        Resumen Financiero
      </h3>
      <p className="mb-4 text-xs text-on-surface-variant">
        Estado de cuentas y cumplimiento normativo
      </p>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
        {cards.map((card) => (
          <div
            key={card.label}
            className="flex flex-col gap-2 rounded-lg border border-outline-variant bg-surface-container-low p-4"
          >
            <div className={`flex h-9 w-9 items-center justify-center rounded-full ${card.bg}`}>
              {card.icon}
            </div>
            <div>
              <p className="text-xs text-on-surface-variant">{card.label}</p>
              <p className="mt-0.5 text-lg font-bold text-on-surface">{card.value}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export { FinancialChart }
