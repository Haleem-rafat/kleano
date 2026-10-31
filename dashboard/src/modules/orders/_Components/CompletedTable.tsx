import { EmtyState, DataTable, AdminStatus } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import { useState } from 'react';
import { Location } from '@servicesTypes/order.types';
import { ColumnDef } from '@tanstack/react-table';
import { formatDate } from '@app/utils/helper';
import { MapPin } from 'lucide-react';
import LocationMapDialog from './LocationMapDialog';
import { Button } from '@/shadecn/components/ui/button';

interface OrderData {
  _id: string;
  user: {
    userName: string;
    phone: string;
  };
  biker: {
    userName: string;
  };
  vehicle: {
    model: string;
  };
  startTime: string;
  location: {
    _id: string;
    latitude: number;
    longitude: number;
    streetName: string;
    subAdministrativeArea: string;
    city: {
      name: {
        en: string;
        ar: string;
      };
    };
    isSaved: boolean;
  };
  status: string;
}

interface CompletedTableProps {
  data: {
    data: OrderData[];
    pagination: {
      page: number;
      perPage: number;
    };
  };
}

const CompletedTable = ({
  data = { data: [], pagination: { page: 1, perPage: 10 } },
}: CompletedTableProps) => {
  const navigate = useNavigate();
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

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const handleMapClick = (order: OrderData) => {
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

  const handleRowClick = (order: OrderData) => {
    navigate(generatePath(ROUTES.ORDER_DETAILS, { orderId: order._id }));
  };

  const columns: ColumnDef<OrderData>[] = [
    {
      accessorKey: 'number',
      header: t('number'),
      enableSorting: false,
      enableHiding: true,
      cell: ({ row }) => {
        const index = row.index;
        return (
          <div className="text-slate-600">
            {(data.pagination.page - 1) * data.pagination.perPage + index + 1}
          </div>
        );
      },
    },
    {
      accessorKey: 'userName',
      header: t('name'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => (
        <div className="font-medium text-slate-900">{row.original.user.userName}</div>
      ),
    },
    {
      accessorKey: 'phone',
      header: t('phone'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => <div className="text-slate-600">{row.original.user.phone}</div>,
    },
    {
      accessorKey: 'bikerName',
      header: t('bikerName'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => <div className="text-slate-600">{row.original.biker.userName}</div>,
    },
    {
      accessorKey: 'model',
      header: t('model'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => <div className="text-slate-600">{row.original.vehicle?.model || ''}</div>,
    },
    {
      accessorKey: 'startTime',
      header: t('startTime'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => <div className="text-slate-600">{formatDate(row.original.startTime)}</div>,
    },

    {
      accessorKey: 'streetName',
      header: t('location'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => {
        const streetName = row.original.location?.streetName || '';
        return (
          <p title={streetName} className="max-w-[200px] truncate text-gray-900">
            {streetName}
          </p>
        );
      },
    },
    {
      accessorKey: 'map',
      header: t('map'),
      enableSorting: false,
      enableHiding: true,
      cell: ({ row }) => (
        <Button
          variant="outline"
          size="sm"
          onClick={(e) => {
            e.stopPropagation();
            handleMapClick(row.original);
          }}
          className="flex items-center gap-2">
          <MapPin className="h-4 w-4" />
          {t('viewMap')}
        </Button>
      ),
    },
    {
      accessorKey: 'status',
      header: t('status'),
      enableSorting: true,
      enableHiding: true,
      cell: ({ row }) => {
        const status = row.original.status;
        return <AdminStatus status={status} />;
      },
    },
  ];

  return (
    <div>
      <DataTable
        columns={columns}
        data={data.data}
        onRowClick={handleRowClick}
        emptyStateComponent={<EmtyState />}
        enableSorting={true}
        enableFilters={true}
        enableColumnVisibility={true}
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

export default CompletedTable;
