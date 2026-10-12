import type { ModuleId } from '@/shared/types/common'

export interface SearchResult {
  id: string
  title: string
  subtitle: string
  moduleId: ModuleId
  moduleName: string
  path: string
  type: 'member' | 'credential' | 'transaction' | 'asset' | 'incident' | 'business' | 'volunteer' | 'assembly' | 'acta'
}

export const GLOBAL_SEARCH_DATA: SearchResult[] = [
  // M1 - Members
  { id: 'mbr-001', title: 'Carlos Mendoza Rivera', subtitle: 'Cédula: 12345678 · Activo · Curridabat', moduleId: 'm1', moduleName: 'Padrón Digital', path: '/m1', type: 'member' },
  { id: 'mbr-002', title: 'María Elena Vargas', subtitle: 'Cédula: 23456789 · Activo · Desamparados', moduleId: 'm1', moduleName: 'Padrón Digital', path: '/m1', type: 'member' },
  { id: 'mbr-003', title: 'Roberto Jiménez Castillo', subtitle: 'Cédula: 34567890 · Activo · Tibás', moduleId: 'm1', moduleName: 'Padrón Digital', path: '/m1', type: 'member' },
  { id: 'mbr-004', title: 'Ana Lucía Rojas', subtitle: 'Cédula: 45678901 · Pendiente · Moravia', moduleId: 'm1', moduleName: 'Padrón Digital', path: '/m1', type: 'member' },

  // M2 - Credentials
  { id: 'cred-001', title: 'CRED-2026-001', subtitle: 'Carlos Mendoza · VERIFICADO · AES-256', moduleId: 'm2', moduleName: 'Identidad', path: '/m2', type: 'credential' },
  { id: 'cred-002', title: 'CRED-2026-002', subtitle: 'María Elena Vargas · VERIFICADO · AES-256', moduleId: 'm2', moduleName: 'Identidad', path: '/m2', type: 'credential' },

  // M3 - Assemblies
  { id: 'asm-001', title: 'Asamblea Ordinaria Q2 2026', subtitle: '2026-06-20 · 48/120 presentes · Quorum 40%', moduleId: 'm3', moduleName: 'Asambleas', path: '/m3', type: 'assembly' },

  // M4 - Actas
  { id: 'acta-001', title: 'Acta #2026-047', subtitle: 'Asamblea Ordinaria Q2 · 3/5 firmas · Pendiente', moduleId: 'm4', moduleName: 'Actas', path: '/m4', type: 'acta' },

  // M5 - Transactions
  { id: 'txn-001', title: 'Cuota Mensual - Carlos Mendoza', subtitle: '₡25,000 · 2026-06-15 · Aprobado', moduleId: 'm5', moduleName: 'Tesorería', path: '/m5', type: 'transaction' },
  { id: 'txn-002', title: 'Mantenimiento Parque Central', subtitle: '₡180,000 · 2026-06-10 · Ejecutado', moduleId: 'm5', moduleName: 'Tesorería', path: '/m5', type: 'transaction' },

  // M8 - Assets
  { id: 'asset-001', title: 'Proyector Epson PowerLite', subtitle: 'INV-029 · Salón Comunal · Disponible', moduleId: 'm8', moduleName: 'Inventario', path: '/m8', type: 'asset' },
  { id: 'asset-002', title: 'Sillas Plegables (x50)', subtitle: 'INV-030 · Bodega Principal · En uso', moduleId: 'm8', moduleName: 'Inventario', path: '/m8', type: 'asset' },

  // M9 - Incidents
  { id: 'inc-001', title: 'Fuga de agua en Salón Comunal', subtitle: 'Alta · Pendiente · Asignado: Mantenimiento', moduleId: 'm9', moduleName: 'Incidencias', path: '/m9', type: 'incident' },
  { id: 'inc-002', title: 'Bomba de agua dañada', subtitle: 'Crítica · En Revisión · Asignado: Técnico', moduleId: 'm9', moduleName: 'Incidencias', path: '/m9', type: 'incident' },

  // M10 - Businesses
  { id: 'biz-001', title: 'Café de las Montañas', subtitle: 'Alimentos · Verificado M1 · ⭐ 4.8', moduleId: 'm10', moduleName: 'Marketplace', path: '/m10', type: 'business' },
  { id: 'biz-002', title: 'Taller Artesanal Doña Rosa', subtitle: 'Artesanías · Verificado M1 · ⭐ 4.6', moduleId: 'm10', moduleName: 'Marketplace', path: '/m10', type: 'business' },

  // M11 - Volunteers
  { id: 'vol-001', title: 'Reforestación Río Torres', subtitle: '12 voluntarios · 48h acumuladas · Activo', moduleId: 'm11', moduleName: 'Voluntariado', path: '/m11', type: 'volunteer' },
  { id: 'vol-002', title: 'Taller de Computación para Adultos', subtitle: '8 voluntarios · 32h acumuladas · Activo', moduleId: 'm11', moduleName: 'Voluntariado', path: '/m11', type: 'volunteer' },
]

export function searchGlobal(query: string): SearchResult[] {
  if (!query || query.length < 2) return []
  const q = query.toLowerCase()
  return GLOBAL_SEARCH_DATA.filter(
    (item) =>
      item.title.toLowerCase().includes(q) ||
      item.subtitle.toLowerCase().includes(q) ||
      item.moduleName.toLowerCase().includes(q)
  )
}
