import { useState } from 'react';
import { IwshaingServicesList } from '@servicesTypes/wshaingServices.types';
import { useTranslation } from 'react-i18next';
import { ColumnDef } from '@tanstack/react-table';

import useSWR from 'swr';
import washingServicesService from '@services/washingServices.service';

import { Button, DataTable, EmtyState, FormSheet } from '@UI/Index';
import { generatePath, useNavigate } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import { formatDate } from '@app/utils/helper';
import WashingServicesForm from './_components/WashingServicesForm';

export default function WashingServices() {
  const [openSheet, setOpenSheet] = useState(false);

  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(['get-washing-services-list'], () =>
    washingServicesService.getWashingServicesList().then((data) => data)
  );

  const columns: ColumnDef<IwshaingServicesList>[] = [
    {
      id: 'name',
      header: t('servesName'),
      accessorFn: (service) => service?.name?.[lang] || service?.name,
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <img
            className="h-8 w-8 rounded-full object-cover"
            src={row.original?.icon?.iconLink}
            alt=""
          />
          <span className="font-medium">{row.original?.name?.[lang] || row.original?.name}</span>
        </div>
      ),
    },
    {
      id: 'duration',
      header: t('durationTime'),
      accessorKey: 'duration',
      cell: ({ row }) => `${row.original.duration} min`,
    },
    {
      id: 'price',
      header: t('servesPrice'),
      accessorKey: 'price',
      cell: ({ row }) => `${row.original?.price} ${t('SAR')}`,
    },
    { id: 'type', header: t('type'), accessorKey: 'type' },
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorKey: 'createdAt',
      cell: ({ row }) => formatDate(row.original?.createdAt),
    },
  ];

  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          {t('washingServices')}
        </h1>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewServices')}</Button>
        </div>
      </div>
      <div>
        <DataTable
          columns={columns}
          data={(data?.data as IwshaingServicesList[]) ?? []}
          isLoading={isLoading}
          onRowClick={(service) =>
            navigate(
              generatePath(ROUTES.WASHING_SERVICES_DETAILS, { washingServicesId: service._id })
            )
          }
          searchable
          showColumnToggle={false}
          emptyStateComponent={<EmtyState />}
        />
      </div>

      <FormSheet
        open={openSheet}
        onOpenChange={() => setOpenSheet(false)}
        title={t('addNewServices')}>
        <WashingServicesForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
}
