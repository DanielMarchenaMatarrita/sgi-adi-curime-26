import { type ReactNode } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/shared/lib/utils'
import { TrendingUp, TrendingDown, Minus } from 'lucide-react'

const statCardVariants = cva(
  'rounded-2xl border border-outline-variant/40 bg-surface-container-lowest p-md transition-all duration-300',
  {
    variants: {
      variant: {
        default: '',
        glass: 'bg-white/60 backdrop-blur-sm border-white/20',
        accent: 'border-l-4 border-l-primary',
      },
      hoverable: {
        true: 'hover:shadow-lg hover:-translate-y-0.5 cursor-pointer',
        false: '',
      },
    },
    defaultVariants: {
      variant: 'default',
      hoverable: false,
    },
  }
)

interface StatCardProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof statCardVariants> {
  label: string
  value: string | number
  unit?: string
  icon?: ReactNode
  trend?: {
    value: number
    label?: string
  }
  color?: 'primary' | 'secondary' | 'tertiary' | 'error' | 'success'
}

const colorMap = {
  primary: {
    icon: 'bg-primary/8 text-primary',
    text: 'text-primary',
  },
  secondary: {
    icon: 'bg-secondary/8 text-secondary',
    text: 'text-secondary',
  },
  tertiary: {
    icon: 'bg-tertiary/8 text-tertiary',
    text: 'text-tertiary',
  },
  error: {
    icon: 'bg-tertiary/8 text-tertiary',
    text: 'text-tertiary',
  },
  success: {
    icon: 'bg-success/8 text-success',
    text: 'text-success',
  },
}

function StatCard({
  className,
  variant,
  hoverable,
  label,
  value,
  unit,
  icon,
  trend,
  color = 'primary',
  ...props
}: StatCardProps) {
  const colors = colorMap[color]

  return (
    <div
      className={cn(statCardVariants({ variant, hoverable }), className)}
      {...props}
    >
      <div className="flex items-center gap-md">
        {icon && (
          <div
            className={cn(
              'flex h-12 w-12 shrink-0 items-center justify-center rounded-xl',
              colors.icon
            )}
          >
            {icon}
          </div>
        )}
        <div className="min-w-0 flex-1">
          <p className="truncate text-[11px] font-semibold uppercase tracking-wider text-on-surface-variant/60">
            {label}
          </p>
          <div className="mt-0.5 flex items-baseline gap-1">
            <span className={cn('font-display text-2xl italic', colors.text)}>
              {typeof value === 'number' ? value.toLocaleString('es-CR') : value}
            </span>
            {unit && (
              <span className="text-sm font-medium text-on-surface-variant">{unit}</span>
            )}
          </div>
          {trend && (
            <div
              className={cn(
                'mt-1 flex items-center gap-1 text-xs font-bold',
                trend.value > 0
                  ? 'text-success'
                  : trend.value < 0
                    ? 'text-tertiary'
                    : 'text-on-surface-variant'
              )}
            >
              {trend.value > 0 ? (
                <TrendingUp className="h-3 w-3" />
              ) : trend.value < 0 ? (
                <TrendingDown className="h-3 w-3" />
              ) : (
                <Minus className="h-3 w-3" />
              )}
              <span>
                {trend.value > 0 ? '+' : ''}
                {trend.value}%
              </span>
              {trend.label && (
                <span className="font-normal text-on-surface-variant">{trend.label}</span>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export { StatCard, statCardVariants }
export type { StatCardProps }
