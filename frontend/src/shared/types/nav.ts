import type { ModuleId } from './common'

export interface NavItem {
  id: string
  label: string
  icon: string
  path: string
  moduleId?: ModuleId
}

export interface NavGroup {
  id: string
  label: string
  items: NavItem[]
}
