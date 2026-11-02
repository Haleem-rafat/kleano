import { formatDate } from '@app/utils/helper';
import { AdminStatus, EmtyState, DataTable } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import { ColumnDef } from '@tanstack/react-table';
import { IOrderList } from '@app/api/types/order.types';
import { useState } from 'react';
import { Location } from '@servicesTypes/order.types';
import { MapPin } from 'lucide-react';
import LocationMapDialog from './LocationMapDialog';
import { Button } from '@/shadecn/components/ui/button';

interface CancelledOrderData extends IOrderList {
  refundAmount?: number;
  cancellationReason?: string;
  cancellationDate?: string;
}

interface CancelledTableProps {
  data: {
    data: CancelledOrderData[];
    pagination: {
      page: number;
      perPage: number;
    };
  };
}

const CancelledTable = ({
  data = { data: [], pagination: { page: 1, perPage: 10 } },
}: CancelledTableProps) => {
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const [mapDialog, setMapDialog] = useState<{
    isOpen: boolean;
    location: Location | null;
    cityName: string;
    streetName: string;
  }>({
    isOpen: false,
    location: null,
    cityName: '',
    streetName: '',
  });

  const handleRowClick = (order: CancelledOrderData) => {
    navigate(generatePath(ROUTES.ORDER_DETAILS, { orderId: order._id }));
  };

  const handleMapClick = (order: CancelledOrderData) => {
    setMapDialog({
      isOpen: true,
      location: order.location,
      cityName: order?.location?.city?.name[lang] || '',
      streetName: order?.location?.streetName || '',
    });
  };

  const closeMapDialog = () => {
    setMapDialog({
      isOpen: false,
      location: null,
      cityName: '',
      streetName: '',
    });
  };

  const columns: ColumnDef<CancelledOrderData>[] = [
    {
      accessorKey: 'number',
      header: t('number'),
      cell: ({ row }) => {
        const index = row.index;
        return (data?.pagination?.page - 1) * data?.pagination?.perPage + index + 1;
      },
    },
    {
      accessorKey: 'user.userName',
      header: t('name'),
      cell: ({ row }) => row.original?.user?.userName,
    },
    {
      accessorKey: 'washingServices',
      header: t('washingServices'),
      // Names come as { en, ar } (or a plain string on old orders).
      cell: ({ row }) =>
        row.original?.washingServices
          ?.map((service) =>
            typeof service.name === 'string' ? service.name : service.name?.[lang]
          )
          .filter(Boolean)
          .join(', ') || '—',
    },
    {
      accessorKey: 'refundAmount',
      header: t('refundAmount'),
      cell: ({ row }) => row.original?.refundAmount,
    },
    {
      accessorKey: 'cancellationReason',
      header: t('cancelReason'),
      cell: ({ row }) => row.original?.cancellationReason,
    },
    {
      accessorKey: 'startTime',
      header: t('startTime'),
      cell: ({ row }) => formatDate(row.original.startTime),
    },
    {
      accessorKey: 'vehicle.model',
      header: t('model'),
      cell: ({ row }) => row.original?.vehicle?.model,
    },
    {
      accessorKey: 'status',
      header: t('status'),
      cell: ({ row }) => <AdminStatus status={row.original?.status} />,
    },
    {
      accessorKey: 'cancellationDate',
      header: t('cancelDate'),
      cell: ({ row }) => formatDate(row.original.cancellationDate),
    },
    {
      accessorKey: 'location.streetName',
      header: t('location'),
      cell: ({ row }) => {
        return (
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={(e) => {
                e.stopPropagation();
                handleMapClick(row.original);
              }}
              className="h-6 items-center gap-1 px-2">
              <MapPin className="h-3 w-3" />
              {t('Show on map')}
            </Button>
          </div>
        );
      },
    },
  ];

  return (
    <div>
      <DataTable
        columns={columns}
        data={data?.data || []}
        onRowClick={handleRowClick}
        emptyStateComponent={<EmtyState />}
        enableSorting={true}
        enableFilters={true}
        enableColumnVisibility={true}
        showColumnToggle={true}
      />

      {mapDialog.location && (
        <LocationMapDialog
          isOpen={mapDialog.isOpen}
          onClose={closeMapDialog}
          location={mapDialog.location}
          cityName={mapDialog.cityName}
          streetName={mapDialog.streetName}
        />
      )}
    </div>
  );
};
export default CancelledTable;
