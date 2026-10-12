import type {
  VecinoProfile,
  QuickAction,
  TransparencyData,
  VecinoEvent,
  MarketplaceProduct,
} from '../types'

export const MOCK_VECINO_PROFILE: VecinoProfile = {
  id: 'vec-001',
  fullName: 'María Elena Rodríguez Méndez',
  district: 'San Pedro de Montes de Oca',
  community: 'Asociación Desarrollo Barrio Los Ángeles',
  memberSince: '2021-03-15',
  accessLevel: 'verificado',
  annualContributions: 185000,
  outstandingBalance: 0,
  solvencyIssued: true,
}

export const MOCK_QUICK_ACTIONS: QuickAction[] = [
  {
    id: 'qa-1',
    label: 'Solicitar Certificación',
    description: 'Obtener constancia de membresía',
    icon: 'FileText',
    href: '/m1',
  },
  {
    id: 'qa-2',
    label: 'Reportar Incidencia',
    description: 'Registrar problema comunitario',
    icon: 'AlertTriangle',
    href: '/m9',
  },
  {
    id: 'qa-3',
    label: 'Reservar Instalación',
    description: 'Agendar espacios disponibles',
    icon: 'Calendar',
    href: '/m7',
  },
  {
    id: 'qa-4',
    label: 'Identidad Digital',
    description: 'Gestionar credenciales',
    icon: 'Shield',
    href: '/m2',
  },
]

export const MOCK_TRANSPARENCY: TransparencyData = {
  budgetExecuted: 10200000,
  budgetTotal: 15000000,
  dataCircularity: 75,
  lastAudit: '2026-05-20',
  pendingProjects: 3,
}

export const MOCK_EVENTS: VecinoEvent[] = [
  {
    id: 'evt-001',
    title: 'Asamblea General Ordinaria',
    date: '2026-07-15',
    time: '09:00',
    location: 'Centro Comunal Barrio Los Ángeles',
    type: 'asamblea',
  },
  {
    id: 'evt-002',
    title: 'Jornada de Reforestación',
    date: '2026-06-28',
    time: '06:30',
    location: 'Quebrada Las Vueltas',
    type: 'voluntariado',
  },
  {
    id: 'evt-003',
    title: 'Taller de Emprendimiento',
    date: '2026-07-05',
    time: '14:00',
    location: 'Salón Comunal La Esperanza',
    type: 'taller',
  },
  {
    id: 'evt-004',
    title: 'Reunión de Consejo',
    date: '2026-07-01',
    time: '18:30',
    location: 'Oficina Administrativa',
    type: 'comunitario',
  },
]

export const MOCK_MARKETPLACE: MarketplaceProduct[] = [
  {
    id: 'mp-001',
    name: 'Café Orgánico Montes de Oca',
    vendor: 'Cooperativa Café Vida',
    price: 4500,
    currency: 'CRC',
    imageUrl: '',
    rating: 4.8,
    reviewCount: 24,
    category: 'Alimentos',
  },
  {
    id: 'mp-002',
    name: 'Artesanías en Madera',
    vendor: 'Taller Don Carlos',
    price: 12000,
    currency: 'CRC',
    imageUrl: '',
    rating: 4.6,
    reviewCount: 18,
    category: 'Artesanías',
  },
  {
    id: 'mp-003',
    name: 'Miel de Abeja Pura',
    vendor: 'Apicultura San José',
    price: 6500,
    currency: 'CRC',
    imageUrl: '',
    rating: 4.9,
    reviewCount: 31,
    category: 'Alimentos',
  },
  {
    id: 'mp-004',
    name: 'Hortalizas Frescas',
    vendor: 'Huerta Comunitaria',
    price: 2800,
    currency: 'CRC',
    imageUrl: '',
    rating: 4.7,
    reviewCount: 15,
    category: 'Alimentos',
  },
  {
    id: 'mp-005',
    name: 'Taller de Cerámica',
    vendor: 'Colectivo Arcilla',
    price: 8500,
    currency: 'CRC',
    imageUrl: '',
    rating: 4.5,
    reviewCount: 12,
    category: 'Talleres',
  },
]
