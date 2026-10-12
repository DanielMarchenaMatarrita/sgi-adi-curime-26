import { Store, CheckCircle, RefreshCw } from 'lucide-react'
import { StatCard } from '@/shared/components/shared'
import type { M10Stats } from '../types'

interface MarketplaceStatsProps {
  stats: M10Stats
}

function MarketplaceStats({ stats }: MarketplaceStatsProps) {
  return (
    <div className="grid gap-4 sm:grid-cols-3">
      <StatCard
        label="Total Emprendimientos"
        value={stats.totalBusinesses}
        icon={<Store className="h-5 w-5" />}
        color="primary"
      />
      <StatCard
        label="Activos"
        value={stats.activeBusinesses}
        icon={<CheckCircle className="h-5 w-5" />}
        color="success"
      />
      <StatCard
        label="Renovación Pendiente"
        value={stats.pendingRenewal}
        icon={<RefreshCw className="h-5 w-5" />}
        color="tertiary"
      />
    </div>
  )
}

export { MarketplaceStats }
export type { MarketplaceStatsProps }
