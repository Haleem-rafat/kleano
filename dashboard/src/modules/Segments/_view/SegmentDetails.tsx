import { useTranslation } from 'react-i18next';
import { formatDate } from '@app/utils/helper';
import segmentsService from '@services/segments.service';
import { useNavigate, useParams } from 'react-router-dom';
import useSWR from 'swr';

import { useState } from 'react';
import { Button, ThreeDotsLoader } from '@UI/Index';
import { ISegment } from '@servicesTypes/segments.types';
import {
  IoArrowBackCircleOutline,
  IoExtensionPuzzleOutline,
  IoPeopleOutline,
} from 'react-icons/io5';
import { t } from 'i18next';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import SegmentModelForm from '../_Components/SegmentModelForm';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

const SegmentDetails = () => {
  const { t } = useTranslation();
  const [openSheet, setOpenSheet] = useState(false);

  const { segmenId } = useParams();
  const navigate = useNavigate();

  const { data, isLoading } = useSWR(
    ['get-segments-details', segmenId],
    () =>
      segmenId && segmentsService.getSegmentUsers(segmenId).then((data) => data?.data as ISegment)
  );

  return (
    <div className="space-y-1">
      {isLoading && <ThreeDotsLoader />}

      <div className="pb-4">
        <div>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="inline-flex h-10 w-10 items-center justify-center rounded-lg bg-slate-100 transition-colors duration-200 hover:bg-slate-200">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('segmentsDetails')}</h1>
                <div className="mt-1 flex items-center space-x-2">
                  <span className="text-sm text-slate-500">{t('segmentsId')}:</span>
                  <span className="rounded bg-slate-100 px-2 py-1 font-mono text-xs text-slate-700">
                    #{data?._id?.slice(-4)}
                  </span>
                </div>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <Button onClick={() => setOpenSheet(true)}>{t('edit')}</Button>
            </div>
          </div>
        </div>
      </div>

      <div className="pt-1">
        <div className="w-full">
          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            <div className="xl:col-span-2">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoExtensionPuzzleOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('segmentsInfo')}</h2>
                      <p className="text-sm text-slate-500">{t('Segment details and information')}</p>
                    </div>
                  </div>
                </div>

                <div className="p-6">
                  <div className="space-y-4">
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-xs font-medium text-slate-500">
                        {t('segmentName')}
                      </h4>
                      <p className="text-sm font-semibold text-slate-900">{data?.name || '—'}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-xs font-medium text-slate-500">
                        {t('createddate')}
                      </h4>
                      <p className="text-sm font-semibold text-slate-900">
                        {data?.createdAt ? formatDate(data.createdAt) : '—'}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoPeopleOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('selectedUser')}</h2>
                      <p className="text-sm text-slate-500">
                        {data?.users?.length || 0} {t('users')}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="p-6">
                  {!data?.users || data.users.length === 0 ? (
                    <div className="py-12 text-center">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <IoPeopleOutline className="h-8 w-8 text-slate-400" />
                      </div>
                      <h3 className="mb-1 text-lg font-medium text-slate-900">{t('No users found')}</h3>
                      <p className="text-slate-500">
                        This segment doesn&apos;t have any users assigned
                      </p>
                    </div>
                  ) : (
                    <div className="overflow-x-auto">
                      <Table>
                        <TableHeader>
                          <TableRow>
                            <TableHead className="text-xs font-medium text-slate-500">
                              {t('users')}
                            </TableHead>
                            <TableHead className="text-xs font-medium text-slate-500">
                              {t('email')}
                            </TableHead>
                          </TableRow>
                        </TableHeader>
                        <TableBody>
                          {data.users.map((user) => (
                            <TableRow key={user._id}>
                              <TableCell className="font-medium text-slate-900">
                                {user.userName}
                              </TableCell>
                              <TableCell className="text-slate-600">{user.email}</TableCell>
                            </TableRow>
                          ))}
                        </TableBody>
                      </Table>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('editegments')}</SheetTitle>
            <SheetDescription>
              <SegmentModelForm setOpenSheet={setOpenSheet} segmentData={data} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
};

export default SegmentDetails;
