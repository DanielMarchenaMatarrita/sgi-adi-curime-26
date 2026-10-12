export type ProjectStatus = 'ABIERTO' | 'EN_CURSO' | 'FINALIZADO'
export type HoursValidation = 'VALIDADO' | 'PENDIENTE'

export interface VolunteerProject {
  id: string
  name: string
  startDate: string
  endDate: string
  vacancies: number
  enrolled: number
  status: ProjectStatus
  description: string
}

export interface VolunteerLog {
  id: string
  volunteerName: string
  documentNumber: string
  projectName: string
  hours: number
  validation: HoursValidation
}

export interface M11Stats {
  totalHours: number
  activeProjects: number
  registeredVolunteers: number
  restrictedTasks: number
}
