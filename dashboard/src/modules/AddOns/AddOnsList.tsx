import { formatDate } from '@app/utils/helper';
import { ROUTES } from '@constants/routes';
import { Button, DataTable, EmtyState, FormSheet } from '@UI/Index';
import { useState } from 'react';
import { generatePath, useNavigate } from 'react-router-dom';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import { ColumnDef } from '@tanstack/react-table';

import addOnsService from '@services/addOns.service';
import { IAddOns } from '@servicesTypes/addOns';
import AddOnsForm from './_components/AddOnsForm';

export default function AddOnsList() {
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [openSheet, setOpenSheet] = useState(false);

  const { data, isLoading } = useSWR(['get-all-add-ons-list'], () =>
    addOnsService.getAllAddOnsList().then((data) => data.data)
  );

  const columns: ColumnDef<IAddOns>[] = [
    {
      id: 'name',
      header: t('addOnsName'),
      accessorFn: (addOns) => addOns?.name?.[lang] || addOns?.name,
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
      id: 'price',
      header: t('addOnsPrice'),
      accessorKey: 'price',
      cell: ({ row }) => `${row.original?.price} ${t('SAR')}`,
    },
    { id: 'stock', header: t('stock'), accessorKey: 'stock' },
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
        <h1 className="text-xl font-semibold tracking-tight text-foreground">{t('addOns')}</h1>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewAddOns')}</Button>
        </div>
      </div>
      <div>
        <DataTable
          columns={columns}
          data={(data as IAddOns[]) ?? []}
          isLoading={isLoading}
          onRowClick={(addOns) =>
            navigate(generatePath(ROUTES.ADD_ONS_DETAILS, { addOnsId: addOns._id }))
          }
          searchable
          showColumnToggle={false}
          emptyStateComponent={<EmtyState />}
        />
      </div>

      <FormSheet
        open={openSheet}
        onOpenChange={() => setOpenSheet(false)}
        title={t('addNewAddOns')}>
        <AddOnsForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
}
