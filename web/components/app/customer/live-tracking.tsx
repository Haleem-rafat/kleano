'use client';

import { SAUDI_TIME } from '@/components/app/bits';
import { Bike, Check, Droplets, ExternalLink, MapPinned, MessageCircle, Phone, Radio, Sparkles, Star, WifiOff, type LucideIcon } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useLiveOrder } from '@/lib/kleano/live';
import type { Order, OrderStatus } from '@/lib/kleano/types';
import { loadMaps, mapsKey, type GoogleMap, type GoogleMarker, type LatLng } from '@/lib/maps';
import { cn } from '@/lib/utils';

/** The stage bar in the app's wash_details.dart and check_step_data.dart: step -1 is before "on the way". */
const STAGES: { status: OrderStatus; icon: LucideIcon; label: keyof AppDictionary['tracking']['stages'] }[] = [
  { status: 'BIKER_ON_THE_WAY', icon: Bike, label: 'onTheWay' },
  { status: 'BIKER_ARRIVED', icon: Check, label: 'arrived' },
  { status: 'ON_WASHING', icon: Droplets, label: 'washing' },
  { status: 'COMPLETED', icon: Sparkles, label: 'completed' },
];

const timeFormat = (locale: Locale) => new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { timeStyle: 'short', timeZone: SAUDI_TIME });

/** Biker and car on one map. Only drawn when a Google Maps key exists. */
function TrackingMap({ biker, car, locale, t }: { biker: LatLng | null; car: LatLng; locale: Locale; t: AppDictionary }) {
  const box = useRef<HTMLDivElement>(null);
  const map = useRef<GoogleMap | null>(null);
  const bikerPin = useRef<GoogleMarker | null>(null);
  const [failed, setFailed] = useState(false);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let alive = true;
    loadMaps(locale)
      .then((maps) => {
        if (!alive || !box.current) return;
        map.current = new maps.Map(box.current, { center: car, zoom: 14, disableDefaultUI: true, zoomControl: true, gestureHandling: 'cooperative' });
        new maps.Marker({ map: map.current, position: car });
        setReady(true);
      })
      .catch(() => setFailed(true));
    return () => {
      alive = false;
    };
  }, [car, locale]);

  useEffect(() => {
    if (!ready || !biker || !map.current || !window.google) return;
    if (bikerPin.current) bikerPin.current.setPosition(biker);
    else bikerPin.current = new window.google.maps.Marker({ map: map.current, position: biker, label: { text: '🛵' } });
    map.current.panTo(biker);
  }, [biker, ready]);

  if (failed) return <p className="p-4 text-sm text-muted-foreground">{t.places.mapFailed}</p>;
  return <div ref={box} className="h-64 w-full bg-muted md:h-80" />;
}

export function LiveTracking({ order, t, locale }: { order: Order; t: AppDictionary; locale: Locale }) {
  const { connected, biker, times } = useLiveOrder(order._id, true);
  const current = STAGES.findIndex((s) => s.status === order.status);
  const car: LatLng | null = order.location ? { lat: order.location.latitude, lng: order.location.longitude } : null;
  const start = order.biker?.latitude !== undefined && order.biker?.longitude !== undefined ? { lat: order.biker.latitude, lng: order.biker.longitude } : null;
  const onTheWay = order.status === 'BIKER_ON_THE_WAY';

  return (
    <section aria-label={t.tracking.title} className="overflow-hidden rounded-[var(--radius-card)] border bg-card">
      <div className="grid gap-5 p-5">
        <div className="flex items-center justify-between gap-3">
          <h2 className="font-semibold">{t.tracking.title}</h2>
          <span role="status" className={cn('inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold', connected ? 'bg-success/15 text-success' : 'bg-muted text-muted-foreground')}>
            {connected ? <Radio className="size-3.5" aria-hidden="true" /> : <WifiOff className="size-3.5" aria-hidden="true" />}
            {connected ? t.tracking.live : t.tracking.reconnecting}
          </span>
        </div>

        <ol className="grid grid-cols-4 gap-2">
          {STAGES.map((s, i) => {
            const done = current >= i;
            const time = times[s.status];
            return (
              <li key={s.status} aria-current={i === current ? 'step' : undefined} className="grid justify-items-center gap-2 text-center">
                <span className={cn('grid size-10 place-items-center rounded-full transition', done ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground')}>
                  <s.icon className="size-5" aria-hidden="true" />
                </span>
                <span className={cn('text-xs', i === current ? 'font-semibold text-foreground' : 'text-muted-foreground')}>{t.tracking.stages[s.label]}</span>
                {time ? <span className="text-[11px] text-muted-foreground tabular-nums">{timeFormat(locale).format(new Date(time))}</span> : null}
              </li>
            );
          })}
        </ol>

        {order.biker ? (
          <div className="flex flex-wrap items-center gap-3 rounded-2xl bg-muted p-3">
            {order.biker.imageLink ? (
              // eslint-disable-next-line @next/next/no-img-element -- biker photo from the backend's storage
              <img src={order.biker.imageLink} alt="" width={44} height={44} loading="lazy" className="size-11 rounded-full object-cover" />
            ) : (
              <span className="grid size-11 place-items-center rounded-full bg-secondary text-primary">
                <Bike className="size-5" aria-hidden="true" />
              </span>
            )}
            <div className="min-w-0 flex-1 basis-32">
              <p className="truncate font-medium">{order.biker.userName}</p>
              {order.biker.rating ? (
                <p className="inline-flex items-center gap-1 text-sm text-muted-foreground">
                  <Star className="size-3.5 fill-current" aria-hidden="true" />
                  <span className="tabular-nums">{order.biker.rating.toFixed(1)}</span>
                </p>
              ) : null}
            </div>
            {order.biker.phone ? (
              <div className="flex gap-2">
                <Button asChild variant="outline" size="chip">
                  <a href={`tel:${order.biker.phone}`}>
                    <Phone />
                    {t.tracking.call}
                  </a>
                </Button>
                <Button asChild variant="outline" size="chip">
                  <a href={`https://wa.me/${order.biker.phone.replace(/\D/g, '')}`} target="_blank" rel="noreferrer">
                    <MessageCircle />
                    {t.tracking.whatsapp}
                  </a>
                </Button>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      {onTheWay && car ? (
        mapsKey ? (
          <TrackingMap biker={biker ?? start} car={car} locale={locale} t={t} />
        ) : (
          <div className="flex flex-wrap items-center justify-between gap-3 border-t p-5">
            <p className="flex min-w-0 flex-1 basis-48 items-center gap-2 text-sm text-muted-foreground">
              <MapPinned className="size-4.5 shrink-0" aria-hidden="true" />
              {t.tracking.noMap}
            </p>
            {biker ?? start ? (
              <Button asChild variant="outline" size="chip">
                <a href={`https://www.google.com/maps/dir/?api=1&origin=${(biker ?? start)!.lat},${(biker ?? start)!.lng}&destination=${car.lat},${car.lng}`} target="_blank" rel="noreferrer">
                  <ExternalLink />
                  {t.tracking.openMaps}
                </a>
              </Button>
            ) : null}
          </div>
        )
      ) : null}
    </section>
  );
}
