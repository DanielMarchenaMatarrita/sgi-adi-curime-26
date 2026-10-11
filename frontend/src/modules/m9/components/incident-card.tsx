import { MapPin, User } from 'lucide-react'
import type { Incident } from '../types'

const PRIORITY_STYLES: Record<string, string> = {
  ALTA: 'bg-red-100 text-red-700',
  MEDIA: 'bg-amber-100 text-amber-700',
  BAJA: 'bg-green-100 text-green-700',
}

const STATUS_DOT: Record<string, string> = {
  PENDIENTE: 'bg-slate-400',
  EN_REVISION: 'bg-blue-500',
  APROBADO: 'bg-amber-500',
  RESUELTO: 'bg-green-500',
}

export function IncidentCard({ incident }: { incident: Incident }) {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm transition-shadow hover:shadow-md">
      <div className="mb-2 flex items-center justify-between">
        <span className="font-mono text-xs font-semibold text-slate-500">{incident.ticketId}</span>
        <span className="flex items-center gap-1.5 text-xs">
          <span className={`inline-block h-2 w-2 rounded-full ${STATUS_DOT[incident.status]}`} />
          {incident.priority}
        </span>
      </div>

      <h4 className="mb-1 text-sm font-semibold text-slate-800">{incident.title}</h4>
      <p className="mb-3 line-clamp-2 text-xs leading-relaxed text-slate-500">{incident.description}</p>

      <div className="flex flex-col gap-1 text-xs text-slate-500">
        <span className="flex items-center gap-1.5">
          <MapPin className="h-3.5 w-3.5 text-slate-400" />
          {incident.location}
        </span>
        <span className="flex items-center gap-1.5">
          <User className="h-3.5 w-3.5 text-slate-400" />
          {incident.reportedBy}
        </span>
      </div>

      <div className="mt-3 border-t border-slate-100 pt-2">
        <span className={`inline-block rounded-full px-2 py-0.5 text-[10px] font-semibold ${PRIORITY_STYLES[incident.priority]}`}>
          Prioridad: {incident.priority}
        </span>
      </div>
    </div>
  )
}
