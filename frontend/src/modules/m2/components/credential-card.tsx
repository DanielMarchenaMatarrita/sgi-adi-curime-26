import { Lock, LockKeyholeOpen, QrCode, RefreshCw } from 'lucide-react'
import type { Credential } from '@/modules/m2/types'

function getInitials(firstName: string, lastName: string): string {
  return `${firstName.charAt(0)}${lastName.split(' ')[0].charAt(0)}`.toUpperCase()
}

const statusConfig: Record<
  string,
  { label: string; bg: string; text: string }
> = {
  VERIFICADO: { label: 'Verificado', bg: 'bg-primary/10', text: 'text-primary' },
  PENDIENTE: { label: 'Pendiente', bg: 'bg-tertiary-container/20', text: 'text-tertiary' },
  REVOCADO: { label: 'Revocado', bg: 'bg-error-container/20', text: 'text-error' },
}

interface CredentialCardProps {
  credential: Credential
  onGenerate?: (id: string) => void
  onSync?: (id: string) => void
  onSelect?: (id: string) => void
}

function CredentialCard({ credential, onGenerate, onSync, onSelect }: CredentialCardProps) {
  const status = statusConfig[credential.status] || statusConfig.PENDIENTE
  const isPending = credential.status === 'PENDIENTE'
  const isVerified = credential.status === 'VERIFICADO'

  return (
    <div
      className={`rounded-xl border border-outline-variant bg-surface overflow-hidden transition-all duration-300 hover:shadow-md ${
        isPending ? 'opacity-80 grayscale-[0.3]' : ''
      }`}
      onClick={() => onSelect?.(credential.id)}
    >
      <div className="flex gap-3 p-4">
        <div
          className={`flex h-16 w-16 shrink-0 items-center justify-center rounded-full text-sm font-bold ${
            isVerified
              ? 'border-2 border-primary-fixed bg-secondary-container text-secondary'
              : 'border-2 border-outline-variant bg-surface-container-highest text-on-surface-variant'
          }`}
        >
          {getInitials(credential.firstName, credential.lastName)}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2">
            <h3 className="font-title-md text-title-md text-on-surface truncate">
              {credential.firstName} {credential.lastName}
            </h3>
            <span
              className={`shrink-0 rounded px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider ${status.bg} ${status.text}`}
            >
              {status.label}
            </span>
          </div>
          <p className="mt-1 font-code-sm text-code-sm text-secondary">
            UUID:{' '}
            <span className="rounded bg-secondary-container px-1 text-on-secondary-container">
              {credential.uuid.split('-').slice(0, 2).join('-')}...
              {credential.uuid.split('-').slice(-2).join('-')}
            </span>
          </p>
          <div className="mt-1 flex items-center gap-1 text-[11px] font-medium">
            {isVerified ? (
              <>
                <Lock className="h-3.5 w-3.5 text-primary" />
                <span className="text-primary">AES-256 Encrypted</span>
              </>
            ) : (
              <>
                <LockKeyholeOpen className="h-3.5 w-3.5 text-on-surface-variant" />
                <span className="text-on-surface-variant">Encryption Pending</span>
              </>
            )}
          </div>
        </div>
      </div>
      <div className="flex items-center justify-between bg-surface-container-low px-4 py-2">
        <span className="text-label-md italic text-on-surface-variant">
          {credential.activeId ? `ID Activo: ${credential.activeId}` : 'ID Inactivo'}
        </span>
        {isVerified ? (
          <button
            onClick={(e) => {
              e.stopPropagation()
              onGenerate?.(credential.id)
            }}
            className="flex items-center gap-1 rounded bg-primary px-3 py-1.5 text-label-md text-on-primary shadow-sm transition-colors hover:bg-primary-container"
          >
            <QrCode className="h-4 w-4" />
            Generar Credencial
          </button>
        ) : isPending ? (
          <button
            onClick={(e) => {
              e.stopPropagation()
              onSync?.(credential.id)
            }}
            className="flex items-center gap-1 rounded bg-secondary px-3 py-1.5 text-label-md text-on-secondary shadow-sm transition-colors hover:opacity-90"
          >
            <RefreshCw className="h-4 w-4" />
            Sincronizar
          </button>
        ) : null}
      </div>
    </div>
  )
}

export { CredentialCard }
