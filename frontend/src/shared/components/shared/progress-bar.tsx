import { cn } from '@/shared/lib/utils'

interface ProgressBarProps {
  percent: number
  label?: string
  color?: 'primary' | 'secondary' | 'tertiary' | 'success' | 'warning' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  showPercent?: boolean
  className?: string
}

const colorMap = {
  primary: 'bg-primary',
  secondary: 'bg-secondary',
  tertiary: 'bg-tertiary',
  success: 'bg-emerald-500',
  warning: 'bg-amber-500',
  danger: 'bg-red-500',
}

const sizeMap = {
  sm: 'h-1',
  md: 'h-1.5',
  lg: 'h-2.5',
}

function ProgressBar({
  percent,
  label,
  color = 'primary',
  size = 'md',
  showPercent = false,
  className,
}: ProgressBarProps) {
  const clampedPercent = Math.max(0, Math.min(100, percent))

  return (
    <div className={cn('w-full', className)} role="group" aria-label={label ?? 'Progreso'}>
      <div
        className={cn('w-full overflow-hidden rounded-full bg-surface-container-high', sizeMap[size])}
        role="progressbar"
        aria-valuenow={clampedPercent}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={label ?? `Progreso: ${clampedPercent}%`}
      >
        <div
          className={cn('h-full rounded-full transition-all duration-500', colorMap[color])}
          style={{ width: `${clampedPercent}%` }}
        />
      </div>
      {(label || showPercent) && (
        <div className="mt-1 flex items-center justify-between">
          {label && (
            <p className="text-[10px] italic text-on-surface-variant">{label}</p>
          )}
          {showPercent && (
            <p className="text-[10px] font-bold text-on-surface-variant">{clampedPercent}%</p>
          )}
        </div>
      )}
    </div>
  )
}

export { ProgressBar }
export type { ProgressBarProps }
