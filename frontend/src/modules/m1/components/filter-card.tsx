import { Filter, RotateCcw } from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import type { M1Filters } from '../types'
import { STATUS_OPTIONS } from '../types'

interface FilterCardProps {
  filters: M1Filters
  onFilterChange: (filters: Partial<M1Filters>) => void
  className?: string
}

function FilterCard({ filters, onFilterChange, className }: FilterCardProps) {
  const hasActiveFilters = filters.status !== 'all' || filters.search.trim() !== ''

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
              onFilterChange({ status: 'all', search: '' })
            }
            className="flex items-center gap-1.5 text-xs font-semibold text-primary hover:text-primary-dark transition-colors"
          >
            <RotateCcw className="h-3 w-3" />
            Limpiar
          </button>
        )}
      </div>

      <div className="grid grid-cols-1 gap-4 p-5 md:grid-cols-3">
        <div className="space-y-1.5">
          <label
            htmlFor="affiliate-search"
            className="block text-[11px] font-bold uppercase tracking-wider text-on-surface-variant/60"
          >
            Nombre completo
          </label>
          <input
            id="affiliate-search"
            type="search"
            value={filters.search}
            onChange={(event) => onFilterChange({ search: event.target.value })}
            placeholder="Buscar afiliado..."
            className="w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2.5 text-sm font-medium text-on-surface transition-colors placeholder:text-on-surface-variant/60 hover:border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/10"
          />
        </div>

        <div className="space-y-1.5">
          <label
            htmlFor="status"
            className="block text-[11px] font-bold uppercase tracking-wider text-on-surface-variant/60"
          >
            Estado
          </label>
          <select
            id="status"
            value={filters.status}
            onChange={(event) => onFilterChange({ status: event.target.value as M1Filters['status'] })}
            className="w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2.5 text-sm font-medium text-on-surface transition-colors hover:border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/10"
          >
            {STATUS_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>

        <div className="flex items-end">
          <button
            onClick={() => onFilterChange({ status: 'all', search: '' })}
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
