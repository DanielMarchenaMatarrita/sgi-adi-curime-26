import { Card, CardHeader, CardTitle, CardContent } from '@/shared/components/ui/card'
import { Badge } from '@/shared/components/ui/badge'
import {
  Clock,
  FolderOpen,
  Users,
  ShieldAlert,
  Info,
} from 'lucide-react'
import type { M11Stats } from '../types'

interface StatCardProps {
  label: string
  value: number
  icon: React.ReactNode
  accent: string
}

function StatCard({ label, value, icon, accent }: StatCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {label}
        </CardTitle>
        <div className={`rounded-md p-2 ${accent}`}>{icon}</div>
      </CardHeader>
      <CardContent>
        <div className="text-3xl font-bold tabular-nums">{value}</div>
      </CardContent>
    </Card>
  )
}

interface VolunteerStatsProps {
  stats: M11Stats
}

export function VolunteerStats({ stats }: VolunteerStatsProps) {
  return (
    <div className="space-y-4">
      <div className="rounded-lg border bg-amber-50 border-amber-200 p-4 flex items-start gap-3">
        <ShieldAlert className="h-5 w-5 text-amber-600 mt-0.5 shrink-0" />
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="text-sm font-semibold text-amber-900">
              Validación M1 — Protección de Menores
            </h4>
            <Badge
              variant="outline"
              className="bg-amber-100 text-amber-800 border-amber-300 text-xs"
            >
              {stats.restrictedTasks} tareas restringidas
            </Badge>
          </div>
          <p className="text-sm text-amber-800/80">
            Las actividades que involucren contacto directo con menores de edad
            requieren validación del Módulo 1 antes de asignar voluntarios.
          </p>
        </div>
        <Info className="h-4 w-4 text-amber-500 shrink-0 mt-0.5" />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          label="Total Horas"
          value={stats.totalHours}
          icon={<Clock className="h-4 w-4 text-white" />}
          accent="bg-blue-600"
        />
        <StatCard
          label="Proyectos Activos"
          value={stats.activeProjects}
          icon={<FolderOpen className="h-4 w-4 text-white" />}
          accent="bg-emerald-600"
        />
        <StatCard
          label="Voluntarios Inscritos"
          value={stats.registeredVolunteers}
          icon={<Users className="h-4 w-4 text-white" />}
          accent="bg-violet-600"
        />
      </div>
    </div>
  )
}
