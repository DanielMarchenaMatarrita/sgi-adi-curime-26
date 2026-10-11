import { BadgeCheck, TrendingUp, Wallet } from 'lucide-react'
import { BentoCard, ProgressBar } from '@/shared/components/shared'
import { AccessLevelIndicator } from './access-level-indicator'
import { formatCurrency } from '@/shared/lib/utils'
import type { VecinoProfile } from '../types'

interface ProfileStatusCardProps {
  profile: VecinoProfile
}

export function ProfileStatusCard({ profile }: ProfileStatusCardProps) {
  const solvencyPercent = profile.solvencyIssued ? 100 : 0
  const contributionProgress = Math.min(100, (profile.annualContributions / 250000) * 100)

  return (
    <BentoCard variant="shadow" className="h-full">
      <div className="space-y-4">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="font-display text-lg italic text-on-surface">{profile.fullName}</h3>
            <p className="text-xs text-on-surface-variant">{profile.community}</p>
            <p className="text-xs text-on-surface-variant/60">{profile.district}</p>
          </div>
          <AccessLevelIndicator level={profile.accessLevel} />
        </div>

        <div className="space-y-3">
          <div className="flex items-center justify-between rounded-lg bg-surface-container-low px-3 py-2.5">
            <div className="flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-primary" />
              <span className="text-xs font-medium text-on-surface-variant">Aportes del año</span>
            </div>
            <span className="font-display text-sm italic font-bold text-primary">
              {formatCurrency(profile.annualContributions)}
            </span>
          </div>

          <ProgressBar
            percent={contributionProgress}
            label="Meta anual ₡250.000"
            color="primary"
            size="sm"
            showPercent
          />

          <div className="flex items-center justify-between rounded-lg bg-surface-container-low px-3 py-2.5">
            <div className="flex items-center gap-2">
              <Wallet className="h-4 w-4 text-success" />
              <span className="text-xs font-medium text-on-surface-variant">Saldo pendiente</span>
            </div>
            <span className="font-display text-sm italic font-bold text-success">
              {formatCurrency(profile.outstandingBalance)}
            </span>
          </div>

          <div className="flex items-center justify-between rounded-lg bg-surface-container-low px-3 py-2.5">
            <div className="flex items-center gap-2">
              <BadgeCheck className="h-4 w-4 text-info" />
              <span className="text-xs font-medium text-on-surface-variant">Solvencia</span>
            </div>
            <span
              className={`text-xs font-bold ${
                profile.solvencyIssued ? 'text-success' : 'text-warning'
              }`}
            >
              {profile.solvencyIssued ? 'Emitida' : 'Pendiente'}
            </span>
          </div>
        </div>

        <ProgressBar
          percent={solvencyPercent}
          color={profile.solvencyIssued ? 'success' : 'warning'}
          size="sm"
        />
      </div>
    </BentoCard>
  )
}
