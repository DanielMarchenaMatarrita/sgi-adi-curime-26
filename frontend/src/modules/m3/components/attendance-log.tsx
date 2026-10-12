import { QrCode, UserCheck } from 'lucide-react'
import type { Attendee } from '@/modules/m3/types'

interface AttendanceLogProps {
  attendees: Attendee[]
}

function AttendanceLog({ attendees }: AttendanceLogProps) {
  return (
    <div className="flex flex-col rounded-xl border border-outline-variant bg-surface p-4">
      <h3 className="mb-1 font-title-md text-title-md text-on-surface">Registro en Vivo</h3>
      <p className="mb-4 text-xs text-on-surface-variant">Asistencia reciente de asociados</p>

      <div className="flex flex-col gap-3">
        {attendees.map((attendee, index) => (
          <div key={attendee.id} className="flex items-start gap-3">
            <div className="flex flex-col items-center">
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary-container">
                <UserCheck className="h-4 w-4 text-on-primary-container" />
              </div>
              {index < attendees.length - 1 && (
                <div className="mt-1 h-6 w-px bg-outline-variant" />
              )}
            </div>

            <div className="flex-1 pb-3">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-on-surface">{attendee.memberName}</span>
                <span
                  className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-medium ${
                    attendee.verifiedBy === 'QR'
                      ? 'bg-primary-container text-on-primary-container'
                      : 'bg-secondary-container text-on-secondary-container'
                  }`}
                >
                  {attendee.verifiedBy === 'QR' ? (
                    <QrCode className="h-3 w-3" />
                  ) : (
                    <UserCheck className="h-3 w-3" />
                  )}
                  {attendee.verifiedBy === 'QR' ? 'Verificado QR' : 'Manual'}
                </span>
              </div>
              <div className="mt-1 flex items-center gap-2 text-xs text-on-surface-variant">
                <span>{attendee.documentNumber}</span>
                <span>-</span>
                <span>{new Date(attendee.timestamp).toLocaleTimeString('es-CR', { hour: '2-digit', minute: '2-digit' })}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export { AttendanceLog }
