import { Package, ArrowRightLeft, Wrench } from 'lucide-react'
import { StatCard } from '@/shared/components/shared/stat-card'
import type { M8Stats } from '../types'

interface InventoryStatsProps {
  stats: M8Stats
}

function InventoryStats({ stats }: InventoryStatsProps) {
  return (
    <div className="grid gap-4 sm:grid-cols-3">
      <StatCard
        label="Total Activos"
        value={stats.totalAssets}
        icon={<Package className="h-5 w-5" />}
        color="primary"
      />
      <StatCard
        label="En Préstamo"
        value={stats.onLoan}
        icon={<ArrowRightLeft className="h-5 w-5" />}
        color="secondary"
      />
      <StatCard
        label="En Mantenimiento"
        value={stats.inMaintenance}
        icon={<Wrench className="h-5 w-5" />}
        color="tertiary"
      />
    </div>
  )
}

export { InventoryStats }
