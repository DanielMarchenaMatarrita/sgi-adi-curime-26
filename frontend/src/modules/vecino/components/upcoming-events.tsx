import { CalendarDays, MapPin, Clock, Users, Wrench, BookOpen, Building } from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import type { VecinoEvent } from '../types'

const eventTypeConfig: Record<
  VecinoEvent['type'],
  { color: string; icon: typeof Users; label: string }
> = {
  asamblea: { color: 'bg-primary/10 text-primary', icon: Users, label: 'Asamblea' },
  voluntariado: { color: 'bg-success/10 text-success', icon: Wrench, label: 'Voluntariado' },
  taller: { color: 'bg-info/10 text-info', icon: BookOpen, label: 'Taller' },
  comunitario: { color: 'bg-secondary/10 text-secondary', icon: Building, label: 'Comunitario' },
}

interface UpcomingEventsProps {
  events: VecinoEvent[]
}

export function UpcomingEvents({ events }: UpcomingEventsProps) {
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/8">
          <CalendarDays className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h3 className="font-display text-lg italic text-on-surface">Próximos Eventos</h3>
          <p className="text-xs text-on-surface-variant">Calendario comunitario</p>
        </div>
      </div>

      <div className="space-y-2">
        {events.map((event) => {
          const config = eventTypeConfig[event.type]
          const Icon = config.icon
          const eventDate = new Date(event.date)
          const day = eventDate.getDate()
          const month = eventDate.toLocaleDateString('es-CR', { month: 'short' }).toUpperCase()

          return (
            <div
              key={event.id}
              className="group flex items-start gap-3 rounded-xl border border-outline-variant/30 bg-surface-container-lowest p-3 transition-all duration-200 hover:border-primary/20 hover:shadow-sm"
            >
              <div className="flex h-12 w-12 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/8">
                <span className="text-[10px] font-bold text-primary/60">{month}</span>
                <span className="font-display text-lg italic leading-none text-primary">{day}</span>
              </div>

              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <h4 className="truncate text-sm font-bold text-on-surface">{event.title}</h4>
                  <span
                    className={cn(
                      'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold',
                      config.color
                    )}
                  >
                    <Icon className="h-2.5 w-2.5" />
                    {config.label}
                  </span>
                </div>
                <div className="mt-1 flex items-center gap-3 text-[11px] text-on-surface-variant">
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    {event.time}
                  </span>
                  <span className="flex items-center gap-1">
                    <MapPin className="h-3 w-3" />
                    {event.location}
                  </span>
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
