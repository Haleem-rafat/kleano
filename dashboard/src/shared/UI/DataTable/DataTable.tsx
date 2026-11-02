import React from 'react';
import { useTranslation } from 'react-i18next';
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  useReactTable,
  getSortedRowModel,
  SortingState,
  getFilteredRowModel,
  ColumnFiltersState,
  VisibilityState,
} from '@tanstack/react-table';
import { IoChevronUp, IoChevronDown, IoEyeOutline, IoSearchOutline } from 'react-icons/io5';
import { ChevronUpDownIcon } from '@heroicons/react/24/solid';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';
import { Button } from '@shadecn/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from '@shadecn/components/ui/dropdown-menu';
import { cn } from '@/shadecn/lib/utils';

/** Columns with these ids stay pinned to the end edge so row actions are always visible. */
const PINNED_IDS = ['actions', 'action', 'delete'];
const isPinned = (id: string) => PINNED_IDS.includes(id);
const PINNED_HEAD =
  'sticky end-0 z-[1] bg-card shadow-[inset_1px_0_0_hsl(var(--border))] rtl:shadow-[inset_-1px_0_0_hsl(var(--border))]';
const PINNED_CELL =
  'sticky end-0 z-[1] bg-card shadow-[inset_1px_0_0_hsl(var(--border))] group-hover:bg-muted rtl:shadow-[inset_-1px_0_0_hsl(var(--border))]';

export interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[];
  data: TData[];
  isLoading?: boolean;
  onRowClick?: (row: TData) => void;
  className?: string;
  emptyStateComponent?: React.ReactNode;
  enableSorting?: boolean;
  enableFilters?: boolean;
  enableColumnVisibility?: boolean;
  enableRowSelection?: boolean;
  initialSorting?: SortingState;
  initialColumnFilters?: ColumnFiltersState;
  initialColumnVisibility?: VisibilityState;
  showColumnToggle?: boolean;
  /** Shows a search box that filters the loaded rows. */
  searchable?: boolean;
  searchPlaceholder?: string;
  /** Number of placeholder rows while loading. */
  skeletonRows?: number;
  getRowId?: (row: TData, index: number) => string;
}

export function DataTable<TData, TValue>({
  columns,
  data,
  isLoading = false,
  onRowClick,
  className = '',
  emptyStateComponent,
  enableSorting = true,
  enableFilters = true,
  enableColumnVisibility = true,
  enableRowSelection = false,
  initialSorting = [],
  initialColumnFilters = [],
  initialColumnVisibility = {},
  showColumnToggle = true,
  searchable = false,
  searchPlaceholder,
  skeletonRows = 6,
  getRowId,
}: DataTableProps<TData, TValue>) {
  const { t } = useTranslation();
  const [sorting, setSorting] = React.useState<SortingState>(initialSorting);
  const [columnFilters, setColumnFilters] =
    React.useState<ColumnFiltersState>(initialColumnFilters);
  const [columnVisibility, setColumnVisibility] =
    React.useState<VisibilityState>(initialColumnVisibility);
  const [rowSelection, setRowSelection] = React.useState({});
  const [globalFilter, setGlobalFilter] = React.useState('');

  const table = useReactTable({
    data: data ?? [],
    columns,
    getRowId,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: enableSorting ? getSortedRowModel() : undefined,
    getFilteredRowModel: enableFilters || searchable ? getFilteredRowModel() : undefined,
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    state: { sorting, columnFilters, columnVisibility, rowSelection, globalFilter },
    enableSorting,
    enableFilters: enableFilters || searchable,
    enableRowSelection,
  });

  const rows = table.getRowModel().rows;
  const visibleColumns = table.getVisibleLeafColumns().length || columns.length;
  const hideableColumns = table.getAllColumns().filter((column) => column.getCanHide());
  const showToggle = showColumnToggle && enableColumnVisibility && hideableColumns.length > 1;

  return (
    <div className={cn('space-y-3', className)}>
      {(searchable || showToggle) && (
        <div className="flex flex-wrap items-center justify-between gap-2">
          {searchable ? (
            <label className="relative w-full sm:w-72">
              <IoSearchOutline className="pointer-events-none absolute start-3 top-1/2 z-10 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="search"
                value={globalFilter}
                onChange={(e) => setGlobalFilter(e.target.value)}
                placeholder={searchPlaceholder || t('search')}
                aria-label={searchPlaceholder || t('search')}
                className="h-9 w-full rounded-md border border-input bg-card pe-3 ps-9 text-sm text-foreground placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </label>
          ) : (
            <span />
          )}
          {showToggle && (
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" className="h-9 gap-2">
                  <IoEyeOutline className="h-4 w-4" />
                  {t('columns')}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48">
                {hideableColumns.map((column) => (
                  <DropdownMenuCheckboxItem
                    key={column.id}
                    className="capitalize"
                    checked={column.getIsVisible()}
                    onCheckedChange={(value) => column.toggleVisibility(!!value)}>
                    {typeof column.columnDef.header === 'string'
                      ? column.columnDef.header
                      : column.id}
                  </DropdownMenuCheckboxItem>
                ))}
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>
      )}

      <div className="overflow-x-auto rounded-lg border border-border bg-card">
        <Table className="w-full" aria-busy={isLoading}>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id} className="hover:bg-transparent">
                {headerGroup.headers.map((header) => {
                  const sorted = header.column.getIsSorted();
                  return (
                    <TableHead
                      key={header.id}
                      className={cn(
                        'whitespace-nowrap',
                        isPinned(header.column.id) && PINNED_HEAD
                      )}>
                      {header.isPlaceholder ? null : header.column.getCanSort() ? (
                        <button
                          type="button"
                          onClick={header.column.getToggleSortingHandler()}
                          className="-mx-1 inline-flex items-center gap-1 rounded px-1 hover:text-foreground">
                          {flexRender(header.column.columnDef.header, header.getContext())}
                          {sorted === 'asc' ? (
                            <IoChevronUp className="h-3.5 w-3.5" />
                          ) : sorted === 'desc' ? (
                            <IoChevronDown className="h-3.5 w-3.5" />
                          ) : (
                            <ChevronUpDownIcon className="h-3.5 w-3.5 opacity-40" />
                          )}
                        </button>
                      ) : (
                        flexRender(header.column.columnDef.header, header.getContext())
                      )}
                    </TableHead>
                  );
                })}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: skeletonRows }).map((_, i) => (
                <TableRow key={`skeleton-${i}`} className="hover:bg-transparent">
                  {Array.from({ length: visibleColumns }).map((__, j) => (
                    <TableCell key={j}>
                      <div className="max-w-40 h-4 w-3/4 animate-pulse rounded bg-muted" />
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : rows.length ? (
              rows.map((row) => (
                <TableRow
                  key={row.id}
                  data-state={row.getIsSelected() && 'selected'}
                  className={cn('group', onRowClick && 'cursor-pointer hover:bg-primary/5')}
                  onClick={onRowClick ? () => onRowClick(row.original) : undefined}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell
                      key={cell.id}
                      onClick={isPinned(cell.column.id) ? (e) => e.stopPropagation() : undefined}
                      className={cn('whitespace-nowrap', isPinned(cell.column.id) && PINNED_CELL)}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={visibleColumns} className="py-12 text-center">
                  {globalFilter || !emptyStateComponent ? (
                    <div>
                      <p className="text-sm font-medium text-foreground">{t('noDataAvailable')}</p>
                      <p className="mt-1 text-[13px] text-muted-foreground">
                        {t('noResultsForFilters')}
                      </p>
                    </div>
                  ) : (
                    emptyStateComponent
                  )}
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}

export default DataTable;
