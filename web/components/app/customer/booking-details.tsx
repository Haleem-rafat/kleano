'use client';

import { useQueryClient } from '@tanstack/react-query';
import { ArrowLeft, Bike, Car, Clock, Coins, Loader2, MapPin, Phone, Receipt, Sparkles, Star, StickyNote, Tag, Wallet, X } from 'lucide-react';
import dynamic from 'next/dynamic';
import Link from 'next/link';
import { useState, type ReactNode } from 'react';
import { toast } from 'sonner';
import { Failed, Money, StatusBadge, formatWhen } from '@/components/app/bits';
import { Confirm, Sheet } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError } from '@/lib/kleano/client';
import { useApplyPoints, useApplyPromo, useCancelOrder, useOrder, usePayOrder, usePoints, useProfile, useRateOrder } from '@/lib/kleano/queries';
import { cityName, localized, type Order, type OrderStatus } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

// Socket.IO and the map only load for a wash that is under way.
const LiveTracking = dynamic(() => import('@/components/app/customer/live-tracking').then((m) => m.LiveTracking), {
  ssr: false,
  loading: () => <Skeleton className="h-28 rounded-[var(--radius-card)]" />,
});

/** Statuses with a biker on the job (getStepData in the app's check_step_data.dart). */
const LIVE: OrderStatus[] = ['ACCEPTED_BY_BIKER', 'BIKER_ON_THE_WAY', 'BIKER_ARRIVED', 'ON_WASHING'];

/**
 * Who can cancel: the app's wash_details.dart (ACTIVE and waiting for a biker). An unpaid booking
 * too, since the backend allows it and the web has no other way out of one.
 */
const CANCELLABLE: OrderStatus[] = ['ACTIVE', 'WAITING_FOR_BIKER_BY_ADMIN', 'PENDING_USER_PAYMENT'];

function Section({ title, icon, children, className }: { title: string; icon: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={cn('rounded-[var(--radius-card)] border bg-card p-5', className)}>
      <h2 className="mb-3 flex items-center gap-2 text-sm font-semibold text-muted-foreground [&_svg]:size-4.5 [&_svg]:text-primary">
        {icon}
        {title}
      </h2>
      {children}
    </section>
  );
}

function DetailsSkeleton({ label }: { label: string }) {
  return (
    <div role="status" aria-label={label} className="grid gap-4">
      <Skeleton className="h-36 rounded-[var(--radius-card)]" />
      <div className="grid gap-4 md:grid-cols-2">
        {[0, 1, 2, 3].map((i) => (
          <Skeleton key={i} className="h-28 rounded-[var(--radius-card)]" />
        ))}
      </div>
      <Skeleton className="h-48 rounded-[var(--radius-card)]" />
    </div>
  );
}

function Stars({ value, label }: { value: number; label: string }) {
  return (
    <span role="img" aria-label={`${value} ${label}`} className="inline-flex gap-0.5 text-primary">
      {[1, 2, 3, 4, 5].map((n) => (
        <Star key={n} className={cn('size-5', n <= value ? 'fill-current' : 'opacity-30')} aria-hidden="true" />
      ))}
    </span>
  );
}

function RateSheet({ id, t, onClose }: { id: string; t: AppDictionary; onClose: () => void }) {
  const rate = useRateOrder(id);
  const [stars, setStars] = useState(5);
  return (
    <Sheet
      open
      onOpenChange={(open) => !open && onClose()}
      title={t.order.rate}
      closeLabel={t.terms.close}
      footer={
        <Button
          size="xl"
          className="w-full"
          disabled={rate.isPending}
          onClick={() =>
            rate.mutate(stars, {
              onSuccess: () => {
                toast.success(t.order.rated);
                onClose();
              },
              onError: (e) => toast.error(e instanceof ApiError ? e.message : t.common.error),
            })
          }
        >
          {rate.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {t.order.rateSend}
        </Button>
      }
    >
      <div className="grid justify-items-center gap-4 py-4">
        <p className="font-medium">{t.order.rateTitle}</p>
        <div role="radiogroup" aria-label={t.order.yourRating} className="flex gap-1" dir="ltr">
          {[1, 2, 3, 4, 5].map((n) => (
            <button key={n} type="button" role="radio" aria-checked={stars === n} aria-label={`${n} ${t.order.stars}`} onClick={() => setStars(n)} className="grid size-12 place-items-center rounded-full text-primary transition hover:bg-muted">
              <Star className={cn('size-8', n <= stars ? 'fill-current' : 'opacity-30')} aria-hidden="true" />
            </button>
          ))}
        </div>
      </div>
    </Sheet>
  );
}

/** For a booking not paid yet: promo or points, then the wallet. The two discounts exclude each other here (applyUserPoints in the backend). */
function PayCard({ order, t, locale }: { order: Order; t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  const points = usePoints();
  const applyPromo = useApplyPromo(order._id);
  const applyPoints = useApplyPoints(order._id);
  const pay = usePayOrder(order._id);
  const [code, setCode] = useState('');
  const balance = profile.data?.walletBalance ?? 0;
  const due = order.totalPay ?? order.totalPrice ?? 0;
  const wallet = order.paymentType === 'WALLET' || due === 0;
  const discounted = Boolean(order.promoCode) || Boolean(order.isPointsApplied);
  const onError = (e: Error) => toast.error(e instanceof ApiError ? e.message : t.common.error);
  const canRedeem = points.data && points.data.points >= points.data.redeemLimit;

  return (
    <Section title={t.order.payNow} icon={<Wallet />}>
      <div className="grid gap-4">
        {!discounted ? (
          <>
            <form
              className="flex gap-2"
              onSubmit={(e) => {
                e.preventDefault();
                if (code.trim()) applyPromo.mutate(code.trim(), { onSuccess: () => toast.success(t.order.promoDone), onError });
              }}
            >
              <div className="min-w-0 flex-1">
                <Input value={code} onChange={(e) => setCode(e.target.value)} placeholder={t.order.promo} aria-label={t.order.promo} dir="ltr" />
              </div>
              <Button type="submit" variant="secondary" className="h-12 px-5" disabled={applyPromo.isPending || !code.trim()}>
                {applyPromo.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : <Tag />}
                {t.order.promoApply}
              </Button>
            </form>
            {points.isPending ? (
              <Skeleton className="h-12 rounded-full" />
            ) : points.data ? (
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl bg-muted p-4">
                <p className="text-sm">
                  {canRedeem ? (
                    <>
                      {t.order.pointsWorth} <Money value={points.data.pointsExchange} t={t} className="font-semibold" />
                    </>
                  ) : (
                    t.order.pointsBelow
                  )}
                  <span className="block text-muted-foreground">
                    {t.review.available}: <span className="tabular-nums">{points.data.points}</span>
                  </span>
                </p>
                <Button variant="secondary" size="chip" disabled={!canRedeem || applyPoints.isPending} onClick={() => applyPoints.mutate(undefined, { onSuccess: () => toast.success(t.order.pointsDone), onError })}>
                  {applyPoints.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : <Coins />}
                  {t.order.usePoints}
                </Button>
              </div>
            ) : null}
          </>
        ) : (
          <p className="text-sm text-muted-foreground">{t.order.promoOrPoints}</p>
        )}

        {wallet ? (
          <>
            <p className={cn('text-sm', balance < due ? 'text-destructive' : 'text-muted-foreground')}>
              {t.book.balance}: <Money value={balance} t={t} />
            </p>
            {balance < due ? (
              <Button asChild size="xl" className="w-full">
                <Link href={`/${locale}/app/wallet`}>{t.plans.goToWallet}</Link>
              </Button>
            ) : (
              <Button size="xl" className="w-full" disabled={pay.isPending} onClick={() => pay.mutate(undefined, { onSuccess: () => toast.success(t.order.paid), onError })}>
                {pay.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
                {t.order.payWallet} · <Money value={due} t={t} />
              </Button>
            )}
          </>
        ) : (
          <p className="text-sm text-muted-foreground">{t.order.otherPayment}</p>
        )}
      </div>
    </Section>
  );
}

export function BookingDetails({ id, t, locale, embedded }: { id: string; t: AppDictionary; locale: Locale; embedded?: boolean }) {
  const qc = useQueryClient();
  const order = useOrder(id);
  const cancel = useCancelOrder(id);
  const [confirming, setConfirming] = useState(false);
  const [rating, setRating] = useState(false);
  const back = embedded ? null : (
    <Link href={`/${locale}/app/bookings`} className="mb-4 inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground">
      <ArrowLeft className="size-4 rtl:-scale-x-100" aria-hidden="true" />
      {t.bookings.back}
    </Link>
  );

  if (order.isPending) return <>{back}<DetailsSkeleton label={t.common.loading} /></>;
  if (order.isError) return <>{back}<Failed message={order.error.message} onRetry={() => order.refetch()} t={t} /></>;
  const o = order.data;
  const live = LIVE.includes(o.status);
  const canCancel = CANCELLABLE.includes(o.status);

  return (
    <div className="grid gap-4">
      {back}
      <section className="grid gap-5 rounded-[var(--radius-card)] border bg-card p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="min-w-0">
            <p className="text-sm text-muted-foreground">{t.bookings.details}</p>
            <h1 className="text-2xl font-bold md:text-3xl">{localized(o.washingServices?.[0]?.name, locale) || t.bookings.details}</h1>
            <p className="mt-1 truncate text-xs text-muted-foreground">
              {t.order.requestId}: <span dir="ltr">{o._id}</span>
            </p>
          </div>
          <StatusBadge status={o.status} t={t} />
        </div>
        {o.cancellationReason ? <p className="text-sm text-muted-foreground">{o.cancellationReason}</p> : null}
        {canCancel ? (
          <Button variant="destructive" size="chip" className="w-fit" onClick={() => setConfirming(true)}>
            <X />
            {t.order.cancel}
          </Button>
        ) : null}
      </section>

      {live ? <LiveTracking order={o} t={t} locale={locale} /> : null}

      {o.status === 'PENDING_USER_PAYMENT' ? <PayCard order={o} t={t} locale={locale} /> : null}

      {o.status === 'COMPLETED' ? (
        o.ratingOfBiker ? (
          <Section title={t.order.yourRating} icon={<Star />}>
            <Stars value={o.ratingOfBiker} label={t.order.stars} />
          </Section>
        ) : (
          <Button size="xl" className="w-full" onClick={() => setRating(true)}>
            <Star />
            {t.order.rate}
          </Button>
        )
      ) : null}

      <div className="grid gap-4 md:grid-cols-2">
        <Section title={t.bookings.time} icon={<Clock />}>
          <p className="font-medium">{formatWhen(o.startTime, locale)}</p>
          {o.totalDuration ? (
            <p className="text-sm text-muted-foreground">
              {o.totalDuration} {t.common.min}
            </p>
          ) : null}
        </Section>

        <Section title={t.bookings.car} icon={<Car />}>
          <p className="font-medium">{[o.vehicle?.brand, o.vehicle?.model].filter(Boolean).join(' ') || '—'}</p>
          <p className="text-sm text-muted-foreground">
            {[o.vehicle?.color && (t.cars.colors[o.vehicle.color as keyof AppDictionary['cars']['colors']] ?? o.vehicle.color), o.vehicle?.plateNumber && `${t.cars.plate} ${o.vehicle.plateNumber}`].filter(Boolean).join(' · ')}
          </p>
        </Section>

        <Section title={t.bookings.place} icon={<MapPin />}>
          <p className="font-medium">{o.location?.savedName || o.location?.streetName || '—'}</p>
          <p className="text-sm text-muted-foreground">{[o.location?.subAdministrativeArea, cityName(o.location?.city, locale)].filter(Boolean).join(' · ')}</p>
        </Section>

        {o.biker && !live ? (
          <Section title={t.bookings.biker} icon={<Bike />}>
            <p className="font-medium">{o.biker.userName}</p>
            {o.biker.phone ? (
              <a href={`tel:${o.biker.phone}`} dir="ltr" className="inline-flex items-center gap-1.5 text-sm text-primary">
                <Phone className="size-4" aria-hidden="true" />
                {o.biker.phone}
              </a>
            ) : null}
          </Section>
        ) : null}

        {o.description ? (
          <Section title={t.order.notes} icon={<StickyNote />}>
            <p className="text-sm whitespace-pre-line">{o.description}</p>
          </Section>
        ) : null}
      </div>

      <Section title={t.bookings.services} icon={<Sparkles />}>
        <ul className="grid gap-2">
          {o.washingServices?.map((s) => (
            <li key={s._id} className="flex justify-between gap-3">
              <span>{localized(s.name, locale)}</span>
              <Money value={s.price} t={t} />
            </li>
          ))}
        </ul>
        <p className="mt-4 mb-2 text-sm font-semibold text-muted-foreground">{t.bookings.addOns}</p>
        {o.addOns?.length ? (
          <ul className="grid gap-2">
            {o.addOns.map((a) => (
              <li key={a._id} className="flex justify-between gap-3">
                <span>{localized(a.name, locale)}</span>
                <Money value={a.price} t={t} />
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-muted-foreground">{t.bookings.noAddOns}</p>
        )}
        {o.isCarFreshened ? (
          <p className="mt-3 flex items-center justify-between gap-3 text-sm">
            {t.order.freshener}
            <span className="rounded-full bg-secondary px-3 py-1 text-xs font-semibold text-secondary-foreground">{t.order.applied}</span>
          </p>
        ) : null}
      </Section>

      <Section title={t.order.payment} icon={<Receipt />}>
        <dl className="grid gap-2">
          <div className="flex justify-between gap-3 text-sm">
            <dt className="text-muted-foreground">{t.order.total}</dt>
            <dd><Money value={o.totalPrice} t={t} /></dd>
          </div>
          {o.discount ? (
            <div className="flex justify-between gap-3 text-sm text-success">
              <dt>{t.order.discount}</dt>
              <dd><Money value={-o.discount} t={t} /></dd>
            </div>
          ) : null}
          {o.pointsDiscount ? (
            <div className="flex justify-between gap-3 text-sm text-success">
              <dt>{t.order.pointsDiscount}</dt>
              <dd><Money value={-o.pointsDiscount} t={t} /></dd>
            </div>
          ) : null}
          <div className="mt-1 flex justify-between gap-3 border-t pt-3 text-lg font-bold">
            <dt>{t.order.totalPay}</dt>
            <dd><Money value={o.totalPay ?? o.totalPrice} t={t} /></dd>
          </div>
        </dl>
      </Section>

      {o.carBeforeWashLink || o.carAfterWashLink ? (
        <Section title={t.bookings.photos} icon={<Sparkles />}>
          <div className="grid grid-cols-2 gap-3">
            {[
              { src: o.carBeforeWashLink, label: t.bookings.before },
              { src: o.carAfterWashLink, label: t.bookings.after },
            ].map((p) =>
              p.src ? (
                <figure key={p.label} className="grid gap-2">
                  {/* eslint-disable-next-line @next/next/no-img-element -- photos come from the backend's storage */}
                  <img src={p.src} alt={p.label} loading="lazy" width={300} height={400} className="aspect-[3/4] w-full rounded-xl object-cover" />
                  <figcaption className="text-center text-sm text-muted-foreground">{p.label}</figcaption>
                </figure>
              ) : null,
            )}
          </div>
        </Section>
      ) : null}

      <Confirm
        open={confirming}
        onOpenChange={setConfirming}
        title={t.order.cancelTitle}
        description={t.order.cancelBody}
        confirmLabel={t.order.cancel}
        cancelLabel={t.order.keep}
        destructive
        busy={cancel.isPending}
        onConfirm={() =>
          cancel.mutate(undefined, {
            onSuccess: () => {
              toast.success(t.order.cancelled);
              setConfirming(false);
              void qc.invalidateQueries({ queryKey: ['subscription'] });
            },
            // The backend's own reason, such as its 4-hour rule for paid bookings.
            onError: (e) => {
              toast.error(e instanceof ApiError ? e.message : t.common.error);
              setConfirming(false);
            },
          })
        }
      />
      {rating ? <RateSheet id={id} t={t} onClose={() => setRating(false)} /> : null}
    </div>
  );
}
