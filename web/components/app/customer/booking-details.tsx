'use client';

import { ArrowLeft, Bike, Car, Check, Clock, Droplets, MapPin, Phone, Sparkles } from 'lucide-react';
import Link from 'next/link';
import type { ReactNode } from 'react';
import { Failed, Loading, Money, StatusBadge, formatWhen } from '@/components/app/bits';
import { GlowingEffect } from '@/components/ui/glowing-effect';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useOrder } from '@/lib/kleano/queries';
import { cityName, localized, type OrderStatus } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

/** The wash stages in order, as the app's tracking screen shows them. */
const stages: { status: OrderStatus[]; icon: typeof Check }[] = [
  { status: ['ACTIVE', 'WAITING_FOR_BIKER_BY_ADMIN', 'SCHEDULED'], icon: Check },
  { status: ['ACCEPTED_BY_BIKER', 'BIKER_ON_THE_WAY'], icon: Bike },
  { status: ['BIKER_ARRIVED', 'ON_WASHING'], icon: Droplets },
  { status: ['COMPLETED'], icon: Sparkles },
];
const stageLabel: OrderStatus[] = ['ACTIVE', 'BIKER_ON_THE_WAY', 'ON_WASHING', 'COMPLETED'];

function Section({ title, icon, children }: { title: string; icon: ReactNode; children: ReactNode }) {
  return (
    <section className="rounded-2xl border border-border bg-card p-5">
      <h2 className="mb-3 flex items-center gap-2 text-sm font-semibold text-muted-foreground [&_svg]:size-4.5 [&_svg]:text-primary">
        {icon}
        {title}
      </h2>
      {children}
    </section>
  );
}

export function BookingDetails({ id, t, locale }: { id: string; t: AppDictionary; locale: Locale }) {
  const order = useOrder(id);
  const back = (
    <Link href={`/${locale}/app/bookings`} className="mb-4 inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground">
      <ArrowLeft className="size-4 rtl:-scale-x-100" aria-hidden="true" />
      {t.bookings.back}
    </Link>
  );

  if (order.isPending) return <>{back}<Loading label={t.common.loading} /></>;
  if (order.isError) return <>{back}<Failed message={order.error.message} onRetry={() => order.refetch()} t={t} /></>;
  const o = order.data;
  const cancelled = o.status.startsWith('CANCELLED') || o.status === 'PAYMENT_FAILED';
  const current = stages.findIndex((s) => s.status.includes(o.status));

  return (
    <div className="grid gap-4">
      {back}
      <div className="relative rounded-3xl border border-border p-1.5">
        <GlowingEffect spread={40} glow={false} disabled={false} proximity={64} inactiveZone={0.01} borderWidth={2} />
        <div className="relative grid gap-5 rounded-[20px] bg-card p-6">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-sm text-muted-foreground">{t.bookings.details}</p>
              <h1 className="text-2xl font-bold md:text-3xl">{localized(o.washingServices?.[0]?.name, locale)}</h1>
            </div>
            <StatusBadge status={o.status} t={t} />
          </div>

          {!cancelled ? (
            <ol className="grid grid-cols-4 gap-2">
              {stages.map((s, i) => {
                const done = current >= i;
                return (
                  <li key={i} className="grid justify-items-center gap-2 text-center">
                    <span className={cn('grid size-10 place-items-center rounded-full transition', done ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground')}>
                      <s.icon className="size-5" aria-hidden="true" />
                    </span>
                    <span className={cn('text-xs', i === current ? 'font-semibold text-foreground' : 'text-muted-foreground')}>{t.status[stageLabel[i]]}</span>
                  </li>
                );
              })}
            </ol>
          ) : o.cancellationReason ? (
            <p className="text-sm text-muted-foreground">{o.cancellationReason}</p>
          ) : null}
        </div>
      </div>

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
            {[o.vehicle?.color, o.vehicle?.plateNumber && `${t.cars.plate} ${o.vehicle.plateNumber}`].filter(Boolean).join(' · ')}
          </p>
        </Section>

        <Section title={t.bookings.place} icon={<MapPin />}>
          <p className="font-medium">{o.location?.savedName || o.location?.streetName || '—'}</p>
          <p className="text-sm text-muted-foreground">{[o.location?.subAdministrativeArea, cityName(o.location?.city, locale)].filter(Boolean).join(' · ')}</p>
        </Section>

        {o.biker ? (
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
        <div className="mt-4 grid gap-1 border-t border-border pt-4">
          {o.discount ? (
            <p className="flex justify-between text-sm text-muted-foreground">
              <span>{t.bookings.discount}</span>
              <Money value={-o.discount} t={t} />
            </p>
          ) : null}
          <p className="flex justify-between text-lg font-bold">
            <span>{t.bookings.total}</span>
            <Money value={o.totalPay ?? o.totalPrice} t={t} />
          </p>
        </div>
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
                  <img src={p.src} alt={p.label} className="aspect-[3/4] w-full rounded-xl object-cover" />
                  <figcaption className="text-center text-sm text-muted-foreground">{p.label}</figcaption>
                </figure>
              ) : null,
            )}
          </div>
        </Section>
      ) : null}
    </div>
  );
}
