import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { MOCK_INCIDENTS, MOCK_M9_STATS } from '@/modules/m9/data/mock-data'
import { IncidentStats } from '@/modules/m9/components/incident-stats'
import { KanbanBoard } from '@/modules/m9/components/kanban-board'

export const Route = createFileRoute('/_modules/m9')({
  component: M9Page,
})

function M9Page() {
  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Operaciones Técnicas"
        subtitle="Control centralizado de incidencias y mantenimiento predial"
      />

      <IncidentStats stats={MOCK_M9_STATS} />

      <KanbanBoard incidents={MOCK_INCIDENTS} />
    </div>
  )
}
