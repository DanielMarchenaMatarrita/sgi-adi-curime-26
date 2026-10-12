import { createFileRoute } from '@tanstack/react-router'
import { Package } from 'lucide-react'
import { PageHeader } from '@/shared/components/shared'
import { AssetCard } from '@/modules/m8/components/asset-card'
import { LoanLog } from '@/modules/m8/components/loan-log'
import { InventoryStats } from '@/modules/m8/components/inventory-stats'
import { MOCK_ASSETS, MOCK_LOANS, MOCK_M8_STATS } from '@/modules/m8/data/mock-data'

export const Route = createFileRoute('/_modules/m8')({
  component: M8Page,
})

function M8Page() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Control de Activos Físicos"
        subtitle="Gestión inteligente de inventario comunitario con seguimiento QR"
        badge={{
          label: 'M8',
          icon: <Package className="h-3 w-3" />,
          variant: 'primary',
        }}
      />

      <InventoryStats stats={MOCK_M8_STATS} />

      <div className="space-y-2">
        <h2 className="font-title-md text-title-md font-semibold text-on-surface">
          Inventario de Activos
        </h2>
        <div className="grid gap-4 sm:grid-cols-2">
          {MOCK_ASSETS.map((asset) => (
            <AssetCard key={asset.id} asset={asset} />
          ))}
        </div>
      </div>

      <LoanLog loans={MOCK_LOANS} />
    </div>
  )
}
