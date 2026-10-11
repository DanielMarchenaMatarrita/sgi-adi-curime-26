import { FileText, AlertTriangle, Calendar, Shield } from 'lucide-react'
import { Link } from '@tanstack/react-router'
import { cn } from '@/shared/lib/utils'
import type { QuickAction } from '../types'

const iconMap: Record<string, typeof FileText> = {
  FileText,
  AlertTriangle,
  Calendar,
  Shield,
}

interface QuickActionsProps {
  actions: QuickAction[]
  className?: string
}

export function QuickActions({ actions, className }: QuickActionsProps) {
  return (
    <div className={cn('grid grid-cols-2 gap-3 sm:grid-cols-4', className)}>
      {actions.map((action) => {
        const Icon = iconMap[action.icon] ?? FileText
        return (
          <Link
            key={action.id}
            to={action.href}
            className="group flex flex-col items-center gap-2 rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 text-center transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-lg"
          >
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/8 text-primary transition-colors duration-200 group-hover:bg-primary group-hover:text-on-primary">
              <Icon className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs font-bold text-on-surface">{action.label}</p>
              <p className="mt-0.5 text-[10px] text-on-surface-variant">{action.description}</p>
            </div>
          </Link>
        )
      })}
    </div>
  )
}
