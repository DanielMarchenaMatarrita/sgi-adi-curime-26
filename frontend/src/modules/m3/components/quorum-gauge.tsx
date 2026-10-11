import type { M3Stats } from '@/modules/m3/types'

interface QuorumGaugeProps {
  stats: M3Stats
}

function QuorumGauge({ stats }: QuorumGaugeProps) {
  const radius = 70
  const stroke = 10
  const normalizedRadius = radius - stroke / 2
  const circumference = normalizedRadius * 2 * Math.PI
  const strokeDashoffset = circumference - (stats.quorumPercent / 100) * circumference

  return (
    <div className="flex flex-col items-center rounded-xl border border-outline-variant bg-surface p-6">
      <h3 className="mb-4 font-title-md text-title-md text-on-surface">Quorum de Asamblea</h3>

      <div className="relative flex items-center justify-center">
        <svg height={radius * 2} width={radius * 2} className="-rotate-90">
          <circle
            stroke="currentColor"
            fill="transparent"
            strokeWidth={stroke}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={0}
            r={normalizedRadius}
            cx={radius}
            cy={radius}
            className="text-surface-container-highest"
          />
          <circle
            stroke="currentColor"
            fill="transparent"
            strokeWidth={stroke}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            r={normalizedRadius}
            cx={radius}
            cy={radius}
            className="text-primary transition-all duration-500"
          />
        </svg>
        <div className="absolute flex flex-col items-center">
          <span className="text-[36px] font-bold text-on-surface">{stats.quorumPercent}%</span>
          <span className="text-xs text-on-surface-variant">de quorum</span>
        </div>
      </div>

      <p className="mt-4 text-sm text-on-surface-variant">
        {stats.present} de {stats.totalAssociates} asociados
      </p>

      <div className="mt-4 flex w-full gap-4 border-t border-outline-variant pt-4">
        <div className="flex flex-col items-center flex-1">
          <span className="text-[20px] font-bold text-primary">{stats.present}</span>
          <span className="text-xs text-on-surface-variant">Presentes</span>
        </div>
        <div className="flex flex-col items-center flex-1">
          <span className="text-[20px] font-bold text-on-surface">{stats.delegatesRequired}</span>
          <span className="text-xs text-on-surface-variant">Delegados Requeridos</span>
        </div>
      </div>
    </div>
  )
}

export { QuorumGauge }
