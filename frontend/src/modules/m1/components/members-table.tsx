import { useMemo } from 'react'
import { createColumnHelper } from '@tanstack/react-table'
import { Pencil, Eye, CheckCircle, XCircle } from 'lucide-react'
import { StatusChip } from '@/shared/components/shared'
import { DataTable } from '@/shared/components/shared'
import type { Member } from '@/modules/m1/types'

const columnHelper = createColumnHelper<Member>()

function getInitials(firstName: string, lastName: string): string {
  return `${firstName.charAt(0)}${lastName.split(' ')[0].charAt(0)}`.toUpperCase()
}

function calculateAge(dateOfBirth: string): number {
  const today = new Date()
  const birth = new Date(dateOfBirth)
  let age = today.getFullYear() - birth.getFullYear()
  const monthDiff = today.getMonth() - birth.getMonth()
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--
  }
  return age
}

const statusColorMap: Record<string, 'primary' | 'tertiary' | 'danger'> = {
  VIGENTE: 'primary',
  PENDIENTE: 'tertiary',
  SUSPENDIDO: 'danger',
}

interface MembersTableProps {
  data: Member[]
}

function MembersTable({ data }: MembersTableProps) {
  const columns = useMemo(
    () => [
      columnHelper.accessor(
        (row: Member) => `${row.firstName} ${row.lastName}`,
        {
          id: 'fullName',
          header: 'Nombre Completo',
          cell: (info) => {
            const member = info.row.original
            return (
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-secondary-container text-xs font-bold text-secondary">
                  {getInitials(member.firstName, member.lastName)}
                </div>
                <span className="font-medium text-on-surface">
                  {member.firstName} {member.lastName}
                </span>
              </div>
            )
          },
        }
      ),
      columnHelper.accessor('documentNumber', {
        header: 'Identificación (Cédula)',
        cell: (info) => (
          <span className="font-code-sm text-on-surface-variant">{info.getValue()}</span>
        ),
      }),
      columnHelper.accessor('dateOfBirth', {
        header: 'Edad',
        cell: (info) => (
          <span className="text-center text-on-surface">{calculateAge(info.getValue())}</span>
        ),
        sortingFn: (rowA, rowB) =>
          new Date(rowA.original.dateOfBirth).getTime() -
          new Date(rowB.original.dateOfBirth).getTime(),
      }),
      columnHelper.accessor('electoralValidation', {
        header: 'Validación Electoral',
        cell: (info) => {
          const isValid = info.getValue()
          return isValid ? (
            <div className="flex justify-center">
              <CheckCircle className="h-5 w-5 text-emerald-600" />
            </div>
          ) : (
            <div className="flex justify-center">
              <XCircle className="h-5 w-5 text-red-500" />
            </div>
          )
        },
        enableSorting: false,
      }),
      columnHelper.accessor('status', {
        header: 'Estado Civil / Legal',
        cell: (info) => (
          <StatusChip
            label={info.getValue()}
            variant={statusColorMap[info.getValue()]}
            size="sm"
          />
        ),
      }),
      columnHelper.display({
        id: 'actions',
        header: 'Acciones',
        cell: () => (
          <div className="flex justify-end gap-2">
            <button className="rounded-lg p-1.5 text-on-surface-variant transition-colors hover:bg-primary-container/10 hover:text-primary">
              <Pencil className="h-4 w-4" />
            </button>
            <button className="rounded-lg p-1.5 text-on-surface-variant transition-colors hover:bg-primary-container/10 hover:text-primary">
              <Eye className="h-4 w-4" />
            </button>
          </div>
        ),
        enableSorting: false,
      }),
    ],
    []
  )

  return (
    <DataTable
      columns={columns}
      data={data}
      title="MIEMBROS DE LA COMUNIDAD"
      searchable
      searchPlaceholder="Buscar miembros..."
    />
  )
}

export { MembersTable }
