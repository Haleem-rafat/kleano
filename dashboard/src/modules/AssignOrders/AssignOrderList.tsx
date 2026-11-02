import { useState } from 'react';
import { generatePath, useNavigate } from 'react-router-dom';
import { DataTable, EmtyState, MainAvatar } from '@UI/Index';
import { ColumnDef } from '@tanstack/react-table';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import { ROUTES } from '@constants/routes';
import { formatDate } from '@app/utils/helper';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import assignedOrdersService from '@services/assignedOrders.service';

const AssignOrderList = () => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [pageIndex, setPageIndex] = useState(1);

  const { data: assignedOrdersList, isLoading } = useSWR(
    ['get-all-assign-orders-list', pageIndex],
    () =>
      assignedOrdersService
        .getAllAssingedOrders({
          page: pageIndex,
          perPage: 20,
        })
        .then((data) => {
          return data;
        })
  );

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const columns: ColumnDef<any>[] = [
    {
      id: 'name',
      header: t('name'),
      accessorFn: (order) => order?.user?.userName,
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <MainAvatar
            src={row.original?.user?.imageLink}
            name={row.original?.user?.userName}
            className="h-8 w-8"
          />
          <span className="font-medium text-foreground">{row.original?.user?.userName}</span>
        </div>
      ),
    },
    { id: 'phone', header: t('phone'), accessorFn: (order) => order?.user?.phone || '—' },
    { id: 'biker', header: t('bikerName'), accessorFn: (order) => order?.biker?.userName || '—' },
    {
      id: 'bikerPhone',
      header: t('bikerPhone'),
      accessorFn: (order) => order?.biker?.phone || '—',
    },
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorKey: 'createdAt',
      cell: ({ row }) => formatDate(row.original.createdAt),
    },
    {
      id: 'status',
      header: t('status'),
      accessorKey: 'status',
      cell: ({ row }) => row.original.status && <MainStatusChipe status={row.original.status} />,
    },
  ];

  return (
    <div className="relative flex h-full w-full flex-col gap-3">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">{t('assignOrder')}</h1>
        <div></div>
      </div>
      <DataTable
        columns={columns}
        data={assignedOrdersList?.data ?? []}
        isLoading={isLoading}
        showColumnToggle={false}
        onRowClick={(order) => navigate(generatePath(ROUTES.ORDER_DETAILS, { orderId: order._id }))}
        emptyStateComponent={<EmtyState />}
      />
      {assignedOrdersList && (
        <PaginationComponent
          page={assignedOrdersList.pagination.page}
          pages={assignedOrdersList.pagination.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
    </div>
  );
};

export default AssignOrderList;
