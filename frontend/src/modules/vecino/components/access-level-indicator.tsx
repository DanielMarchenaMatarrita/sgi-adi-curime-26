import { ShieldCheck, Shield, UserCheck } from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import type { AccessLevel } from '../types'

const accessConfig: Record<AccessLevel, { label: string; color: string; icon: typeof ShieldCheck }> = {
  basico: {
    label: 'Básico',
    color: 'bg-secondary/10 text-secondary border-secondary/20',
    icon: UserCheck,
  },
  verificado: {
    label: 'Verificado',
    color: 'bg-primary/10 text-primary border-primary/20',
    icon: ShieldCheck,
  },
  vip: {
    label: 'VIP',
    color: 'bg-amber/10 text-amber border-amber/20',
    icon: Shield,
  },
}

interface AccessLevelIndicatorProps {
  level: AccessLevel
  className?: string
}

export function AccessLevelIndicator({ level, className }: AccessLevelIndicatorProps) {
  const config = accessConfig[level]
  const Icon = config.icon

  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-bold',
        config.color,
        className
      )}
    >
      <Icon className="h-3.5 w-3.5" />
      Acceso {config.label}
    </span>
  )
}
