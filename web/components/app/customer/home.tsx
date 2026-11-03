'use client';

import { ArrowRight, CalendarClock, Clock, Coins, MapPin, Sparkles, Wallet } from 'lucide-react';
import Link from 'next/link';
import type { ReactNode } from 'react';
import { Empty, Failed, Money, SectionTitle, StatusBadge, formatWhen } from '@/components/app/bits';
import { BentoGrid } from '@/components/ui/bento-grid';
import { HoverEffect } from '@/components/ui/card-hover-effect';
import Carousel from '@/components/ui/carousel';
import { GlowingEffect } from '@/components/ui/glowing-effect';
import { HoverBorderGradient } from '@/components/ui/hover-border-gradient';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { pickLocation, useBanners, useOrders, usePlans, useProfile, useSavedLocations, useServices } from '@/lib/kleano/queries';
import { cityName, localized } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

/** One Bento tile with Aceternity's glowing border that follows the pointer. */
function Tile({ className, children }: { className?: string; children: ReactNode }) {
  return (
    <div className={cn('relative rounded-2xl border border-border p-1.5', className)}>
      <GlowingEffect spread={40} glow={false} disabled={false} proximity={64} inactiveZone={0.01} borderWidth={2} />
      <div className="relative flex h-full flex-col justify-between gap-4 overflow-hidden rounded-xl bg-card p-5">{children}</div>
    </div>
  );
}

export function CustomerHome({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  const saved = useSavedLocations();
  const banners = useBanners();
  const active = useOrders('ACTIVE');
  const location = pickLocation(saved.data, profile.data);
  const services = useServices(location);
  const plans = usePlans(location);
  const next = active.data?.pages[0]?.data?.[0];
  const base = `/${locale}/app`;
  const firstName = profile.data?.userName?.split(' ')[0];

  return (
    <div className="grid gap-2">
      <BentoGrid className="max-w-none md:auto-rows-[11rem] md:grid-cols-4">
        <Tile className="md:col-span-2 md:row-span-2">
          <div className="grid gap-2">
            <span className="inline-flex w-fit items-center gap-1.5 rounded-full bg-secondary px-3 py-1 text-xs font-semibold text-secondary-foreground">
              <Sparkles className="size-3.5" aria-hidden="true" />
              {t.home.tagline}
            </span>
            <h1 className="text-3xl font-bold md:text-5xl">
              {t.home.hello}
              {firstName ? `${locale === 'ar' ? '، ' : ', '}${firstName}` : ''}
            </h1>
          </div>
          <Link href={`${base}/book`} className="w-fit">
            <HoverBorderGradient as="span" containerClassName="rounded-full" className="flex items-center gap-2 px-6 py-3 text-base font-semibold">
              {t.home.bookNow}
              <ArrowRight className="size-5 rtl:-scale-x-100" aria-hidden="true" />
            </HoverBorderGradient>
          </Link>
        </Tile>

        <Tile>
          <span className="grid size-10 place-items-center rounded-full bg-secondary text-primary">
            <Wallet className="size-5" aria-hidden="true" />
          </span>
          <div>
            <p className="text-sm text-muted-foreground">{t.home.wallet}</p>
            {profile.isPending ? <Skeleton className="mt-1 h-8 w-24" /> : <Money value={profile.data?.walletBalance} t={t} className="text-2xl font-bold" />}
          </div>
        </Tile>

        <Tile>
          <span className="grid size-10 place-items-center rounded-full bg-secondary text-primary">
            <Coins className="size-5" aria-hidden="true" />
          </span>
          <div>
            <p className="text-sm text-muted-foreground">{t.home.points}</p>
            {profile.isPending ? <Skeleton className="mt-1 h-8 w-16" /> : <p className="text-2xl font-bold tabular-nums">{profile.data?.points ?? 0}</p>}
          </div>
        </Tile>

        <Tile className="md:col-span-2">
          <div className="flex items-center justify-between gap-3">
            <span className="inline-flex items-center gap-2 text-sm text-muted-foreground">
              <CalendarClock className="size-4.5" aria-hidden="true" />
              {t.home.upcoming}
            </span>
            {next ? <StatusBadge status={next.status} t={t} /> : null}
          </div>
          {active.isPending ? (
            <Skeleton className="h-10 w-full" />
          ) : next ? (
            <Link href={`${base}/bookings/${next._id}`} className="group flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="truncate font-semibold">{localized(next.washingServices?.[0]?.name, locale)}</p>
                <p className="text-sm text-muted-foreground">{formatWhen(next.startTime, locale)}</p>
              </div>
              <ArrowRight className="size-5 shrink-0 text-muted-foreground transition group-hover:text-primary rtl:-scale-x-100" aria-hidden="true" />
            </Link>
          ) : (
            <p className="text-muted-foreground">{t.home.noUpcoming}</p>
          )}
        </Tile>
      </BentoGrid>

      <div className="mt-3 flex items-center gap-2 text-sm text-muted-foreground">
        <MapPin className="size-4 shrink-0 text-primary" aria-hidden="true" />
        {saved.isPending || profile.isPending ? (
          <Skeleton className="h-4 w-48" />
        ) : location ? (
          <span className="truncate">
            {[location.savedName, location.streetName, cityName(location.city, locale)].filter(Boolean).join(' · ')}
          </span>
        ) : (
          <span>{t.home.noLocation}</span>
        )}
      </div>

      {banners.data && banners.data.length > 0 ? (
        <div className="mt-8">
          <Carousel
            slides={banners.data
              .map((b) => ({
                src: (locale === 'ar' ? b.imageLinkAr : b.imageLink) ?? b.imageLink ?? '',
                title: b.title,
                href: b.externalUrl,
                button: t.common.viewAll,
              }))
              .filter((s) => s.src)}
          />
        </div>
      ) : null}

      <SectionTitle title={t.home.services} />
      {saved.isPending || profile.isPending || (location && services.isPending) ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[0, 1, 2].map((i) => (
            <Skeleton key={i} className="h-36 rounded-2xl" />
          ))}
        </div>
      ) : !location ? (
        <Empty icon={<MapPin />} text={t.home.noLocation} />
      ) : services.isError ? (
        <Failed message={services.error.message || t.home.notAvailable} onRetry={() => services.refetch()} t={t} />
      ) : !services.data?.length ? (
        <Empty icon={<MapPin />} text={t.home.notAvailable} />
      ) : (
        <HoverEffect
          className="-mx-2"
          items={services.data.map((s) => ({
            id: s._id,
            href: `${base}/book?service=${s._id}`,
            content: (
              <div className="grid gap-3">
                <div className="flex items-start justify-between gap-3">
                  {s.icon?.iconLink ? (
                    // eslint-disable-next-line @next/next/no-img-element -- icons come from the backend's storage
                    <img src={s.icon.iconLink} alt="" className="size-11 rounded-xl bg-secondary object-contain p-2" />
                  ) : (
                    <span className="grid size-11 place-items-center rounded-xl bg-secondary text-primary">
                      <Sparkles className="size-5" aria-hidden="true" />
                    </span>
                  )}
                  <Money value={s.price} t={t} className="text-lg font-bold" />
                </div>
                <div>
                  <h3 className="font-semibold">{localized(s.name, locale)}</h3>
                  {s.description?.length ? (
                    <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">{s.description.map((d) => localized(d, locale)).join(' · ')}</p>
                  ) : null}
                </div>
                {s.duration ? (
                  <span className="inline-flex items-center gap-1.5 text-xs text-muted-foreground">
                    <Clock className="size-3.5" aria-hidden="true" />
                    {s.duration} {t.common.min}
                  </span>
                ) : null}
              </div>
            ),
          }))}
        />
      )}

      {location && plans.data && plans.data.length > 0 ? (
        <>
          <SectionTitle title={t.home.plans} />
          <HoverEffect
            className="-mx-2"
            items={plans.data.map((p) => ({
              id: p._id,
              content: (
                <div className="grid gap-3">
                  <span className="size-3 rounded-full" style={{ background: p.color || 'var(--primary)' }} aria-hidden="true" />
                  <h3 className="text-lg font-semibold">{localized(p.type, locale)}</h3>
                  <Money value={p.price} t={t} className="text-2xl font-bold" />
                  {p.usageCount ? (
                    <p className="text-sm text-muted-foreground">
                      {p.usageCount} {t.home.perPlan}
                    </p>
                  ) : null}
                  {p.description?.length ? (
                    <ul className="grid gap-1 text-sm text-muted-foreground">
                      {p.description.map((d, i) => (
                        <li key={i}>• {localized(d, locale)}</li>
                      ))}
                    </ul>
                  ) : null}
                </div>
              ),
            }))}
          />
        </>
      ) : null}
    </div>
  );
}
