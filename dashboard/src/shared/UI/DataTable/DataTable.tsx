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
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';
import { ThreeDotsLoader } from '@UI/Index';
import { IoChevronUp, IoChevronDown, IoEyeOutline } from 'react-icons/io5';
import { Button } from '@shadecn/components/ui/button';
import { ChevronUpDownIcon } from '@heroicons/react/24/solid';
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from '@shadecn/components/ui/dropdown-menu';

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
}: DataTableProps<TData, TValue>) {
  const { t } = useTranslation();
  const [sorting, setSorting] = React.useState<SortingState>(initialSorting);
  const [columnFilters, setColumnFilters] =
    React.useState<ColumnFiltersState>(initialColumnFilters);
  const [columnVisibility, setColumnVisibility] =
    React.useState<VisibilityState>(initialColumnVisibility);
  const [rowSelection, setRowSelection] = React.useState({});

  const table = useReactTable({
    data,
    columns,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: enableSorting ? getSortedRowModel() : undefined,
    getFilteredRowModel: enableFilters ? getFilteredRowModel() : undefined,
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    state: {
      sorting,
      columnFilters,
      columnVisibility,
      rowSelection,
    },
    enableSorting,
    enableFilters,
    enableRowSelection,
  });

  const handleRowClick = (rowData: TData) => {
    if (onRowClick) {
      onRowClick(rowData);
    }
  };

  return (
    <div className={`relative ${isLoading ? 'min-h-64' : ''} ${className}`}>
      {isLoading && <ThreeDotsLoader />}

      {!isLoading && (
        <>
          {/* Column Visibility Toggle */}
          {showColumnToggle && enableColumnVisibility && (
            <div className="mb-3 flex justify-end">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="outline" size="sm" className="h-8 gap-2">
                    <IoEyeOutline className="h-4 w-4" />
                    {t('columns')}
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-48">
                  {table
                    .getAllColumns()
                    .filter((column) => column.getCanHide())
                    .map((column) => {
                      return (
                        <DropdownMenuCheckboxItem
                          key={column.id}
                          className="capitalize"
                          checked={column.getIsVisible()}
                          onCheckedChange={(value) => column.toggleVisibility(!!value)}>
                          {column.id}
                        </DropdownMenuCheckboxItem>
                      );
                    })}
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          )}

          <div>
            <Table className="w-full">
              <TableHeader>
                {table.getHeaderGroups().map((headerGroup) => (
                  <TableRow key={headerGroup.id}>
                    {headerGroup.headers.map((header) => (
                      <TableHead key={header.id}>
                        {header.isPlaceholder ? null : (
                          <div className="flex items-center gap-1">
                            <span>
                              {flexRender(header.column.columnDef.header, header.getContext())}
                            </span>
                            {header.column.getCanSort() && (
                              <Button
                                variant="ghost"
                                size="sm"
                                className="h-6 w-6 p-0 hover:bg-slate-200"
                                onClick={header.column.getToggleSortingHandler()}>
                                {header.column.getIsSorted() === 'asc' ? (
                                  <IoChevronUp className="h-4 w-4 text-slate-600" />
                                ) : header.column.getIsSorted() === 'desc' ? (
                                  <IoChevronDown className="h-4 w-4 text-slate-600" />
                                ) : (
                                  <ChevronUpDownIcon className="h-4 w-4 text-slate-400" />
                                )}
                              </Button>
                            )}
                          </div>
                        )}
                      </TableHead>
                    ))}
                  </TableRow>
                ))}
              </TableHeader>
              <TableBody>
                {table.getRowModel().rows?.length ? (
                  table.getRowModel().rows.map((row) => (
                    <TableRow
                      key={row.id}
                      data-state={row.getIsSelected() && 'selected'}
                      className={onRowClick ? 'cursor-pointer' : undefined}
                      onClick={() => handleRowClick(row.original)}>
                      {row.getVisibleCells().map((cell) => (
                        <TableCell key={cell.id} className="whitespace-nowrap">
                          {flexRender(cell.column.columnDef.cell, cell.getContext())}
                        </TableCell>
                      ))}
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={columns.length} className="px-6 py-12 text-center">
                      {emptyStateComponent || (
                        <div className="py-12 text-center">
                          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                            <ChevronUpDownIcon className="h-8 w-8 text-slate-400" />
                          </div>
                          <h3 className="mb-1 text-sm font-medium text-slate-900">
                            {t('noDataAvailable')}
                          </h3>
                          <p className="text-[13px] text-slate-500">{t('noResultsForFilters')}</p>
                        </div>
                      )}
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </>
      )}
    </div>
  );
}

export default DataTable;
