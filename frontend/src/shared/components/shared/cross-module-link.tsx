import { Link } from '@tanstack/react-router'
import { ArrowRight } from 'lucide-react'
import { cn } from '@/shared/lib/utils'

interface CrossModuleLinkProps {
  to: string
  label: string
  description?: string
  className?: string
}

export function CrossModuleLink({ to, label, description, className }: CrossModuleLinkProps) {
  return (
    <Link
      to={to}
      className={cn(
        'inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 transition-colors group',
        className
      )}
    >
      <span>{label}</span>
      {description && (
        <span className="text-xs text-on-surface-variant font-normal">· {description}</span>
      )}
      <ArrowRight className="h-3 w-3 group-hover:translate-x-0.5 transition-transform" />
    </Link>
  )
}
