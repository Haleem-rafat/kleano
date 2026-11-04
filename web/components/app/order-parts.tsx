'use client';

import { Bike, Check, Clock, Droplets, ImageOff, Maximize2, Sparkles, type LucideIcon } from 'lucide-react';
import { useState, type CSSProperties, type ReactNode } from 'react';
import { formatWhen } from '@/components/app/bits';
import { ImageViewer, ZoomImage } from '@/components/app/image-viewer';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Icon, Order, OrderStatus, Vehicle } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

/** The real pictures and progress of an order, shared by the customer and biker web apps. */

const STAGE_ICONS: LucideIcon[] = [Clock, Bike, Check, Droplets, Sparkles];
const STAGE_OF: Partial<Record<OrderStatus, number>> = {
  ACTIVE: 0,
  SCHEDULED: 0,
  PENDING_USER_REVIEW: 0,
  WAITING_FOR_BIKER_BY_ADMIN: 0,
  ACCEPTED_BY_BIKER: 0,
  BIKER_ON_THE_WAY: 1,
  BIKER_ARRIVED: 2,
  ON_WASHING: 3,
  COMPLETED: 4,
};
const PERCENT = [10, 35, 60, 80, 100];

/** How far along an order is, or null when it has no progress to show (unpaid or cancelled). */
export function orderPercent(status: OrderStatus): number | null {
  const stage = STAGE_OF[status];
  return stage === undefined ? null : PERCENT[stage];
}

export function ProgressBar({ percent, className, label }: { percent: number; className?: string; label?: string }) {
  return (
    <div role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={percent} aria-label={label} className={cn('h-2 overflow-hidden rounded-full bg-muted', className)}>
      <div className="h-full rounded-full bg-gradient-to-r from-primary/70 to-primary transition-[width] duration-700 motion-reduce:transition-none rtl:bg-gradient-to-l" style={{ width: `${percent}%` }} />
    </div>
  );
}

/** Progress bar, percentage and stages. `compact` is the one-line version for lists. */
export function OrderProgress({ status, t, compact, className }: { status: OrderStatus; t: AppDictionary; compact?: boolean; className?: string }) {
  const stage = STAGE_OF[status];
  if (stage === undefined) return null;
  const percent = PERCENT[stage];
  const label = t.progress.stages[stage];
  if (compact) {
    return (
      <div className={cn('flex items-center gap-2', className)}>
        <ProgressBar percent={percent} label={label} className="h-1.5 flex-1" />
        <span className="shrink-0 text-xs font-medium text-muted-foreground tabular-nums">{percent}%</span>
      </div>
    );
  }
  return (
    <div className={cn('grid gap-3', className)}>
      <div className="flex items-baseline justify-between gap-3">
        <span className="font-semibold">{label}</span>
        <span className="text-sm font-semibold text-primary tabular-nums">{percent}%</span>
      </div>
      <ProgressBar percent={percent} label={label} />
      <ol className="grid grid-cols-5 gap-1">
        {t.progress.stages.map((name, i) => {
          const StageIcon = STAGE_ICONS[i];
          return (
            <li key={name} aria-current={i === stage ? 'step' : undefined} className="grid justify-items-center gap-1 text-center">
              <span className={cn('grid size-8 place-items-center rounded-full transition-colors', i <= stage ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground', i === stage && i < 4 && 'ring-4 ring-primary/20')}>
                <StageIcon className="size-4" aria-hidden="true" />
              </span>
              <span className={cn('text-[11px] leading-tight md:text-xs', i === stage ? 'font-semibold text-foreground' : 'text-muted-foreground')}>{name}</span>
            </li>
          );
        })}
      </ol>
    </div>
  );
}

const CAR_ART: Record<string, string> = { sedan: 'sedan', hatchback: 'hatchback', suv: 'SUV', van: 'van' };

/** The customer's photo of the car, or the app's drawing of its type. */
export function CarThumb({ vehicle, className, t }: { vehicle?: Vehicle; className?: string; /** Pass it where the photo may open big (not inside a link). */ t?: AppDictionary }) {
  if (vehicle?.imageLink && t) {
    return <ZoomImage src={vehicle.imageLink} alt={[vehicle.brand, vehicle.model].filter(Boolean).join(' ')} t={t} className={cn('size-14 shrink-0 rounded-xl object-cover', className)} />;
  }
  if (vehicle?.imageLink) {
    return (
      // eslint-disable-next-line @next/next/no-img-element -- car photos come from the backend's storage
      <img src={vehicle.imageLink} alt="" loading="lazy" className={cn('size-14 shrink-0 rounded-xl object-cover', className)} />
    );
  }
  const art = CAR_ART[(vehicle?.type ?? '').toLowerCase()] ?? (vehicle?.type ? 'sportCar' : 'sedan');
  const mask: CSSProperties = { maskImage: `url(/images/cars/${art}.svg)`, WebkitMaskImage: `url(/images/cars/${art}.svg)`, maskRepeat: 'no-repeat', WebkitMaskRepeat: 'no-repeat', maskPosition: 'center', WebkitMaskPosition: 'center', maskSize: 'contain', WebkitMaskSize: 'contain' };
  return (
    <span aria-hidden="true" className={cn('grid size-14 shrink-0 place-items-center rounded-xl bg-secondary p-2', className)}>
      <span className="size-full bg-primary" style={mask} />
    </span>
  );
}

/** A person's photo, or their initials. */
export function PersonThumb({ src, name, fallback, className, t }: { src?: string; name?: string; fallback?: ReactNode; className?: string; t?: AppDictionary }) {
  if (src && t) return <ZoomImage src={src} alt={name ?? ''} t={t} className={cn('size-11 shrink-0 rounded-full object-cover', className)} />;
  if (src) {
    return (
      // eslint-disable-next-line @next/next/no-img-element -- photos come from the backend's storage
      <img src={src} alt="" loading="lazy" className={cn('size-11 shrink-0 rounded-full object-cover', className)} />
    );
  }
  const initials = (name ?? '').split(' ').filter(Boolean).slice(0, 2).map((w) => w[0]).join('').toUpperCase();
  return <span className={cn('grid size-11 shrink-0 place-items-center rounded-full bg-primary text-sm font-semibold text-primary-foreground', className)}>{initials || fallback}</span>;
}

/** A service or add-on's icon from the backend. */
export function ServiceThumb({ icon, className }: { icon?: Icon; className?: string }) {
  return icon?.iconLink ? (
    // eslint-disable-next-line @next/next/no-img-element -- icons come from the backend's storage
    <img src={icon.iconLink} alt="" loading="lazy" className={cn('size-9 shrink-0 rounded-lg bg-secondary object-contain p-1.5', className)} />
  ) : (
    <span className={cn('grid size-9 shrink-0 place-items-center rounded-lg bg-secondary text-primary', className)}>
      <Sparkles className="size-4" aria-hidden="true" />
    </span>
  );
}

/** Before and after the wash: drag across to compare when both exist. Any photo opens full size. */
export function WashPhotos({ before, after, beforeLabel, afterLabel, t }: { before?: string; after?: string; beforeLabel: string; afterLabel: string; t: AppDictionary }) {
  const [split, setSplit] = useState(50);
  const [viewing, setViewing] = useState<number | null>(null);
  const images = [before ? { src: before, alt: beforeLabel } : null, after ? { src: after, alt: afterLabel } : null].filter((i): i is { src: string; alt: string } => Boolean(i));
  const chip = 'pointer-events-none absolute top-2 rounded-full bg-black/60 px-2.5 py-1 text-xs font-medium text-white';
  const viewer = viewing !== null ? <ImageViewer images={images} start={viewing} t={t} onClose={() => setViewing(null)} /> : null;
  if (images.length === 0) {
    return (
      <p className="flex items-center gap-2 rounded-xl bg-muted/60 p-4 text-sm text-muted-foreground">
        <ImageOff className="size-4 shrink-0" aria-hidden="true" />
        {t.progress.noPhotos}
      </p>
    );
  }
  if (images.length === 1) {
    return (
      <figure className="relative overflow-hidden rounded-xl">
        <button type="button" aria-label={`${t.progress.viewPhoto}: ${images[0].alt}`} onClick={() => setViewing(0)} className="block w-full cursor-zoom-in">
          {/* eslint-disable-next-line @next/next/no-img-element -- wash photos come from the backend's storage */}
          <img src={images[0].src} alt={images[0].alt} loading="lazy" className="aspect-[4/3] w-full object-cover" />
        </button>
        <figcaption className={cn(chip, 'start-2')}>{images[0].alt}</figcaption>
        {viewer}
      </figure>
    );
  }
  return (
    // Left to right in both languages: it is a picture, and the handle must follow the finger.
    <div dir="ltr" className="relative aspect-[4/3] select-none overflow-hidden rounded-xl bg-muted">
      {/* eslint-disable-next-line @next/next/no-img-element -- wash photos come from the backend's storage */}
      <img src={after} alt={afterLabel} loading="lazy" className="absolute inset-0 size-full object-cover" />
      {/* eslint-disable-next-line @next/next/no-img-element -- wash photos come from the backend's storage */}
      <img src={before} alt={beforeLabel} loading="lazy" className="absolute inset-0 size-full object-cover" style={{ clipPath: `inset(0 ${100 - split}% 0 0)` }} />
      <span className={cn(chip, 'left-2')}>{beforeLabel}</span>
      <span className={cn(chip, 'right-2')}>{afterLabel}</span>
      <span aria-hidden="true" className="pointer-events-none absolute inset-y-0 w-0.5 -translate-x-1/2 bg-white shadow" style={{ left: `${split}%` }}>
        <span className="absolute top-1/2 left-1/2 size-8 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white bg-black/50" />
      </span>
      <input type="range" min={0} max={100} value={split} aria-label={t.progress.compare} onChange={(e) => setSplit(Number(e.target.value))} className="absolute inset-0 size-full cursor-ew-resize opacity-0" />
      <button type="button" aria-label={t.progress.viewBig} onClick={() => setViewing(0)} className="absolute right-2 bottom-2 grid size-10 place-items-center rounded-full bg-black/60 text-white transition hover:bg-black/80">
        <Maximize2 className="size-4.5" aria-hidden="true" />
      </button>
      {viewer}
    </div>
  );
}

/** When each step really happened, from the times the backend saves. */
export function OrderTimeline({ order, t, locale }: { order: Order; t: AppDictionary; locale: string }) {
  const rows = [
    { label: t.progress.booked, at: order.createdAt },
    { label: t.progress.onTheWay, at: order.OnTheWayAt },
    { label: t.progress.washStarted, at: order.onWashingAt },
    { label: t.progress.finished, at: order.status === 'COMPLETED' ? order.endTime : undefined },
  ].filter((r) => r.at);
  return (
    <ol className="grid gap-3">
      {rows.map((row, i) => (
        <li key={row.label} className="relative flex items-start justify-between gap-3 ps-5 text-sm">
          <span aria-hidden="true" className="absolute start-0 top-1.5 size-2.5 rounded-full bg-primary" />
          {i < rows.length - 1 ? <span aria-hidden="true" className="absolute start-[4.5px] top-4 -bottom-3 w-px bg-border" /> : null}
          <span className="font-medium">{row.label}</span>
          <span className="text-end text-muted-foreground">{formatWhen(row.at, locale)}</span>
        </li>
      ))}
    </ol>
  );
}
