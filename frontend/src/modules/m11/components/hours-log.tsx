import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/components/ui/table'
import { Badge } from '@/shared/components/ui/badge'
import type { VolunteerLog, HoursValidation } from '../types'

const VALIDATION_STYLES: Record<HoursValidation, string> = {
  VALIDADO: 'bg-emerald-100 text-emerald-800 border-emerald-200',
  PENDIENTE: 'bg-amber-100 text-amber-800 border-amber-200',
}

const MAX_HOURS = 40

interface HoursLogProps {
  logs: VolunteerLog[]
}

export function HoursLog({ logs }: HoursLogProps) {
  return (
    <div className="rounded-lg border bg-card">
      <div className="p-4 border-b">
        <h3 className="text-sm font-semibold">Registro de Horas</h3>
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-[200px]">Voluntario</TableHead>
            <TableHead>Proyecto</TableHead>
            <TableHead className="text-center">Horas</TableHead>
            <TableHead className="w-[140px]">Distribución</TableHead>
            <TableHead className="text-right">Validación</TableHead>
          </TableRow>
        </TableHeader>

        <TableBody>
          {logs.map((log) => {
            const barWidth = Math.min((log.hours / MAX_HOURS) * 100, 100)
            const barColor =
              log.validation === 'VALIDADO'
                ? 'bg-emerald-500'
                : 'bg-amber-500'

            return (
              <TableRow key={log.id}>
                <TableCell>
                  <div className="font-medium text-sm">{log.volunteerName}</div>
                  <div className="text-xs text-muted-foreground">
                    {log.documentNumber}
                  </div>
                </TableCell>
                <TableCell className="text-sm">{log.projectName}</TableCell>
                <TableCell className="text-center font-medium tabular-nums">
                  {log.hours}h
                </TableCell>
                <TableCell>
                  <div className="w-full bg-muted rounded-full h-2.5">
                    <div
                      className={`${barColor} h-2.5 rounded-full transition-all`}
                      style={{ width: `${barWidth}%` }}
                    />
                  </div>
                </TableCell>
                <TableCell className="text-right">
                  <Badge
                    variant="outline"
                    className={`text-xs font-medium ${VALIDATION_STYLES[log.validation]}`}
                  >
                    {log.validation}
                  </Badge>
                </TableCell>
              </TableRow>
            )
          })}
        </TableBody>
      </Table>
    </div>
  )
}
