import { QrCode, Stamp, CheckCircle, Clock, XCircle } from 'lucide-react'
import type { Donation, ReceiptStatus } from '../types'

interface ReceiptPreviewProps {
  receipt: {
    number: string
    issuedDate: string
    issuedBy: string
    validUntil: string
    digitalSignature: string
  }
  donation: Donation
}

const STATUS_CONFIG: Record<ReceiptStatus, { icon: typeof CheckCircle; label: string; color: string }> = {
  VALIDADO: { icon: CheckCircle, label: 'Validado', color: 'text-emerald-600 bg-emerald-50' },
  PENDIENTE: { icon: Clock, label: 'Pendiente', color: 'text-amber-600 bg-amber-50' },
  ANULADO: { icon: XCircle, label: 'Anulado', color: 'text-red-600 bg-red-50' },
}

export function ReceiptPreview({ receipt, donation }: ReceiptPreviewProps) {
  const statusConfig = STATUS_CONFIG[donation.status]
  const StatusIcon = statusConfig.icon

  return (
    <div className="rounded-xl border border-border bg-card p-6 shadow-sm">
      <div className="mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
            <Stamp className="h-5 w-5 text-primary" />
          </div>
          <div>
            <h3 className="font-heading text-base font-semibold text-foreground">
              Vista Previa del Comprobante
            </h3>
            <p className="text-xs text-muted-foreground">Comprobante de donación oficial</p>
          </div>
        </div>
        <span
          className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium ${statusConfig.color}`}
        >
          <StatusIcon className="h-3.5 w-3.5" />
          {statusConfig.label}
        </span>
      </div>

      <div className="overflow-hidden rounded-lg border border-border">
        <div className="border-b border-border bg-primary/5 px-5 py-3">
          <p className="text-center font-heading text-sm font-bold tracking-wide text-primary">
            COMPROBANTE DE DONACIÓN
          </p>
          <p className="text-center text-xs text-muted-foreground">N.° {receipt.number}</p>
        </div>

        <div className="space-y-3 px-5 py-4">
          <div className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <p className="text-xs text-muted-foreground">Donante</p>
              <p className="font-medium text-foreground">{donation.donorName}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Cédula / NIT</p>
              <p className="font-medium text-foreground">{donation.taxId}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Fecha de Emisión</p>
              <p className="font-medium text-foreground">{receipt.issuedDate}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Válido Hasta</p>
              <p className="font-medium text-foreground">{receipt.validUntil}</p>
            </div>
          </div>

          <div className="border-t border-border pt-3">
            <p className="text-xs text-muted-foreground">Concepto</p>
            <p className="text-sm text-foreground">{donation.concept}</p>
          </div>

          <div className="flex items-center justify-between border-t border-border pt-3">
            <div>
              <p className="text-xs text-muted-foreground">Monto</p>
              <p className="font-heading text-lg font-bold text-primary">
                ₡{donation.amount.toLocaleString('es-CR')}
              </p>
            </div>
            <div className="flex h-16 w-16 items-center justify-center rounded-lg border border-dashed border-border bg-muted/50">
              <QrCode className="h-10 w-10 text-muted-foreground/50" />
            </div>
          </div>
        </div>

        <div className="border-t border-border bg-muted/30 px-5 py-2">
          <p className="text-center text-[10px] text-muted-foreground">
            Emitido por: {receipt.issuedBy} · Firma: {receipt.digitalSignature}
          </p>
        </div>
      </div>
    </div>
  )
}
