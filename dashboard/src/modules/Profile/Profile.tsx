import settingsService from '@services/settings.service';
import { Button, InfoList, MainAvatar, PageHeader, SectionCard, PageSkeleton } from '@UI/Index';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import { formatDate } from '@app/utils/helper';
import { toast } from 'react-toastify';
import useSWR from 'swr';
import { Input } from '@shadecn/components/ui/input';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { useTranslation } from 'react-i18next';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@shadecn/components/ui/form';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';
const Profile = () => {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const { i18n, t } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const fetchProfile = async () => {
    return await settingsService
      .getProfile()
      .then((data) => {
        return data.data;
      })
      .catch((e) => {
        toast.error(e?.response?.data?.localizedMessage?.[lang] || t('somethingWentWrong'));
      });
  };
  const { data, isLoading } = useSWR('get-amin-profile', fetchProfile);

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
    setLoading(true);
    await settingsService
      .resetMpassword(data)
      .then(() => {
        setLoading(false);
        setOpen(false);
        toast.success(t('passwordUpdated'));
      })
      .catch((e) => {
        setLoading(false);

        toast.error(e?.response?.data?.localizedMessage?.[lang] || t('somethingWentWrong'));
      });
  };
  if (isLoading) return <PageSkeleton kind="form" />;
  return (
    <div className="mx-auto w-full max-w-4xl space-y-5">
      <PageHeader
        leading={<MainAvatar src={undefined} name={data?.userName || ''} className="h-10 w-10" />}
        title={data?.userName || t('User Profile')}
        description={t('User Profile')}
        actions={
          <>
            {data?.status && <MainStatusChipe status={data.status} />}
            <Dialog open={open} onOpenChange={setOpen}>
              <DialogTrigger asChild>
                <Button variant="secondary">{t('Reset password')}</Button>
              </DialogTrigger>
              <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                  <DialogTitle>{t('Reset password')}</DialogTitle>
                  <DialogDescription>{t('resetPasswordHint')}</DialogDescription>
                </DialogHeader>

                <div className=" w-full">
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
                      />{' '}
                      <Button disabled={loading} loading={loading} type="submit" className="w-full">
                        {t('Save changes')}
                      </Button>
                    </form>
                  </Form>
                </div>
              </DialogContent>
            </Dialog>
          </>
        }
      />
      <SectionCard title={t('accountInfo')}>
        <InfoList
          items={[
            { label: t('User Name'), value: data?.userName },
            { label: t('Language'), value: data?.lang?.toUpperCase() },
            { label: t('role'), value: data?.isSuperAdmin ? t('superAdmin') : t('admin') },
            { label: t('Created At'), value: data?.createdAt && formatDate(data.createdAt) },
            { label: t('Last Updated'), value: data?.updatedAt && formatDate(data.updatedAt) },
            ...(data?.suspendReason
              ? [{ label: t('Suspend Reason'), value: data.suspendReason }]
              : []),
            {
              label: t('City'),
              wide: true,
              value: data?.city?.length ? (
                <span className="flex flex-wrap gap-1.5">
                  {data.city.map((c) => (
                    <span
                      key={c._id}
                      className="rounded-full bg-accent px-2.5 py-0.5 text-xs font-medium text-primary">
                      {c?.name?.[lang] || c?.name?.en}
                    </span>
                  ))}
                </span>
              ) : undefined,
            },
          ]}
        />
      </SectionCard>
    </div>
  );
};

export default Profile;
