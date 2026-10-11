import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { QuorumGauge } from '@/modules/m3/components/quorum-gauge'
import { AttendanceLog } from '@/modules/m3/components/attendance-log'
import { AssemblyStats } from '@/modules/m3/components/assembly-stats'
import {
  MOCK_ASSEMBLY,
  MOCK_ATTENDEES,
  MOCK_M3_STATS,
} from '@/modules/m3/data/mock-data'

function M3Page() {
  return (
    <div className="space-y-4">
      <PageHeader
        title="Control de Asambleas en Tiempo Real"
        subtitle="Registro biométrico y verificación de quorum para asambleas de asociados"
        badge={{ label: MOCK_ASSEMBLY.status === 'EN_CURSO' ? 'En Curso' : MOCK_ASSEMBLY.status, variant: 'primary' }}
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Asambleas' },
        ]}
        actions={[]}
      />

      <AssemblyStats stats={MOCK_M3_STATS} />

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-12">
        <div className="lg:col-span-4">
          <QuorumGauge stats={MOCK_M3_STATS} />
        </div>
        <div className="lg:col-span-8">
          <AttendanceLog attendees={MOCK_ATTENDEES} />
        </div>
      </div>
    </div>
  )
}

export const Route = createFileRoute('/_modules/m3')({
  component: M3Page,
})
