import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from '@/shared/components/ui/card'
import { Badge } from '@/shared/components/ui/badge'
import { Button } from '@/shared/components/ui/button'
import { Calendar, Users, ArrowRight } from 'lucide-react'
import type { VolunteerProject, ProjectStatus } from '../types'

const STATUS_STYLES: Record<ProjectStatus, string> = {
  ABIERTO: 'bg-emerald-100 text-emerald-800 border-emerald-200',
  EN_CURSO: 'bg-amber-100 text-amber-800 border-amber-200',
  FINALIZADO: 'bg-slate-100 text-slate-600 border-slate-200',
}

interface ProjectCardProps {
  project: VolunteerProject
}

export function ProjectCard({ project }: ProjectCardProps) {
  const spotsLeft = project.vacancies - project.enrolled

  return (
    <Card className="h-full flex flex-col">
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between gap-2">
          <CardTitle className="text-base leading-tight">
            {project.name}
          </CardTitle>
          <Badge
            variant="outline"
            className={`shrink-0 text-xs font-medium ${STATUS_STYLES[project.status]}`}
          >
            {project.status.replace('_', ' ')}
          </Badge>
        </div>
        <CardDescription className="line-clamp-2 mt-1 text-sm">
          {project.description}
        </CardDescription>
      </CardHeader>

      <CardContent className="flex-1 space-y-3">
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Calendar className="h-4 w-4" />
          <span>
            {project.startDate} — {project.endDate}
          </span>
        </div>

        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Users className="h-4 w-4" />
          <span>
            <span className="font-medium text-foreground">
              {project.enrolled}
            </span>
            /{project.vacancies} inscritos
          </span>
        </div>

        <div className="w-full bg-muted rounded-full h-2">
          <div
            className="bg-primary h-2 rounded-full transition-all"
            style={{
              width: `${(project.enrolled / project.vacancies) * 100}%`,
            }}
          />
        </div>
      </CardContent>

      <CardFooter>
        <Button
          variant={spotsLeft > 0 ? 'default' : 'outline'}
          disabled={project.status === 'FINALIZADO' || spotsLeft <= 0}
          className="w-full gap-2"
        >
          {spotsLeft > 0 ? 'Inscribirse' : 'Cupos completos'}
          <ArrowRight className="h-4 w-4" />
        </Button>
      </CardFooter>
    </Card>
  )
}
