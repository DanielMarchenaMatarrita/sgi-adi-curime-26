import { useState, useMemo, useCallback } from 'react'
import { FileDown, Save, Users, UserCheck, Clock, ShieldCheck, MapPin } from 'lucide-react'
import { createFileRoute } from '@tanstack/react-router'
import { PageHeader, StatCard, AuditTimeline, CrossModuleLink } from '@/shared/components/shared'
import type { AuditTimelineItem } from '@/shared/components/shared'
import { FilterCard } from '@/modules/m1/components/filter-card'
import { MembersTable } from '@/modules/m1/components/members-table'
import { RegionalCoverage } from '@/modules/m1/components/regional-coverage'
import { MOCK_MEMBERS, MOCK_AUDIT_ENTRIES, MOCK_KPI_DATA } from '@/modules/m1/data/mock-data'
import type { M1Filters } from '@/modules/m1/types'

function M1Page() {
  const [filters, setFilters] = useState<M1Filters>({
    ageRange: 'all',
    status: 'all',
    district: 'all',
    search: '',
  })

  const handleFilterChange = useCallback((partial: Partial<M1Filters>) => {
    setFilters((prev) => ({ ...prev, ...partial }))
  }, [])

  const filteredMembers = useMemo(() => {
    return MOCK_MEMBERS.filter((member) => {
      if (filters.ageRange !== 'all') {
        const today = new Date()
        const birth = new Date(member.dateOfBirth)
        let age = today.getFullYear() - birth.getFullYear()
        const monthDiff = today.getMonth() - birth.getMonth()
        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
          age--
        }
        switch (filters.ageRange) {
          case '18-30':
            if (age < 18 || age > 30) return false
            break
          case '31-50':
            if (age < 31 || age > 50) return false
            break
          case '50+':
            if (age < 50) return false
            break
        }
      }
      if (filters.status !== 'all' && member.status !== filters.status) return false
      if (filters.district !== 'all' && member.district !== filters.district) return false
      if (filters.search) {
        const q = filters.search.toLowerCase()
        const fullName = `${member.firstName} ${member.lastName}`.toLowerCase()
        if (!fullName.includes(q) && !member.documentNumber.toLowerCase().includes(q)) {
          return false
        }
      }
      return true
    })
  }, [filters])

  const auditItems: AuditTimelineItem[] = MOCK_AUDIT_ENTRIES.map((entry) => ({
    id: entry.id,
    timestamp: entry.timestamp,
    title: entry.action.replace(/_/g, ' '),
    description: entry.details,
    actor: entry.actor,
    uuid: entry.currentHash,
    type: entry.action.includes('REGISTRO')
      ? 'create'
      : entry.action.includes('ACTUALIZACION')
        ? 'update'
        : entry.action.includes('VALIDACION') || entry.action.includes('SINCRONIZACION')
          ? 'validate'
          : 'update',
  }))

  const pageActions = [
    {
      label: 'Exportar PDF',
      icon: <FileDown className="h-4 w-4" />,
      onClick: () => {},
      variant: 'outline' as const,
    },
    {
      label: 'Guardar Cambios',
      icon: <Save className="h-4 w-4" />,
      onClick: () => {},
      variant: 'default' as const,
    },
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        title="Padrón Digital Único"
        subtitle="Registro único de miembros de la asociación"
        badge={{ label: 'Base de Datos Sincronizada', variant: 'primary' }}
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Padrón Digital' },
        ]}
        actions={pageActions}
      />

      {/* KPI Stats Row */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 animate-fade-in-up stagger-1">
        <StatCard
          label="Total Miembros"
          value={MOCK_KPI_DATA.totalMembers}
          icon={<Users className="h-5 w-5" />}
          color="primary"
          variant="accent"
        />
        <StatCard
          label="Vigentes"
          value={MOCK_KPI_DATA.activeMembers}
          icon={<UserCheck className="h-5 w-5" />}
          color="success"
          trend={{ value: 3.2, label: 'vs mes anterior' }}
        />
        <StatCard
          label="Pendientes"
          value={MOCK_KPI_DATA.pendingMembers}
          icon={<Clock className="h-5 w-5" />}
          color="tertiary"
        />
        <StatCard
          label="Cobertura Electoral"
          value={`${MOCK_KPI_DATA.electoralCoverage}%`}
          icon={<ShieldCheck className="h-5 w-5" />}
          color="success"
          trend={{ value: 1.8 }}
        />
      </div>

      {/* Filters */}
      <FilterCard filters={filters} onFilterChange={handleFilterChange} />

      {/* Members Table */}
      <MembersTable data={filteredMembers} />

      {/* Bottom Grid: Audit + Coverage */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
        <div className="lg:col-span-5">
          <div className="rounded-xl border border-outline-variant/30 bg-surface-container-lowest p-5">
            <div className="mb-4">
              <div className="flex items-center gap-2 mb-1">
                <div className="h-2 w-2 rounded-full bg-primary animate-pulse-soft" />
                <h3 className="text-sm font-bold uppercase tracking-wider text-on-surface">
                  Auditoría en Vivo
                </h3>
              </div>
              <p className="text-xs text-on-surface-variant">
                Rastreo de integridad de datos por UUID
              </p>
            </div>
            <AuditTimeline items={auditItems} variant="dot" />
          </div>
        </div>
        <div className="lg:col-span-7">
          <RegionalCoverage />
        </div>
      </div>

      {/* Cross-module links */}
      <div className="rounded-xl border border-outline-variant/30 bg-surface-container-lowest p-5">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/8">
            <MapPin className="h-4 w-4 text-primary" />
          </div>
          <div className="flex flex-wrap items-center gap-4">
            <span className="text-xs font-bold uppercase tracking-wider text-on-surface-variant">
              Módulos relacionados
            </span>
            <CrossModuleLink to="/m2" label="Identidad Digital" description="Credenciales de miembros" />
            <CrossModuleLink to="/m3" label="Asambleas" description="Control de asistencia" />
            <CrossModuleLink to="/m5" label="Tesorería" description="Cuotas de miembros" />
          </div>
        </div>
      </div>
    </div>
  )
}

export const Route = createFileRoute('/_modules/m1')({
  component: M1Page,
})
