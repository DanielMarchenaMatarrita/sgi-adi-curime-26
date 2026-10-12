import type {
  VolunteerProject,
  VolunteerLog,
  M11Stats,
} from '../types'

export const MOCK_M11_STATS: M11Stats = {
  totalHours: 1248,
  activeProjects: 3,
  registeredVolunteers: 56,
  restrictedTasks: 2,
}

export const MOCK_PROJECTS: VolunteerProject[] = [
  {
    id: 'PRJ-001',
    name: 'Huerta Urbana Comunitaria',
    startDate: '2026-03-01',
    endDate: '2026-06-30',
    vacancies: 15,
    enrolled: 12,
    status: 'EN_CURSO',
    description:
      'Siembra y mantenimiento de huertas en barrios populares con acompañamiento de productores locales.',
  },
  {
    id: 'PRJ-002',
    name: 'Alfabetización Digital',
    startDate: '2026-04-15',
    endDate: '2026-09-15',
    vacancies: 20,
    enrolled: 8,
    status: 'ABIERTO',
    description:
      'Talleres de introducción a tecnología para adultos mayores en centros comunitarios.',
  },
  {
    id: 'PRJ-003',
    name: 'Capacitación Tech para Jóvenes',
    startDate: '2026-02-01',
    endDate: '2026-05-31',
    vacancies: 10,
    enrolled: 10,
    status: 'FINALIZADO',
    description:
      'Programa intensivo de programación y habilidades digitales dirigido a jóvenes de 16 a 25 años.',
  },
]

export const MOCK_VOLUNTEER_LOGS: VolunteerLog[] = [
  {
    id: 'LOG-001',
    volunteerName: 'María González',
    documentNumber: '30.123.456',
    projectName: 'Huerta Urbana Comunitaria',
    hours: 24,
    validation: 'VALIDADO',
  },
  {
    id: 'LOG-002',
    volunteerName: 'Lucas Fernández',
    documentNumber: '28.765.123',
    projectName: 'Alfabetización Digital',
    hours: 16,
    validation: 'PENDIENTE',
  },
  {
    id: 'LOG-003',
    volunteerName: 'Camila Herrera',
    documentNumber: '32.987.654',
    projectName: 'Capacitación Tech para Jóvenes',
    hours: 40,
    validation: 'VALIDADO',
  },
  {
    id: 'LOG-004',
    volunteerName: 'Juan Pérez',
    documentNumber: '29.345.789',
    projectName: 'Huerta Urbana Comunitaria',
    hours: 12,
    validation: 'PENDIENTE',
  },
  {
    id: 'LOG-005',
    volunteerName: 'Valentina López',
    documentNumber: '31.654.321',
    projectName: 'Alfabetización Digital',
    hours: 8,
    validation: 'VALIDADO',
  },
]
