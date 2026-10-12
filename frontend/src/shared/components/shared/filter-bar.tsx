import { type ReactNode } from 'react'
import { cn } from '@/shared/lib/utils'

interface FilterOption {
  id: string
  label: string
  icon?: ReactNode
}

interface FilterBarProps {
  filters: FilterOption[]
  activeFilter: string
  onFilterChange: (id: string) => void
  variant?: 'pill' | 'tab'
  className?: string
}

function FilterBar({
  filters,
  activeFilter,
  onFilterChange,
  variant = 'pill',
  className,
}: FilterBarProps) {
  if (variant === 'tab') {
    return (
      <div
        className={cn(
          'flex overflow-x-auto border-b border-outline-variant',
          className
        )}
      >
        {filters.map((filter) => (
          <button
            key={filter.id}
            onClick={() => onFilterChange(filter.id)}
            className={cn(
              'flex shrink-0 items-center gap-2 border-b-2 px-md py-2.5 text-sm font-medium transition-colors',
              activeFilter === filter.id
                ? 'border-primary text-primary'
                : 'border-transparent text-on-surface-variant hover:text-on-surface'
            )}
          >
            {filter.icon}
            {filter.label}
          </button>
        ))}
      </div>
    )
  }

  return (
    <div className={cn('flex gap-2 overflow-x-auto pb-2', className)}>
      {filters.map((filter) => (
        <button
          key={filter.id}
          onClick={() => onFilterChange(filter.id)}
          className={cn(
            'flex shrink-0 items-center gap-1.5 rounded-full px-4 py-2 text-sm font-medium whitespace-nowrap transition-colors',
            activeFilter === filter.id
              ? 'bg-primary text-white'
              : 'bg-surface-container-high text-on-surface-variant hover:bg-outline-variant/30'
          )}
        >
          {filter.icon}
          {filter.label}
        </button>
      ))}
    </div>
  )
}

export { FilterBar }
export type { FilterBarProps, FilterOption }
