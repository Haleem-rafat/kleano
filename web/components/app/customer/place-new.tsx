'use client';

import { ArrowLeft, Loader2, LocateFixed, MapPinOff, Search } from 'lucide-react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { useCallback, useEffect, useRef, useState, type FormEvent } from 'react';
import { toast } from 'sonner';
import { Empty, Failed, PageTitle } from '@/components/app/bits';
import { Field } from '@/components/app/field';
import { Button } from '@/components/ui/button';
import { LiquidGlass } from '@/components/ui/liquid-glass';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError } from '@/lib/kleano/client';
import { useSavePlace } from '@/lib/kleano/queries';
import { currentPosition, defaultCenter, loadMaps, mapsKey, reverseGeocode, searchAddress, type Address, type GoogleMap, type GoogleMaps, type GoogleMarker, type LatLng } from '@/lib/maps';
import { cn } from '@/lib/utils';

type Label = 'home' | 'work' | 'other';

/** Add a saved place, as in the app's home_screen.dart: pin on a map, a label, then POST. */
export function CustomerPlaceNew({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const router = useRouter();
  const first = useSearchParams().get('first') === '1';
  const home = `/${locale}/app`;
  const back = (
    <Link href={`${home}/places`} className="mb-4 inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground">
      <ArrowLeft className="size-4 rtl:-scale-x-100" aria-hidden="true" />
      {t.places.title}
    </Link>
  );

  if (!mapsKey) {
    return (
      <div>
        {back}
        <PageTitle title={t.places.addTitle} />
        <Empty
          icon={<MapPinOff />}
          text={t.places.noMapKey}
          action={
            first ? (
              <Button asChild size="chip">
                <Link href={home}>{t.nav.home}</Link>
              </Button>
            ) : undefined
          }
        />
      </div>
    );
  }
  return <PlaceMap t={t} locale={locale} first={first} back={back} onDone={() => router.replace(first ? home : `${home}/places`)} />;
}

function PlaceMap({ t, locale, first, back, onDone }: { t: AppDictionary; locale: Locale; first: boolean; back: React.ReactNode; onDone: () => void }) {
  const save = useSavePlace();
  const box = useRef<HTMLDivElement>(null);
  const map = useRef<GoogleMap | null>(null);
  const marker = useRef<GoogleMarker | null>(null);
  const [maps, setMaps] = useState<GoogleMaps | null>(null);
  const [failed, setFailed] = useState(0);
  const [loadError, setLoadError] = useState(false);
  const [position, setPosition] = useState<LatLng | null>(null);
  const [address, setAddress] = useState<Address | null>(null);
  const [resolving, setResolving] = useState(false);
  const [query, setQuery] = useState('');
  const [label, setLabel] = useState<Label>('home');
  const [otherName, setOtherName] = useState('');
  const [otherError, setOtherError] = useState<string | null>(null);

  useEffect(() => {
    let alive = true;
    loadMaps(locale)
      .then((m) => {
        if (alive) setMaps(m);
      })
      .catch(() => {
        if (alive) setLoadError(true);
      });
    return () => {
      alive = false;
    };
  }, [locale, failed]);

  const pin = useCallback(
    async (at: LatLng) => {
      if (!maps || !map.current) return;
      setPosition(at);
      setResolving(true);
      marker.current?.setPosition(at);
      if (!marker.current) marker.current = new maps.Marker({ map: map.current, position: at });
      try {
        setAddress(await reverseGeocode(maps, at, locale));
      } catch {
        setAddress(null);
        toast.error(t.places.notFound);
      } finally {
        setResolving(false);
      }
    },
    [maps, locale, t],
  );

  useEffect(() => {
    if (!maps || !box.current || map.current) return;
    map.current = new maps.Map(box.current, { center: defaultCenter, zoom: 12, disableDefaultUI: true, zoomControl: true, clickableIcons: false, gestureHandling: 'greedy' });
    map.current.addListener('click', (e) => {
      if (e.latLng) void pin({ lat: e.latLng.lat(), lng: e.latLng.lng() });
    });
  }, [maps, pin]);

  const goTo = (at: LatLng) => {
    map.current?.panTo(at);
    map.current?.setZoom(16);
    void pin(at);
  };

  const onSearch = async (e: FormEvent) => {
    e.preventDefault();
    if (!maps || !query.trim()) return;
    const found = await searchAddress(maps, query.trim(), locale).catch(() => null);
    if (found) goTo(found);
    else toast.error(t.places.notFound);
  };

  const locateMe = async () => {
    const at = await currentPosition();
    if (at) goTo(at);
    else toast.error(t.places.locationDenied);
  };

  const submit = async () => {
    if (!position || !address) return;
    const savedName = label === 'home' ? t.places.home : label === 'work' ? t.places.work : otherName.trim();
    if (!savedName) {
      setOtherError(t.places.labelRequired);
      return;
    }
    try {
      await save.mutateAsync({
        latitude: position.lat.toFixed(6),
        longitude: position.lng.toFixed(6),
        streetName: address.streetName,
        subAdministrativeArea: address.subAdministrativeArea,
        country: address.country,
        savedName,
      });
      toast.success(t.places.saved);
      onDone();
    } catch (e) {
      toast.error(e instanceof ApiError ? e.message : t.common.error);
    }
  };

  const labels: { value: Label; text: string }[] = [
    { value: 'home', text: t.places.home },
    { value: 'work', text: t.places.work },
    { value: 'other', text: t.places.other },
  ];

  return (
    <div>
      {back}
      <PageTitle title={t.places.addTitle} subtitle={first ? t.places.firstHint : undefined} />
      <div className="grid gap-6 lg:grid-cols-[1fr_360px]">
        <div className="relative h-[52dvh] min-h-80 overflow-hidden rounded-[var(--radius-card)] border bg-muted lg:h-[68dvh]">
          {loadError ? (
            <div className="grid h-full place-items-center p-6">
              <Failed
                message={t.places.mapFailed}
                onRetry={() => {
                  setLoadError(false);
                  setFailed((n) => n + 1);
                }}
                t={t}
              />
            </div>
          ) : (
            <>
              <div ref={box} className="absolute inset-0" />
              {!maps ? <Skeleton className="absolute inset-0 rounded-none" /> : null}
              {/* Controls floating over the map are the one place glass is used on content screens. */}
              <div className="absolute inset-x-3 top-3 flex items-center gap-2">
                <LiquidGlass radius={999} className="min-w-0 flex-1 shadow-input" contentClassName="flex h-11 items-center">
                  <form onSubmit={onSearch} className="flex h-full w-full items-center gap-2 px-4">
                    <Search className="size-4 shrink-0" aria-hidden="true" />
                    <input
                      value={query}
                      onChange={(e) => setQuery(e.target.value)}
                      placeholder={t.places.search}
                      aria-label={t.places.search}
                      className="h-full min-w-0 flex-1 bg-transparent text-sm text-foreground outline-none placeholder:text-foreground/80"
                    />
                  </form>
                </LiquidGlass>
                <LiquidGlass radius={999} className="shrink-0 shadow-input">
                  <button type="button" onClick={() => void locateMe()} aria-label={t.places.useCurrent} title={t.places.useCurrent} className="grid size-11 place-items-center text-foreground">
                    <LocateFixed className="size-5" aria-hidden="true" />
                  </button>
                </LiquidGlass>
              </div>
            </>
          )}
        </div>

        <aside className="grid content-start gap-5 rounded-[var(--radius-card)] border bg-card p-5">
          <div>
            <h2 className="mb-2 font-semibold">{t.places.details}</h2>
            {resolving ? (
              <Skeleton className="h-5 w-4/5" />
            ) : (
              <p className={cn('text-sm', address ? 'text-foreground' : 'text-muted-foreground')}>{address?.streetName ?? t.places.selectOnMap}</p>
            )}
          </div>
          <div className="grid gap-2">
            <p className="text-sm font-medium">{t.places.label}</p>
            <div role="radiogroup" aria-label={t.places.label} className="flex flex-wrap gap-2">
              {labels.map((l) => (
                <button
                  key={l.value}
                  type="button"
                  role="radio"
                  aria-checked={label === l.value}
                  onClick={() => setLabel(l.value)}
                  className={cn('h-10 rounded-full px-4 text-sm font-medium transition', label === l.value ? 'bg-primary text-primary-foreground' : 'bg-muted hover:bg-secondary')}
                >
                  {l.text}
                </button>
              ))}
            </div>
          </div>
          {label === 'other' ? (
            <Field
              id="otherName"
              label={t.places.label}
              value={otherName}
              onChange={(e) => {
                setOtherName(e.target.value);
                setOtherError(null);
              }}
              error={otherError}
            />
          ) : null}
          <Button size="xl" className="w-full" disabled={!address || resolving || save.isPending} onClick={() => void submit()}>
            {save.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {t.places.add}
          </Button>
        </aside>
      </div>
    </div>
  );
}
