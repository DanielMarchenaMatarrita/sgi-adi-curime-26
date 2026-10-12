import { useState, useEffect, useCallback, useRef } from 'react'
import { useNavigate } from '@tanstack/react-router'
import { Search, X, Users, ShieldCheck, Vote, FileText, Landmark, Package, AlertTriangle, Store, Handshake, ArrowRight } from 'lucide-react'
import { cn } from '@/shared/lib/utils'
import { searchGlobal, type SearchResult } from '@/shared/data/search-data'
import { Dialog, DialogContent } from '@/shared/components/ui/dialog'

const TYPE_ICONS: Record<SearchResult['type'], typeof Users> = {
  member: Users,
  credential: ShieldCheck,
  assembly: Vote,
  acta: FileText,
  transaction: Landmark,
  asset: Package,
  incident: AlertTriangle,
  business: Store,
  volunteer: Handshake,
}

interface GlobalSearchProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function GlobalSearch({ open, onOpenChange }: GlobalSearchProps) {
  const [query, setQuery] = useState('')
  const [selectedIndex, setSelectedIndex] = useState(0)
  const inputRef = useRef<HTMLInputElement>(null)
  const navigate = useNavigate()
  const results = searchGlobal(query)

  useEffect(() => {
    if (open) {
      setTimeout(() => inputRef.current?.focus(), 100)
    }
  }, [open])

  const handleOpenChange = useCallback((nextOpen: boolean) => {
    if (nextOpen) {
      setQuery('')
      setSelectedIndex(0)
    }
    onOpenChange(nextOpen)
  }, [onOpenChange])

  const handleSelect = useCallback(
    (result: SearchResult) => {
      navigate({ to: result.path })
      onOpenChange(false)
    },
    [navigate, onOpenChange]
  )

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault()
        setSelectedIndex((prev) => Math.min(prev + 1, results.length - 1))
      } else if (e.key === 'ArrowUp') {
        e.preventDefault()
        setSelectedIndex((prev) => Math.max(prev - 1, 0))
      } else if (e.key === 'Enter' && results[selectedIndex]) {
        handleSelect(results[selectedIndex])
      } else if (e.key === 'Escape') {
        onOpenChange(false)
      }
    },
    [results, selectedIndex, handleSelect, onOpenChange]
  )

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="max-w-lg p-0 gap-0 overflow-hidden rounded-2xl border-outline-variant/50 shadow-2xl">
        <div className="flex items-center gap-3 border-b border-outline-variant/50 px-4 py-3">
          <Search className="h-5 w-5 text-primary shrink-0" />
          <input
            ref={inputRef}
            type="text"
            placeholder="Buscar miembros, credenciales, transacciones..."
            value={query}
            onChange={(e) => {
              setQuery(e.target.value)
              setSelectedIndex(0)
            }}
            onKeyDown={handleKeyDown}
            className="flex-1 bg-transparent text-sm text-on-surface placeholder:text-on-surface-variant/50 outline-none"
          />
          {query && (
            <button
              onClick={() => {
                setQuery('')
                setSelectedIndex(0)
              }}
              className="p-1 hover:bg-surface-container-high rounded-lg transition-colors"
            >
              <X className="h-4 w-4 text-on-surface-variant" />
            </button>
          )}
        </div>

        <div className="max-h-80 overflow-y-auto">
          {query.length < 2 ? (
            <div className="px-4 py-10 text-center">
              <Search className="h-8 w-8 text-on-surface-variant/30 mx-auto mb-2" />
              <p className="text-sm text-on-surface-variant/60">
                Escribe al menos 2 caracteres para buscar
              </p>
            </div>
          ) : results.length === 0 ? (
            <div className="px-4 py-10 text-center">
              <p className="text-sm text-on-surface-variant">
                No se encontraron resultados para "<span className="font-semibold text-on-surface">{query}</span>"
              </p>
            </div>
          ) : (
            <div className="py-2">
              {results.map((result, index) => {
                const Icon = TYPE_ICONS[result.type]
                return (
                  <button
                    key={result.id}
                    onClick={() => handleSelect(result)}
                    className={cn(
                      'w-full flex items-center gap-3 px-4 py-2.5 text-left transition-all duration-150',
                      index === selectedIndex
                        ? 'bg-primary/8 text-primary'
                        : 'hover:bg-surface-container-high/60 text-on-surface'
                    )}
                  >
                    <div
                      className={cn(
                        'w-8 h-8 rounded-lg flex items-center justify-center shrink-0 transition-colors',
                        index === selectedIndex ? 'bg-primary/15' : 'bg-surface-container-highest/80'
                      )}
                    >
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-semibold truncate">{result.title}</div>
                      <div className="text-xs text-on-surface-variant truncate">{result.subtitle}</div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <span className="text-[10px] font-bold uppercase text-on-surface-variant/60 bg-surface-container-highest/60 px-2 py-0.5 rounded-full">
                        {result.moduleName}
                      </span>
                      <ArrowRight className="h-3 w-3 text-on-surface-variant/40" />
                    </div>
                  </button>
                )
              })}
            </div>
          )}
        </div>

        {results.length > 0 && (
          <div className="border-t border-outline-variant/50 px-4 py-2 flex items-center justify-between text-[10px] text-on-surface-variant/50 font-medium">
            <span>{results.length} resultado{results.length !== 1 ? 's' : ''}</span>
            <span>↑↓ navegar · Enter seleccionar · Esc cerrar</span>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}
