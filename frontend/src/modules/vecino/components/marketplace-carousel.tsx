import { Store, Star, ChevronLeft, ChevronRight } from 'lucide-react'
import { useState, useRef } from 'react'
import { formatCurrency } from '@/shared/lib/utils'
import type { MarketplaceProduct } from '../types'

interface MarketplaceCarouselProps {
  products: MarketplaceProduct[]
}

export function MarketplaceCarousel({ products }: MarketplaceCarouselProps) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const [canScrollLeft, setCanScrollLeft] = useState(false)
  const [canScrollRight, setCanScrollRight] = useState(true)

  const checkScroll = () => {
    const el = scrollRef.current
    if (!el) return
    setCanScrollLeft(el.scrollLeft > 0)
    setCanScrollRight(el.scrollLeft < el.scrollWidth - el.clientWidth - 10)
  }

  const scroll = (direction: 'left' | 'right') => {
    const el = scrollRef.current
    if (!el) return
    el.scrollBy({ left: direction === 'left' ? -280 : 280, behavior: 'smooth' })
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/8">
            <Store className="h-5 w-5 text-primary" />
          </div>
          <div>
            <h3 className="font-display text-lg italic text-on-surface">Marketplace Local</h3>
            <p className="text-xs text-on-surface-variant">Productos y servicios de la comunidad</p>
          </div>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={() => scroll('left')}
            disabled={!canScrollLeft}
            className="flex h-8 w-8 items-center justify-center rounded-full border border-outline-variant/40 bg-surface-container-lowest text-on-surface-variant transition-colors hover:bg-surface-container disabled:opacity-30"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
          <button
            onClick={() => scroll('right')}
            disabled={!canScrollRight}
            className="flex h-8 w-8 items-center justify-center rounded-full border border-outline-variant/40 bg-surface-container-lowest text-on-surface-variant transition-colors hover:bg-surface-container disabled:opacity-30"
          >
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>

      <div
        ref={scrollRef}
        onScroll={checkScroll}
        className="flex gap-3 overflow-x-auto pb-2 scrollbar-none"
        style={{ scrollbarWidth: 'none' }}
      >
        {products.map((product) => (
          <div
            key={product.id}
            className="group w-[240px] shrink-0 rounded-xl border border-outline-variant/30 bg-surface-container-lowest p-3 transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/20 hover:shadow-md"
          >
            <div className="mb-2 flex h-28 items-center justify-center rounded-lg bg-gradient-to-br from-primary/5 to-primary/10">
              <Store className="h-8 w-8 text-primary/30" />
            </div>
            <div className="space-y-1">
              <span className="inline-block rounded-full bg-primary/8 px-2 py-0.5 text-[10px] font-bold text-primary">
                {product.category}
              </span>
              <h4 className="truncate text-sm font-bold text-on-surface">{product.name}</h4>
              <p className="truncate text-xs text-on-surface-variant">{product.vendor}</p>
              <div className="flex items-center justify-between pt-1">
                <span className="font-display text-base italic font-bold text-primary">
                  {formatCurrency(product.price)}
                </span>
                <div className="flex items-center gap-1 text-[10px] text-on-surface-variant">
                  <Star className="h-3 w-3 fill-amber text-amber" />
                  <span className="font-bold">{product.rating}</span>
                  <span>({product.reviewCount})</span>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
