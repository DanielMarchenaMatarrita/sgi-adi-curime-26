import { cn } from '@/shared/lib/utils'

interface KPISummaryItem {
  label: string
  value: string | number
  color?: 'primary' | 'secondary' | 'tertiary' | 'error' | 'success' | 'info'
}

interface KPISummaryProps {
  items: KPISummaryItem[]
  columns?: 2 | 3 | 4 | 5
  className?: string
}

const colorMap = {
  primary: 'text-primary',
  secondary: 'text-secondary',
  tertiary: 'text-tertiary',
  error: 'text-red-600',
  success: 'text-emerald-600',
  info: 'text-blue-600',
}

const gridMap = {
  2: 'grid-cols-2',
  3: 'grid-cols-3',
  4: 'grid-cols-4',
  5: 'grid-cols-5',
}

function KPISummary({ items, columns = 4, className }: KPISummaryProps) {
  return (
    <div className={cn('grid gap-3', gridMap[columns], className)}>
      {items.map((item, i) => (
        <div
          key={i}
          className="rounded-lg border border-outline-variant/30 bg-surface-container p-3"
        >
          <p className="text-xs font-medium text-on-surface-variant">{item.label}</p>
          <p
            className={cn(
              'mt-0.5 font-headline-lg text-headline-lg',
              item.color ? colorMap[item.color] : 'text-primary'
            )}
          >
            {typeof item.value === 'number' ? item.value.toLocaleString('es-CR') : item.value}
          </p>
        </div>
      ))}
    </div>
  )
}

export { KPISummary }
export type { KPISummaryProps, KPISummaryItem }
