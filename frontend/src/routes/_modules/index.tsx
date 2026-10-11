import { useMemo } from 'react'
import { Link } from '@tanstack/react-router'
import { createFileRoute } from '@tanstack/react-router'
import {
  Users,
  Landmark,
  AlertTriangle,
  CalendarDays,
  TrendingUp,
  ArrowRight,
  Trees,
  ShieldCheck,
  Activity,
} from 'lucide-react'
import { useApp } from '@/shared/context/app-context'
import { cn } from '@/shared/lib/utils'
import { MODULE_SUMMARIES } from '@/shared/data/module-summaries'

function DashboardPage() {
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
  const activeAssemblies = MODULE_SUMMARIES.find(m => m.moduleId === 'm3')?.metrics[0]?.value ?? '—'

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
      label: 'Próxima Asamblea',
      value: activeAssemblies,
      icon: CalendarDays,
      color: 'text-amber',
      bg: 'bg-amber/8',
      change: '40% quórum',
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
            Tu ecosistema digital está operativo. 11 módulos activos, 1,248 miembros registrados
            y 99.8% de uptime este mes.
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

      {/* Quick Access */}
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {/* Recent Activity */}
        <div className="rounded-2xl border border-outline-variant/40 bg-surface-container-lowest p-5 animate-fade-in-up stagger-5">
          <h3 className="font-bold text-on-surface mb-4 flex items-center gap-2">
            <Activity className="h-4 w-4 text-primary" />
            Actividad Reciente
          </h3>
          <div className="space-y-3">
            {[
              { text: 'María Elena Vargas fue añadida al padrón digital', time: 'Hace 15 min', type: 'success' },
              { text: 'Acta #2026-047 requiere 2 firmas pendientes', time: 'Hace 1 hora', type: 'warning' },
              { text: 'Fuga de agua reportada en Salón Comunal', time: 'Hace 2 horas', type: 'error' },
              { text: 'Donación de ₡250,000 recibida de Don Carlos', time: 'Hace 3 horas', type: 'success' },
              { text: 'Reserva confirmada: Salón Comunal, 25 Jun', time: 'Hace 5 horas', type: 'info' },
            ].map((item, i) => (
              <div
                key={i}
                className="flex items-start gap-3 py-2 border-b border-outline-variant/20 last:border-0 last:pb-0"
              >
                <div className={cn(
                  'mt-1 w-2 h-2 rounded-full shrink-0',
                  item.type === 'success' ? 'bg-success' :
                    item.type === 'warning' ? 'bg-warning' :
                      item.type === 'error' ? 'bg-tertiary' : 'bg-info'
                )} />
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-on-surface leading-tight">{item.text}</p>
                  <p className="text-[11px] text-on-surface-variant/60 mt-0.5">{item.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* System Status */}
        <div className="rounded-2xl border border-outline-variant/40 bg-surface-container-lowest p-5 animate-fade-in-up stagger-6">
          <h3 className="font-bold text-on-surface mb-4 flex items-center gap-2">
            <ShieldCheck className="h-4 w-4 text-primary" />
            Estado del Sistema
          </h3>
          <div className="space-y-4">
            {[
              { label: 'Uptime del Ecosistema', value: '99.8%', bar: 99.8, color: 'bg-success' },
              { label: 'Módulos Operativos', value: '9/11', bar: 81.8, color: 'bg-primary' },
              { label: 'Sincronización de Datos', value: '100%', bar: 100, color: 'bg-success' },
              { label: 'Certificados Activos', value: '5/8', bar: 62.5, color: 'bg-warning' },
            ].map((item) => (
              <div key={item.label}>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-sm text-on-surface font-medium">{item.label}</span>
                  <span className="text-sm font-bold text-on-surface">{item.value}</span>
                </div>
                <div className="h-2 bg-surface-container-high rounded-full overflow-hidden">
                  <div
                    className={cn('h-full rounded-full transition-all duration-700 ease-out', item.color)}
                    style={{ width: `${item.bar}%` }}
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="mt-5 pt-4 border-t border-outline-variant/30">
            <Link
              to="/control-central"
              className="flex items-center justify-center gap-2 w-full py-2.5 rounded-xl bg-surface-container-high/50 text-sm font-semibold text-on-surface hover:bg-primary/10 hover:text-primary transition-all duration-200"
            >
              Abrir Panel de Control
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}

export const Route = createFileRoute('/_modules/')({
  component: DashboardPage,
})
