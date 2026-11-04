'use client';

import { ArrowLeft, Camera, Car, CheckCircle2, Clock, ImagePlus, Loader2, MapPin, MessageCircle, Navigation, Phone, Sparkles, Star, StickyNote, User } from 'lucide-react';
import Link from 'next/link';
import { useState, type ReactNode } from 'react';
import { toast } from 'sonner';
import { Failed, Money, StatusBadge, formatSlot, formatWhen } from '@/components/app/bits';
import { CarThumb, orderPercent, OrderProgress, PersonThumb, ServiceThumb, WashPhotos } from '@/components/app/order-parts';
import { RowsSkeleton, Sheet, StickyActions } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useShareLocation } from '@/lib/kleano/biker-live';
import { ApiError } from '@/lib/kleano/client';
import { bikerApi, currentPosition, useBikerOrder, useJobAction, type BikerOrder } from '@/lib/kleano/domains/biker';
import { cityName, localized, type OrderStatus } from '@/lib/kleano/types';
import { shrinkImage } from '@/lib/image';
import { cn } from '@/lib/utils';

const STEP: Partial<Record<OrderStatus, number>> = { ACCEPTED_BY_BIKER: -1, BIKER_ON_THE_WAY: 0, BIKER_ARRIVED: 1, ON_WASHING: 2, COMPLETED: 3 };
const NEEDS_ACCEPT: OrderStatus[] = ['ACTIVE', 'WAITING_FOR_BIKER_BY_ADMIN'];

function Block({ icon, title, children }: { icon: ReactNode; title: string; children: ReactNode }) {
  return (
    <section className="grid gap-3 rounded-2xl border bg-card p-4">
      <h2 className="flex items-center gap-2 text-sm font-medium text-muted-foreground [&_svg]:size-4 [&_svg]:text-primary">
        {icon}
        {title}
      </h2>
      {children}
    </section>
  );
}

/** The two washing stages ask for a photo first, as the app does. */
function PhotoSheet({ title, label, t, busy, onClose, onSend }: { title: string; label: string; t: AppDictionary; busy: boolean; onClose: () => void; onSend: (photo: Blob) => void }) {
  const [photo, setPhoto] = useState<Blob | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  return (
    <Sheet
      open
      onOpenChange={(open) => !open && onClose()}
      title={title}
      closeLabel={t.terms.close}
      footer={
        <Button size="xl" className="w-full" disabled={!photo || busy} onClick={() => photo && onSend(photo)}>
          {busy ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {label}
        </Button>
      }
    >
      <label className="relative grid aspect-[4/3] cursor-pointer place-items-center overflow-hidden rounded-2xl border border-dashed bg-muted/60 text-muted-foreground transition hover:bg-muted">
        {preview ? (
          // eslint-disable-next-line @next/next/no-img-element -- a local preview of the chosen file
          <img src={preview} alt="" className="absolute inset-0 size-full object-cover" />
        ) : (
          <span className="grid justify-items-center gap-2 text-sm">
            <ImagePlus className="size-8" aria-hidden="true" />
            {t.b.choosePhoto}
          </span>
        )}
        <input
          type="file"
          accept="image/*"
          className="sr-only"
          onChange={async (e) => {
            const file = e.target.files?.[0];
            if (!file) return;
            const small = await shrinkImage(file, 800, 0.8);
            setPhoto(small);
            setPreview(URL.createObjectURL(small));
          }}
        />
      </label>
    </Sheet>
  );
}

function RateClient({ order, t }: { order: BikerOrder; t: AppDictionary }) {
  const [stars, setStars] = useState(5);
  const rate = useJobAction(order._id, (n: number) => bikerApi.rate(order._id, n));
  if (order.ratingOfUser) {
    return (
      <p className="flex items-center gap-1 font-semibold">
        <Star className="size-4 fill-current text-primary" aria-hidden="true" />
        {order.ratingOfUser}
      </p>
    );
  }
  return (
    <div className="flex flex-wrap items-center justify-between gap-3">
      <div role="radiogroup" aria-label={t.b.yourRating} className="flex gap-1">
        {[1, 2, 3, 4, 5].map((n) => (
          <button key={n} type="button" role="radio" aria-checked={stars === n} aria-label={String(n)} onClick={() => setStars(n)} className="grid size-10 place-items-center rounded-full text-primary transition hover:bg-muted">
            <Star className={cn('size-6', n <= stars ? 'fill-current' : 'opacity-30')} aria-hidden="true" />
          </button>
        ))}
      </div>
      <Button size="chip" disabled={rate.isPending} onClick={() => rate.mutate(stars, { onSuccess: () => toast.success(t.b.rated), onError: (e) => toast.error(e instanceof ApiError ? e.message : t.common.error) })}>
        {rate.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
        {t.b.sendRating}
      </Button>
    </div>
  );
}

export function BikerOrderDetails({ id, t, locale }: { id: string; t: AppDictionary; locale: Locale }) {
  const order = useBikerOrder(id);
  const [photoStep, setPhotoStep] = useState<'washing' | 'complete' | null>(null);
  const fail = (e: unknown) => toast.error(e instanceof ApiError ? e.message : t.common.error);

  const accept = useJobAction(id, async () => bikerApi.accept(id, await currentPosition(t.b.currentLocation)));
  const onTheWay = useJobAction(id, () => bikerApi.onTheWay(id));
  const arrived = useJobAction(id, () => bikerApi.arrived(id));
  const washing = useJobAction(id, (photo: Blob) => bikerApi.washing(id, photo));
  const complete = useJobAction(id, (photo: Blob) => bikerApi.complete(id, photo));

  useShareLocation(id, order.data?.status === 'BIKER_ON_THE_WAY');

  if (order.isPending) return <RowsSkeleton label={t.common.loading} />;
  if (order.isError) return <Failed message={order.error.message} onRetry={() => order.refetch()} t={t} />;

  const o = order.data;
  const step = STEP[o.status];
  const needsAccept = NEEDS_ACCEPT.includes(o.status);
  const done = o.status === 'COMPLETED';
  const busy = accept.isPending || onTheWay.isPending || arrived.isPending;
  const place = o.location;
  const map = place?.latitude && place.longitude ? `https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}` : null;
  const phone = o.user?.phone;
  const car = [o.vehicle?.brand, o.vehicle?.model].filter(Boolean).join(' ');

  const onAccept = () =>
    accept.mutate(undefined, {
      onSuccess: () => toast.success(t.b.accepted),
      onError: (e) => toast.error(e instanceof ApiError ? e.message : t.b.needLocation),
    });

  const next = needsAccept
    ? { label: t.b.accept, run: onAccept }
    : step === -1
      ? { label: t.b.goOnTheWay, run: () => onTheWay.mutate(undefined, { onError: fail }) }
      : step === 0
        ? { label: t.b.arriveToClient, run: () => arrived.mutate(undefined, { onError: fail }) }
        : step === 1
          ? { label: t.b.startWashing, run: () => setPhotoStep('washing') }
          : step === 2
            ? { label: t.b.completeWash, run: () => setPhotoStep('complete') }
            : null;

  return (
    <div className="grid gap-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex min-w-0 items-center gap-2">
          <Button asChild variant="outline" size="chip" className="px-3">
            <Link href={`/${locale}/biker/orders`} aria-label={t.b.back}>
              <ArrowLeft className="rtl:-scale-x-100" />
            </Link>
          </Button>
          <h1 className="truncate text-2xl font-bold md:text-3xl">{t.b.washDetails}</h1>
        </div>
        <StatusBadge status={o.status} t={t} label={t.b.status[o.status as keyof AppDictionary['b']['status']]} />
      </div>

      {orderPercent(o.status) !== null ? (
        <section className="rounded-2xl border bg-card p-4">
          <OrderProgress status={o.status} t={t} />
        </section>
      ) : null}

      {done ? (
        <p className="flex items-center gap-2 rounded-2xl bg-success/15 p-4 font-semibold text-success">
          <CheckCircle2 className="size-5" aria-hidden="true" />
          {t.b.washCompleted}
        </p>
      ) : null}

      <div className="grid items-start gap-4 lg:grid-cols-2">
        <div className="grid gap-4">
          <Block icon={<User />} title={t.b.client}>
            <div className="flex flex-wrap items-center justify-between gap-3">
              <div className="flex min-w-0 items-center gap-3">
                <PersonThumb src={o.user?.imageLink} name={o.user?.userName} />
                <p className="min-w-0 truncate font-semibold">{o.user?.userName ?? '—'}</p>
              </div>
              {phone && !done ? (
                <div className="flex gap-2">
                  <Button asChild variant="outline" size="chip">
                    <a href={`tel:${phone}`}>
                      <Phone />
                      {t.b.call}
                    </a>
                  </Button>
                  <Button asChild variant="outline" size="chip">
                    <a href={`https://wa.me/${phone.replace(/\D/g, '')}`} target="_blank" rel="noreferrer">
                      <MessageCircle />
                      {t.b.whatsapp}
                    </a>
                  </Button>
                </div>
              ) : null}
            </div>
          </Block>

          <Block icon={<MapPin />} title={t.b.location}>
            <p>{[place?.savedName, place?.streetName, cityName(place?.city, locale)].filter(Boolean).join(' · ') || '—'}</p>
            {map && !done ? (
              <Button asChild variant="secondary" size="chip" className="w-fit">
                <a href={map} target="_blank" rel="noreferrer">
                  <Navigation />
                  {t.b.directions}
                </a>
              </Button>
            ) : null}
          </Block>

          <Block icon={<Clock />} title={t.b.washingDate}>
            <p>{formatWhen(o.startTime, locale) || formatSlot(o.timeSlot, locale) || '—'}</p>
          </Block>

          <Block icon={<Car />} title={t.b.car}>
            <div className="flex flex-wrap items-center justify-between gap-3">
              <div className="flex min-w-0 items-center gap-3">
                <CarThumb vehicle={o.vehicle} />
                <p className="font-semibold">{[car, o.vehicle?.color].filter(Boolean).join(' · ') || '—'}</p>
              </div>
              {o.vehicle?.plateNumber ? (
                <span className="rounded-md border border-foreground/30 bg-muted/60 px-2.5 py-0.5 font-mono text-sm font-bold tracking-widest" dir="ltr">
                  {o.vehicle.plateNumber}
                </span>
              ) : null}
            </div>
          </Block>
        </div>

        <div className="grid gap-4">
          <Block icon={<Sparkles />} title={t.b.services}>
            <ul className="grid gap-2">
              {(o.washingServices ?? []).map((s) => (
                <li key={s._id} className="flex items-center justify-between gap-3">
                  <span className="flex min-w-0 items-center gap-2.5">
                    <ServiceThumb icon={s.icon} />
                    {localized(s.name, locale)}
                  </span>
                  {s.duration ? (
                    <span className="shrink-0 text-sm text-muted-foreground">
                      {s.duration} {t.common.min}
                    </span>
                  ) : null}
                </li>
              ))}
              {(o.addOns ?? []).map((a) => (
                <li key={a._id} className="flex items-center gap-2.5 text-sm text-muted-foreground">
                  <ServiceThumb icon={a.icon} />
                  {localized(a.name, locale)}
                </li>
              ))}
              {o.isCarFreshened ? <li className="text-sm text-muted-foreground">{t.b.freshener}</li> : null}
            </ul>
            <div className="flex items-center justify-between gap-3 border-t pt-3">
              <span className="text-sm text-muted-foreground">{t.b.total}</span>
              <Money value={o.totalPay ?? o.totalPrice} t={t} className="text-lg font-bold" />
            </div>
          </Block>

          {o.description ? (
            <Block icon={<StickyNote />} title={t.b.notes}>
              <p>{o.description}</p>
            </Block>
          ) : null}

          {o.carBeforeWashLink || o.carAfterWashLink ? (
            <Block icon={<Camera />} title={t.b.photos}>
              <WashPhotos before={o.carBeforeWashLink} after={o.carAfterWashLink} beforeLabel={t.b.beforeWash} afterLabel={t.b.afterWash} compareLabel={t.progress.compare} />
            </Block>
          ) : null}

          {done ? (
            <Block icon={<Star />} title={t.b.yourRating}>
              <RateClient order={o} t={t} />
              {o.ratingOfBiker ? (
                <p className="text-sm text-muted-foreground">
                  {t.b.clientRating}: <span className="font-semibold text-foreground">{o.ratingOfBiker}</span>
                </p>
              ) : null}
            </Block>
          ) : null}
        </div>
      </div>

      {next ? (
        <StickyActions>
          <Button size="xl" className="flex-1" disabled={busy} onClick={next.run}>
            {busy ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {next.label}
          </Button>
        </StickyActions>
      ) : null}

      {photoStep === 'washing' ? (
        <PhotoSheet
          title={t.b.beforeTitle}
          label={t.b.startWashing}
          t={t}
          busy={washing.isPending}
          onClose={() => setPhotoStep(null)}
          onSend={(photo) => washing.mutate(photo, { onSuccess: () => setPhotoStep(null), onError: fail })}
        />
      ) : null}
      {photoStep === 'complete' ? (
        <PhotoSheet
          title={t.b.afterTitle}
          label={t.b.completeWash}
          t={t}
          busy={complete.isPending}
          onClose={() => setPhotoStep(null)}
          onSend={(photo) =>
            complete.mutate(photo, {
              onSuccess: () => {
                setPhotoStep(null);
                toast.success(t.b.washCompleted);
              },
              onError: fail,
            })
          }
        />
      ) : null}
    </div>
  );
}
