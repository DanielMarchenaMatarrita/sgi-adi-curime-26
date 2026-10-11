import { createFileRoute } from '@tanstack/react-router'
import { TreePine, FileText, PenLine } from 'lucide-react'
import { PageHeader, StatCard } from '@/shared/components/shared'
import { DocumentEditor } from '@/modules/m4/components/document-editor'
import { VersionHistory } from '@/modules/m4/components/version-history'
import { SignatureList } from '@/modules/m4/components/signature-list'
import {
  MOCK_ACTA,
  MOCK_VERSIONS,
  MOCK_SIGNATURES,
  MOCK_M4_STATS,
} from '@/modules/m4/data/mock-data'

function M4Page() {
  return (
    <div className="space-y-4">
      <PageHeader
        title="Gestión de Actas y Firma Digital"
        subtitle="Creación, control de versiones y firma digital de actas de sesión"
        badge={{ label: 'Sistema de Firmas Activo', variant: 'success' }}
        breadcrumbs={[
          { label: 'Módulos' },
          { label: 'Actas y Firmas' },
        ]}
        actions={[]}
      />

      <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
        <StatCard
          label="Árboles Salvados"
          value={MOCK_M4_STATS.treesSaved}
          icon={<TreePine className="h-6 w-6" />}
          color="success"
        />
        <StatCard
          label="Total Actas"
          value={MOCK_M4_STATS.totalActas}
          icon={<FileText className="h-6 w-6" />}
          color="primary"
        />
        <StatCard
          label="Firmas Pendientes"
          value={MOCK_M4_STATS.pendingSignatures}
          icon={<PenLine className="h-6 w-6" />}
          color="tertiary"
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-12">
        <div className="lg:col-span-8">
          <DocumentEditor acta={MOCK_ACTA} />
        </div>
        <div className="space-y-4 lg:col-span-4">
          <VersionHistory
            versions={MOCK_VERSIONS}
            currentVersion={MOCK_ACTA.version}
          />
          <SignatureList signatures={MOCK_SIGNATURES} />
        </div>
      </div>
    </div>
  )
}


// Define the route for the M4 module: Esta es la que me esta dando
export const Route = createFileRoute('/_modules/m4')({
  component: M4Page,
})