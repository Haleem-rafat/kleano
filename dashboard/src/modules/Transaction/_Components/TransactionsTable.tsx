import { formatDate } from '@app/utils/helper';
import { AdminStatus, DataTable, EmtyState, MainAvatar } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import { ColumnDef } from '@tanstack/react-table';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Transaction = { _id: string; order?: any };

const TransactionsTable = ({
  data,
  isLoading = false,
}: {
  data?: { data?: unknown };
  isLoading?: boolean;
}) => {
  const { t } = useTranslation();

  const columns: ColumnDef<Transaction>[] = [
    {
      id: 'name',
      header: t('name'),
      accessorFn: (tr) => tr.order?.user?.userName,
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <MainAvatar
            src={row.original.order?.user?.imageLink}
            name={row.original.order?.user?.userName}
            className="h-8 w-8"
          />
          <span className="font-medium text-foreground">{row.original.order?.user?.userName}</span>
        </div>
      ),
    },
    { id: 'phone', header: t('phone'), accessorFn: (tr) => tr.order?.user?.phone },
    {
      id: 'biker',
      header: t('bikerName'),
      accessorFn: (tr) => tr.order?.biker?.userName || '—',
    },
    { id: 'discount', header: t('discount'), accessorFn: (tr) => tr.order?.discount },
    { id: 'paid', header: t('paied'), accessorFn: (tr) => tr.order?.totalPay },
    { id: 'refund', header: t('refundAmount'), accessorFn: (tr) => tr.order?.refundAmount },
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorFn: (tr) => tr.order?.createdAt,
      cell: ({ row }) => formatDate(row.original.order?.createdAt),
    },
    {
      id: 'paymentStatus',
      header: t('paymentStatus'),
      accessorFn: (tr) => tr.order?.paymentStatus,
      cell: ({ row }) => t(row.original.order?.paymentStatus),
    },
    {
      id: 'status',
      header: t('status'),
      accessorFn: (tr) => tr.order?.status,
      cell: ({ row }) => <AdminStatus status={row.original.order?.status} />,
    },
  ];

  return (
    <DataTable
      columns={columns}
      data={Array.isArray(data?.data) ? (data.data as Transaction[]) : []}
      isLoading={isLoading}
      showColumnToggle={false}
      emptyStateComponent={<EmtyState />}
    />
  );
};

export default TransactionsTable;
