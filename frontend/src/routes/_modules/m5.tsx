import { createFileRoute } from '@tanstack/react-router'
import { DollarSign, FileDown } from 'lucide-react'
import { PageHeader, CrossModuleLink } from '@/shared/components/shared'
import { FinancialSummary } from '@/modules/m5/components/financial-summary'
import { TransactionTable } from '@/modules/m5/components/transaction-table'
import { MOCK_TRANSACTIONS, MOCK_M5_STATS } from '@/modules/m5/data/mock-data'

function M5Page() {
  const pageActions = [
    {
      label: 'Exportar PDF',
      icon: <FileDown className="h-4 w-4" />,
      onClick: () => {},
      variant: 'outline' as const,
    },
  ]

  return (
    <div className="space-y-4">
      <PageHeader
        title="Gestión de Tesorería"
        subtitle="Control financiero y libro mayor digital con integridad criptográfica"
        badge={{
          label: `Saldo: ₡${MOCK_M5_STATS.consolidatedBalance.toLocaleString('es-CR')}`,
          icon: <DollarSign className="h-3 w-3" />,
          variant: 'success',
        }}
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Tesorería y Libro Mayor' },
        ]}
        actions={pageActions}
      />

      <FinancialSummary stats={MOCK_M5_STATS} />

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-12">
        <div className="lg:col-span-8">
          <TransactionTable transactions={MOCK_TRANSACTIONS} />
        </div>

        <div className="space-y-4 lg:col-span-4">
          <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-md">
            <h3 className="font-title-sm text-title-sm text-on-surface">
              Resumen de Caja
            </h3>
            <div className="mt-3 space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-on-surface-variant">Caja Chica</span>
                <span className="font-bold text-on-surface">
                  ₡{MOCK_M5_STATS.pettyCash.toLocaleString('es-CR')}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-on-surface-variant">Compromisos Pendientes</span>
                <span className="font-bold text-amber-600">
                  {MOCK_M5_STATS.pendingCommitments}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-on-surface-variant">Proyectos Activos</span>
                <span className="font-bold text-emerald-600">
                  {MOCK_M5_STATS.activeProjects}
                </span>
              </div>
            </div>
          </div>

          <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-md">
            <h3 className="font-title-sm text-title-sm text-on-surface">
              Última Actividad
            </h3>
            <div className="mt-3 space-y-2">
              {MOCK_TRANSACTIONS.slice(0, 3).map((txn) => (
                <div
                  key={txn.id}
                  className="flex items-start gap-2 rounded-lg bg-surface-container-low p-2"
                >
                  <div
                    className={`mt-1 h-2 w-2 shrink-0 rounded-full ${
                      txn.type === 'INGRESO' ? 'bg-emerald-500' : 'bg-red-500'
                    }`}
                  />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-xs font-medium text-on-surface">
                      {txn.concept}
                    </p>
                    <p className="text-[10px] text-on-surface-variant">
                      {new Date(txn.date).toLocaleDateString('es-CR')} · {txn.referenceCode}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Cross-module links */}
      <div className="flex items-center gap-6 p-4 bg-surface-container-low rounded-lg border border-outline-variant">
        <span className="text-xs font-medium text-on-surface-variant uppercase tracking-wide">Módulos relacionados:</span>
        <CrossModuleLink to="/m6" label="Donaciones" description="Comprobantes de aportes" />
        <CrossModuleLink to="/m1" label="Padrón Digital" description="Cuotas de miembros" />
        <CrossModuleLink to="/control-central" label="Control Central" description="Resumen financiero" />
      </div>
    </div>
  )
}

export const Route = createFileRoute('/_modules/m5')({
  component: M5Page,
})
