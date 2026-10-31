import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { formatDate } from '@app/utils/helper';
import useSWR, { mutate } from 'swr';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@shadecn/components/ui/form';

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { Button, ThreeDotsLoader } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import {
  IoArrowBackCircleOutline,
  IoPersonCircleOutline,
  IoLocationOutline,
  IoSettingsOutline,
} from 'react-icons/io5';
import adminsService from '@services/admins.service';
import { toast } from 'react-toastify';
import Alert from '@UI/Alert/Alert';
import { IAdmin } from '@servicesTypes/admins.types';
import { selectAuth } from '@store/slices/auth.slice';
import { useAppSelector } from '@hooks';
import settingsService from '@services/settings.service';
import { Input } from '@shadecn/components/ui/input';
import AdminModelForm from './_Components/AdminModelForm';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';

export default function AdminDetails() {
  const { adminId } = useParams();
  const navigate = useNavigate();
  const { isSuperAdmin } = useAppSelector(selectAuth);
  const [open, setOpen] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const [reason, setReason] = useState('');
  const [openSheet, setOpenSheet] = useState(false);
  const [isloading, setIsLoading] = useState(false);

  const { data: AdminDetails, isLoading } = useSWR(
    ['get-all-admins-details', adminId],
    () =>
      adminId &&
      adminsService.getAdminDetails(adminId).then((data) => {
        return data.data as IAdmin;
      })
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
  const handleDeleteAdmin = () => {
    setIsLoading(true);
    adminsService
      .deleteAdmin(adminId)
      .then(() => {
        mutate((key: string) => key.includes('get-all-admins-list'));
        mutate((key: string) => key.includes('get-all-admins-details'));
        toast.success(t('The admin has been successfully deleted'));
        navigate(-1);
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
  const handleToggleAdminStatus = (status: 'restore' | 'suspend', reason?: string) => {
    setIsLoading(true);
    adminsService
      .toggleAdminStatus(adminId, status, reason)
      .then(() => {
        mutate((key: string) => key.includes('get-all-admins-list'));
        mutate((key: string) => key.includes('get-all-admins-details'));
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
  const onEditPassword = async (data) => {
    setIsLoading(true);
    await settingsService
      .updateAdminPassword(data, adminId)
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
  return (
    <div className="min-h-screen bg-slate-50">
      {(isLoading || isloading) && <ThreeDotsLoader />}

      {/* Professional Header */}
      <div className="sticky top-0 z-[50] border-b border-slate-200 bg-white shadow-sm">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 transition-colors duration-200 hover:bg-slate-200">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('adminDetails')}</h1>
                <p className="mt-1 text-sm text-slate-500">
                  {t('adminId')}: #{AdminDetails?._id?.slice(-4)}
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <MainStatusChipe status={AdminDetails?.status} />
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6">
        <div className="mx-auto max-w-[95%]">
          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            {/* Admin Information Card */}
            <div className="xl:col-span-2">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoPersonCircleOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('adminInfo')}</h2>
                      <p className="text-sm text-slate-500">Personal and contact information</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('name')}</h4>
                      <p className="text-lg font-bold text-slate-900">{AdminDetails?.userName}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('phone')}</h4>
                      <p className="text-lg font-bold text-slate-900">{AdminDetails?.phone}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('nationalId')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">{AdminDetails?.nationalId}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('createddate')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {formatDate(AdminDetails?.createdAt)}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Cities Card */}
              <div className="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoLocationOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('adminCities')}</h2>
                      <p className="text-sm text-slate-500">Assigned cities and regions</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="flex flex-wrap gap-3">
                    {AdminDetails?.city?.map((e) => (
                      <div
                        key={e._id}
                        className="rounded-full border-2 border-orange-200 bg-orange-50 px-4 py-2 text-sm font-medium text-orange-700 transition-colors duration-200 hover:bg-orange-100">
                        {e?.name[lang]}
                      </div>
                    ))}
                  </div>
                </div>
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
                      <h2 className="text-sm font-semibold text-slate-900">{t('actions')}</h2>
                      <p className="text-sm text-slate-500">Manage admin settings</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="space-y-4 p-6">
                  {/* Edit Info */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t('editInfo')}</h4>
                      <p className="text-xs text-slate-500">Update admin information</p>
                    </div>
                    <Button
                      size="sm"
                      className="min-w-[8rem] font-semibold"
                      onClick={() => setOpenSheet(true)}>
                      {t('editAdmin')}
                    </Button>
                  </div>

                  {/* Status Toggle */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">
                        {AdminDetails?.status === 'SUSPENDED' ? t('active') : t('suspend')}
                      </h4>
                      <p className="text-xs text-slate-500">
                        {AdminDetails?.status === 'SUSPENDED'
                          ? 'Restore admin access'
                          : 'Suspend admin access'}
                      </p>
                    </div>
                    {AdminDetails?.status === 'SUSPENDED' ? (
                      <Alert
                        handler={() => handleToggleAdminStatus('restore')}
                        id={AdminDetails?._id}
                        description={t('restoreAdminAlert')}
                        buttonComponent={
                          <Button
                            size="sm"
                            className="min-w-[8rem] bg-green-600 font-semibold text-white hover:bg-green-700">
                            {t('active')}
                          </Button>
                        }
                      />
                    ) : (
                      <Alert
                        handler={() => handleToggleAdminStatus('suspend', reason)}
                        id={AdminDetails?._id}
                        description={t('suspendAdminAlert')}
                        hasReason
                        setInputValue={setReason}
                        buttonComponent={
                          <Button
                            size="sm"
                            className="min-w-[8rem] bg-red-600 font-semibold text-white hover:bg-red-700">
                            {t('suspend')}
                          </Button>
                        }
                      />
                    )}
                  </div>

                  {/* Delete Admin */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-red-300 hover:shadow-red-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t('delete')}</h4>
                      <p className="text-xs text-slate-500">Permanently remove admin</p>
                    </div>
                    <Alert
                      handler={handleDeleteAdmin}
                      id={AdminDetails?._id}
                      description="Are you sure you want to delete this admin?"
                      buttonComponent={
                        <Button
                          size="sm"
                          className="min-w-[8rem] bg-red-200 font-semibold text-red-600 hover:bg-red-100">
                          {t('deleteAdmin')}
                        </Button>
                      }
                    />
                  </div>

                  {/* Reset Password - Super Admin Only */}
                  {isSuperAdmin && (
                    <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                      <div>
                        <h4 className="text-sm font-semibold text-slate-700">
                          {t('Reset password')}
                        </h4>
                        <p className="text-xs text-slate-500">Generate new password</p>
                      </div>
                      <Dialog open={open} onOpenChange={setOpen}>
                        <DialogTrigger asChild>
                          <Button variant="secondary" size="sm" className="min-w-[8rem]">
                            Reset password
                          </Button>
                        </DialogTrigger>
                        <DialogContent className="sm:max-w-[425px]">
                          <DialogHeader>
                            <DialogTitle>Reset password</DialogTitle>
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
              {AdminDetails && (
                <AdminModelForm setOpenSheet={setOpenSheet} oldData={AdminDetails} />
              )}
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
