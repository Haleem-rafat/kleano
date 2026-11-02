import Alert from '@UI/Alert/Alert';
import { Button, DataTable, EmtyState, FormSheet } from '@UI/Index';
import React, { useState } from 'react';
import iconsService from '@services/icons.service';
import { toast } from 'react-toastify';
import { mutate } from 'swr';
import { useTranslation } from 'react-i18next';
import { ColumnDef } from '@tanstack/react-table';
import IconsForm from './_components/IconsForm';
import useGetIconsOptions from '@/hooks/useGetIconsOptions';

export default function Icons() {
  const [openSheet, setOpenSheet] = useState(false);
  const [isloading, setIsLoading] = useState(false);

  const { iconsOptions, loadingiconsOptions } = useGetIconsOptions();

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const handelDelete = (id) => {
    setIsLoading(true);
    iconsService
      .deleteIcons(id)
      .then((e) => {
        mutate((key: string) => key.includes('get-icons'));
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
      })
      .finally(() => {
        setIsLoading(false);
      });
  };

  const columns: ColumnDef<{ value: string; label: React.ReactNode }>[] = [
    {
      id: 'label',
      header: t('Title'),
      enableSorting: false,
      cell: ({ row }) => row.original.label,
    },
    {
      id: 'delete',
      header: t('delete'),
      enableSorting: false,
      enableGlobalFilter: false,
      cell: ({ row }) => (
        <Alert
          id=""
          description={t('deleteIconConfirm')}
          handler={() => handelDelete(row.original?.value)}
          buttonComponent={
            <Button variant="danger" size="sm" loading={isloading}>
              {t('Deleteimg')}
            </Button>
          }
        />
      ),
    },
  ];

  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">{t('Icons')}</h1>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('AddNewIcons')}</Button>
        </div>
      </div>
      <div>
        <DataTable
          columns={columns}
          data={iconsOptions ?? []}
          isLoading={loadingiconsOptions}
          showColumnToggle={false}
          emptyStateComponent={<EmtyState />}
        />
      </div>

      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('AddNewIcons')}>
        <IconsForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
}
