import ordersService from '@services/orders.service';
import { IOrderList } from '@servicesTypes/order.types';
import {
  AdminStatus,
  Button,
  FormSheet,
  ImageModal,
  InfoList,
  MainAvatar,
  PageHeader,
  SectionCard,
  StarRating,
  PageSkeleton,
} from '@UI/Index';
import { ROUTES } from '@constants/routes';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate, useParams } from 'react-router-dom';
import useSWR from 'swr';
import { formatDate } from '@app/utils/helper';
import AssignedBikerTable from '../_Components/AssignedBikerTable';
import UserPopover from '../_Components/UserPopover';

export default function OrderDetails() {
  const navigate = useNavigate();
  const { orderId } = useParams();

  const [openSheet, setOpenSheet] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  // Backend text may be plain or { en, ar }; never render the object itself.
  const localized = (value) =>
    typeof value === 'string' ? value : value?.[lang] || value?.en || value?.ar || '';

  const { data, isLoading } = useSWR(
    ['get-all-order-details', orderId],
    () =>
      orderId &&
      ordersService.getOrdersDetails(orderId).then((data) => {
        return data.data as IOrderList;
      })
  );
  const sar = (v?: number | string) => `${v ?? 0} ${t('SAR')}`;
  const openStatuses = !['COMPLETED', 'CANCELLED_BY_ADMIN', 'CANCELLED_BY_USER'].includes(
    data?.status
  );
  const canAssign = ['WAITING_FOR_BIKER_BY_ADMIN', 'ACCEPTED_BY_BIKER'].includes(data?.status);
  const person = (
    p?: { _id?: string; userName?: string; phone?: string; imageLink?: string },
    to?: string
  ) =>
    p ? (
      <button
        type="button"
        disabled={!to}
        onClick={() => to && navigate(to)}
        className="flex w-full items-center gap-3 rounded-md text-start enabled:hover:bg-muted">
        <MainAvatar src={p.imageLink} name={p.userName || ''} className="h-10 w-10" />
        <div className="min-w-0">
          <p className="truncate text-sm font-medium text-foreground">{p.userName}</p>
          <p className="truncate text-xs text-muted-foreground" dir="ltr">
            {p.phone}
          </p>
        </div>
      </button>
    ) : null;

  if (isLoading) return <PageSkeleton kind="details" />;
  if (!data)
    return <p className="py-24 text-center text-muted-foreground">{t('noDataAvailable')}</p>;

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        title={`${t('orderDetails')} #${data._id.slice(-6)}`}
        description={`${t('orderDate')} ${formatDate(data.createdAt)}`}
        actions={
          <>
            <AdminStatus status={data.status} />
            {openStatuses && <UserPopover orderId={data._id} paid={data.totalPay} />}
            {canAssign && <Button onClick={() => setOpenSheet(true)}>{t('assignedBiker')}</Button>}
          </>
        }
      />

      <div className="grid gap-5 lg:grid-cols-3">
        <SectionCard title={t('userInfo')}>
          {person(
            data.user,
            data.user?._id && generatePath(ROUTES.USERS_DETAILS, { userId: data.user._id })
          )}
          <InfoList
            className="mt-2 sm:grid-cols-1"
            items={[
              { label: t('orderCount'), value: data.userOrdersCount },
              {
                label: t('userRatingForThisOrder'),
                value: <StarRating rating={data.ratingOfUser || 0} size="sm" showValue />,
              },
              ...(data.description
                ? [{ label: t('User Notes'), value: localized(data.description) }]
                : []),
            ]}
          />
        </SectionCard>

        <SectionCard title={t('bikerInfo')}>
          {data.biker ? (
            <>
              {person(data.biker, generatePath(ROUTES.BIKERS_DETAILS, { bikerId: data.biker._id }))}
              <InfoList
                className="mt-2 sm:grid-cols-1"
                items={[
                  {
                    label: t('bikerCommission'),
                    value: data.bikerCommission != null && sar(data.bikerCommission),
                  },
                  {
                    label: t('bikerRatingForThisOrder'),
                    value: <StarRating rating={data.ratingOfBiker || 0} size="sm" showValue />,
                  },
                ]}
              />
            </>
          ) : (
            <div className="flex flex-col items-start gap-3">
              <p className="text-[13px] text-muted-foreground">{t('noBikerYet')}</p>
              {canAssign && (
                <Button variant="secondary" size="sm" onClick={() => setOpenSheet(true)}>
                  {t('assignedBiker')}
                </Button>
              )}
            </div>
          )}
        </SectionCard>

        <SectionCard title={t('vehicleInfo')}>
          <div className="flex items-start gap-3">
            {data.vehicle?.imageLink && (
              <ImageModal
                src={data.vehicle.imageLink}
                alt={`${data.vehicle.brand} ${data.vehicle.model}`}
                className="h-14 w-14 shrink-0 rounded-md"
                fallbackText=""
              />
            )}
            <InfoList
              className="flex-1 sm:grid-cols-2"
              items={[
                { label: t('brand'), value: data.vehicle?.brand },
                { label: t('model'), value: data.vehicle?.model },
                {
                  label: t('plateNumber'),
                  value: data.vehicle?.plateNumber && (
                    <span className="font-mono">{data.vehicle.plateNumber}</span>
                  ),
                },
                { label: t('color'), value: data.vehicle?.color },
              ]}
            />
          </div>
        </SectionCard>
      </div>

      <div className="grid gap-5 lg:grid-cols-3">
        <SectionCard
          title={t('location')}
          action={
            data.googleMapsLink && (
              <a
                href={data.googleMapsLink}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[13px] font-medium text-primary hover:underline">
                {t('View on Google Maps')}
              </a>
            )
          }>
          <InfoList
            className="sm:grid-cols-1"
            items={[
              { label: t('cityName'), value: data.location?.city?.name?.[lang] },
              { label: t('area'), value: data.location?.subAdministrativeArea },
              { label: t('streetName'), value: data.location?.streetName },
              { label: t('startTime'), value: data.startTime && formatDate(data.startTime) },
            ]}
          />
        </SectionCard>

        <SectionCard title={t('pricing')}>
          <dl className="space-y-2 text-sm">
            {[
              { label: t('total price'), value: sar(data.totalPrice) },
              data.isPointsApplied && {
                label: t('Points Discount'),
                value: `− ${sar(data.pointsDiscount)}`,
              },
              Number(data.discount) > 0 && {
                label: t('Discount'),
                value: `− ${sar(data.discount)}`,
              },
              data.promoCode && { label: t('promo Code'), value: data.promoCode.code },
              { label: t('Payment Type'), value: data.paymentType ? t(data.paymentType) : '—' },
            ]
              .filter(Boolean)
              .map((row) => {
                const r = row as { label: string; value: string };
                return (
                  <div key={r.label} className="flex items-center justify-between gap-3">
                    <dt className="text-muted-foreground">{r.label}</dt>
                    <dd className="font-medium tabular-nums text-foreground">{r.value}</dd>
                  </div>
                );
              })}
            <div className="flex items-center justify-between gap-3 border-t border-border pt-3">
              <dt className="font-semibold text-foreground">{t('paied price')}</dt>
              <dd className="text-base font-semibold tabular-nums text-primary">
                {sar(data.totalPay)}
              </dd>
            </div>
          </dl>
        </SectionCard>

        {data.subscription ? (
          <SectionCard title={t('subscription')}>
            <InfoList
              className="sm:grid-cols-1"
              items={[
                {
                  label: t('Plan Name'),
                  value: (
                    <span className="inline-flex items-center gap-2">
                      {data.subscription.plan?.color && (
                        <span
                          className="h-3 w-3 rounded-full"
                          style={{ backgroundColor: data.subscription.plan.color }}
                        />
                      )}
                      {data.subscription.plan?.type?.[lang]}
                    </span>
                  ),
                },
                {
                  label: t('Remaining Washes'),
                  value: `${data.subscription.remainingWashes ?? 0} / ${
                    data.subscription.washesCount ?? 0
                  }`,
                },
                { label: t('Price'), value: sar(data.subscription.plan?.price) },
              ]}
            />
          </SectionCard>
        ) : (
          <SectionCard title={t('carPictures')}>
            <Photos data={data} t={t} />
          </SectionCard>
        )}
      </div>

      <div className="grid gap-5 lg:grid-cols-3">
        <SectionCard
          className="lg:col-span-2"
          title={t('Washing Services')}
          action={
            <span className="text-xs text-muted-foreground">
              {(data.washingServices?.length || 0) + (data.addOns?.length || 0)}
            </span>
          }>
          <ul className="divide-y divide-border rounded-md border border-border">
            {[
              ...(data.washingServices ?? []).map((s) => ({ ...s, kind: 'service' })),
              ...(data.addOns ?? []).map((a) => ({ ...a, kind: 'addon' })),
            ].map((item) => (
              <li key={`${item.kind}-${item._id}`} className="flex items-center gap-3 px-3 py-2.5">
                {item.icon?.iconLink ? (
                  <img
                    src={item.icon.iconLink}
                    alt=""
                    className="h-9 w-9 shrink-0 rounded-md object-contain"
                  />
                ) : (
                  <span className="h-9 w-9 shrink-0 rounded-md bg-muted" />
                )}
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-foreground">
                    {localized(item.name)}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {item.kind === 'addon'
                      ? t('addOns')
                      : `${(item as { duration?: number }).duration ?? '—'} ${t('min')}`}
                  </p>
                </div>
                <span className="text-sm font-medium tabular-nums text-foreground">
                  {sar(item.price)}
                </span>
              </li>
            ))}
            {!data.washingServices?.length && !data.addOns?.length && (
              <li className="px-3 py-6 text-center text-[13px] text-muted-foreground">—</li>
            )}
          </ul>
        </SectionCard>

        {data.subscription && (
          <SectionCard title={t('carPictures')}>
            <Photos data={data} t={t} />
          </SectionCard>
        )}
      </div>

      <FormSheet
        open={openSheet}
        onOpenChange={() => setOpenSheet(false)}
        size="lg"
        title={t('AllBikeAvailable')}
        description={t('selectBikerToAssign')}>
        {data && (
          <AssignedBikerTable
            areaId={data?.location?.area?._id}
            orderId={orderId}
            setOpenSheet={setOpenSheet}
          />
        )}
      </FormSheet>
    </div>
  );
}

/** Before / after wash photos, or a hint while the wash hasn't happened yet. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function Photos({ data, t }: { data: any; t: (k: string) => string }) {
  const pics = [
    { label: t('beforeWash'), src: data.carBeforeWashLink },
    { label: t('afterWash'), src: data.carAfterWashLink },
  ];
  if (!pics.some((p) => p.src)) {
    return <p className="text-[13px] text-muted-foreground">{t('noPhotosYet')}</p>;
  }
  return (
    <div className="grid grid-cols-2 gap-3">
      {pics.map((p) => (
        <figure key={p.label} className="space-y-1.5">
          {p.src ? (
            <ImageModal
              src={p.src}
              alt={p.label}
              className="aspect-square w-full rounded-md"
              fallbackText=""
            />
          ) : (
            <div className="flex aspect-square w-full items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">
              —
            </div>
          )}
          <figcaption className="text-xs text-muted-foreground">{p.label}</figcaption>
        </figure>
      ))}
    </div>
  );
}
