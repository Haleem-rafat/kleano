import { ColumnDef } from '@tanstack/react-table';
import { generatePath } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { formatDate } from '@app/utils/helper';
import { ROUTES } from '@constants/routes';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import { IAdmin } from '@servicesTypes/admins.types';

export const createAdminColumns = (t: (key: string) => string): ColumnDef<IAdmin>[] => [
  {
    accessorKey: 'userName',
    header: t('name'),
    enableSorting: true,
    enableHiding: true,
    cell: ({ row }) => <div className="font-medium text-slate-900">{row.getValue('userName')}</div>,
  },
  {
    accessorKey: 'phone',
    header: t('phone'),
    enableSorting: true,
    enableHiding: true,
    cell: ({ row }) => <div className="text-slate-600">{row.getValue('phone')}</div>,
  },
  {
    accessorKey: 'createdAt',
    header: t('createddate'),
    enableSorting: true,
    enableHiding: true,
    cell: ({ row }) => (
      <div className="text-slate-600">{formatDate(row.getValue('createdAt'))}</div>
    ),
  },
  {
    accessorKey: 'status',
    header: t('status'),
    enableSorting: true,
    enableHiding: true,
    cell: ({ row }) => {
      const status = row.getValue('status') as 'SUSPENDED' | 'ACTIVE';
      return status ? <MainStatusChipe status={status} /> : null;
    },
  },
];

export default createAdminColumns;
