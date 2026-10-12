import { Users } from 'lucide-react'
import type { ControlStats } from '../types'

interface QuorumWidgetProps {
  stats: ControlStats
}

function QuorumWidget({ stats }: QuorumWidgetProps) {
  const radius = 54
  const circumference = 2 * Math.PI * radius
  const offset = circumference - (stats.quorumPercent / 100) * circumference

  const qrVotes = Math.floor(stats.quorumPresent * 0.62)
  const manualVotes = stats.quorumPresent - qrVotes

  return (
    <div className="rounded-xl border border-outline-variant bg-surface p-6">
      <h3 className="mb-4 font-title-md text-title-md text-on-surface">
        Estado del Quórum
      </h3>

      <div className="flex items-center gap-6">
        <div className="relative h-32 w-32 flex-shrink-0">
          <svg className="h-full w-full -rotate-90" viewBox="0 0 120 120">
            <circle
              cx="60"
              cy="60"
              r={radius}
              fill="none"
              stroke="currentColor"
              strokeWidth="10"
              className="text-outline-variant"
            />
            <circle
              cx="60"
              cy="60"
              r={radius}
              fill="none"
              stroke="currentColor"
              strokeWidth="10"
              strokeDasharray={circumference}
              strokeDashoffset={offset}
              strokeLinecap="round"
              className="text-primary transition-all duration-700"
            />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <span className="text-2xl font-bold text-on-surface">
              {stats.quorumPercent}%
            </span>
            <span className="text-xs text-on-surface-variant">quórum</span>
          </div>
        </div>

        <div className="flex-1 space-y-3">
          <div className="flex items-center gap-2 text-sm text-on-surface">
            <Users className="h-4 w-4 text-primary" />
            <span>
              <span className="font-bold">{stats.quorumPresent}</span> / {stats.quorumTotal} presentes
            </span>
          </div>

          <div className="space-y-1.5">
            <div className="flex items-center justify-between text-xs">
              <span className="text-on-surface-variant">Voto QR</span>
              <span className="font-medium text-on-surface">{qrVotes}</span>
            </div>
            <div className="h-1.5 overflow-hidden rounded-full bg-outline-variant">
              <div
                className="h-full rounded-full bg-primary"
                style={{ width: `${(qrVotes / stats.quorumPresent) * 100}%` }}
              />
            </div>

            <div className="flex items-center justify-between text-xs">
              <span className="text-on-surface-variant">Voto Manual</span>
              <span className="font-medium text-on-surface">{manualVotes}</span>
            </div>
            <div className="h-1.5 overflow-hidden rounded-full bg-outline-variant">
              <div
                className="h-full rounded-full bg-amber-500"
                style={{ width: `${(manualVotes / stats.quorumPresent) * 100}%` }}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export { QuorumWidget }
