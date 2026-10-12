import { useState, useMemo } from 'react'
import { Calculator } from 'lucide-react'
import type { EventType } from '../types'

const EVENT_LABELS: Record<EventType, string> = {
  FAMILIAR: 'Familiar',
  COMUNITARIO: 'Comunitario',
  COMERCIAL: 'Comercial',
}

const BASE_RATES: Record<EventType, number> = {
  FAMILIAR: 1500,
  COMUNITARIO: 1000,
  COMERCIAL: 3000,
}

const CLEANING_FEE = 2000

export function FeeCalculator() {
  const [eventType, setEventType] = useState<EventType>('FAMILIAR')
  const [hours, setHours] = useState(4)

  const calculation = useMemo(() => {
    const baseFee = BASE_RATES[eventType] * hours
    return {
      baseFee,
      cleaningFee: CLEANING_FEE,
      total: baseFee + CLEANING_FEE,
      eventType,
      hours,
    }
  }, [eventType, hours])

  return (
    <div className="rounded-xl border border-border bg-card p-5">
      <div className="mb-4 flex items-center gap-2">
        <Calculator className="h-5 w-5 text-primary" />
        <h3 className="text-sm font-semibold text-foreground">Calculadora de Tarifas</h3>
      </div>

      <div className="space-y-4">
        <div>
          <label className="mb-1 block text-xs font-medium text-muted-foreground">
            Tipo de Evento
          </label>
          <div className="flex gap-2">
            {(Object.keys(EVENT_LABELS) as EventType[]).map((et) => (
              <button
                key={et}
                onClick={() => setEventType(et)}
                className={`flex-1 rounded-lg border px-3 py-2 text-xs font-medium transition-colors ${
                  eventType === et
                    ? 'border-primary bg-primary/10 text-primary'
                    : 'border-border text-muted-foreground hover:bg-muted'
                }`}
              >
                {EVENT_LABELS[et]}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="mb-1 block text-xs font-medium text-muted-foreground">
            Horas
          </label>
          <input
            type="number"
            min={1}
            max={12}
            value={hours}
            onChange={(e) => setHours(Math.max(1, Number(e.target.value)))}
            className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground outline-none focus:border-primary focus:ring-1 focus:ring-primary"
          />
        </div>

        <div className="space-y-2 rounded-lg bg-muted/50 p-3">
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">
              Tarifa base ({EVENT_LABELS[eventType]} × {hours}h)
            </span>
            <span className="font-medium text-foreground">
              ₡{calculation.baseFee.toLocaleString('es-CR')}
            </span>
          </div>
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">Limpieza</span>
            <span className="font-medium text-foreground">
              ₡{calculation.cleaningFee.toLocaleString('es-CR')}
            </span>
          </div>
          <div className="border-t border-border pt-2">
            <div className="flex items-center justify-between text-sm font-semibold">
              <span className="text-foreground">Total</span>
              <span className="text-primary">
                ₡{calculation.total.toLocaleString('es-CR')}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
