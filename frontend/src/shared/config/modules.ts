import type { ModuleId } from '@/shared/types/common'

export interface ModuleMeta {
  id: ModuleId
  name: string
  shortName: string
  description: string
  icon: string
  color: string
  route: string
}

export const MODULES: ModuleMeta[] = [
  {
    id: 'm1',
    name: 'Padron Digital',
    shortName: 'Padron',
    description: 'Registro unico de miembros de la asociacion',
    icon: 'badge',
    color: '#006948',
    route: '/m1',
  },
  {
    id: 'm2',
    name: 'Identidad Encriptada',
    shortName: 'Identidad',
    description: 'Credenciales criptograficas y verificacion',
    icon: 'shield',
    color: '#006948',
    route: '/m2',
  },
  {
    id: 'm3',
    name: 'Asambleas',
    shortName: 'Asambleas',
    description: 'Convocatorias y control de asistencia',
    icon: 'groups',
    color: '#006948',
    route: '/m3',
  },
  {
    id: 'm4',
    name: 'Actas Digitales',
    shortName: 'Actas',
    description: 'Registro y versionado de actas',
    icon: 'description',
    color: '#006948',
    route: '/m4',
  },
  {
    id: 'm5',
    name: 'Tesoreria',
    shortName: 'Tesoreria',
    description: 'Gestion financiera y contabilidad',
    icon: 'account_balance',
    color: '#006948',
    route: '/m5',
  },
  {
    id: 'm6',
    name: 'Donaciones',
    shortName: 'Donaciones',
    description: 'Registro de aportes y contribuciones',
    icon: 'volunteer_activism',
    color: '#006948',
    route: '/m6',
  },
  {
    id: 'm7',
    name: 'Reservas',
    shortName: 'Reservas',
    description: 'Gestion de espacios y equipos',
    icon: 'event',
    color: '#006948',
    route: '/m7',
  },
  {
    id: 'm8',
    name: 'Inventario',
    shortName: 'Inventario',
    description: 'Control de bienes y activos',
    icon: 'inventory_2',
    color: '#006948',
    route: '/m8',
  },
  {
    id: 'm9',
    name: 'Incidencias',
    shortName: 'Incidencias',
    description: 'Registro y seguimiento de problemas',
    icon: 'report_problem',
    color: '#9b3e3b',
    route: '/m9',
  },
  {
    id: 'm10',
    name: 'Marketplace',
    shortName: 'Marketplace',
    description: 'Directorio de negocios comunitarios',
    icon: 'store',
    color: '#006948',
    route: '/m10',
  },
  {
    id: 'm11',
    name: 'Voluntariado',
    shortName: 'Voluntariado',
    description: 'Gestion de proyectos y voluntarios',
    icon: 'handshake',
    color: '#006948',
    route: '/m11',
  },
  {
    id: 'vecino',
    name: 'Mi Comunidad',
    shortName: 'Vecino',
    description: 'Portal ciudadano del ecosistema confiable',
    icon: 'people',
    color: '#0a7c57',
    route: '/vecino',
  },
  {
    id: 'control',
    name: 'Control Central',
    shortName: 'Control',
    description: 'Monitoreo y analisis del ecosistema',
    icon: 'monitoring',
    color: '#545f73',
    route: '/control-central',
  },
]

export const getModuleById = (id: ModuleId): ModuleMeta | undefined =>
  MODULES.find((m) => m.id === id)

export const getModuleByRoute = (route: string): ModuleMeta | undefined =>
  MODULES.find((m) => route.startsWith(m.route))
