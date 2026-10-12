import type { NavGroup } from '@/shared/types/nav'

export const APP_NAME = 'SGI-CURIME'
export const APP_DESCRIPTION = 'Ecosistema Digital Confiable para Asociaciones de Desarrollo Comunitario'
export const APP_VERSION = '1.0.0'

export const SIDEBAR_WIDTH = 272
export const TOPBAR_HEIGHT = 64

export const NAVIGATION: NavGroup[] = [
  {
    id: 'modules',
    label: 'Modulos',
    items: [
      { id: 'm1', label: 'Padron Digital', icon: 'badge', path: '/m1', moduleId: 'm1' },
      { id: 'm2', label: 'Identidad', icon: 'shield', path: '/m2', moduleId: 'm2' },
      { id: 'm3', label: 'Asambleas', icon: 'groups', path: '/m3', moduleId: 'm3' },
      { id: 'm4', label: 'Actas', icon: 'description', path: '/m4', moduleId: 'm4' },
      { id: 'm5', label: 'Tesoreria', icon: 'account_balance', path: '/m5', moduleId: 'm5' },
      { id: 'm6', label: 'Donaciones', icon: 'volunteer_activism', path: '/m6', moduleId: 'm6' },
      { id: 'm7', label: 'Reservas', icon: 'event', path: '/m7', moduleId: 'm7' },
      { id: 'm8', label: 'Inventario', icon: 'inventory_2', path: '/m8', moduleId: 'm8' },
      { id: 'm9', label: 'Incidencias', icon: 'report_problem', path: '/m9', moduleId: 'm9' },
      { id: 'm10', label: 'Marketplace', icon: 'store', path: '/m10', moduleId: 'm10' },
      { id: 'm11', label: 'Voluntariado', icon: 'handshake', path: '/m11', moduleId: 'm11' },
      { id: 'vecino', label: 'Mi Comunidad', icon: 'people', path: '/vecino', moduleId: 'vecino' },
    ],
  },
  {
    id: 'admin',
    label: 'Administracion',
    items: [
      { id: 'control', label: 'Control Central', icon: 'monitoring', path: '/control-central', moduleId: 'control' },
    ],
  },
]
