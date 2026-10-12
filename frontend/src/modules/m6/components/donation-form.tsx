import { useState } from 'react'
import { Coins, User, FileText, Building2, ToggleLeft, ToggleRight } from 'lucide-react'
import type { Donation, DonationType } from '../types'

interface DonationFormProps {
  initialData: Donation
}

export function DonationForm({ initialData }: DonationFormProps) {
  const [donationType, setDonationType] = useState<DonationType>(initialData.type)

  const toggleType = () => {
    setDonationType((prev) => (prev === 'MONETARIA' ? 'EN_ESPECIE' : 'MONETARIA'))
  }

  return (
    <div className="rounded-xl border border-border bg-card p-6 shadow-sm">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
          <Coins className="h-5 w-5 text-primary" />
        </div>
        <div>
          <h3 className="font-heading text-base font-semibold text-foreground">
            Datos de la Donación
          </h3>
          <p className="text-xs text-muted-foreground">Información del donante y monto</p>
        </div>
      </div>

      <div className="space-y-4">
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm font-medium text-foreground">
            <User className="h-4 w-4 text-muted-foreground" />
            Nombre del Donante
          </label>
          <input
            type="text"
            defaultValue={initialData.donorName}
            className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-foreground">Cédula / NIT</label>
            <input
              type="text"
              defaultValue={initialData.taxId}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-foreground">Fecha</label>
            <input
              type="date"
              defaultValue={initialData.date}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
            />
          </div>
        </div>

        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm font-medium text-foreground">
            <FileText className="h-4 w-4 text-muted-foreground" />
            Concepto
          </label>
          <textarea
            defaultValue={initialData.concept}
            rows={2}
            className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary resize-none"
          />
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium text-foreground">Tipo de Donación</label>
          <button
            type="button"
            onClick={toggleType}
            className="flex items-center gap-2 rounded-lg border border-border bg-background px-3 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            {donationType === 'MONETARIA' ? (
              <ToggleRight className="h-5 w-5 text-primary" />
            ) : (
              <ToggleLeft className="h-5 w-5 text-muted-foreground" />
            )}
            {donationType === 'MONETARIA' ? 'Monetaria' : 'En Especie'}
          </button>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-foreground">Monto (₡)</label>
            <input
              type="number"
              defaultValue={initialData.amount}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
            />
          </div>
          <div className="space-y-2">
            <label className="flex items-center gap-2 text-sm font-medium text-foreground">
              <Building2 className="h-4 w-4 text-muted-foreground" />
              Cuenta Tesorería
            </label>
            <select
              defaultValue={initialData.treasuryAccount}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm text-foreground focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
            >
              <option value="CTA-2026-001">CTA-2026-001 — Fondos Generales</option>
              <option value="CTA-2026-002">CTA-2026-002 — Proyectos Especiales</option>
              <option value="CTA-2026-003">CTA-2026-003 — Fondo de Reserva</option>
            </select>
          </div>
        </div>
      </div>
    </div>
  )
}
