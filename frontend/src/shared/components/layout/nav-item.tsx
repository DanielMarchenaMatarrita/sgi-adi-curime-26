import { Link, useMatchRoute } from '@tanstack/react-router'
import {
  LayoutDashboard,
  Users,
  ShieldCheck,
  Vote,
  FileText,
  Landmark,
  HeartHandshake,
  CalendarDays,
  Package,
  AlertTriangle,
  Store,
  Handshake,
  Activity,
  type LucideIcon,
} from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import type { NavItem as NavItemType } from '@/shared/types/nav'

const ICON_MAP: Record<string, LucideIcon> = {
  badge: Users,
  shield: ShieldCheck,
  groups: Vote,
  description: FileText,
  account_balance: Landmark,
  volunteer_activism: HeartHandshake,
  event: CalendarDays,
  inventory_2: Package,
  report_problem: AlertTriangle,
  store: Store,
  handshake: Handshake,
  monitoring: Activity,
}

interface NavItemProps {
  item: NavItemType
  collapsed?: boolean
  staggerIndex?: number
}

export function NavItem({ item, collapsed = false, staggerIndex = 0 }: NavItemProps) {
  const matchRoute = useMatchRoute()
  const isActive = matchRoute({ to: item.path, fuzzy: true })
  const Icon = ICON_MAP[item.icon] || LayoutDashboard

  return (
    <Link
      to={item.path}
      className={cn(
        'group relative flex items-center gap-3 rounded-xl transition-all duration-200',
        collapsed ? 'justify-center px-2 py-2.5' : 'px-3 py-2',
        'animate-fade-in-up',
        `stagger-${Math.min(staggerIndex + 1, 8)}`,
        isActive
          ? 'bg-primary/10 text-primary'
          : 'text-on-surface-variant hover:bg-surface-container-high/70 hover:text-on-surface'
      )}
    >
      {/* Active indicator bar */}
      {isActive && (
        <div className="absolute left-0 top-1/2 -translate-y-1/2 w-[3px] h-[60%] bg-primary rounded-r-full" />
      )}

      <Icon
        className={cn(
          'h-[18px] w-[18px] shrink-0 transition-all duration-200',
          isActive ? 'text-primary' : 'text-on-surface-variant group-hover:text-on-surface',
          isActive && 'drop-shadow-[0_0_6px_rgba(10,124,87,0.3)]'
        )}
        strokeWidth={isActive ? 2.2 : 1.8}
      />

      {!collapsed && (
        <span
          className={cn(
            'truncate text-[13px] transition-all duration-200',
            isActive ? 'font-semibold' : 'font-medium'
          )}
        >
          {item.label}
        </span>
      )}

      {/* Hover shine effect */}
      {!isActive && (
        <div className="absolute inset-0 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity duration-300 bg-gradient-to-r from-transparent via-white/40 to-transparent pointer-events-none" />
      )}
    </Link>
  )
}
