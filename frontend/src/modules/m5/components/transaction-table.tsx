import { cn } from '@/shared/lib/utils'
import { Shield, Clock, XCircle } from 'lucide-react'
import type { Transaction, TransactionStatus } from '../types'

interface TransactionTableProps {
  transactions: Transaction[]
}

const statusConfig: Record<TransactionStatus, { label: string; icon: typeof Shield; className: string }> = {
  CIFRADO: {
    label: 'Cifrado',
    icon: Shield,
    className: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
  },
  PENDIENTE: {
    label: 'Pendiente',
    icon: Clock,
    className: 'bg-amber-50 text-amber-700 border border-amber-200',
  },
  ANULADO: {
    label: 'Anulado',
    icon: XCircle,
    className: 'bg-red-50 text-red-700 border border-red-200',
  },
}

function TransactionTable({ transactions }: TransactionTableProps) {
  return (
    <div className="rounded-xl border border-outline-variant bg-surface-container-lowest">
      <div className="border-b border-outline-variant px-md py-3">
        <h3 className="font-title-sm text-title-sm text-on-surface">
          Libro Mayor Digital
        </h3>
        <p className="text-xs text-on-surface-variant">
          Registro de transacciones con integridad criptográfica
        </p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead>
            <tr className="border-b border-outline-variant bg-surface-container-low">
              <th className="px-md py-3 text-xs font-medium uppercase tracking-wider text-on-surface-variant">
                Fecha
              </th>
              <th className="px-md py-3 text-xs font-medium uppercase tracking-wider text-on-surface-variant">
                Concepto
              </th>
              <th className="px-md py-3 text-xs font-medium uppercase tracking-wider text-on-surface-variant">
                Origen
              </th>
              <th className="px-md py-3 text-right text-xs font-medium uppercase tracking-wider text-on-surface-variant">
                Monto
              </th>
              <th className="px-md py-3 text-xs font-medium uppercase tracking-wider text-on-surface-variant">
                Hash
              </th>
              <th className="px-md py-3 text-xs font-medium uppercase tracking-wider text-on-surface-variant">
                Estado
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-outline-variant">
            {transactions.map((txn) => {
              const status = statusConfig[txn.status]
              const StatusIcon = status.icon

              return (
                <tr
                  key={txn.id}
                  className="transition-colors hover:bg-surface-container-low/50"
                >
                  <td className="whitespace-nowrap px-md py-3 text-on-surface-variant">
                    {new Date(txn.date).toLocaleDateString('es-CR', {
                      day: '2-digit',
                      month: 'short',
                      year: 'numeric',
                    })}
                  </td>
                  <td className="px-md py-3">
                    <div>
                      <p className="font-medium text-on-surface">{txn.concept}</p>
                      <p className="text-xs text-on-surface-variant">{txn.referenceCode}</p>
                    </div>
                  </td>
                  <td className="px-md py-3 text-on-surface-variant">{txn.origin}</td>
                  <td className="whitespace-nowrap px-md py-3 text-right font-mono font-bold">
                    <span
                      className={cn(
                        txn.type === 'INGRESO' ? 'text-emerald-600' : 'text-red-600'
                      )}
                    >
                      {txn.type === 'INGRESO' ? '+' : '-'}₡
                      {txn.amount.toLocaleString('es-CR')}
                    </span>
                  </td>
                  <td className="px-md py-3">
                    <code className="rounded bg-surface-container-high px-1.5 py-0.5 font-mono text-xs text-on-surface-variant">
                      {txn.auditHash}
                    </code>
                  </td>
                  <td className="px-md py-3">
                    <span
                      className={cn(
                        'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium',
                        status.className
                      )}
                    >
                      <StatusIcon className="h-3 w-3" />
                      {status.label}
                    </span>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {transactions.length === 0 && (
        <div className="p-8 text-center">
          <p className="text-sm text-on-surface-variant">
            No se encontraron transacciones registradas.
          </p>
        </div>
      )}
    </div>
  )
}

export { TransactionTable }
