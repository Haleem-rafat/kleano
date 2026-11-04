'use client';

import { ArrowRight, Car, ChevronDown, Clock, Coins, MapPin, Wallet, type LucideIcon } from 'lucide-react';
import { motion } from 'motion/react';
import Image from 'next/image';
import Link from 'next/link';
import { OrderProgress } from '@/components/app/order-parts';
import { Empty, Failed, Money, SectionTitle, StatusBadge, formatWhen } from '@/components/app/bits';
import { Button } from '@/components/ui/button';
import { GlowingEffect } from '@/components/ui/glowing-effect';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useVehicles } from '@/lib/kleano/domains/vehicles';
import { pickLocation, useBanners, useOrders, usePlans, useProfile, useSavedLocations, useServices } from '@/lib/kleano/queries';
import { cityName, localized, type WashingService } from '@/lib/kleano/types';
import inside from '@/public/images/inside.jpg';
import outside from '@/public/images/outside.jpg';
import washing from '@/public/images/washing.jpg';

/** A small photo for a service: the backend only sends a little icon. */
function photoFor(service: WashingService, index: number) {
  const name = `${service.name?.en ?? ''}`.toLowerCase();
  if (/ext|out/.test(name)) return outside;
  if (/int|in\b|full/.test(name)) return inside;
  return [washing, outside, inside][index % 3];
}

function Stat({ href, icon: Icon, label, loading, children }: { href: string; icon: LucideIcon; label: string; loading: boolean; children: React.ReactNode }) {
  return (
    <Link href={href} className="group relative rounded-2xl border bg-card p-4 transition hover:border-primary/40">
      <GlowingEffect spread={40} glow={false} disabled={false} proximity={64} inactiveZone={0.01} borderWidth={2} />
      <span className="flex items-center gap-2 text-sm text-muted-foreground">
        <Icon className="size-4 text-primary" aria-hidden="true" />
        <span className="truncate">{label}</span>
      </span>
      <div className="mt-2 text-2xl font-bold tracking-tight">{loading ? <Skeleton className="h-8 w-20" /> : children}</div>
    </Link>
  );
}

export function CustomerHome({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  const saved = useSavedLocations();
  const banners = useBanners();
  const active = useOrders('ACTIVE');
  const vehicles = useVehicles();
  const location = pickLocation(saved.data, profile.data);
  const services = useServices(location);
  const plans = usePlans(location);
  const next = active.data?.pages[0]?.data?.[0];
  const base = `/${locale}/app`;
  const firstName = profile.data?.userName?.split(' ')[0];
  const place = location ? [location.savedName, cityName(location.city, locale)].filter(Boolean).join(' · ') : t.home.noPlaceShort;
  const placeLoading = saved.isPending || profile.isPending;
  const slides = (banners.data ?? [])
    .map((b) => ({ id: b._id, src: (locale === 'ar' ? b.imageLinkAr : b.imageLink) ?? b.imageLink ?? '', title: b.title, href: b.externalUrl }))
    .filter((s) => s.src);

  return (
    <div className="grid gap-4">
      {/* The welcome: a real wash, the place it will happen, and the one thing to do next. */}
      <motion.section
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
        className="relative isolate overflow-hidden rounded-3xl bg-[#1c1023] text-white"
      >
        <Image src={washing} alt="" fill priority placeholder="blur" sizes="(max-width: 1024px) 100vw, 1000px" className="-z-20 object-cover object-[70%_40%]" />
        <div aria-hidden="true" className="absolute inset-0 -z-10 bg-gradient-to-t from-[#1c1023] via-[#1c1023]/75 to-[#1c1023]/20 md:bg-gradient-to-r md:from-[#1c1023] md:via-[#1c1023]/80 md:to-transparent md:rtl:bg-gradient-to-l" />
        <div className="grid min-h-[300px] content-between gap-10 p-5 md:min-h-[320px] md:max-w-[62%] md:p-8">
          <Link href={`${base}/places`} className="inline-flex h-9 w-fit max-w-full items-center gap-1.5 rounded-full bg-white/15 px-3 text-sm font-medium backdrop-blur-md transition hover:bg-white/25">
            <MapPin className="size-4 shrink-0" aria-hidden="true" />
            {placeLoading ? <Skeleton className="h-4 w-28 bg-white/20" /> : <span className="truncate">{place}</span>}
            <ChevronDown className="size-4 shrink-0 opacity-70" aria-hidden="true" />
          </Link>
          <div className="grid gap-4">
            <div className="grid gap-1.5">
              <h1 className="text-3xl font-bold text-balance md:text-5xl">
                {t.home.hello}
                {firstName ? `${locale === 'ar' ? '، ' : ', '}${firstName}` : ''}
              </h1>
              <p className="text-base text-white/80 md:text-lg">{t.home.tagline}</p>
            </div>
            <div className="flex flex-wrap items-center gap-2">
              <Button asChild size="xl" className="bg-white text-[#2c1838] hover:bg-white/90">
                <Link href={`${base}/book`}>
                  {t.home.bookNow}
                  <ArrowRight className="rtl:-scale-x-100" aria-hidden="true" />
                </Link>
              </Button>
              <Button asChild variant="ghost" size="xl" className="text-white hover:bg-white/15 hover:text-white">
                <Link href={`${base}/bookings`}>{t.home.myBookings}</Link>
              </Button>
            </div>
          </div>
        </div>
      </motion.section>

      {next ? (
        <Link href={`${base}/bookings/${next._id}`} className="group grid gap-4 rounded-2xl border border-primary/30 bg-card p-4 transition hover:border-primary md:p-5">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <div className="min-w-0">
              <p className="text-sm text-muted-foreground">{t.home.upcoming}</p>
              <p className="truncate font-semibold">
                {localized(next.washingServices?.[0]?.name, locale)} · <span className="font-normal text-muted-foreground">{formatWhen(next.startTime, locale)}</span>
              </p>
            </div>
            <span className="flex items-center gap-2">
              <StatusBadge status={next.status} t={t} />
              <ArrowRight className="size-5 shrink-0 text-muted-foreground transition group-hover:text-primary rtl:-scale-x-100" aria-hidden="true" />
            </span>
          </div>
          <OrderProgress status={next.status} t={t} />
        </Link>
      ) : null}

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Stat href={`${base}/wallet`} icon={Wallet} label={t.home.wallet} loading={profile.isPending}>
          <Money value={profile.data?.walletBalance} t={t} />
        </Stat>
        <Stat href={`${base}/points`} icon={Coins} label={t.home.points} loading={profile.isPending}>
          <span className="tabular-nums">{profile.data?.points ?? 0}</span>
        </Stat>
        <Stat href={`${base}/cars`} icon={Car} label={t.nav.vehicles} loading={vehicles.isPending}>
          <span className="tabular-nums">{vehicles.data?.length ?? 0}</span>
        </Stat>
        <Stat href={`${base}/places`} icon={MapPin} label={t.places.title} loading={saved.isPending}>
          <span className="tabular-nums">{saved.data?.length ?? 0}</span>
        </Stat>
      </div>

      <div>
        <SectionTitle title={t.home.services} />
        {saved.isPending || profile.isPending || (location && services.isPending) ? (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {[0, 1, 2].map((i) => (
              <Skeleton key={i} className="h-64 rounded-2xl" />
            ))}
          </div>
        ) : !location ? (
          <Empty
            icon={<MapPin />}
            text={t.home.noLocation}
            action={
              <Button asChild size="chip">
                <Link href={`${base}/places/new`}>{t.places.add}</Link>
              </Button>
            }
          />
        ) : services.isError ? (
          <Failed message={services.error.message || t.home.notAvailable} onRetry={() => services.refetch()} t={t} />
        ) : !services.data?.length ? (
          <Empty icon={<MapPin />} text={t.home.notAvailable} />
        ) : (
          <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {services.data.map((s, i) => (
              <li key={s._id}>
                <Link href={`${base}/book?service=${s._id}`} className="group flex h-full flex-col overflow-hidden rounded-2xl border bg-card transition hover:border-primary/40 hover:shadow-input">
                  <span className="relative block h-36 overflow-hidden">
                    <Image src={photoFor(s, i)} alt="" fill placeholder="blur" sizes="(max-width: 640px) 100vw, 380px" className="object-cover transition duration-500 group-hover:scale-105 motion-reduce:transition-none" />
                  </span>
                  <span className="flex flex-1 flex-col gap-2 p-4">
                    <span className="flex items-start justify-between gap-3">
                      <span className="font-semibold">{localized(s.name, locale)}</span>
                      <Money value={s.price} t={t} className="shrink-0 font-bold" />
                    </span>
                    {s.description?.length ? <span className="line-clamp-2 text-sm text-muted-foreground">{s.description.map((d) => localized(d, locale)).join(' · ')}</span> : null}
                    <span className="mt-auto flex items-center justify-between gap-3 pt-2 text-sm">
                      <span className="inline-flex items-center gap-1.5 text-muted-foreground">
                        {s.duration ? (
                          <>
                            <Clock className="size-3.5" aria-hidden="true" />
                            {s.duration} {t.common.min}
                          </>
                        ) : null}
                      </span>
                      <span className="inline-flex items-center gap-1 font-semibold text-primary">
                        {t.home.bookService}
                        <ArrowRight className="size-4 transition group-hover:translate-x-0.5 rtl:-scale-x-100 rtl:group-hover:-translate-x-0.5" aria-hidden="true" />
                      </span>
                    </span>
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </div>

      {slides.length > 0 ? (
        <div>
          <SectionTitle title={t.home.offers} />
          <ul className="-mx-4 flex snap-x snap-mandatory gap-3 overflow-x-auto px-4 pb-2 md:mx-0 md:px-0">
            {slides.map((s) => {
              const picture = (
                // eslint-disable-next-line @next/next/no-img-element -- banners come from the backend's storage
                <img src={s.src} alt={s.title ?? ''} loading="lazy" className="h-40 w-[300px] rounded-2xl object-cover md:h-44 md:w-[380px]" />
              );
              return (
                <li key={s.id} className="shrink-0 snap-start">
                  {s.href ? (
                    <a href={s.href} target="_blank" rel="noreferrer">
                      {picture}
                    </a>
                  ) : (
                    picture
                  )}
                </li>
              );
            })}
          </ul>
        </div>
      ) : null}

      {location && plans.data && plans.data.length > 0 ? (
        <div>
          <SectionTitle
            title={t.home.plans}
            action={
              <Link href={`${base}/plans`} className="text-sm font-medium text-primary hover:underline">
                {t.common.viewAll}
              </Link>
            }
          />
          <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {plans.data.map((p) => (
              <li key={p._id}>
                <Link href={`${base}/plans`} className="relative flex items-center justify-between gap-3 overflow-hidden rounded-2xl border bg-card p-4 ps-5 transition hover:border-primary/40">
                  <span aria-hidden="true" className="absolute inset-y-0 start-0 w-1.5" style={{ background: p.color || 'var(--primary)' }} />
                  <span className="min-w-0">
                    <span className="block truncate font-semibold">{localized(p.type, locale)}</span>
                    {p.usageCount ? (
                      <span className="block text-sm text-muted-foreground">
                        {p.usageCount} {t.home.perPlan}
                      </span>
                    ) : null}
                  </span>
                  <Money value={p.price} t={t} className="shrink-0 text-xl font-bold" />
                </Link>
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </div>
  );
}
