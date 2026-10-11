import { useMemo } from 'react'
import { Link } from '@tanstack/react-router'
import { createFileRoute } from '@tanstack/react-router'
import {
  ShieldCheck,
  Users,
  Landmark,
  AlertTriangle,
  CalendarDays,
  TrendingUp,
  ArrowRight,
  Trees,
  Activity,
  Vote,
  FileText,
  HeartHandshake,
  Package,
  Store,
  Handshake,
  Eye,
} from 'lucide-react'
import { useApp } from '@/shared/context/app-context'
import { cn } from '@/shared/lib/utils'
import { MODULES } from '@/shared/config/modules'
import { MODULE_SUMMARIES, getModulesByStatus } from '@/shared/data/module-summaries'
import { AuditMonitor } from '@/modules/control/components/audit-monitor'
import { MOCK_AUDIT_LOG } from '@/modules/control/data/mock-data'
import { CrossModuleLink } from '@/shared/components/shared'

const MODULE_ICONS: Record<string, typeof Users> = {
  m1: Users,
  m2: ShieldCheck,
  m3: Vote,
  m4: FileText,
  m5: Landmark,
  m6: HeartHandshake,
  m7: CalendarDays,
  m8: Package,
  m9: AlertTriangle,
  m10: Store,
  m11: Handshake,
}

const STATUS_COLORS = {
  healthy: 'bg-success/10 text-success border-success/20',
  warning: 'bg-warning/10 text-warning border-warning/20',
  critical: 'bg-tertiary/10 text-tertiary border-tertiary/20',
}

const STATUS_DOT = {
  healthy: 'bg-success',
  warning: 'bg-warning',
  critical: 'bg-tertiary',
}

function ControlCentralPage() {
  const { currentUser } = useApp()

  const greeting = useMemo(() => {
    const hour = new Date().getHours()
    if (hour < 12) return 'Buenos días'
    if (hour < 18) return 'Buenas tardes'
    return 'Buenas noches'
  }, [])

  const totalMembers = MODULE_SUMMARIES.find(m => m.moduleId === 'm1')?.metrics[0]?.value ?? 0
  const activeIncidents = MODULE_SUMMARIES.find(m => m.moduleId === 'm9')?.metrics[0]?.value ?? 0
  const treasury = MODULE_SUMMARIES.find(m => m.moduleId === 'm5')?.metrics[0]?.value ?? '—'
  const criticalModules = getModulesByStatus('critical')
  const warningModules = getModulesByStatus('warning')

  const kpis = [
    {
      label: 'Miembros Activos',
      value: totalMembers,
      icon: Users,
      color: 'text-primary',
      bg: 'bg-primary/8',
      change: '+12 este mes',
      changeUp: true,
    },
    {
      label: 'Saldo Tesorería',
      value: treasury,
      icon: Landmark,
      color: 'text-indigo',
      bg: 'bg-indigo/8',
      change: '+₡1.2M este mes',
      changeUp: true,
    },
    {
      label: 'Incidencias Abiertas',
      value: activeIncidents,
      icon: AlertTriangle,
      color: 'text-tertiary',
      bg: 'bg-tertiary/8',
      change: '2 críticas',
      changeUp: false,
    },
    {
      label: 'Módulos con Alerta',
      value: warningModules.length + criticalModules.length,
      icon: Eye,
      color: 'text-amber',
      bg: 'bg-amber/8',
      change: `${criticalModules.length} críticos`,
      changeUp: null,
    },
  ]

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Welcome Hero */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-primary p-8 text-white noise-overlay">
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-1">
            <Trees className="h-6 w-6 text-white/80" />
            <span className="text-xs font-bold uppercase tracking-[0.2em] text-white/60">
              SGI-CURIME
            </span>
          </div>
          <h1 className="font-display text-3xl md:text-4xl italic mt-3 mb-2">
            {greeting}, {currentUser?.name.split('.')[1]?.trim() || currentUser?.name}
          </h1>
          <p className="text-white/70 text-sm max-w-lg">
            Panel de gobernanza digital. Monitorea el estado de todos los módulos del ecosistema cooperativo.
          </p>
        </div>
        {/* Decorative circles */}
        <div className="absolute -right-20 -top-20 w-64 h-64 rounded-full bg-white/5" />
        <div className="absolute -right-8 -bottom-16 w-48 h-48 rounded-full bg-white/5" />
        <div className="absolute right-40 -top-10 w-24 h-24 rounded-full bg-white/5" />
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {kpis.map((kpi, i) => {
          const Icon = kpi.icon
          return (
            <div
              key={kpi.label}
              className={cn(
                'group relative rounded-2xl border border-outline-variant/50 bg-surface-container-lowest p-5',
                'transition-all duration-300 hover:shadow-lg hover:-translate-y-0.5 hover-lift',
                'animate-fade-in-up',
                `stagger-${i + 1}`
              )}
            >
              <div className="flex items-start justify-between mb-3">
                <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center', kpi.bg)}>
                  <Icon className={cn('h-5 w-5', kpi.color)} strokeWidth={2} />
                </div>
                {kpi.changeUp !== null && (
                  <div className={cn(
                    'flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full',
                    kpi.changeUp ? 'bg-success/10 text-success' : 'bg-tertiary/10 text-tertiary'
                  )}>
                    <TrendingUp className={cn('h-3 w-3', !kpi.changeUp && 'rotate-180')} />
                    {kpi.change}
                  </div>
                )}
              </div>
              <p className="text-[11px] font-semibold uppercase tracking-wider text-on-surface-variant/60 mb-1">
                {kpi.label}
              </p>
              <p className="text-2xl font-bold text-on-surface tracking-tight">
                {typeof kpi.value === 'number' ? kpi.value.toLocaleString('es-CR') : kpi.value}
              </p>
            </div>
          )
        })}
      </div>

      {/* Module Grid */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="font-display text-2xl italic text-on-surface">
              Módulos del Ecosistema
            </h2>
            <p className="text-sm text-on-surface-variant mt-0.5">
              Resumen del rendimiento de todos los módulos
            </p>
          </div>
          <div className="flex items-center gap-4 text-[10px]">
            <span className="flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-success" /> Operativo
            </span>
            <span className="flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-warning" /> Alerta
            </span>
            <span className="flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-tertiary" /> Crítico
            </span>
          </div>
        </div>

        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {MODULES.filter(m => m.id !== 'control').map((mod, i) => {
            const Icon = MODULE_ICONS[mod.id] || Activity
            const summary = MODULE_SUMMARIES.find(s => s.moduleId === mod.id)
            const status = summary?.status || 'healthy'

            return (
              <Link
                key={mod.id}
                to={mod.route}
                className={cn(
                  'group relative flex flex-col rounded-2xl border border-outline-variant/40 bg-surface-container-lowest p-4',
                  'transition-all duration-300 hover:shadow-lg hover:-translate-y-0.5 hover:border-primary/20',
                  'animate-fade-in-up',
                  `stagger-${Math.min(i + 1, 8)}`
                )}
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-3">
                  <div className="w-10 h-10 rounded-xl bg-primary/8 flex items-center justify-center group-hover:bg-primary/15 transition-colors duration-200">
                    <Icon className="h-5 w-5 text-primary" strokeWidth={1.8} />
                  </div>
                  <div className="flex items-center gap-1.5">
                    <div className={cn('w-2 h-2 rounded-full', STATUS_DOT[status])} />
                    <span className={cn(
                      'text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full border',
                      STATUS_COLORS[status]
                    )}>
                      {status === 'healthy' ? 'OK' : status === 'warning' ? 'Alerta' : 'Crítico'}
                    </span>
                  </div>
                </div>

                {/* Title */}
                <h3 className="text-sm font-bold text-on-surface mb-1 group-hover:text-primary transition-colors">
                  {mod.name}
                </h3>
                <p className="text-xs text-on-surface-variant line-clamp-2 mb-3 flex-1">
                  {mod.description}
                </p>

                {/* Metrics preview */}
                {summary && (
                  <div className="grid grid-cols-2 gap-2 pt-3 border-t border-outline-variant/30">
                    {summary.metrics.slice(0, 2).map((metric) => (
                      <div key={metric.label}>
                        <p className="text-[10px] text-on-surface-variant/60 font-medium uppercase tracking-wider">
                          {metric.label}
                        </p>
                        <p className="text-sm font-bold text-on-surface">
                          {typeof metric.value === 'number' ? metric.value.toLocaleString('es-CR') : metric.value}
                        </p>
                      </div>
                    ))}
                  </div>
                )}

                {/* Hover arrow */}
                <ArrowRight className="absolute right-4 top-1/2 -translate-y-1/2 h-4 w-4 text-on-surface-variant/0 group-hover:text-primary/60 transition-all duration-200 group-hover:translate-x-1" />
              </Link>
            )
          })}
        </div>
      </div>

      {/* Audit Monitor */}
      <div className="animate-fade-in-up stagger-5">
        <AuditMonitor entries={MOCK_AUDIT_LOG} />
      </div>

      {/* Cross-module links */}
      <div className="rounded-xl border border-outline-variant/30 bg-surface-container-lowest p-5 animate-fade-in-up stagger-6">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/8">
            <ShieldCheck className="h-4 w-4 text-primary" />
          </div>
          <div className="flex flex-wrap items-center gap-4">
            <span className="text-xs font-bold uppercase tracking-wider text-on-surface-variant">
              Módulos relacionados
            </span>
            <CrossModuleLink to="/m3" label="Asambleas" description="Control de asistencia" />
            <CrossModuleLink to="/m4" label="Actas Digitales" description="Firma y control de actas" />
            <CrossModuleLink to="/m5" label="Tesorería" description="Gestión financiera" />
            <CrossModuleLink to="/m9" label="Incidencias" description="Monitoreo de incidentes" />
          </div>
        </div>
      </div>
    </div>
  )
}

export const Route = createFileRoute('/_modules/control-central')({
  component: ControlCentralPage,
})
