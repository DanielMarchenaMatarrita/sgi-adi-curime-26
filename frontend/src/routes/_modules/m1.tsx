import { useState, useMemo, useCallback } from 'react'
import { useQuery } from '@tanstack/react-query'
import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { getAffiliates } from '@/shared/api/affiliates'
import { FilterCard } from '@/modules/m1/components/filter-card'
import { MembersTable } from '@/modules/m1/components/members-table'
import type { M1Filters } from '@/modules/m1/types'

const PAGE_SIZE = 25

function M1Page() {
  const [filters, setFilters] = useState<M1Filters>({
    status: 'all',
    search: '',
  })
  const [offset, setOffset] = useState(0)

  const handleFilterChange = useCallback((partial: Partial<M1Filters>) => {
    setFilters((prev) => ({ ...prev, ...partial }))
    setOffset(0)
  }, [])

  const queryParams = useMemo(
    () => ({
      limit: PAGE_SIZE,
      offset,
      status: filters.status === 'all' ? undefined : filters.status,
      q: filters.search,
    }),
    [filters.search, filters.status, offset],
  )

  const affiliatesQuery = useQuery({
    queryKey: ['affiliates', queryParams],
    queryFn: () => getAffiliates(queryParams),
  })

  return (
    <div className="space-y-6">
      <PageHeader
        title="Padrón Digital Único"
        subtitle="Registro único de miembros de la asociación"
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Padrón Digital' },
        ]}
      />

      <FilterCard filters={filters} onFilterChange={handleFilterChange} />

      {affiliatesQuery.isPending ? (
        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-8 text-center text-sm text-on-surface-variant" role="status">
          Cargando afiliados…
        </div>
      ) : affiliatesQuery.isError ? (
        <div className="rounded-xl border border-danger/30 bg-surface-container-lowest p-8 text-center">
          <p className="text-sm font-medium text-on-surface">No fue posible cargar afiliados.</p>
          <button
            type="button"
            onClick={() => affiliatesQuery.refetch()}
            className="mt-3 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
          >
            Reintentar
          </button>
        </div>
      ) : (
        <MembersTable
          data={affiliatesQuery.data.items}
          total={affiliatesQuery.data.total}
          limit={affiliatesQuery.data.limit}
          offset={affiliatesQuery.data.offset}
          onPageChange={setOffset}
        />
      )}
    </div>
  )
}

export const Route = createFileRoute('/_modules/m1')({
  component: M1Page,
})
