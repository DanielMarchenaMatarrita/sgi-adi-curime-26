import { useMemo } from 'react'
import { createColumnHelper } from '@tanstack/react-table'
import { StatusChip } from '@/shared/components/shared'
import { DataTable } from '@/shared/components/shared'
import type { AffiliateListItem } from '@/shared/api/contracts'

const columnHelper = createColumnHelper<AffiliateListItem>()

function getInitials(fullName: string): string {
  return fullName
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((name) => name.charAt(0))
    .join('')
    .toUpperCase()
}

function formatAffiliationDate(value: string): string {
  const date = new Date(value)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat('es-CR', { dateStyle: 'medium' }).format(date)
}

const statusColorMap: Record<string, 'primary' | 'tertiary' | 'danger'> = {
  ACTIVE: 'primary',
  INACTIVE: 'danger',
}

interface MembersTableProps {
  data: AffiliateListItem[]
  total: number
  limit: number
  offset: number
  onPageChange: (offset: number) => void
}

function MembersTable({ data, total, limit, offset, onPageChange }: MembersTableProps) {
  const columns = useMemo(
    () => [
      columnHelper.accessor(
        (row: AffiliateListItem) => row.fullName,
        {
          id: 'fullName',
          header: 'Nombre Completo',
          cell: (info) => {
            const member = info.row.original
            return (
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-secondary-container text-xs font-bold text-secondary">
                  {getInitials(member.fullName)}
                </div>
                <span className="font-medium text-on-surface">
                  {member.fullName}
                </span>
              </div>
            )
          },
        }
      ),
      columnHelper.accessor('affiliateType', {
        header: 'Tipo de afiliación',
        cell: (info) => info.getValue() ?? 'Sin especificar',
      }),
      columnHelper.accessor('affiliationDate', {
        header: 'Fecha de afiliación',
        cell: (info) => formatAffiliationDate(info.getValue()),
      }),
      columnHelper.accessor('status', {
        header: 'Estado',
        cell: (info) => (
          <StatusChip
            label={info.getValue() === 'ACTIVE' ? 'Activo' : 'Inactivo'}
            variant={statusColorMap[info.getValue()]}
            size="sm"
          />
        ),
      }),
    ],
    []
  )

  return (
    <DataTable
      columns={columns}
      data={data}
      title="AFILIADOS"
      totalRecords={total}
      pageSize={limit}
      currentPage={Math.floor(offset / limit)}
      onPageChange={(page) => onPageChange(page * limit)}
      serverPagination
      searchable={false}
    />
  )
}

export { MembersTable }
