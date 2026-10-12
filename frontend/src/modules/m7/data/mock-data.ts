import type { Reservation, FeeCalculation } from '../types'

const today = new Date()
const yyyy = today.getFullYear()
const mm = String(today.getMonth() + 1).padStart(2, '0')

export const MOCK_RESERVATIONS: Reservation[] = [
  {
    id: 'R-2026-001',
    facility: 'SALON',
    event_name: 'Reunión de Vecinos',
    organizer: 'Junta de Distrito',
    date: `${yyyy}-${mm}-05`,
    startTime: '09:00',
    endTime: '12:00',
    status: 'CONFIRMADO',
    eventType: 'COMUNITARIO',
  },
  {
    id: 'R-2026-002',
    facility: 'CANCHA',
    event_name: 'Torneo Amistoso',
    organizer: 'Club Deportivo Sol',
    date: `${yyyy}-${mm}-10`,
    startTime: '14:00',
    endTime: '18:00',
    status: 'CONFIRMADO',
    eventType: 'COMERCIAL',
  },
  {
    id: 'R-2026-003',
    facility: 'SALON',
    event_name: 'Fiesta de Cumpleaños',
    organizer: 'María López',
    date: `${yyyy}-${mm}-15`,
    startTime: '16:00',
    endTime: '21:00',
    status: 'EN_REVISION',
    eventType: 'FAMILIAR',
  },
  {
    id: 'R-2026-004',
    facility: 'CANCHA',
    event_name: 'Clase de Yoga',
    organizer: 'Ana Ramírez',
    date: `${yyyy}-${mm}-20`,
    startTime: '07:00',
    endTime: '09:00',
    status: 'CONFIRMADO',
    eventType: 'COMUNITARIO',
  },
  {
    id: 'R-2026-005',
    facility: 'SALON',
    event_name: 'Fer Artesanal',
    organizer: 'Asociación Artesanos',
    date: `${yyyy}-${mm}-28`,
    startTime: '10:00',
    endTime: '17:00',
    status: 'CANCELADO',
    eventType: 'COMERCIAL',
  },
]

export const MOCK_FEE_CALCULATION: FeeCalculation = {
  baseFee: 5000,
  cleaningFee: 2000,
  total: 7000,
  eventType: 'FAMILIAR',
  hours: 4,
}

export const MOCK_CALENDAR_EVENTS: Record<string, { count: number; facility: string }[]> = {}

MOCK_RESERVATIONS.forEach((r) => {
  if (!MOCK_CALENDAR_EVENTS[r.date]) {
    MOCK_CALENDAR_EVENTS[r.date] = []
  }
  MOCK_CALENDAR_EVENTS[r.date].push({
    count: 1,
    facility: r.facility,
  })
})
