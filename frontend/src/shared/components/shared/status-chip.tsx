import { type ReactNode } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/shared/lib/utils'

const statusChipVariants = cva(
  'inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider whitespace-nowrap',
  {
    variants: {
      variant: {
        primary:
          'border-primary/20 bg-primary/10 text-primary',
        secondary:
          'border-secondary/20 bg-secondary/10 text-secondary',
        tertiary:
          'border-tertiary/20 bg-tertiary/10 text-tertiary',
        success:
          'border-emerald-200 bg-emerald-50 text-emerald-700',
        warning:
          'border-amber-200 bg-amber-50 text-amber-700',
        info:
          'border-blue-200 bg-blue-50 text-blue-700',
        neutral:
          'border-outline-variant bg-surface-container-high text-on-surface-variant',
        danger:
          'border-red-200 bg-red-50 text-red-700',
      },
      size: {
        sm: 'px-1.5 py-0.5 text-[9px]',
        md: 'px-2 py-0.5 text-[10px]',
        lg: 'px-3 py-1 text-xs',
      },
      filled: {
        true: '',
        false: '',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
      filled: false,
    },
    compoundVariants: [
      {
        variant: 'primary',
        filled: true,
        className: 'border-primary bg-primary text-white',
      },
      {
        variant: 'secondary',
        filled: true,
        className: 'border-secondary bg-secondary text-white',
      },
      {
        variant: 'tertiary',
        filled: true,
        className: 'border-tertiary bg-tertiary text-white',
      },
      {
        variant: 'success',
        filled: true,
        className: 'border-emerald-600 bg-emerald-600 text-white',
      },
      {
        variant: 'warning',
        filled: true,
        className: 'border-amber-500 bg-amber-500 text-white',
      },
      {
        variant: 'info',
        filled: true,
        className: 'border-blue-600 bg-blue-600 text-white',
      },
      {
        variant: 'neutral',
        filled: true,
        className: 'border-surface-container-highest bg-surface-container-highest text-on-surface',
      },
      {
        variant: 'danger',
        filled: true,
        className: 'border-red-600 bg-red-600 text-white',
      },
    ],
  }
)

interface StatusChipProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof statusChipVariants> {
  icon?: ReactNode
  label: string
}

function StatusChip({
  className,
  variant,
  size,
  filled,
  icon,
  label,
  ...props
}: StatusChipProps) {
  return (
    <span
      className={cn(statusChipVariants({ variant, size, filled }), className)}
      {...props}
    >
      {icon}
      {label}
    </span>
  )
}

export { StatusChip, statusChipVariants }
export type { StatusChipProps }
