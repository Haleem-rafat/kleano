'use client';

import { useQuery } from '@tanstack/react-query';
import { Clock, LocateFixed, MapPinOff, Sparkles } from 'lucide-react';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { Empty, Failed, Money, PageTitle, SectionTitle } from '@/components/app/bits';
import { CardsSkeleton } from '@/components/app/kit';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { kleano } from '@/lib/kleano/client';
import { localized, type AddOn, type Plan, type WashingService, type Wrapped } from '@/lib/kleano/types';
import { currentPosition, loadMaps, mapsKey, reverseGeocode } from '@/lib/maps';

type Place = { latitude: number; longitude: number; country: string };

const where = (p: Place) => `latitude=${p.latitude.toFixed(6)}&longitude=${p.longitude.toFixed(6)}&country=${encodeURIComponent(p.country)}`;

/** Guest browsing, as in the app's guest_home.dart: the catalogue where you are, booking needs an account. */
export function CustomerExplore({ t, locale, themeLabel }: { t: AppDictionary; locale: Locale; themeLabel: string }) {
  const [place, setPlace] = useState<Place | null>(null);
  const [state, setState] = useState<'asking' | 'denied' | 'ready'>('asking');
  const noKey = !mapsKey;

  const locate = async () => {
    const position = await currentPosition();
    if (!position) return setState('denied');
    try {
      const address = await reverseGeocode(await loadMaps(locale), position, locale);
      if (!address?.country) return setState('denied');
      setPlace({ latitude: position.lat, longitude: position.lng, country: address.country });
      setState('ready');
    } catch {
      setState('denied');
    }
  };

  useEffect(() => {
    if (noKey) return;
    const timer = window.setTimeout(() => void locate(), 0);
    return () => window.clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps -- once, on arrival
  }, []);

  const services = useQuery({
    queryKey: ['guest-services', place],
    enabled: Boolean(place),
    retry: false,
    queryFn: () => kleano<Wrapped<WashingService[]>>(`/washing-services/guest/all?${where(place!)}`).then((r) => r.data ?? []),
  });
  const addOns = useQuery({
    queryKey: ['guest-add-ons', place],
    enabled: Boolean(place),
    retry: false,
    queryFn: () => kleano<Wrapped<AddOn[]>>(`/add-ons/guest/all?${where(place!)}`).then((r) => r.data ?? []),
  });
  const plans = useQuery({
    queryKey: ['guest-plans', place],
    enabled: Boolean(place),
    retry: false,
    queryFn: () => kleano<Wrapped<Plan[]>>(`/plans/guest/all?${where(place!)}`).then((r) => r.data ?? []),
  });
  const base = `/${locale}/app`;

  return (
    <div className="min-h-dvh bg-background">
      <header className="sticky top-0 z-30 border-b bg-background/85 backdrop-blur-xl">
        <div className="mx-auto flex h-16 max-w-5xl items-center justify-between gap-3 px-4 md:px-8">
          <Link href={`/${locale}`} aria-label={t.backToSite} className="text-primary">
            <Logo className="h-9 w-auto" />
          </Link>
          <div className="flex items-center gap-2">
            <ThemeToggle label={themeLabel} />
            <Button asChild size="chip">
              <Link href={`${base}/signup`}>{t.welcome.signUp}</Link>
            </Button>
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-5xl px-4 py-8 md:px-8">
        <PageTitle title={t.explore.title} subtitle={t.explore.subtitle} />
        {noKey ? (
          <Empty
            icon={<MapPinOff />}
            text={t.places.noMapKey}
            action={
              <Button asChild size="chip">
                <Link href={`${base}/login`}>{t.welcome.login}</Link>
              </Button>
            }
          />
        ) : state === 'asking' ? (
          <CardsSkeleton label={t.common.loading} />
        ) : state === 'denied' ? (
          <Empty
            icon={<LocateFixed />}
            text={t.explore.needLocation}
            action={
              <Button
                size="chip"
                onClick={() => {
                  setState('asking');
                  void locate();
                }}
              >
                {t.common.retry}
              </Button>
            }
          />
        ) : services.isPending ? (
          <CardsSkeleton label={t.common.loading} />
        ) : services.isError ? (
          <Failed message={services.error.message} onRetry={() => services.refetch()} t={t} />
        ) : !services.data.length ? (
          <Empty icon={<MapPinOff />} text={t.home.notAvailable} />
        ) : (
          <>
            <section aria-label={t.home.services} className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {services.data.map((s) => (
                <article key={s._id} className="grid gap-3 rounded-[var(--radius-card)] border bg-card p-5">
                  <div className="flex items-start justify-between gap-3">
                    <span className="grid size-11 place-items-center rounded-xl bg-secondary text-primary">
                      <Sparkles className="size-5" aria-hidden="true" />
                    </span>
                    <Money value={s.price} t={t} className="text-lg font-bold" />
                  </div>
                  <h2 className="font-semibold">{localized(s.name, locale)}</h2>
                  {s.description?.length ? <p className="line-clamp-2 text-sm text-muted-foreground">{s.description.map((d) => localized(d, locale)).join(' · ')}</p> : null}
                  {s.duration ? (
                    <span className="inline-flex items-center gap-1.5 text-xs text-muted-foreground">
                      <Clock className="size-3.5" aria-hidden="true" />
                      {s.duration} {t.common.min}
                    </span>
                  ) : null}
                </article>
              ))}
            </section>
            {addOns.data?.length ? (
              <>
                <SectionTitle title={t.bookings.addOns} />
                <ul className="flex flex-wrap gap-2">
                  {addOns.data.map((a) => (
                    <li key={a._id} className="inline-flex h-11 items-center gap-2 rounded-full border bg-card px-4 text-sm font-medium">
                      {localized(a.name, locale)} <Money value={a.price} t={t} className="text-muted-foreground" />
                    </li>
                  ))}
                </ul>
              </>
            ) : null}
            {plans.data?.length ? (
              <>
                <SectionTitle title={t.home.plans} />
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {plans.data.map((p) => (
                    <article key={p._id} className="grid gap-2 rounded-[var(--radius-card)] border bg-card p-5">
                      <h3 className="text-lg font-semibold">{localized(p.type, locale)}</h3>
                      <Money value={p.price} t={t} className="text-2xl font-bold" />
                      {p.usageCount ? (
                        <p className="text-sm text-muted-foreground">
                          {p.usageCount} {t.home.perPlan}
                        </p>
                      ) : null}
                    </article>
                  ))}
                </div>
              </>
            ) : null}
            <div className="mt-8 flex justify-center">
              <Button asChild size="xl">
                <Link href={`${base}/signup`}>{t.explore.signUpToBook}</Link>
              </Button>
            </div>
          </>
        )}
      </main>
    </div>
  );
}
