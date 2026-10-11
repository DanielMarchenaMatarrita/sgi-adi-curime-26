import { createFileRoute } from '@tanstack/react-router'
import { PageHeader, CrossModuleLink } from '@/shared/components/shared'
import {
  ProfileStatusCard,
  QuickActions,
  TransparencyDashboard,
  UpcomingEvents,
  MarketplaceCarousel,
} from '@/modules/vecino'
import {
  MOCK_VECINO_PROFILE,
  MOCK_QUICK_ACTIONS,
  MOCK_TRANSPARENCY,
  MOCK_EVENTS,
  MOCK_MARKETPLACE,
} from '@/modules/vecino/data/mock-data'

function VecinoPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Bienvenido, Vecino"
        subtitle="Portal ciudadano — Ecosistema Confiable"
        badge={{ label: 'Acceso Verificado', variant: 'primary' }}
        lastUpdated="Hace 5 minutos"
        breadcrumbs={[
          { label: 'Mi Comunidad' },
        ]}
      />

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
        <div className="lg:col-span-4 animate-fade-in-up stagger-1">
          <ProfileStatusCard profile={MOCK_VECINO_PROFILE} />
        </div>

        <div className="lg:col-span-8 animate-fade-in-up stagger-2">
          <QuickActions actions={MOCK_QUICK_ACTIONS} />
        </div>
      </div>

      <div className="animate-fade-in-up stagger-3">
        <TransparencyDashboard data={MOCK_TRANSPARENCY} />
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
        <div className="lg:col-span-5 animate-fade-in-up stagger-4">
          <UpcomingEvents events={MOCK_EVENTS} />
        </div>

        <div className="lg:col-span-7 animate-fade-in-up stagger-5">
          <MarketplaceCarousel products={MOCK_MARKETPLACE} />
        </div>
      </div>

      <div className="rounded-xl border border-outline-variant/30 bg-surface-container-lowest p-5 animate-fade-in-up stagger-6">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/8">
            <span className="text-sm">🔗</span>
          </div>
          <div className="flex flex-wrap items-center gap-4">
            <span className="text-xs font-bold uppercase tracking-wider text-on-surface-variant">
              Módulos relacionados
            </span>
            <CrossModuleLink to="/m1" label="Padrón Digital" description="Registro de miembros" />
            <CrossModuleLink to="/m5" label="Tesorería" description="Estado de cuentas" />
            <CrossModuleLink to="/m10" label="Marketplace" description="Directorio completo" />
            <CrossModuleLink to="/m9" label="Incidencias" description="Reportar problemas" />
          </div>
        </div>
      </div>
    </div>
  )
}

export const Route = createFileRoute('/_modules/vecino')({
  component: VecinoPage,
})
