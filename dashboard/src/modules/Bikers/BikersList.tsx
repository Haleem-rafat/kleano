import { Loader2 } from 'lucide-react';
import { useState } from 'react';
import { generatePath, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useSWR, { mutate } from 'swr';
import { toast } from 'react-toastify';
import {
  IoPencilOutline,
  IoCheckmarkCircleOutline,
  IoCloseCircleOutline,
  IoCalendarOutline,
  IoSearchOutline,
} from 'react-icons/io5';

import { ROUTES } from '@constants/routes';
import bikersService from '@services/bikers.service';
import { IBikers } from '@servicesTypes/bikers.types';

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@shadecn/components/ui/alert-dialog';

import {
  AdminStatus,
  Button,
  DataTable,
  EmtyState,
  MainAvatar,
  PageHeader,
  FormSheet,
} from '@UI/Index';
import { ColumnDef } from '@tanstack/react-table';
import { DatePickerWithPresets } from '@UI/datePickerComponent/DatePicker';
import { Input } from '@shadecn/components/ui/input';
import BikersFrom from './_components/BikersFrom';
import useDebounce from '@/hooks/useDebounce';

export default function BikersList() {
  const navigate = useNavigate();

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 800);
  const [openSheet, setOpenSheet] = useState(false);
  const [editingBiker, setEditingBiker] = useState<IBikers | null>(null);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [selectedBiker, setSelectedBiker] = useState<{ id: string; status: string } | null>(null);
  const [dateObj, setDateObj] = useState({ from: '', to: '' });
  const [loading, setLoading] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const { data, isLoading } = useSWR(['get-all-bikers-list', dateObj, debouncedSearch], () =>
    bikersService
      .getAllBikers({
        fromDate: dateObj.from ?? undefined,
        toDate: dateObj.to ?? undefined,
        search: debouncedSearch,
      })
      .then((data) => data)
  );
  const handelExport = async () => {
    setLoading(true);
    try {
      const response = await bikersService.getBikersExportExcel();
      const url = window.URL.createObjectURL(response);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'Bikers_export.xlsx');
      link.click();
      link.parentNode.removeChild(link);
      window.URL.revokeObjectURL(url);
    } catch ({ response }) {
      const messages = response?.data?.message;
      const errList = Array.isArray(messages)
        ? messages.map((e, index) => <p key={index}>{e}</p>)
        : messages?.[lang] || t('An error occurred');
      toast.error(<div>{errList}</div>);
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (biker: IBikers) => {
    setEditingBiker(biker);
    setOpenSheet(true);
  };

  const handleStatusAction = (id: string, status: string) => {
    setSelectedBiker({ id, status });
    setConfirmDialogOpen(true);
  };

  const confirmStatusAction = async () => {
    if (!selectedBiker) return;

    setActionLoading(true);
    const endPoint =
      selectedBiker.status !== 'SUSPENDED'
        ? bikersService.suspendBiker(selectedBiker.id)
        : bikersService.restoreBiker(selectedBiker.id);

    endPoint
      .then(() => {
        mutate((key: string) => key.includes('get-all-bikers-list'));
        mutate((key: string) => key.includes('get-biker-details'));
        toast.success(
          selectedBiker.status !== 'SUSPENDED'
            ? t('bikerSuspendedSuccessfully')
            : t('bikerRestoredSuccessfully')
        );
        setConfirmDialogOpen(false);
        setSelectedBiker(null);
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
      })
      .finally(() => {
        setActionLoading(false);
      });
  };

  const handleSchedule = (bikerId: string) => {
    navigate(generatePath(ROUTES.BIKERS_SCHEDULE, { bikerId }));
  };
  const iconBtn = 'h-8 w-8 border-0 bg-transparent p-0 hover:bg-accent hover:text-primary';
  const orDash = (v: unknown) => (v === undefined || v === null || v === '' ? '—' : String(v));

  const columns: ColumnDef<IBikers>[] = [
    {
      id: 'userName',
      header: t('name'),
      accessorKey: 'userName',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <MainAvatar
            src={row.original.imageLink}
            name={row.original.userName}
            className="h-8 w-8"
          />
          <span className="font-medium text-foreground">{row.original.userName}</span>
        </div>
      ),
    },
    {
      id: 'phone',
      header: t('phone'),
      accessorKey: 'phone',
      cell: ({ row }) => <span dir="ltr">{row.original.phone}</span>,
    },
    { id: 'nationalId', header: t('nationalId'), accessorFn: (b) => orDash(b.nationalId) },
    { id: 'totalDeliveries', header: t('totalDeliveries'), accessorKey: 'totalDeliveries' },
    { id: 'totalTimeWorked', header: t('totalTimeWorked'), accessorKey: 'totalTimeWorked' },
    {
      id: 'commissionType',
      header: t('commissionType'),
      accessorKey: 'commissionType',
      cell: ({ row }) =>
        row.original.commissionType ? (
          <span
            className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${
              row.original.commissionType === 'PERCENTAGE'
                ? 'bg-accent text-primary'
                : 'bg-muted text-foreground'
            }`}>
            {t(row.original.commissionType)}
          </span>
        ) : (
          '—'
        ),
    },
    {
      id: 'commission',
      header: t('commission'),
      accessorKey: 'commission',
      cell: ({ row }) =>
        row.original.commission === undefined || row.original.commission === null
          ? '—'
          : `${row.original.commission}${row.original.commissionType === 'PERCENTAGE' ? '%' : ''}`,
    },
    {
      id: 'ordersBeforeCommission',
      header: t('ordersBeforeCommission'),
      accessorFn: (b) => orDash(b.ordersBeforeCommission),
    },
    {
      id: 'status',
      header: t('status'),
      accessorKey: 'status',
      cell: ({ row }) => <AdminStatus status={row.original.status} />,
    },
    {
      id: 'actions',
      header: t('actions'),
      enableSorting: false,
      cell: ({ row }) => {
        const biker = row.original;
        const suspended = biker.status === 'SUSPENDED';
        return (
          <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
            <Button
              variant="secondary"
              size="icon"
              className={iconBtn}
              onClick={() => handleEdit(biker)}
              aria-label={t('edit')}
              title={t('edit')}>
              <IoPencilOutline className="h-4 w-4" />
            </Button>
            <Button
              variant="secondary"
              size="icon"
              className={iconBtn}
              onClick={() => handleSchedule(biker._id)}
              aria-label={t('schedule')}
              title={t('schedule')}>
              <IoCalendarOutline className="h-4 w-4" />
            </Button>
            <Button
              variant="secondary"
              size="icon"
              onClick={() => handleStatusAction(biker._id, biker.status)}
              className={`h-8 w-8 border-0 bg-transparent p-0 ${
                suspended
                  ? 'hover:bg-success/10 hover:text-success'
                  : 'hover:bg-destructive/10 hover:text-destructive'
              }`}
              aria-label={suspended ? t('activate') : t('suspend')}
              title={suspended ? t('activate') : t('suspend')}>
              {suspended ? (
                <IoCheckmarkCircleOutline className="h-4 w-4" />
              ) : (
                <IoCloseCircleOutline className="h-4 w-4" />
              )}
            </Button>
          </div>
        );
      },
    },
  ];

  return (
    <div className="space-y-4">
      <PageHeader
        title={t('bikers')}
        description={t('manageBikers')}
        actions={
          <>
            <Button loading={loading} onClick={() => handelExport()} variant="secondary">
              {t('Export')}
            </Button>
            <Button
              onClick={() => {
                setEditingBiker(null);
                setOpenSheet(true);
              }}>
              {t('addNewBiker')}
            </Button>
          </>
        }
      />
      <div className="flex flex-wrap items-center justify-between gap-2">
        <label className="relative w-full sm:w-72">
          <IoSearchOutline className="pointer-events-none absolute start-3 top-1/2 z-10 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            type="search"
            onChange={(e) => setSearch(e.target.value)}
            value={search}
            placeholder={t('search')}
            aria-label={t('search')}
            className="h-9 ps-9"
          />
        </label>
        <DatePickerWithPresets setDateObj={setDateObj} />
      </div>
      <DataTable
        columns={columns}
        data={(data?.data as IBikers[]) ?? []}
        isLoading={isLoading}
        showColumnToggle={false}
        onRowClick={(biker) =>
          navigate(generatePath(ROUTES.BIKERS_DETAILS, { bikerId: biker._id }))
        }
        emptyStateComponent={<EmtyState />}
      />

      {/* Edit Sheet */}
      <FormSheet
        open={openSheet}
        onOpenChange={(open) => {
          setOpenSheet(open);
          if (!open) setEditingBiker(null);
        }}
        title={editingBiker ? t('editBikerInfo') || 'Edit Biker' : t('addNewBiker')}>
        <BikersFrom setOpenSheet={setOpenSheet} oldData={editingBiker || undefined} />
      </FormSheet>

      {/* Confirmation Dialog */}
      <AlertDialog open={confirmDialogOpen} onOpenChange={setConfirmDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{t('confirmationMessage')}</AlertDialogTitle>
            <AlertDialogDescription>
              {selectedBiker?.status !== 'SUSPENDED'
                ? t('confirmSuspendBiker') ||
                  'Are you sure you want to suspend this biker? This action will restrict their access.'
                : t('confirmRestoreBiker') ||
                  'Are you sure you want to restore this biker? This action will restore their access.'}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={actionLoading}>{t('cancel')}</AlertDialogCancel>
            <AlertDialogAction
              onClick={confirmStatusAction}
              disabled={actionLoading}
              className={
                selectedBiker?.status !== 'SUSPENDED'
                  ? 'bg-destructive text-white hover:bg-destructive'
                  : 'bg-success text-white hover:bg-success'
              }>
              {actionLoading ? (
                <span className="flex items-center gap-2">
                  <Loader2 className="h-4 w-4 animate-spin" />
                  {t('processing') || 'Processing...'}
                </span>
              ) : (
                t('continue')
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
