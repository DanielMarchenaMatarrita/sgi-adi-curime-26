import { useState, useMemo } from 'react'
import { Store } from 'lucide-react'
import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { BusinessCard } from '@/modules/m10/components/business-card'
import { CategoryFilter } from '@/modules/m10/components/category-filter'
import { MarketplaceStats } from '@/modules/m10/components/marketplace-stats'
import { MOCK_BUSINESSES, MOCK_M10_STATS } from '@/modules/m10/data/mock-data'
import type { BusinessCategory } from '@/modules/m10/types'

export const Route = createFileRoute('/_modules/m10')({
  component: M10Page,
})

function M10Page() {
  const [selectedCategory, setSelectedCategory] = useState<BusinessCategory>('TODOS')

  const filteredBusinesses = useMemo(() => {
    if (selectedCategory === 'TODOS') return MOCK_BUSINESSES
    return MOCK_BUSINESSES.filter((b) => b.category === selectedCategory)
  }, [selectedCategory])

  return (
    <div className="space-y-6">
      <PageHeader
        title="Directorio de Emprendimientos Comunitarios"
        subtitle="Marketplace de proximidad para asociados"
        badge={{ label: 'Validado con M1', icon: <Store className="h-3 w-3" />, variant: 'primary' }}
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Directorio Comercial' },
        ]}
      />

      <MarketplaceStats stats={MOCK_M10_STATS} />

      <div className="flex items-center gap-3">
        <h2 className="text-sm font-semibold text-on-surface">Filtrar por categoría</h2>
        <CategoryFilter selected={selectedCategory} onSelect={setSelectedCategory} />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {filteredBusinesses.map((business) => (
          <BusinessCard key={business.id} business={business} />
        ))}
      </div>

      {filteredBusinesses.length === 0 && (
        <div className="rounded-xl border border-dashed border-outline-variant bg-surface-container-low p-8 text-center">
          <Store className="mx-auto mb-2 h-8 w-8 text-on-surface-variant" />
          <p className="text-sm font-medium text-on-surface-variant">
            No hay emprendimientos en esta categoría
          </p>
        </div>
      )}
    </div>
  )
}
