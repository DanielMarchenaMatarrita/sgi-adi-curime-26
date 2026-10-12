import type { BusinessCategory } from '../types'

const CATEGORIES: { value: BusinessCategory; label: string }[] = [
  { value: 'TODOS', label: 'Todos' },
  { value: 'ALIMENTACION', label: 'Alimentación' },
  { value: 'SERVICIOS', label: 'Servicios' },
  { value: 'ARTESANIA', label: 'Artesanía' },
  { value: 'TURISMO', label: 'Turismo Rural' },
  { value: 'TECNOLOGIA', label: 'Tecnología' },
  { value: 'EDUCACION', label: 'Educación' },
]

interface CategoryFilterProps {
  selected: BusinessCategory
  onSelect: (category: BusinessCategory) => void
}

function CategoryFilter({ selected, onSelect }: CategoryFilterProps) {
  return (
    <div className="flex items-center gap-2 overflow-x-auto pb-1">
      {CATEGORIES.map((cat) => (
        <button
          key={cat.value}
          onClick={() => onSelect(cat.value)}
          className={`shrink-0 rounded-full border px-3 py-1.5 text-xs font-medium transition-colors ${
            selected === cat.value
              ? 'border-primary bg-primary/10 text-primary'
              : 'border-border text-muted-foreground hover:bg-muted'
          }`}
        >
          {cat.label}
        </button>
      ))}
    </div>
  )
}

export { CategoryFilter }
export type { CategoryFilterProps }
