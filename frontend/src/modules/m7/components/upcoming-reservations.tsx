import { Clock, MapPin, User } from 'lucide-react'
import { MOCK_RESERVATIONS } from '../data/mock-data'
import type { ReservationStatus } from '../types'

const STATUS_STYLES: Record<ReservationStatus, { label: string; className: string }> = {
  CONFIRMADO: {
    label: 'Confirmado',
    className: 'bg-emerald-100 text-emerald-700',
  },
  EN_REVISION: {
    label: 'En Revisión',
    className: 'bg-amber-100 text-amber-700',
  },
  CANCELADO: {
    label: 'Cancelado',
    className: 'bg-red-100 text-red-700',
  },
}

const FACILITY_LABELS: Record<string, string> = {
  SALON: 'Salón Comunal',
  CANCHA: 'Cancha Multiuso',
}

export function UpcomingReservations() {
  const sorted = [...MOCK_RESERVATIONS].sort(
    (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
  )

  return (
    <div className="rounded-xl border border-border bg-card p-5">
      <h3 className="mb-4 text-sm font-semibold text-foreground">Próximas Reservas</h3>

      <div className="space-y-3">
        {sorted.map((r) => {
          const st = STATUS_STYLES[r.status]
          const formattedDate = new Date(r.date + 'T12:00:00').toLocaleDateString('es-ES', {
            day: 'numeric',
            month: 'short',
          })

          return (
            <div
              key={r.id}
              className="flex items-start justify-between gap-3 rounded-lg border border-border p-3 transition-colors hover:bg-muted/50"
            >
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium text-foreground">{r.event_name}</p>
                <div className="mt-1 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
                  <span className="flex items-center gap-1">
                    <MapPin className="h-3 w-3" />
                    {FACILITY_LABELS[r.facility]}
                  </span>
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    {r.startTime} – {r.endTime}
                  </span>
                  <span className="flex items-center gap-1">
                    <User className="h-3 w-3" />
                    {r.organizer}
                  </span>
                </div>
              </div>

              <div className="flex shrink-0 flex-col items-end gap-1">
                <span className="text-xs text-muted-foreground">{formattedDate}</span>
                <span className={`rounded-full px-2 py-0.5 text-[10px] font-semibold ${st.className}`}>
                  {st.label}
                </span>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
