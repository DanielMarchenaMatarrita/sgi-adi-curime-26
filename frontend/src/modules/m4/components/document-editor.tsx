import { FileText, Shield, Hash } from 'lucide-react'
import { BentoCard } from '@/shared/components/shared'
import type { Acta } from '@/modules/m4/types'
import { StatusChip } from '@/shared/components/shared'

interface DocumentEditorProps {
  acta: Acta
}

const statusVariantMap: Record<string, 'primary' | 'success' | 'warning'> = {
  BORRADOR: 'warning',
  APROBADA: 'success',
  FIRMANDO: 'primary',
}

function DocumentEditor({ acta }: DocumentEditorProps) {
  return (
    <BentoCard
      variant="solid"
      header={
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-sm">
            <FileText className="h-5 w-5 text-primary" />
            <span className="font-title-sm text-title-sm text-on-surface">
              Editor de Documento
            </span>
          </div>
          <div className="flex items-center gap-sm">
            <StatusChip
              variant={statusVariantMap[acta.status]}
              label={acta.status}
              size="sm"
            />
            <span className="text-xs text-on-surface-variant">v{acta.version}</span>
          </div>
        </div>
      }
    >
      <div className="relative">
        <div className="mb-4 border-b border-outline-variant/30 pb-4">
          <h2 className="font-title-md text-title-md text-on-surface">{acta.title}</h2>
          <div className="mt-2 flex items-center gap-md text-xs text-on-surface-variant">
            <span>Sesión: {acta.sessionNumber}</span>
            <span>Fecha: {acta.date}</span>
          </div>
        </div>

        <div className="prose prose-sm max-w-none text-on-surface">
          {acta.content.split('\n\n').map((paragraph, i) => (
            <p key={i} className="mb-3 leading-relaxed text-on-surface-variant">
              {paragraph}
            </p>
          ))}
        </div>

        <div className="absolute right-4 bottom-4 flex items-center gap-2 rounded-lg border border-emerald-200 bg-emerald-50 px-3 py-2">
          <Shield className="h-5 w-5 text-emerald-600" />
          <div className="flex flex-col">
            <span className="text-[10px] font-bold uppercase tracking-wider text-emerald-700">
              Sello Digital
            </span>
            <span className="text-[9px] text-emerald-600">Activo y verificado</span>
          </div>
        </div>

        <div className="mt-6 flex items-center gap-sm rounded-lg bg-surface-container-low px-3 py-2">
          <Hash className="h-4 w-4 text-on-surface-variant" />
          <span className="font-mono text-xs text-on-surface-variant">
            {acta.integrityHash}
          </span>
        </div>
      </div>
    </BentoCard>
  )
}

export { DocumentEditor }