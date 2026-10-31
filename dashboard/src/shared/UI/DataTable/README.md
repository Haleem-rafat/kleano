# DataTable Component

A reusable TanStack Table component built for the Kleano Admin application.

## Features

- **Sorting**: Built-in column sorting functionality with visual indicators
- **Filtering**: Column-based filtering support
- **Row Selection**: Optional row selection capabilities
- **Column Visibility**: Toggle column visibility
- **Loading States**: Professional loading indicator with centered layout
- **Empty States**: Customizable empty state component following design system
- **Row Click Handling**: Optional row click events with hover effects
- **TypeScript Support**: Full TypeScript support with generics
- **Design System Compliance**: Follows Kleano Admin UI design guidelines
- **Responsive Design**: Mobile-friendly with proper overflow handling

## Usage

### Basic Usage

```tsx
import { DataTable } from '@UI/Index';
import { createAdminColumns } from '@UI/DataTable/columns/adminColumns';

const MyComponent = () => {
  const { t } = useTranslation();
  const columns = createAdminColumns(t);

  return (
    <DataTable
      columns={columns}
      data={myData}
      isLoading={loading}
      onRowClick={(row) => console.log('Row clicked:', row)}
      emptyStateComponent={<EmptyState />}
    />
  );
};
```

### Advanced Usage with Sorting and Filtering

```tsx
const MyComponent = () => {
  const [sorting, setSorting] = useState<SortingState>([]);
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);

  const columns = createAdminColumns(t);

  return (
    <DataTable
      columns={columns}
      data={myData}
      isLoading={loading}
      enableSorting={true}
      enableFiltering={true}
      enableColumnVisibility={true}
      enableRowSelection={true}
      initialSorting={sorting}
      initialColumnFilters={columnFilters}
      onRowClick={(row) => handleRowClick(row)}
      emptyStateComponent={<EmptyState />}
    />
  );
};
```

## Creating Column Definitions

Create column definitions using TanStack Table's `ColumnDef` type:

```tsx
import { ColumnDef } from '@tanstack/react-table';

export const createMyColumns = (t: (key: string) => string): ColumnDef<MyDataType>[] => [
  {
    accessorKey: 'name',
    header: t('name'),
    cell: ({ row }) => <div className="font-medium">{row.getValue('name')}</div>,
  },
  {
    accessorKey: 'status',
    header: t('status'),
    cell: ({ row }) => {
      const status = row.getValue('status') as 'ACTIVE' | 'INACTIVE';
      return <StatusChip status={status} />;
    },
  },
];
```

## Props

| Prop                      | Type                         | Default | Description                           |
| ------------------------- | ---------------------------- | ------- | ------------------------------------- |
| `columns`                 | `ColumnDef<TData, TValue>[]` | -       | Column definitions for the table      |
| `data`                    | `TData[]`                    | -       | Array of data to display              |
| `isLoading`               | `boolean`                    | `false` | Whether the table is in loading state |
| `onRowClick`              | `(row: TData) => void`       | -       | Callback when a row is clicked        |
| `className`               | `string`                     | `''`    | Additional CSS classes                |
| `emptyStateComponent`     | `React.ReactNode`            | -       | Component to show when no data        |
| `enableSorting`           | `boolean`                    | `true`  | Enable column sorting                 |
| `enableFiltering`         | `boolean`                    | `true`  | Enable column filtering               |
| `enableColumnVisibility`  | `boolean`                    | `false` | Enable column visibility toggle       |
| `enableRowSelection`      | `boolean`                    | `false` | Enable row selection                  |
| `initialSorting`          | `SortingState`               | `[]`    | Initial sorting state                 |
| `initialColumnFilters`    | `ColumnFiltersState`         | `[]`    | Initial column filters                |
| `initialColumnVisibility` | `VisibilityState`            | `{}`    | Initial column visibility             |

## Design System Compliance

The DataTable component follows the Kleano Admin UI design system:

- **Card-based Layout**: Uses `rounded-xl` borders with `border-slate-200`
- **Professional Headers**: Slate-50 background with proper typography
- **Sorting Indicators**: Clear visual feedback with chevron icons
- **Hover Effects**: Subtle transitions with `hover:bg-slate-50`
- **Typography**: Consistent text colors (`text-slate-900`, `text-slate-600`)
- **Spacing**: Proper padding (`px-6 py-4`) following design guidelines
- **Empty States**: Professional empty state with icon and descriptive text

## Examples

See `src/modules/Admins/AdminsList.tsx` for a complete implementation example with:

- Professional header with search and action buttons
- Tab filtering with design system styling
- Search functionality with proper spacing
- Pagination with centered layout
- Row click navigation with hover effects
- Loading states with centered indicators
- Empty states following design guidelines
