import { createFileRoute } from '@tanstack/react-router'
import { PageHeader } from '@/shared/components/shared'
import { DonationForm } from '@/modules/m6/components/donation-form'
import { ReceiptPreview } from '@/modules/m6/components/receipt-preview'
import { DonationAudit } from '@/modules/m6/components/donation-audit'
import { MOCK_DONATION, MOCK_RECEIPT, MOCK_M6_AUDIT } from '@/modules/m6/data/mock-data'

export const Route = createFileRoute('/_modules/m6')({
  component: M6Page,
})

function M6Page() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Registro de Nueva Donación"
        subtitle="Gestión integral de donaciones con trazabilidad fiscal y comprobantes oficiales"
      />

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        <DonationForm initialData={MOCK_DONATION} />
        <ReceiptPreview receipt={MOCK_RECEIPT} donation={MOCK_DONATION} />
      </div>

      <DonationAudit entries={MOCK_M6_AUDIT} />
    </div>
  )
}
