import { useState } from 'react'
import { createFileRoute } from '@tanstack/react-router'
import { CalendarDays, Landmark } from 'lucide-react'
import { PageHeader } from '@/shared/components/shared'
import { CalendarGrid } from '@/modules/m7/components/calendar-grid'
import { FeeCalculator } from '@/modules/m7/components/fee-calculator'
import { UpcomingReservations } from '@/modules/m7/components/upcoming-reservations'
import type { FacilityType } from '@/modules/m7/types'

export const Route = createFileRoute('/_modules/m7')({
  component: M7Page,
})

const FACILITY_OPTIONS: { value: FacilityType; label: string }[] = [
  { value: 'SALON', label: 'Salón Comunal' },
  { value: 'CANCHA', label: 'Cancha Multiuso' },
]

function M7Page() {
  const [selectedFacility, setSelectedFacility] = useState<FacilityType>('SALON')

  return (
    <div className="space-y-6">
      <PageHeader
        title="Reservas en Línea"
        subtitle="Gestione la reserva de instalaciones comunitarias"
      />

      <div className="flex items-center gap-2">
        <Landmark className="h-4 w-4 text-muted-foreground" />
        <label className="text-sm font-medium text-foreground">Instalación:</label>
        <div className="flex gap-2">
          {FACILITY_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => setSelectedFacility(opt.value)}
              className={`rounded-lg border px-3 py-1.5 text-xs font-medium transition-colors ${
                selectedFacility === opt.value
                  ? 'border-primary bg-primary/10 text-primary'
                  : 'border-border text-muted-foreground hover:bg-muted'
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-[1fr_320px]">
        <div className="space-y-6">
          <div className="flex items-center gap-2">
            <CalendarDays className="h-5 w-5 text-primary" />
            <h2 className="text-sm font-semibold text-foreground">Calendario</h2>
          </div>
          <CalendarGrid />
          <UpcomingReservations />
        </div>

        <div>
          <FeeCalculator />
        </div>
      </div>
    </div>
  )
}
