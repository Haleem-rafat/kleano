import { useState } from 'react';
import { generatePath, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useSWR, { mutate } from 'swr';
import { toast } from 'react-toastify';
import {
  IoEyeOutline,
  IoPencilOutline,
  IoCheckmarkCircleOutline,
  IoCloseCircleOutline,
  IoCalendarOutline,
  IoPersonOutline,
} from 'react-icons/io5';

import { ROUTES } from '@constants/routes';
import bikersService from '@services/bikers.service';
import { IBikers } from '@servicesTypes/bikers.types';

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';
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

import { AdminStatus, Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
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
  return (
    <div className="space-y-1">
      {isLoading && <ThreeDotsLoader />}

      {/* Professional Header */}
      <div className="pb-4">
        <div>
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                <IoPersonOutline className="h-4 w-4 text-primary" />
              </div>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('bikers')}</h1>
                <p className="mt-1 text-sm text-slate-500">Manage and view all bikers</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Input
                onChange={(e) => setSearch(e.target.value)}
                value={search}
                placeholder={t('search') || 'Search...'}
                className="w-64"
              />
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
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="pt-1">
        <div className="mx-auto w-full">
          {/* Filters */}
          <div className="mb-6 flex justify-end">
            <DatePickerWithPresets setDateObj={setDateObj} />
          </div>

          {/* Table Card */}
          <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
            {/* Table Content */}
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="border-slate-200">
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('name')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('phone')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('nationalId')}
                    </TableHead>

                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('totalDeliveries')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('totalTimeWorked')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('commissionType')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('commission')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('ordersBeforeCommission')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('status')}
                    </TableHead>
                    <TableHead className="text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('actions') || 'Actions'}
                    </TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data && (data?.data as IBikers[])?.length > 0 ? (
                    (data?.data as IBikers[])?.map((biker) => (
                      <TableRow
                        key={biker._id}
                        className="border-slate-200 transition-colors duration-200 hover:bg-slate-50">
                        <TableCell className="font-medium text-slate-900">
                          {biker.userName}
                        </TableCell>
                        <TableCell className="text-slate-600">{biker.phone}</TableCell>
                        <TableCell className="text-slate-600">{biker.nationalId}</TableCell>
                        <TableCell className="text-slate-600">{biker.totalDeliveries}</TableCell>
                        <TableCell className="text-slate-600">{biker.totalTimeWorked}</TableCell>
                        <TableCell>
                          {biker.commissionType ? (
                            <div
                              className={`w-fit whitespace-nowrap rounded-full px-4 py-0.5 text-sm font-medium ${
                                biker.commissionType === 'PERCENTAGE'
                                  ? 'bg-primary/30 text-primary'
                                  : 'bg-purple-500/30 text-purple-700'
                              }`}>
                              {t(biker.commissionType)}
                            </div>
                          ) : (
                            <span className="text-slate-400">--</span>
                          )}
                        </TableCell>
                        <TableCell className="text-slate-600">
                          {biker.commission !== undefined && biker.commission !== null
                            ? `${biker.commission}${
                                biker.commissionType === 'PERCENTAGE' ? '%' : ''
                              }`
                            : '--'}
                        </TableCell>
                        <TableCell className="text-slate-600">
                          {biker.ordersBeforeCommission !== undefined &&
                          biker.ordersBeforeCommission !== null
                            ? biker.ordersBeforeCommission
                            : '--'}
                        </TableCell>
                        <TableCell>
                          <AdminStatus status={biker.status} />
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            {/* View Button */}
                            <Button
                              variant="secondary"
                              size="icon"
                              onClick={(e) => {
                                e.stopPropagation();
                                navigate(
                                  generatePath(ROUTES.BIKERS_DETAILS, { bikerId: biker._id })
                                );
                              }}
                              className="h-8 w-8 border-0 bg-transparent p-0 hover:bg-brandTint hover:text-primary">
                              <IoEyeOutline className="h-4 w-4" />
                            </Button>

                            {/* Edit Button */}
                            <Button
                              variant="secondary"
                              size="icon"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleEdit(biker);
                              }}
                              className="h-8 w-8 border-0 bg-transparent p-0 hover:bg-brandTint hover:text-primary">
                              <IoPencilOutline className="h-4 w-4" />
                            </Button>

                            {/* Active/Disable Button */}
                            <Button
                              variant="secondary"
                              size="icon"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleStatusAction(biker._id, biker.status);
                              }}
                              className={`h-8 w-8 border-0 bg-transparent p-0 ${
                                biker.status !== 'SUSPENDED'
                                  ? 'hover:bg-red-100 hover:text-red-600'
                                  : 'hover:bg-green-100 hover:text-green-600'
                              }`}>
                              {biker.status !== 'SUSPENDED' ? (
                                <IoCloseCircleOutline className="h-4 w-4" />
                              ) : (
                                <IoCheckmarkCircleOutline className="h-4 w-4" />
                              )}
                            </Button>

                            {/* Schedule Button */}
                            <Button
                              variant="secondary"
                              size="icon"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleSchedule(biker._id);
                              }}
                              className="h-8 w-8 border-0 bg-transparent p-0 hover:bg-purple-100 hover:text-purple-600">
                              <IoCalendarOutline className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  ) : (
                    <TableRow>
                      <TableCell colSpan={11} className="h-32 text-center">
                        <EmtyState />
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </div>
          </div>
        </div>
      </div>

      {/* Edit Sheet */}
      <Sheet
        open={openSheet}
        onOpenChange={(open) => {
          setOpenSheet(open);
          if (!open) setEditingBiker(null);
        }}
        modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>
              {editingBiker ? t('editBikerInfo') || 'Edit Biker' : t('addNewBiker')}
            </SheetTitle>
            <SheetDescription>
              <BikersFrom setOpenSheet={setOpenSheet} oldData={editingBiker || undefined} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>

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
                  ? 'bg-red-600 text-white hover:bg-red-700'
                  : 'bg-green-600 text-white hover:bg-green-700'
              }>
              {actionLoading ? (
                <span className="flex items-center gap-2">
                  <ThreeDotsLoader />
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
