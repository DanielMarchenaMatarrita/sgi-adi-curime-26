import { ShieldCheck, Clock, AlertTriangle } from 'lucide-react'
import { StatusChip } from '@/shared/components/shared'
import type { Business, BusinessCategory, BusinessStatus } from '../types'

const CATEGORY_LABELS: Record<BusinessCategory, string> = {
  TODOS: 'Todos',
  ALIMENTACION: 'Alimentación',
  SERVICIOS: 'Servicios',
  ARTESANIA: 'Artesanía',
  TURISMO: 'Turismo Rural',
  TECNOLOGIA: 'Tecnología',
  EDUCACION: 'Educación',
}

const CATEGORY_COLORS: Record<BusinessCategory, string> = {
  TODOS: 'bg-surface-container-high text-on-surface-variant',
  ALIMENTACION: 'bg-emerald-50 text-emerald-700',
  SERVICIOS: 'bg-blue-50 text-blue-700',
  ARTESANIA: 'bg-amber-50 text-amber-700',
  TURISMO: 'bg-purple-50 text-purple-700',
  TECNOLOGIA: 'bg-cyan-50 text-cyan-700',
  EDUCACION: 'bg-rose-50 text-rose-700',
}

const STATUS_CHIP_MAP: Record<BusinessStatus, { variant: 'success' | 'warning' | 'danger'; label: string }> = {
  ACTIVO: { variant: 'success', label: 'Activo' },
  VENCIDO: { variant: 'danger', label: 'Vencido' },
  PENDIENTE_RENOVACION: { variant: 'warning', label: 'Renovación Pendiente' },
}

interface BusinessCardProps {
  business: Business
}

function BusinessCard({ business }: BusinessCardProps) {
  const statusInfo = STATUS_CHIP_MAP[business.status]
  const categoryColor = CATEGORY_COLORS[business.category]

  return (
    <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-md transition-all duration-200 hover:shadow-md">
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <h3 className="truncate text-title-md font-semibold text-on-surface">
              {business.name}
            </h3>
            {business.verified && (
              <ShieldCheck className="h-4 w-4 shrink-0 text-primary" />
            )}
          </div>
          <span className={`mt-1 inline-block rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider ${categoryColor}`}>
            {CATEGORY_LABELS[business.category]}
          </span>
        </div>
        <StatusChip variant={statusInfo.variant} label={statusInfo.label} size="sm" />
      </div>

      <p className="mt-sm text-sm leading-relaxed text-on-surface-variant line-clamp-2">
        {business.description}
      </p>

      <div className="mt-md flex items-center justify-between border-t border-outline-variant pt-sm">
        <span className="text-xs text-on-surface-variant">
          Propietario: <span className="font-medium text-on-surface">{business.ownerName}</span>
        </span>
        <div className="flex items-center gap-1 text-xs text-on-surface-variant">
          {business.status === 'ACTIVO' ? (
            <Clock className="h-3 w-3" />
          ) : (
            <AlertTriangle className="h-3 w-3 text-amber-500" />
          )}
          {business.lastActivity}
        </div>
      </div>
    </div>
  )
}

export { BusinessCard }
export type { BusinessCardProps }
