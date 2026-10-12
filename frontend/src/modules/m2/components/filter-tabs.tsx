import { Search } from 'lucide-react'
import type { M2Filters, M2TabFilter } from '@/modules/m2/types'
import { TAB_OPTIONS } from '@/modules/m2/types'

interface FilterTabsProps {
  filters: M2Filters
  onFilterChange: (partial: Partial<M2Filters>) => void
}

function FilterTabs({ filters, onFilterChange }: FilterTabsProps) {
  return (
    <div className="flex items-center justify-between rounded-xl border border-outline-variant/30 bg-surface p-4">
      <div className="flex gap-3">
        {TAB_OPTIONS.map((tab) => (
          <button
            key={tab.value}
            onClick={() => onFilterChange({ tab: tab.value as M2TabFilter })}
            className={`rounded-full px-4 py-1 font-label-md text-label-md transition-colors ${
              filters.tab === tab.value
                ? 'bg-primary-container text-on-primary-container'
                : 'text-on-surface-variant hover:bg-surface-container-low'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>
      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-on-surface-variant" />
        <input
          type="text"
          value={filters.search}
          onChange={(e) => onFilterChange({ search: e.target.value })}
          placeholder="Buscar por nombre o UUID..."
          className="w-64 rounded-full border border-outline-variant bg-background py-2 pl-10 pr-4 text-label-md focus:border-primary focus:ring-2 focus:ring-primary"
        />
      </div>
    </div>
  )
}

export { FilterTabs }
