import type { ModuleId } from '@/shared/types/common'

export interface ModuleSummary {
  moduleId: ModuleId
  moduleName: string
  status: 'healthy' | 'warning' | 'critical'
  metrics: { label: string; value: string | number }[]
  lastActivity: string
  route: string
}

export const MODULE_SUMMARIES: ModuleSummary[] = [
  {
    moduleId: 'm1',
    moduleName: 'Padrón Digital',
    status: 'healthy',
    metrics: [
      { label: 'Total Miembros', value: 1248 },
      { label: 'Activos', value: 1173 },
      { label: 'Pendientes', value: 52 },
      { label: 'Inactivos', value: 23 },
    ],
    lastActivity: '2026-06-20T14:32:00Z',
    route: '/m1',
  },
  {
    moduleId: 'm2',
    moduleName: 'Identidad Encriptada',
    status: 'healthy',
    metrics: [
      { label: 'Credenciales', value: 8 },
      { label: 'Activas', value: 5 },
      { label: 'Pendientes QR', value: 2 },
      { label: 'Revocadas', value: 1 },
    ],
    lastActivity: '2026-06-20T14:35:00Z',
    route: '/m2',
  },
  {
    moduleId: 'm3',
    moduleName: 'Asambleas',
    status: 'warning',
    metrics: [
      { label: 'Última Asistencia', value: '48/120' },
      { label: 'Quórum', value: '40%' },
      { label: 'Asistentes QR', value: 38 },
      { label: 'Manuales', value: 10 },
    ],
    lastActivity: '2026-06-20T10:00:00Z',
    route: '/m3',
  },
  {
    moduleId: 'm4',
    moduleName: 'Actas Digitales',
    status: 'warning',
    metrics: [
      { label: 'Actas Totales', value: 47 },
      { label: 'Firmadas', value: 44 },
      { label: 'Pendientes', value: 3 },
      { label: 'Última Versión', value: 'v3' },
    ],
    lastActivity: '2026-06-20T14:32:00Z',
    route: '/m4',
  },
  {
    moduleId: 'm5',
    moduleName: 'Tesorería',
    status: 'healthy',
    metrics: [
      { label: 'Saldo Disponible', value: '₡12.4M' },
      { label: 'Pendiente', value: '₡2.1M' },
      { label: 'Ejecutado', value: '₡4.8M' },
      { label: 'Transacciones', value: 156 },
    ],
    lastActivity: '2026-06-20T14:38:00Z',
    route: '/m5',
  },
  {
    moduleId: 'm6',
    moduleName: 'Donaciones',
    status: 'healthy',
    metrics: [
      { label: 'Total Recibido', value: '₡850K' },
      { label: 'Este Mes', value: '₡125K' },
      { label: 'Donantes', value: 34 },
      { label: 'Comprobantes', value: 42 },
    ],
    lastActivity: '2026-06-19T16:20:00Z',
    route: '/m6',
  },
  {
    moduleId: 'm7',
    moduleName: 'Reservas',
    status: 'healthy',
    metrics: [
      { label: 'Reservas Activas', value: 12 },
      { label: 'Hoy', value: 3 },
      { label: 'Esta Semana', value: 8 },
      { label: 'Ingresos', value: '₡420K' },
    ],
    lastActivity: '2026-06-20T08:15:00Z',
    route: '/m7',
  },
  {
    moduleId: 'm8',
    moduleName: 'Inventario',
    status: 'healthy',
    metrics: [
      { label: 'Total Activos', value: 45 },
      { label: 'Disponibles', value: 38 },
      { label: 'En Préstamo', value: 5 },
      { label: 'Mantenimiento', value: 2 },
    ],
    lastActivity: '2026-06-18T11:30:00Z',
    route: '/m8',
  },
  {
    moduleId: 'm9',
    moduleName: 'Incidencias',
    status: 'critical',
    metrics: [
      { label: 'Abiertas', value: 6 },
      { label: 'Críticas', value: 2 },
      { label: 'En Progreso', value: 3 },
      { label: 'Resueltas (mes)', value: 14 },
    ],
    lastActivity: '2026-06-20T12:48:00Z',
    route: '/m9',
  },
  {
    moduleId: 'm10',
    moduleName: 'Marketplace',
    status: 'healthy',
    metrics: [
      { label: 'Negocios', value: 24 },
      { label: 'Verificados', value: 18 },
      { label: 'Categorías', value: 6 },
      { label: 'Valoración Prom.', value: '4.5⭐' },
    ],
    lastActivity: '2026-06-20T09:45:00Z',
    route: '/m10',
  },
  {
    moduleId: 'm11',
    moduleName: 'Voluntariado',
    status: 'healthy',
    metrics: [
      { label: 'Proyectos Activos', value: 5 },
      { label: 'Voluntarios', value: 42 },
      { label: 'Horas Acumuladas', value: 320 },
      { label: 'Comunidad Benef.', value: '1,200' },
    ],
    lastActivity: '2026-06-20T14:10:00Z',
    route: '/m11',
  },
]

export function getModuleSummary(moduleId: ModuleId): ModuleSummary | undefined {
  return MODULE_SUMMARIES.find((m) => m.moduleId === moduleId)
}

export function getModulesByStatus(status: ModuleSummary['status']): ModuleSummary[] {
  return MODULE_SUMMARIES.filter((m) => m.status === status)
}
