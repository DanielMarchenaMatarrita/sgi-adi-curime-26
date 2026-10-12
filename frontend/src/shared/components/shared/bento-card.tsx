import { type ReactNode } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/shared/lib/utils'

const bentoCardVariants = cva(
  'rounded-xl border border-outline-variant p-md transition-all duration-200',
  {
    variants: {
      variant: {
        solid: 'bg-surface-container-lowest',
        glass: 'bg-white/80 backdrop-blur-sm border-outline-variant/50',
        shadow: 'bg-surface-container-lowest shadow-[0px_4px_20px_rgba(30,41,59,0.05)]',
        flat: 'bg-surface-container-low',
      },
      hoverable: {
        true: 'hover:-translate-y-0.5 hover:shadow-[0px_4px_20px_rgba(30,41,59,0.1)] cursor-pointer',
        false: '',
      },
      accent: {
        none: '',
        primary: 'border-l-4 border-l-primary',
        secondary: 'border-l-4 border-l-secondary',
        tertiary: 'border-l-4 border-l-tertiary',
        success: 'border-l-4 border-l-emerald-500',
        danger: 'border-l-4 border-l-red-500',
      },
    },
    defaultVariants: {
      variant: 'solid',
      hoverable: false,
      accent: 'none',
    },
  }
)

interface BentoCardProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof bentoCardVariants> {
  header?: ReactNode
  footer?: ReactNode
}

function BentoCard({
  className,
  variant,
  hoverable,
  accent,
  header,
  footer,
  children,
  ...props
}: BentoCardProps) {
  return (
    <div
      className={cn(bentoCardVariants({ variant, hoverable, accent }), className)}
      {...props}
    >
      {header && (
        <div className="mb-sm border-b border-outline-variant/30 pb-sm">
          {header}
        </div>
      )}
      {children}
      {footer && (
        <div className="mt-sm border-t border-outline-variant/30 pt-sm">
          {footer}
        </div>
      )}
    </div>
  )
}

export { BentoCard, bentoCardVariants }
export type { BentoCardProps }
