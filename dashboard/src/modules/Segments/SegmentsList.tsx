import useSWR from 'swr';
import { IAllSegment } from '@servicesTypes/segments.types';

import { Button, DataTable, EmtyState, FormSheet } from '@UI/Index';
import { generatePath, useNavigate } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import segmentsService from '@services/segments.service';
import { useTranslation } from 'react-i18next';
import { ColumnDef } from '@tanstack/react-table';

import { formatDate } from '@app/utils/helper';
import { useState } from 'react';
import SegmentsDialogeWrapper from './_Components/SegmentsDialogeWrapper';
import ViewUsers from './_Components/ViewUsers';
import SegmentModelForm from './_Components/SegmentModelForm';

const SegmentsList = () => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [openSheet, setOpenSheet] = useState(false);

  const { data, isLoading } = useSWR(['get-all-segments-list'], () =>
    segmentsService.getAllSegments().then((data) => data)
  );

  const columns: ColumnDef<IAllSegment>[] = [
    { id: 'name', header: t('name'), accessorKey: 'name' },
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorKey: 'createdAt',
      cell: ({ row }) => formatDate(row.original.createdAt),
    },
    {
      id: 'users',
      header: t('selectedUser'),
      enableSorting: false,
      enableGlobalFilter: false,
      cell: ({ row }) => (
        <SegmentsDialogeWrapper
          modal
          triggerButtonElement={
            <Button onClick={(e) => e.stopPropagation()} variant="secondary" size="sm">
              {row.original.users.length} users
            </Button>
          }>
          <ViewUsers segmentId={row.original._id} />
        </SegmentsDialogeWrapper>
      ),
    },
  ];

  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">{t('segments')}</h1>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewSegments')}</Button>
        </div>
      </div>
      <div>
        <DataTable
          columns={columns}
          data={data?.data ?? []}
          isLoading={isLoading}
          onRowClick={(segment) =>
            navigate(generatePath(ROUTES.SEGMENTS_DETAILS, { segmenId: segment._id }))
          }
          searchable
          showColumnToggle={false}
          emptyStateComponent={<EmtyState />}
        />
      </div>

      <FormSheet
        open={openSheet}
        onOpenChange={() => setOpenSheet(false)}
        title={t('addNewSegments')}>
        <SegmentModelForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
};

export default SegmentsList;
