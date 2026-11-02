import { formatDate } from '@app/utils/helper';

import { AdminStatus, EmtyState, DataTable } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate, useSearchParams } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import { ColumnDef } from '@tanstack/react-table';
import { Button } from '@shadecn/components/ui/button';
import { IOrderList } from '@app/api/types/order.types';
import { useState } from 'react';
import { IoLocationOutline } from 'react-icons/io5';
import UserPopover from './UserPopover';
import LocationMapDialog from './LocationMapDialog';

const LifeOrderTable = ({ data = [] }: { data }) => {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const status = params.getAll('status');

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [openMapDialog, setOpenMapDialog] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<{
    location: IOrderList['location'];
    cityName: string;
    streetName: string;
  } | null>(null);

  const showActionColumn = ['ACCEPTED_BY_BIKER', 'BIKER_ON_THE_WAY'].includes(status && status[1]);

  const handleShowMap = (order: IOrderList, event: React.MouseEvent) => {
    event.stopPropagation(); // Prevent row click
    setSelectedLocation({
      location: order.location,
      cityName: order.location.city?.name[lang],
      streetName: order.location?.streetName,
    });
    setOpenMapDialog(true);
  };

  const handleCloseMap = () => {
    setOpenMapDialog(false);
    setSelectedLocation(null);
  };

  const columns: ColumnDef<IOrderList>[] = [
    {
      accessorKey: 'number',
      header: t('number'),
      cell: ({ row, table }) => {
        const index = table.getRowModel().rows.findIndex((r) => r.id === row.id);
        return (data?.pagination?.page - 1) * data?.pagination?.perPage + index + 1;
      },
    },
    {
      accessorKey: 'user.userName',
      header: t('name'),
      cell: ({ row }) => (
        <span
          onClick={(e) => {
            e.stopPropagation();
            navigate(generatePath(ROUTES.USERS_DETAILS, { userId: row.original?.user?._id }));
          }}
          className="cursor-pointer hover:text-primary">
          {row.original?.user?.userName}
        </span>
      ),
    },
    {
      accessorKey: 'user.phone',
      header: t('phone'),
      cell: ({ row }) => row.original?.user?.phone,
    },
    {
      accessorKey: 'biker.userName',
      header: t('bikerName'),
      cell: ({ row }) => row.original?.biker?.userName,
    },
    {
      accessorKey: 'vehicle.model',
      header: t('model'),
      cell: ({ row }) => row.original?.vehicle?.model,
    },
    {
      accessorKey: 'startTime',
      header: t('startTime'),
      cell: ({ row }) => formatDate(row.original?.startTime),
    },

    {
      accessorKey: 'location',
      header: t('location'),
      cell: ({ row }) => (
        <Button
          variant="outline"
          size="sm"
          onClick={(e) => handleShowMap(row.original, e)}
          className="flex items-center gap-2">
          <IoLocationOutline className="h-4 w-4" />
          {t('show on map')}
        </Button>
      ),
    },
    {
      accessorKey: 'status',
      header: t('status'),
      cell: ({ row }) => <AdminStatus status={row.original?.status} />,
    },
    ...(showActionColumn
      ? [
          {
            accessorKey: 'action',
            header: t('action'),
            cell: ({ row }) => (
              <UserPopover orderId={row.original?._id} paid={row.original?.totalPay} compact />
            ),
          },
        ]
      : []),
  ];

  return (
    <div>
      <DataTable
        columns={columns}
        data={data?.data || []}
        onRowClick={(row) => navigate(generatePath(ROUTES.ORDER_DETAILS, { orderId: row._id }))}
        emptyStateComponent={<EmtyState />}
      />
      {selectedLocation && (
        <LocationMapDialog
          isOpen={openMapDialog}
          onClose={handleCloseMap}
          location={selectedLocation.location}
          cityName={selectedLocation.cityName}
          streetName={selectedLocation.streetName}
        />
      )}
    </div>
  );
};

export default LifeOrderTable;
