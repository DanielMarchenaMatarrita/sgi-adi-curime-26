import { Filter, RotateCcw } from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import type { M1Filters, AgeRange, MemberStatus, DistrictFilter } from '../types'
import { AGE_RANGES, STATUS_OPTIONS, DISTRICT_OPTIONS } from '../types'

interface FilterCardProps {
  filters: M1Filters
  onFilterChange: (filters: Partial<M1Filters>) => void
  className?: string
}

function FilterCard({ filters, onFilterChange, className }: FilterCardProps) {
  const hasActiveFilters =
    filters.ageRange !== 'all' || filters.status !== 'all' || filters.district !== 'all'

  return (
    <div
      className={cn(
        'rounded-xl border border-outline-variant/30 bg-surface-container-lowest overflow-hidden',
        className
      )}
    >
      <div className="flex items-center justify-between border-b border-outline-variant/20 px-5 py-3.5">
        <div className="flex items-center gap-2.5">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-primary/8">
            <Filter className="h-3.5 w-3.5 text-primary" />
          </div>
          <h3 className="text-sm font-bold text-on-surface">Filtros Avanzados</h3>
        </div>
        {hasActiveFilters && (
          <button
            onClick={() =>
              onFilterChange({ ageRange: 'all', status: 'all', district: 'all', search: '' })
            }
            className="flex items-center gap-1.5 text-xs font-semibold text-primary hover:text-primary-dark transition-colors"
          >
            <RotateCcw className="h-3 w-3" />
            Limpiar
          </button>
        )}
      </div>

      <div className="grid grid-cols-1 gap-4 p-5 md:grid-cols-4">
        {/* Rango de Edad */}
        <div className="space-y-1.5">
          <label
            htmlFor="ageRange"
            className="block text-[11px] font-bold uppercase tracking-wider text-on-surface-variant/60"
          >
            Rango de Edad
          </label>
          <select
            id="ageRange"
            value={filters.ageRange}
            onChange={(e) => onFilterChange({ ageRange: e.target.value as AgeRange })}
            className="w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2.5 text-sm font-medium text-on-surface transition-colors hover:border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/10"
          >
            {AGE_RANGES.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>

        {/* Estado Legal */}
        <div className="space-y-1.5">
          <label
            htmlFor="status"
            className="block text-[11px] font-bold uppercase tracking-wider text-on-surface-variant/60"
          >
            Estado Legal
          </label>
          <select
            id="status"
            value={filters.status}
            onChange={(e) => onFilterChange({ status: e.target.value as MemberStatus | 'all' })}
            className="w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2.5 text-sm font-medium text-on-surface transition-colors hover:border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/10"
          >
            {STATUS_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>

        {/* Distrito */}
        <div className="space-y-1.5">
          <label
            htmlFor="district"
            className="block text-[11px] font-bold uppercase tracking-wider text-on-surface-variant/60"
          >
            Distrito
          </label>
          <select
            id="district"
            value={filters.district}
            onChange={(e) => onFilterChange({ district: e.target.value as DistrictFilter })}
            className="w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2.5 text-sm font-medium text-on-surface transition-colors hover:border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/10"
          >
            {DISTRICT_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>

        {/* Limpiar */}
        <div className="flex items-end">
          <button
            onClick={() =>
              onFilterChange({ ageRange: 'all', status: 'all', district: 'all', search: '' })
            }
            className="w-full rounded-lg border border-outline-variant/30 bg-surface-container-highest px-4 py-2.5 text-sm font-semibold text-on-surface-variant transition-all hover:bg-surface-variant hover:border-outline-variant/50 active:scale-[0.98]"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>
    </div>
  )
}

export { FilterCard }
