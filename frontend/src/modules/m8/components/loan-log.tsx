import { StatusChip } from '@/shared/components/shared/status-chip'
import type { Loan, LoanStatus } from '../types'

const loanStatusConfig: Record<LoanStatus, { variant: 'success' | 'info' | 'danger'; label: string }> = {
  ACTIVO: { variant: 'info', label: 'Activo' },
  DEVUELTO: { variant: 'success', label: 'Devuelto' },
  VENCIDO: { variant: 'danger', label: 'Vencido' },
}

interface LoanLogProps {
  loans: Loan[]
}

function LoanLog({ loans }: LoanLogProps) {
  return (
    <div className="rounded-xl border border-outline-variant bg-surface-container-lowest">
      <div className="border-b border-outline-variant px-md py-3">
        <h3 className="font-title-md text-title-md font-semibold text-on-surface">
          Registro de Préstamos Recientes
        </h3>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-outline-variant bg-surface-container">
              <th className="px-md py-2.5 text-left text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
                Código Activo
              </th>
              <th className="px-md py-2.5 text-left text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
                Responsable
              </th>
              <th className="px-md py-2.5 text-left text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
                Fecha Préstamo
              </th>
              <th className="px-md py-2.5 text-left text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
                Estado
              </th>
              <th className="px-md py-2.5 text-left text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
                ID Encriptado
              </th>
            </tr>
          </thead>
          <tbody>
            {loans.map((loan) => {
              const status = loanStatusConfig[loan.status]
              return (
                <tr key={loan.id} className="border-b border-outline-variant last:border-b-0 hover:bg-surface-container-low">
                  <td className="px-md py-3 text-sm font-medium text-on-surface">{loan.assetCode}</td>
                  <td className="px-md py-3 text-sm text-on-surface">{loan.borrower}</td>
                  <td className="px-md py-3 text-sm text-on-surface-variant">{loan.loanDate}</td>
                  <td className="px-md py-3">
                    <StatusChip variant={status.variant} label={status.label} size="sm" />
                  </td>
                  <td className="px-md py-3 font-mono text-xs text-on-surface-variant">{loan.encryptedId}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}

export { LoanLog }
