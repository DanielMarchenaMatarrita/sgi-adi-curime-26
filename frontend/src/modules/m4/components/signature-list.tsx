import { PenLine, CheckCircle2, Clock } from 'lucide-react'
import { BentoCard, StatusChip } from '@/shared/components/shared'
import type { BoardSignature } from '@/modules/m4/types'
import { cn } from '@/shared/lib/utils'

interface SignatureListProps {
  signatures: BoardSignature[]
}

function SignatureList({ signatures }: SignatureListProps) {
  const signedCount = signatures.filter((s) => s.status === 'FIRMADO').length
  const totalCount = signatures.length

  return (
    <BentoCard
      variant="solid"
      header={
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-sm">
            <PenLine className="h-5 w-5 text-tertiary" />
            <span className="font-title-sm text-title-sm text-on-surface">
              Firmas del Consejo
            </span>
          </div>
          <span className="text-xs text-on-surface-variant">
            {signedCount}/{totalCount} firmadas
          </span>
        </div>
      }
    >
      <div className="space-y-3">
        {signatures.map((sig) => (
          <div
            key={sig.documentNumber}
            className={cn(
              'flex items-center justify-between rounded-lg border p-sm',
              sig.status === 'FIRMADO'
                ? 'border-emerald-200 bg-emerald-50/50'
                : 'border-outline-variant/30 bg-surface-container-lowest'
            )}
          >
            <div className="flex items-center gap-sm">
              <div
                className={cn(
                  'flex h-10 w-10 items-center justify-center rounded-full',
                  sig.status === 'FIRMADO'
                    ? 'bg-emerald-100 text-emerald-600'
                    : 'bg-amber-100 text-amber-600'
                )}
              >
                {sig.status === 'FIRMADO' ? (
                  <CheckCircle2 className="h-5 w-5" />
                ) : (
                  <Clock className="h-5 w-5" />
                )}
              </div>
              <div>
                <p className="text-sm font-medium text-on-surface">{sig.memberName}</p>
                <p className="text-[10px] text-on-surface-variant">
                  {sig.role} · {sig.documentNumber}
                </p>
              </div>
            </div>
            <StatusChip
              variant={sig.status === 'FIRMADO' ? 'success' : 'warning'}
              label={sig.status}
              size="sm"
            />
          </div>
        ))}
      </div>
    </BentoCard>
  )
}

export { SignatureList }