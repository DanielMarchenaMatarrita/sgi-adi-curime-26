import type { Incident, IncidentStatus } from '../types'
import { IncidentCard } from './incident-card'

const COLUMNS: { key: IncidentStatus; label: string; dotColor: string }[] = [
  { key: 'PENDIENTE', label: 'Pendiente', dotColor: 'bg-slate-400' },
  { key: 'EN_REVISION', label: 'En Revisión', dotColor: 'bg-blue-500' },
  { key: 'APROBADO', label: 'Aprobado', dotColor: 'bg-amber-500' },
  { key: 'RESUELTO', label: 'Resuelto', dotColor: 'bg-green-500' },
]

export function KanbanBoard({ incidents }: { incidents: Incident[] }) {
  return (
    <div className="grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-4">
      {COLUMNS.map((col) => {
        const columnIncidents = incidents.filter((i) => i.status === col.key)

        return (
          <div key={col.key} className="flex flex-col rounded-xl bg-slate-50 p-3">
            <div className="mb-3 flex items-center justify-between px-1">
              <div className="flex items-center gap-2">
                <span className={`inline-block h-2.5 w-2.5 rounded-full ${col.dotColor}`} />
                <h3 className="text-sm font-semibold text-slate-700">{col.label}</h3>
              </div>
              <span className="rounded-full bg-slate-200 px-2 py-0.5 text-xs font-medium text-slate-600">
                {columnIncidents.length}
              </span>
            </div>

            <div className="flex flex-1 flex-col gap-3">
              {columnIncidents.map((incident) => (
                <IncidentCard key={incident.id} incident={incident} />
              ))}
              {columnIncidents.length === 0 && (
                <p className="py-8 text-center text-xs text-slate-400">Sin incidencias</p>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
