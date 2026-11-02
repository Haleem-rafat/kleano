import { useState } from 'react';
import { generatePath, useNavigate, useParams } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';

import useSWR, { mutate } from 'swr';
import bikersService from '@services/bikers.service';
import { IBikers } from '@servicesTypes/bikers.types';
import Alert from '@UI/Alert/Alert';
import {
  AdminStatus,
  Button,
  FormSheet,
  InfoList,
  MainAvatar,
  PageHeader,
  SectionCard,
  PageSkeleton,
} from '@UI/Index';
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';
export default function BikersDetails() {
  const { bikerId } = useParams();
  const navigate = useNavigate();

  const { t, i18n } = useTranslation();
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
        password: yup.string().required('validation.required').min(8, 'validation.password'),
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
        toast.success(t('passwordUpdated'));
      })
      .catch((e) => {
        setIsLoading(false);

        toast.error(e?.response?.data?.localizedMessage?.[lang] || t('somethingWentWrong'));
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
  if (isLoading) return <PageSkeleton kind="details" />;
  if (!data) return <p className="py-24 text-center text-muted-foreground">{t('bikerNotFound')}</p>;

  const suspended = data.status === 'SUSPENDED';
  const pct = data.commissionType === 'PERCENTAGE' ? '%' : ` ${t('SAR')}`;
  const money = (v?: number) => `${(v ?? 0).toFixed(2)} ${t('SAR')}`;
  const tiles = [
    {
      label: t('today'),
      value: money(totalCommission?.today?.totalCommission),
      sub: totalCommission?.today?.ordersCount,
    },
    {
      label: t('allWeekends'),
      value: money(totalCommission?.allWeekends?.totalCommission),
      sub: totalCommission?.allWeekends?.ordersCount,
    },
    {
      label: t('allTime'),
      value: money(totalCommission?.allTime?.totalCommission),
      sub: totalCommission?.allTime?.ordersCount,
    },
  ];

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        leading={<MainAvatar src={data.imageLink} name={data.userName} className="h-10 w-10" />}
        title={data.userName}
        description={<span dir="ltr">{data.phone}</span>}
        actions={
          <>
            <AdminStatus status={data.status} />
            <Button
              variant="secondary"
              onClick={() => navigate(generatePath(ROUTES.BIKERS_SCHEDULE, { bikerId: data._id }))}>
              {t('schedule')}
            </Button>
            <Button onClick={() => setOpenSheet(true)}>{t('edit')}</Button>
          </>
        }
      />

      <div className="grid gap-3 sm:grid-cols-3">
        {tiles.map((tile) => (
          <div key={tile.label} className="rounded-lg border border-border bg-card px-4 py-3">
            <p className="text-xs font-medium text-muted-foreground">
              {t('totalCommission')} · {tile.label}
            </p>
            <p className="mt-1 text-lg font-semibold tabular-nums text-foreground">{tile.value}</p>
            {tile.sub !== undefined && (
              <p className="text-xs text-muted-foreground">
                {t('ordersCountN', { count: tile.sub })}
              </p>
            )}
          </div>
        ))}
      </div>

      <div className="grid gap-5 xl:grid-cols-3">
        <div className="space-y-5 xl:col-span-2">
          <SectionCard title={t('bikerInfo')}>
            <InfoList
              items={[
                { label: t('name'), value: data.userName },
                { label: t('phone'), value: <span dir="ltr">{data.phone}</span> },
                { label: t('nationalId'), value: data.nationalId },
                { label: t('createddate'), value: data.createdAt && formatDate(data.createdAt) },
                { label: t('thisBikerCreatedBy'), value: data.createdBy?.userName },
              ]}
            />
          </SectionCard>

          <SectionCard title={t('commission')}>
            <InfoList
              items={[
                {
                  label: t('commissionType'),
                  value: data.commissionType && t(data.commissionType),
                },
                {
                  label: t('commission'),
                  value: data.commission != null && `${data.commission}${pct}`,
                },
                { label: t('ordersBeforeCommission'), value: data.ordersBeforeCommission },
                {
                  label: t('Minimum Commission'),
                  value: data.minimumCommission != null && `${data.minimumCommission} ${t('SAR')}`,
                },
                {
                  label: t('weekendCommission'),
                  value: data.weekendCommission != null && `${data.weekendCommission}${pct}`,
                },
              ]}
            />
          </SectionCard>
        </div>

        <div className="xl:col-span-1">
          <SectionCard title={t('bikerActions')}>
            <ul className="divide-y divide-border">
              <li className="flex items-center justify-between gap-3 py-3 first:pt-0">
                <div className="min-w-0">
                  <p className="text-sm font-medium text-foreground">{t('editPassword')}</p>
                  <p className="text-xs text-muted-foreground">{t('resetPasswordHint')}</p>
                </div>
                <Dialog open={open} onOpenChange={setOpen}>
                  <DialogTrigger asChild>
                    <Button variant="secondary" size="sm">
                      {t('editPassword')}
                    </Button>
                  </DialogTrigger>
                  <DialogContent className="sm:max-w-md">
                    <DialogHeader>
                      <DialogTitle>{t('editPassword')}</DialogTitle>
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
              <li className="flex items-center justify-between gap-3 py-3 last:pb-0">
                <div className="min-w-0">
                  <p className="text-sm font-medium text-foreground">
                    {suspended ? t('activate') : t('suspend')}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {suspended ? t('restoreBikerAccess') : t('suspendBikerAccess')}
                  </p>
                </div>
                <Alert
                  id={data._id}
                  description={suspended ? t('activate') : t('suspendBikerConfirm')}
                  handler={() => handelActionBiker(data._id, data.status)}
                  buttonComponent={
                    <Button
                      size="sm"
                      variant={suspended ? 'secondary' : 'dangerOutline'}
                      loading={isloading}>
                      {suspended ? t('activate') : t('suspend')}
                    </Button>
                  }
                />
              </li>
            </ul>
          </SectionCard>
        </div>
      </div>

      <FormSheet
        open={openSheet}
        onOpenChange={() => setOpenSheet(false)}
        title={t('editBikerInfo')}>
        <BikersFrom setOpenSheet={setOpenSheet} oldData={data} />
      </FormSheet>
    </div>
  );
}
