import { useState, useEffect } from 'react'
import { Verified, Printer, Smartphone, ShieldCheck } from 'lucide-react'
import type { Credential, M2AuditEntry } from '@/modules/m2/types'

function generateToken(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let result = 'CUR-7742-'
  for (let i = 0; i < 4; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

const auditColorMap: Record<string, string> = {
  primary: 'bg-primary',
  secondary: 'bg-secondary',
  tertiary: 'bg-tertiary',
}

interface WalletViewerProps {
  credential: Credential | null
  auditEntries: M2AuditEntry[]
}

function WalletViewer({ credential, auditEntries }: WalletViewerProps) {
  const [dynamicToken, setDynamicToken] = useState(credential?.token || 'CUR-7742-XXXX')

  useEffect(() => {
    if (!credential) return
    const interval = setInterval(() => {
      setDynamicToken(generateToken())
    }, 10000)
    return () => clearInterval(interval)
  }, [credential])

  if (!credential) {
    return (
      <div className="sticky top-24 rounded-xl bg-inverse-surface p-6 shadow-xl">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-title-md text-title-md text-on-primary">Digital Wallet</h2>
          <Verified className="h-6 w-6 text-inverse-primary" />
        </div>
        <p className="text-label-md text-surface-variant">
          Selecciona un asociado para ver su credencial.
        </p>
      </div>
    )
  }

  const firstName = credential.firstName
  const lastName = credential.lastName

  return (
    <div className="sticky top-24 rounded-xl bg-inverse-surface p-6 shadow-xl">
      <div className="flex items-center justify-between mb-4">
        <h2 className="font-title-md text-title-md text-on-primary">Digital Wallet</h2>
        <Verified className="h-6 w-6 text-inverse-primary" />
      </div>
      <p className="text-label-md text-surface-variant mb-4">
        Visualización previa del Carné QR Encriptado para {firstName} {lastName}.
      </p>

      {/* ID Card Preview */}
      <div className="relative w-full overflow-hidden rounded-2xl shadow-2xl transition-transform hover:scale-[1.02] cursor-default" style={{ aspectRatio: '1.6/1' }}>
        <div className="absolute inset-0 opacity-90" style={{ background: 'linear-gradient(135deg, #006948 0%, #2c322e 100%)' }} />
        <div className="relative z-10 flex h-full flex-col justify-between p-4">
          {/* Card Header */}
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-white p-1">
                <span className="text-primary text-[28px]">🌿</span>
              </div>
              <div>
                <p className="text-white text-sm font-bold leading-tight">SGI-CURIME</p>
                <p className="text-[10px] uppercase tracking-widest text-white/60">Digital Identity</p>
              </div>
            </div>
            <span className="rounded-full border border-white/20 bg-white/20 px-2 py-0.5 text-[9px] text-white">
              ADI-7742
            </span>
          </div>

          {/* Card Center */}
          <div className="flex items-center gap-3">
            <div className="flex h-20 w-20 items-center justify-center rounded-full border-2 border-white/50 bg-secondary-container text-lg font-bold text-secondary shadow-lg">
              {firstName.charAt(0)}{lastName.charAt(0)}
            </div>
            <div className="flex-1">
              <h4 className="text-headline-lg-mobile font-headline-lg-mobile leading-tight text-white">
                {firstName}<br />{lastName}
              </h4>
              <p className="mt-1 font-code-sm text-code-sm text-inverse-primary">
                ID: {credential.activeId || 'N/A'}
              </p>
            </div>
            <div className="flex items-center justify-center rounded bg-white p-1 shadow-inner">
              <div className="relative flex h-16 w-16 items-center justify-center overflow-hidden bg-slate-100">
                <div className="grid h-full w-full grid-cols-4 grid-rows-4 gap-0.5 p-1 opacity-80">
                  <div className="bg-primary" /><div className="bg-primary" /><div /><div className="bg-primary" />
                  <div className="bg-primary" /><div /><div className="bg-primary" /><div />
                  <div /><div className="bg-primary" /><div className="bg-primary" /><div className="bg-primary" />
                  <div className="bg-primary" /><div /><div className="bg-primary" /><div className="bg-primary" />
                </div>
                <div className="absolute inset-0 flex items-center justify-center bg-white/20">
                  <span className="text-primary text-[20px]">⊞</span>
                </div>
              </div>
            </div>
          </div>

          {/* Card Footer */}
          <div className="flex items-end justify-between">
            <div className="flex flex-col">
              <span className="text-[8px] uppercase text-white/40">Dynamic Token</span>
              <span className="font-mono text-[10px] tracking-[0.2em] text-white">{dynamicToken}</span>
            </div>
            <div className="flex items-center gap-1 rounded bg-black/30 px-2 py-1 text-[9px] text-white">
              <ShieldCheck className="h-3 w-3" />
              ENCRYPTED DATA
            </div>
          </div>
        </div>
      </div>

      {/* Wallet Actions */}
      <div className="mt-4 space-y-2">
        <button className="flex w-full items-center justify-center gap-2 rounded-lg bg-primary-container py-3 font-title-md text-title-md text-on-primary-container transition-all hover:brightness-110 active:scale-[0.99]">
          <Printer className="h-5 w-5" />
          Imprimir Carné Físico
        </button>
        <button className="flex w-full items-center justify-center gap-2 rounded-lg border border-outline-variant py-3 font-label-md text-label-md text-surface-variant transition-all hover:bg-white/5">
          <Smartphone className="h-5 w-5" />
          Enviar a Wallet Móvil
        </button>
      </div>

      {/* Security Audit Trail */}
      <div className="mt-4 border-t border-white/10 pt-4">
        <h4 className="mb-3 text-[11px] font-bold uppercase tracking-widest text-white/50">
          Historial de Identidad
        </h4>
        <div className="space-y-3">
          {auditEntries.map((entry) => (
            <div key={entry.id} className="flex gap-2">
              <div className={`w-1 rounded-full ${auditColorMap[entry.color]}`} />
              <div>
                <p className="text-[13px] font-medium text-on-primary">{entry.action}</p>
                <p className="text-[11px] text-white/40">
                  {new Date(entry.timestamp).toLocaleDateString('es-CR', {
                    day: 'numeric',
                    month: 'short',
                  })}{' '}
                  • {entry.actor}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export { WalletViewer }
