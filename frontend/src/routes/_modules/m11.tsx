import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { VolunteerStats } from '@/modules/m11/components/volunteer-stats'
import { ProjectCard } from '@/modules/m11/components/project-card'
import { HoursLog } from '@/modules/m11/components/hours-log'
import {
  MOCK_M11_STATS,
  MOCK_PROJECTS,
  MOCK_VOLUNTEER_LOGS,
} from '@/modules/m11/data/mock-data'

export const Route = createFileRoute('/_modules/m11')({
  component: M11Page,
})

function M11Page() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestión de Voluntariado"
        subtitle="Administración de proyectos de voluntariado, inscripciones y registro de horas."
      />

      <VolunteerStats stats={MOCK_M11_STATS} />

      <section className="space-y-4">
        <h2 className="text-lg font-semibold tracking-tight">Proyectos</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {MOCK_PROJECTS.map((project) => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </div>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-semibold tracking-tight">
          Registro de Horas
        </h2>
        <HoursLog logs={MOCK_VOLUNTEER_LOGS} />
      </section>
    </div>
  )
}
