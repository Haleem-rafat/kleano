import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { toast } from 'react-toastify';
import {
  IoArrowBackCircleOutline,
  IoPersonCircleOutline,
  IoSettingsOutline,
} from 'react-icons/io5';
import { useTranslation } from 'react-i18next';

import useSWR, { mutate } from 'swr';
import bikersService from '@services/bikers.service';
import { IBikers } from '@servicesTypes/bikers.types';
import { AdminStatus, Button, ThreeDotsLoader } from '@UI/Index';
import { t } from 'i18next';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@shadecn/components/ui/form';
import settingsService from '@services/settings.service';
import { yupResolver } from '@hookform/resolvers/yup';
import { useForm } from 'react-hook-form';
import * as yup from 'yup';
import { formatDate } from '@app/utils/helper';
import { Input } from '@shadecn/components/ui/input';
import BikersFrom from '../_components/BikersFrom';
import PicViewModel from '../_components/PicViewModel';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';
import SegmentsDialogeWrapper from '@/modules/Segments/_Components/SegmentsDialogeWrapper';
export default function BikersDetails() {
  const { bikerId } = useParams();
  const navigate = useNavigate();

  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const [isloading, setIsLoading] = useState(false);
  const [openSheet, setOpenSheet] = useState(false);
  const [open, setOpen] = useState(false);

  const { data, isLoading } = useSWR(
    ['get-biker-details', bikerId],
    () => bikerId && bikersService.getBikerById(bikerId).then((data) => data?.data as IBikers)
  );
  const { data: totalCommission } = useSWR(
    ['get-biker-total-commission', bikerId],
    () =>
      bikerId &&
      bikersService.getBikerTotalCommission(bikerId).then(
        (data) =>
          data?.data as {
            today: {
              totalCommission: number;
              ordersCount: number;
            };
            allTime: {
              totalCommission: number;
              ordersCount: number;
            };
            allWeekends: {
              totalCommission: number;
              ordersCount: number;
            };
          }
      )
  );

  const newPasswrodForm = useForm({
    defaultValues: {
      password: '',
    },
    resolver: yupResolver(
      yup.object({
        password: yup
          .string()
          .required('Required')
          .min(8, 'Password must be at least 8 characters'),
      })
    ),
  });
  const onEditPassword = async (data) => {
    setIsLoading(true);
    await settingsService
      .updateBikerPassword(data, bikerId)
      .then(() => {
        setIsLoading(false);
        setOpen(false);
        toast.success('Password updated successfully');
      })
      .catch((e) => {
        setIsLoading(false);

        toast.error(e.response.localizedMessage['en']);
      });
  };
  const handelActionBiker = (id: string, state: string) => {
    setIsLoading(true);

    const endPoint =
      state === 'ACTIVE' ? bikersService.suspendBiker(id) : bikersService.restoreBiker(id);
    endPoint
      .then(() => {
        mutate((key: string) => key.includes('get-biker-details'));
        toast.success(
          state === 'ACTIVE' ? t('bikerSuspendedSuccessfully') : t('bikerRestoredSuccessfully')
        );
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
  if (isLoading && isloading)
    return (
      <div className="relative">
        <ThreeDotsLoader />
      </div>
    );
  return (
    <div className="min-h-screen bg-slate-50">
      {(isLoading || isloading) && <ThreeDotsLoader />}

      {/* Professional Header */}
      <div className="border-b border-slate-200 bg-white shadow-sm">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 transition-colors duration-200 hover:bg-slate-200">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div className="flex items-center gap-3">
                <div>
                  <div className="flex items-center gap-3">
                    <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('bikerDetails')}</h1>
                  </div>
                  <p className="mt-1 text-sm text-slate-500">
                    {t('bikerId')}: #{data?._id?.slice(-4)}
                  </p>
                </div>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              {data?.status && (
                <div className="mt-1">
                  <AdminStatus status={data?.status} />
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6">
        <div className="w-full">
          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            {/* Biker Information Card */}
            <div className="xl:col-span-2">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoPersonCircleOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('bikerInfo')}</h2>
                      <p className="text-sm text-slate-500">Personal and contact information</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('bikerImage')}
                      </h4>
                      <div className="flex justify-center">
                        <SegmentsDialogeWrapper
                          modal
                          triggerButtonElement={
                            <img
                              className="h-20 w-32 cursor-pointer rounded-lg object-cover transition-opacity duration-200 hover:opacity-80"
                              src={data?.imageLink}
                              alt="Biker profile"
                            />
                          }>
                          <PicViewModel pic={data?.imageLink} />
                        </SegmentsDialogeWrapper>
                      </div>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('name')}</h4>
                      <p className="text-lg font-bold text-slate-900">{data?.userName}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('phone')}</h4>
                      <p className="text-lg font-bold text-slate-900">{data?.phone}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('nationalId')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">{data?.nationalId}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('thisBikerCreatedBy')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {data?.createdBy?.userName || '--'}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('createddate')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {formatDate(data?.createdAt)}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('commissionType')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {data?.commissionType ? t(data.commissionType) : '--'}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('commission')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {data?.commission !== undefined && data?.commission !== null
                          ? `${data.commission}${data?.commissionType === 'PERCENTAGE' ? '%' : ''}`
                          : '--'}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('ordersBeforeCommission')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {data?.ordersBeforeCommission !== undefined &&
                        data?.ordersBeforeCommission !== null
                          ? data.ordersBeforeCommission
                          : '--'}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('Minimum Commission')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {data?.minimumCommission !== undefined && data?.minimumCommission !== null
                          ? data.minimumCommission
                          : '--'}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('weekendCommission')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {data?.weekendCommission !== undefined && data?.weekendCommission !== null
                          ? data.weekendCommission
                          : '--'}
                      </p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('totalCommission')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {totalCommission?.today?.totalCommission} {t('today')}
                      </p>
                      <p className="text-lg font-bold text-slate-900">
                        {totalCommission?.allTime?.totalCommission} {t('allTime')}
                      </p>
                      <p className="text-lg font-bold text-slate-900">
                        {totalCommission?.allWeekends?.totalCommission} {t('allWeekends')}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Areas Card */}
              {/* <div className="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white"> */}
              {/* Gradient Header */}
              {/* <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoLocationOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('bikerAreas')}</h2>
                      <p className="text-sm text-slate-500">Assigned service areas</p>
                    </div>
                  </div>
                </div> */}

              {/* Card Content */}
              {/* <div className="p-6">
                  <div className="flex flex-wrap gap-3">
                    {data?.areas?.map((e) => (
                      <div
                        key={e?._id}
                        className="rounded-full border-2 border-orange-200 bg-orange-50 px-4 py-2 text-sm font-medium text-orange-700 transition-colors duration-200 hover:bg-orange-100">
                        {e.name?.[lang]}
                      </div>
                    ))}
                  </div>
                </div> */}
              {/* </div> */}

              {/* Cities Card */}
              <div className="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                {/* <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoLocationOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('bikerCities')}</h2>
                      <p className="text-sm text-slate-500">Assigned cities</p>
                    </div>
                  </div>
                </div> */}

                {/* Card Content */}
                {/* <div className="p-6">
                  <div className="flex flex-wrap gap-3">
                    <div className="rounded-full border-2 border-emerald-200 bg-emerald-50 px-4 py-2 text-sm font-medium text-emerald-700 transition-colors duration-200 hover:bg-emerald-100">
                      {data?.city?.name?.[lang]}
                    </div>
                  </div>
                </div> */}
              </div>
            </div>

            {/* Actions Card */}
            <div className="xl:col-span-1">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoSettingsOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('bikerActions')}</h2>
                      <p className="text-sm text-slate-500">Manage biker settings</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="space-y-4 p-6">
                  {/* Edit Password */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t('editPassword')}</h4>
                      <p className="text-xs text-slate-500">Update biker password</p>
                    </div>
                    <Dialog open={open} onOpenChange={setOpen}>
                      <DialogTrigger asChild>
                        <Button variant="secondary" size="sm" className="min-w-[8rem]">
                          {t('editPassword')}
                        </Button>
                      </DialogTrigger>
                      <DialogContent className="sm:max-w-[425px]">
                        <DialogHeader>
                          <DialogTitle>{t('editPassword')}</DialogTitle>
                          <DialogDescription>
                            Make changes to your Password here. Click save when you&lsquo;re done.
                          </DialogDescription>
                        </DialogHeader>

                        <div className="w-full">
                          <Form {...newPasswrodForm}>
                            <form
                              className="flex w-full flex-col gap-3"
                              onSubmit={newPasswrodForm.handleSubmit(onEditPassword)}>
                              <FormField
                                control={newPasswrodForm.control}
                                name="password"
                                render={({ field }) => (
                                  <FormItem>
                                    <FormLabel />
                                    <FormControl>
                                      <Input type="password" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                  </FormItem>
                                )}
                              />
                              <Button
                                disabled={isLoading}
                                loading={isLoading}
                                type="submit"
                                className="w-full">
                                Save changes
                              </Button>
                            </form>
                          </Form>
                        </div>
                      </DialogContent>
                    </Dialog>
                  </div>

                  {/* Edit Info */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t('editInfo')}</h4>
                      <p className="text-xs text-slate-500">Update biker information</p>
                    </div>
                    <Button size="sm" loading={isloading} onClick={() => setOpenSheet(true)}>
                      {t('edit')}
                    </Button>
                  </div>

                  {/* Status Toggle */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t(data?.status)}</h4>
                      <p className="text-xs text-slate-500">
                        {data?.status !== 'SUSPENDED'
                          ? 'Suspend biker access'
                          : data?.status === 'SUSPENDED'
                          ? 'Restore biker access'
                          : ''}
                      </p>
                    </div>
                    <Button
                      size="sm"
                      loading={isloading}
                      onClick={() => handelActionBiker(data?._id, data?.status)}
                      className={
                        data?.status !== 'SUSPENDED'
                          ? 'bg-red-600 text-white hover:bg-red-700'
                          : 'bg-green-600 text-white hover:bg-green-700'
                      }>
                      {data?.status !== 'SUSPENDED' ? t('suspend') : t('activate')}
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('editBikerInfo')}</SheetTitle>
            <SheetDescription>
              <BikersFrom setOpenSheet={setOpenSheet} oldData={data} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
