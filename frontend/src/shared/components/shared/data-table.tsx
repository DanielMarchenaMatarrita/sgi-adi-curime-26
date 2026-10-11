import { useState } from 'react'
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  getFilteredRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
  type ColumnFiltersState,
} from '@tanstack/react-table'
import { cn } from '@/shared/lib/utils'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shared/components/ui/table'
import { Button } from '@/shared/components/ui/button'
import { Input } from '@/shared/components/ui/input'
import {
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Search,
} from 'lucide-react'

interface DataTableProps<TData> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  columns: ColumnDef<TData, any>[]
  data: TData[]
  title?: string
  totalRecords?: number
  pageSize?: number
  currentPage?: number
  onPageChange?: (page: number) => void
  serverPagination?: boolean
  searchPlaceholder?: string
  searchable?: boolean
  sortable?: boolean
  className?: string
}

function DataTable<TData>({
  columns,
  data,
  title,
  totalRecords,
  pageSize = 10,
  currentPage,
  onPageChange,
  serverPagination = false,
  searchPlaceholder = 'Buscar...',
  searchable = true,
  sortable = true,
  className,
}: DataTableProps<TData>) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
  const [globalFilter, setGlobalFilter] = useState('')

  const table = useReactTable({
    data,
    columns,
    state: {
      sorting,
      columnFilters,
      globalFilter,
    },
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: sortable ? getSortedRowModel() : undefined,
    getPaginationRowModel: serverPagination ? undefined : getPaginationRowModel(),
    getFilteredRowModel: searchable ? getFilteredRowModel() : undefined,
    initialState: {
      pagination: { pageIndex: currentPage ?? 0, pageSize },
    },
  })

  const filteredCount = table.getFilteredRowModel().rows.length
  const pageIndex = currentPage ?? table.getState().pagination.pageIndex
  const pageCount = serverPagination
    ? Math.ceil((totalRecords ?? 0) / pageSize)
    : table.getPageCount()
  const goToPage = (nextPage: number) => {
    if (serverPagination) {
      onPageChange?.(nextPage)
      return
    }
    table.setPageIndex(nextPage)
  }

  return (
    <div
      className={cn(
        'overflow-hidden rounded-xl border border-outline-variant bg-surface-container-lowest shadow-sm',
        className
      )}
    >
      {(title || searchable) && (
        <div className="flex items-center justify-between border-b border-outline-variant bg-surface-container-low px-md py-sm">
          {title && (
            <h3 className="text-sm font-bold uppercase tracking-wider text-on-surface-variant">
               {title} ({serverPagination ? totalRecords ?? 0 : filteredCount})
            </h3>
          )}
          {searchable && (
            <div className="relative">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-on-surface-variant" />
              <Input
                value={globalFilter ?? ''}
                onChange={(e) => setGlobalFilter(e.target.value)}
                placeholder={searchPlaceholder}
                className="h-8 w-64 rounded-full pl-9 text-sm"
              />
            </div>
          )}
        </div>
      )}

      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id} className="border-b border-outline-variant">
                {headerGroup.headers.map((header) => (
                  <TableHead
                    key={header.id}
                    className="text-xs font-bold uppercase tracking-wider text-on-surface-variant"
                  >
                    {header.isPlaceholder ? null : sortable && header.column.getCanSort() ? (
                      <button
                        className="flex items-center gap-1 hover:text-primary transition-colors"
                        onClick={header.column.getToggleSortingHandler()}
                      >
                        {flexRender(header.column.columnDef.header, header.getContext())}
                        {header.column.getIsSorted() === 'asc' ? (
                          <ArrowUp className="h-3 w-3" />
                        ) : header.column.getIsSorted() === 'desc' ? (
                          <ArrowDown className="h-3 w-3" />
                        ) : (
                          <ArrowUpDown className="h-3 w-3 opacity-40" />
                        )}
                      </button>
                    ) : (
                      flexRender(header.column.columnDef.header, header.getContext())
                    )}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow
                  key={row.id}
                  className="border-b border-outline-variant/50 transition-colors hover:bg-primary/5"
                >
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-24 text-center">
                  <p className="text-sm text-on-surface-variant">No se encontraron registros.</p>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

       {pageCount > 1 && (
        <div className="flex items-center justify-between border-t border-outline-variant bg-surface-container-low px-md py-sm">
          <span className="text-sm text-on-surface-variant">
             Mostrando {pageIndex * pageSize + 1}–
             {Math.min((pageIndex + 1) * pageSize, totalRecords ?? filteredCount)} de{' '}
            {totalRecords ?? filteredCount}
          </span>
          <div className="flex items-center gap-1">
            <Button
              variant="outline"
              size="sm"
               onClick={() => goToPage(0)}
               disabled={pageIndex === 0}
              className="h-8 w-8 p-0"
            >
              <ChevronsLeft className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
               onClick={() => goToPage(pageIndex - 1)}
               disabled={pageIndex === 0}
              className="h-8 w-8 p-0"
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
             {Array.from({ length: Math.min(5, pageCount) }, (_, i) => {
               const pageIndex = i + Math.max(
                 0,
                 (currentPage ?? table.getState().pagination.pageIndex) - 2
               )
               if (pageIndex >= pageCount) return null
              return (
                <Button
                  key={pageIndex}
                   variant={pageIndex === (currentPage ?? table.getState().pagination.pageIndex) ? 'default' : 'outline'}
                  size="sm"
                   onClick={() => goToPage(pageIndex)}
                  className="h-8 w-8 p-0"
                >
                  {pageIndex + 1}
                </Button>
              )
            })}
            <Button
              variant="outline"
              size="sm"
               onClick={() => goToPage(pageIndex + 1)}
               disabled={pageIndex >= pageCount - 1}
              className="h-8 w-8 p-0"
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
               onClick={() => goToPage(pageCount - 1)}
               disabled={pageIndex >= pageCount - 1}
              className="h-8 w-8 p-0"
            >
              <ChevronsRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}

export { DataTable }
export type { DataTableProps }
