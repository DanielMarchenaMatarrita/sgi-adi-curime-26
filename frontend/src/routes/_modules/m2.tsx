import { useState, useMemo, useCallback } from 'react'
import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { FilterTabs } from '@/modules/m2/components/filter-tabs'
import { CredentialCard } from '@/modules/m2/components/credential-card'
import { WalletViewer } from '@/modules/m2/components/wallet-viewer'
import { IdentityStats } from '@/modules/m2/components/identity-stats'
import { MOCK_CREDENTIALS, MOCK_IDENTITY_STATS, MOCK_IDENTITY_AUDIT } from '@/modules/m2/data/mock-data'
import type { M2Filters, Credential } from '@/modules/m2/types'

function M2Page() {
  const [filters, setFilters] = useState<M2Filters>({
    tab: 'all',
    search: '',
  })
  const [selectedCredential, setSelectedCredential] = useState<Credential | null>(
    MOCK_CREDENTIALS[0]
  )

  const handleFilterChange = useCallback((partial: Partial<M2Filters>) => {
    setFilters((prev) => ({ ...prev, ...partial }))
  }, [])

  const filteredCredentials = useMemo(() => {
    return MOCK_CREDENTIALS.filter((cred) => {
      if (filters.tab === 'pending' && cred.status !== 'PENDIENTE') return false
      if (filters.search) {
        const q = filters.search.toLowerCase()
        const fullName = `${cred.firstName} ${cred.lastName}`.toLowerCase()
        if (!fullName.includes(q) && !cred.uuid.toLowerCase().includes(q)) return false
      }
      return true
    })
  }, [filters])

  return (
    <div className="space-y-4">
      <PageHeader
        title="Módulo de Identidad"
        subtitle="Gestión de credenciales criptográficas y perfiles de asociados."
        badge={{ label: 'Nodo de Encriptación Activo', variant: 'primary' }}
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Identidad Digital' },
        ]}
        actions={[]}
      />

      <FilterTabs filters={filters} onFilterChange={handleFilterChange} />

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-12">
        {/* Profile Cards Grid */}
        <div className="space-y-4 lg:col-span-8">
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            {filteredCredentials.map((cred) => (
              <CredentialCard
                key={cred.id}
                credential={cred}
                onSelect={(id) => {
                  const found = MOCK_CREDENTIALS.find((c) => c.id === id)
                  setSelectedCredential(found ?? null)
                }}
                onGenerate={(id) => console.log('Generate credential:', id)}
                onSync={(id) => console.log('Sync credential:', id)}
              />
            ))}
          </div>
          {filteredCredentials.length === 0 && (
            <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-8 text-center">
              <p className="text-sm text-on-surface-variant">
                No se encontraron credenciales con los filtros seleccionados.
              </p>
            </div>
          )}
        </div>

        {/* Digital Wallet Viewer */}
        <div className="lg:col-span-4">
          <WalletViewer
            key={selectedCredential?.id ?? 'empty'}
            credential={selectedCredential}
            auditEntries={MOCK_IDENTITY_AUDIT}
          />
        </div>
      </div>

      <IdentityStats stats={MOCK_IDENTITY_STATS} />
    </div>
  )
}

export const Route = createFileRoute('/_modules/m2')({
  component: M2Page,
})
