import { Package, QrCode, AlertTriangle, ArrowRightLeft } from 'lucide-react'
import { StatusChip } from '@/shared/components/shared/status-chip'
import { Button } from '@/shared/components/ui/button'
import type { Asset, AssetStatus } from '../types'

const statusConfig: Record<AssetStatus, { variant: 'success' | 'info' | 'warning' | 'danger'; label: string }> = {
  DISPONIBLE: { variant: 'success', label: 'Disponible' },
  PRESTADO: { variant: 'info', label: 'Prestado' },
  EN_MANTENIMIENTO: { variant: 'warning', label: 'En Mantenimiento' },
  DANADO: { variant: 'danger', label: 'Dañado' },
}

interface AssetCardProps {
  asset: Asset
}

function AssetCard({ asset }: AssetCardProps) {
  const status = statusConfig[asset.status]

  return (
    <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-md transition-all duration-200 hover:shadow-md">
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
            <Package className="h-5 w-5 text-primary" />
          </div>
          <div>
            <p className="text-xs font-medium text-on-surface-variant">{asset.code}</p>
            <h3 className="font-body-lg text-body-lg font-semibold text-on-surface">{asset.name}</h3>
          </div>
        </div>
        <StatusChip variant={status.variant} label={status.label} size="sm" />
      </div>

      <div className="mt-3 flex items-center gap-2">
        <span className="rounded-full bg-surface-container-high px-2 py-0.5 text-[10px] font-medium text-on-surface-variant">
          {asset.category}
        </span>
      </div>

      <p className="mt-2 text-xs text-on-surface-variant line-clamp-2">{asset.description}</p>

      <div className="mt-4 flex items-center gap-3">
        <div className="flex h-16 w-16 items-center justify-center rounded-lg border-2 border-dashed border-outline-variant bg-surface-container">
          <div className="text-center">
            <QrCode className="mx-auto h-6 w-6 text-on-surface-variant" />
            <span className="text-[8px] text-on-surface-variant">QR</span>
          </div>
        </div>
        <div className="flex-1" />
        <div className="flex gap-2">
          <Button variant="outline" size="sm" className="gap-1 text-xs">
            <ArrowRightLeft className="h-3 w-3" />
            Préstamo
          </Button>
          <Button variant="ghost" size="sm" className="gap-1 text-xs text-amber-600 hover:text-amber-700">
            <AlertTriangle className="h-3 w-3" />
            Reportar
          </Button>
        </div>
      </div>
    </div>
  )
}

export { AssetCard }
