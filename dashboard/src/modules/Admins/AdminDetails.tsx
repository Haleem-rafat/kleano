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
  Button,
  FormSheet,
  InfoList,
  MainAvatar,
  PageHeader,
  SectionCard,
  PageSkeleton,
} from '@UI/Index';
import { useTranslation } from 'react-i18next';
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
        password: yup.string().required('validation.required').min(8, 'validation.password'),
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
        toast.success(t('passwordUpdated'));
      })
      .catch((e) => {
        setIsLoading(false);

        toast.error(e?.response?.data?.localizedMessage?.[lang] || t('somethingWentWrong'));
      });
  };
  const suspended = AdminDetails?.status === 'SUSPENDED';
  if (isLoading) return <PageSkeleton kind="details" />;

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        leading={
          <MainAvatar src={undefined} name={AdminDetails?.userName || ''} className="h-10 w-10" />
        }
        title={AdminDetails?.userName || t('adminDetails')}
        description={AdminDetails && `${t('adminDetails')} · #${AdminDetails._id.slice(-6)}`}
        actions={
          <>
            {AdminDetails?.status && <MainStatusChipe status={AdminDetails.status} />}
            <Button onClick={() => setOpenSheet(true)} disabled={!AdminDetails}>
              {t('editAdmin')}
            </Button>
          </>
        }
      />

      <div className="grid gap-5 xl:grid-cols-3">
        <div className="space-y-5 xl:col-span-2">
          <SectionCard title={t('adminInfo')}>
            <InfoList
              items={[
                { label: t('name'), value: AdminDetails?.userName },
                {
                  label: t('phone'),
                  value: AdminDetails?.phone && <span dir="ltr">{AdminDetails.phone}</span>,
                },
                { label: t('nationalId'), value: AdminDetails?.nationalId },
                {
                  label: t('createddate'),
                  value: AdminDetails?.createdAt && formatDate(AdminDetails.createdAt),
                },
              ]}
            />
          </SectionCard>

          <SectionCard
            title={t('adminCities')}
            action={
              <span className="text-xs text-muted-foreground">
                {AdminDetails?.city?.length || 0}
              </span>
            }>
            {AdminDetails?.city?.length ? (
              <div className="flex flex-wrap gap-2">
                {AdminDetails.city.map((c) => (
                  <span
                    key={c._id}
                    className="rounded-full bg-accent px-3 py-1 text-[13px] font-medium text-primary">
                    {c?.name?.[lang]}
                  </span>
                ))}
              </div>
            ) : (
              <p className="text-[13px] text-muted-foreground">{t('noCitiesYet')}</p>
            )}
          </SectionCard>
        </div>

        <div className="xl:col-span-1">
          <SectionCard title={t('actions')}>
            <ul className="divide-y divide-border">
              {isSuperAdmin && (
                <li className="flex items-center justify-between gap-3 py-3 first:pt-0">
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-foreground">{t('Reset password')}</p>
                    <p className="text-xs text-muted-foreground">{t('resetPasswordHint')}</p>
                  </div>
                  <Dialog open={open} onOpenChange={setOpen}>
                    <DialogTrigger asChild>
                      <Button variant="secondary" size="sm">
                        {t('Reset password')}
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-md">
                      <DialogHeader>
                        <DialogTitle>{t('Reset password')}</DialogTitle>
                        <DialogDescription>{t('resetPasswordHint')}</DialogDescription>
                      </DialogHeader>
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
                            {t('Save changes')}
                          </Button>
                        </form>
                      </Form>
                    </DialogContent>
                  </Dialog>
                </li>
              )}
              <li className="flex items-center justify-between gap-3 py-3 first:pt-0">
                <div className="min-w-0">
                  <p className="text-sm font-medium text-foreground">
                    {suspended ? t('activate') : t('suspend')}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {suspended ? t('restoreAdminHint') : t('suspendAdminHint')}
                  </p>
                </div>
                {suspended ? (
                  <Alert
                    handler={() => handleToggleAdminStatus('restore')}
                    id={AdminDetails?._id}
                    description={t('restoreAdminAlert')}
                    buttonComponent={
                      <Button size="sm" variant="secondary" loading={isloading}>
                        {t('activate')}
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
                      <Button size="sm" variant="dangerOutline" loading={isloading}>
                        {t('suspend')}
                      </Button>
                    }
                  />
                )}
              </li>
              <li className="flex items-center justify-between gap-3 py-3 last:pb-0">
                <div className="min-w-0">
                  <p className="text-sm font-medium text-destructive">{t('deleteAdmin')}</p>
                  <p className="text-xs text-muted-foreground">{t('deleteAdminHint')}</p>
                </div>
                <Alert
                  handler={handleDeleteAdmin}
                  id={AdminDetails?._id}
                  description={t('deleteAdminConfirm')}
                  buttonComponent={
                    <Button size="sm" variant="danger" loading={isloading}>
                      {t('delete')}
                    </Button>
                  }
                />
              </li>
            </ul>
          </SectionCard>
        </div>
      </div>

      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('editAdmin')}>
        {AdminDetails && <AdminModelForm setOpenSheet={setOpenSheet} oldData={AdminDetails} />}
      </FormSheet>
    </div>
  );
}
