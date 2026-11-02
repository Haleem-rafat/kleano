import { formatDate } from '@app/utils/helper';
import { ROUTES } from '@constants/routes';
import plansService from '@services/plans.service';
import { Button, DataTable, EmtyState, FormSheet } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ColumnDef } from '@tanstack/react-table';
import { generatePath, useNavigate } from 'react-router-dom';
import useSWR from 'swr';
import PlansModelForm from './_Components/PlansModelForm';

interface IPlan {
  _id: string;
  type: { en: string; ar: string } | string;
  color: string;
  duration: number;
  price: number;
  usageCount: number;
  createdAt: string;
}

export default function Plans() {
  const navigate = useNavigate();

  const [openSheet, setOpenSheet] = useState(false);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(['get-all-plans-list'], () =>
    plansService.getAllPlansList().then((data) => data)
  );

  const columns: ColumnDef<IPlan>[] = [
    {
      id: 'type',
      header: t('planType'),
      accessorFn: (plan) => plan.type?.[lang] || plan.type,
      cell: ({ row }) => (
        <div className="flex items-center gap-2">
          <span className="h-8 w-8 rounded-full" style={{ backgroundColor: row.original.color }} />
          <span className="font-medium">{row.original.type?.[lang] || row.original.type}</span>
        </div>
      ),
    },
    {
      id: 'duration',
      header: t('durationByMonth'),
      accessorKey: 'duration',
      cell: ({ row }) => `${row.original.duration} ${t('month')}`,
    },
    {
      id: 'price',
      header: t('servesPrice'),
      accessorKey: 'price',
      cell: ({ row }) => `${row.original.price} ${t('SAR')}`,
    },
    { id: 'usageCount', header: t('usageCount'), accessorKey: 'usageCount' },
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorKey: 'createdAt',
      cell: ({ row }) => formatDate(row.original.createdAt),
    },
  ];

  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">{t('plans')}</h1>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('AddNewPlan')}</Button>
        </div>
      </div>
      <div>
        <DataTable
          columns={columns}
          data={data?.data ?? []}
          isLoading={isLoading}
          onRowClick={(plan) => navigate(generatePath(ROUTES.PLANS_DETAILS, { plansId: plan._id }))}
          searchable
          showColumnToggle={false}
          emptyStateComponent={<EmtyState />}
        />
      </div>

      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('AddNewPlan')}>
        <PlansModelForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
}
