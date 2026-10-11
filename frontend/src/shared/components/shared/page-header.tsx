import { type ReactNode } from 'react'
import { cn } from '@/shared/lib/utils'
import { ChevronRight } from 'lucide-react'
import { Button } from '@/shared/components/ui/button'

interface BreadcrumbItem {
  label: string
  href?: string
}

interface PageHeaderAction {
  label: string
  icon?: ReactNode
  variant?: 'default' | 'outline' | 'ghost'
  onClick?: () => void
  href?: string
}

interface PageHeaderProps {
  title: string
  subtitle?: string
  badge?: {
    label: string
    icon?: ReactNode
    variant?: 'primary' | 'success' | 'warning' | 'info'
  }
  lastUpdated?: string
  breadcrumbs?: BreadcrumbItem[]
  actions?: PageHeaderAction[]
  children?: ReactNode
  className?: string
}

const badgeColorMap = {
  primary: 'bg-primary/10 text-primary border-primary/15',
  success: 'bg-success/10 text-success border-success/15',
  warning: 'bg-warning/10 text-warning border-warning/15',
  info: 'bg-info/10 text-info border-info/15',
}

function PageHeader({
  title,
  subtitle,
  badge,
  lastUpdated,
  breadcrumbs,
  actions,
  children,
  className,
}: PageHeaderProps) {
  return (
    <div className={cn('mb-lg animate-fade-in', className)}>
      {breadcrumbs && breadcrumbs.length > 0 && (
        <nav className="mb-sm flex items-center gap-2 text-sm text-on-surface-variant" aria-label="Migas de pan">
          {breadcrumbs.map((crumb, i) => (
            <span key={i} className="flex items-center gap-2">
              {i > 0 && <ChevronRight className="h-3.5 w-3.5 text-outline-variant" />}
              {crumb.href ? (
                <a
                  href={crumb.href}
                  className="hover:text-primary transition-colors duration-150"
                >
                  {crumb.label}
                </a>
              ) : (
                <span
                  className={cn(
                    i === breadcrumbs.length - 1
                      ? 'font-bold text-primary'
                      : 'font-medium'
                  )}
                >
                  {crumb.label}
                </span>
              )}
            </span>
          ))}
        </nav>
      )}

      <div className="flex flex-col gap-md md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="font-display text-2xl md:text-3xl italic text-on-surface tracking-tight">
            {title}
          </h1>
          <div className="mt-1.5 flex items-center gap-sm flex-wrap">
            {badge && (
              <span
                className={cn(
                  'inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-bold border',
                  badgeColorMap[badge.variant || 'primary']
                )}
              >
                {badge.icon}
                {badge.label}
              </span>
            )}
            {lastUpdated && (
              <span className="text-xs text-on-surface-variant/60">
                Últ. actualización: {lastUpdated}
              </span>
            )}
            {subtitle && !lastUpdated && (
              <span className="text-sm text-on-surface-variant">{subtitle}</span>
            )}
          </div>
        </div>

        {(actions && actions.length > 0) || children ? (
          <div className="flex items-center gap-sm">
            {children}
            {actions?.map((action, i) => (
              <Button
                key={i}
                variant={action.variant || 'outline'}
                size="sm"
                onClick={action.onClick}
                className="gap-2 rounded-xl transition-all duration-200 hover:shadow-md"
              >
                {action.icon}
                {action.label}
              </Button>
            ))}
          </div>
        ) : null}
      </div>
    </div>
  )
}

export { PageHeader }
export type { PageHeaderProps, PageHeaderAction, BreadcrumbItem }
