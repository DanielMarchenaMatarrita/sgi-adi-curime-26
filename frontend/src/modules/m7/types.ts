export type FacilityType = 'SALON' | 'CANCHA'
export type ReservationStatus = 'CONFIRMADO' | 'EN_REVISION' | 'CANCELADO'
export type EventType = 'FAMILIAR' | 'COMUNITARIO' | 'COMERCIAL'

export interface Reservation {
  id: string
  facility: FacilityType
  event_name: string
  organizer: string
  date: string
  startTime: string
  endTime: string
  status: ReservationStatus
  eventType: EventType
}

export interface FeeCalculation {
  baseFee: number
  cleaningFee: number
  total: number
  eventType: EventType
  hours: number
}
