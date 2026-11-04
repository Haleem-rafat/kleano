'use client';

import { useQueryClient } from '@tanstack/react-query';
import { ArrowLeft, ArrowRight, Car, Check, Clock, CreditCard, Loader2, MapPin, Sparkles, Tag, Wallet, X } from 'lucide-react';
import { AnimatePresence, motion } from 'motion/react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useMemo, useState, type ReactNode } from 'react';
import { toast } from 'sonner';
import { Empty, Failed, Money, PageTitle } from '@/components/app/bits';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { MultiStepLoader } from '@/components/ui/multi-step-loader';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError } from '@/lib/kleano/client';
import {
  ordersApi,
  pickLocation,
  useAddOns,
  useProfile,
  useSavedLocations,
  useServices,
  useSlots,
  useVehicles,
  type PromoResult,
} from '@/lib/kleano/queries';
import { cityName, localized } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

type Step = 0 | 1 | 2 | 3;

/** Next 7 days as YYYY-MM-DD on the Saudi clock, which is how the backend reads booking days. */
function nextDays(count = 7): string[] {
  const now = Date.now() + 3 * 60 * 60 * 1000;
  return Array.from({ length: count }, (_, i) => new Date(now + i * 86_400_000).toISOString().slice(0, 10));
}

/** Selectable card used by every step: solid card, purple ring and tick when chosen. */
function Choice({ selected, onSelect, children, disabled }: { selected: boolean; onSelect: () => void; children: ReactNode; disabled?: boolean }) {
  return (
    <button
      type="button"
      role="radio"
      aria-checked={selected}
      disabled={disabled}
      onClick={onSelect}
      className={cn(
        'relative w-full rounded-2xl border-2 bg-card p-4 text-start transition hover:shadow-input disabled:cursor-not-allowed disabled:opacity-50',
        selected ? 'border-primary shadow-input' : 'border-transparent ring-1 ring-border',
      )}
    >
      {selected ? (
        <motion.span
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="absolute end-3 top-3 grid size-6 place-items-center rounded-full bg-primary text-primary-foreground"
        >
          <Check className="size-4" aria-hidden="true" />
        </motion.span>
      ) : null}
      {children}
    </button>
  );
}

export function BookingFlow({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const router = useRouter();
  const qc = useQueryClient();
  const params = useSearchParams();
  const profile = useProfile();
  const saved = useSavedLocations();
  const vehicles = useVehicles();

  const [step, setStep] = useState<Step>(0);
  const [reached, setReached] = useState<Step>(0);
  const [serviceId, setServiceId] = useState<string | null>(params.get('service'));
  const [addOnIds, setAddOnIds] = useState<string[]>([]);
  const [vehicleId, setVehicleId] = useState<string | null>(null);
  const [placeId, setPlaceId] = useState<string | null>(null);
  const days = useMemo(() => nextDays(), []);
  const [day, setDay] = useState(days[0]);
  const [pickedSlot, setSlot] = useState<string | null>(null);
  const [freshener, setFreshener] = useState(false);
  const [promoInput, setPromoInput] = useState('');
  const [checkedPromo, setPromo] = useState<(PromoResult & { code: string; forSubtotal: number }) | null>(null);
  const [promoBusy, setPromoBusy] = useState(false);
  const [working, setWorking] = useState<number | null>(null);

  // Smart defaults: the default saved place and the first car.
  const places = useMemo(() => saved.data?.filter((l) => l.latitude && l.country) ?? [], [saved.data]);
  const fallbackPlace = pickLocation(saved.data, profile.data);
  const place = places.find((l) => l._id === placeId) ?? fallbackPlace;
  const vehicle = vehicles.data?.find((v) => v._id === vehicleId) ?? vehicles.data?.[0];

  const services = useServices(place);
  const addOns = useAddOns(place);
  const slots = useSlots(place, day);
  const service = services.data?.find((s) => s._id === serviceId);
  const chosenAddOns = addOns.data?.filter((a) => addOnIds.includes(a._id)) ?? [];
  const subtotal = (service?.price ?? 0) + chosenAddOns.reduce((sum, a) => sum + a.price, 0);
  // A promo code was checked against one total; it only counts while the total is the same.
  const promo = checkedPromo && checkedPromo.forSubtotal === subtotal ? checkedPromo : null;
  const total = promo ? promo.totalPayAfterDiscount : subtotal;
  // The first free time of the chosen day is used until you pick another one.
  const slot = slots.data?.some((s) => s.timeSlot === pickedSlot && s.isAvailable)
    ? pickedSlot
    : (slots.data?.find((s) => s.isAvailable)?.timeSlot ?? null);
  const balance = profile.data?.walletBalance ?? 0;

  const canContinue = [Boolean(service), Boolean(vehicle && place), Boolean(slot), balance >= total][step];
  const blocker = [t.book.pickService, t.book.pickCarPlace, t.book.pickTime, t.book.notEnough][step];

  const go = (next: Step) => {
    setStep(next);
    setReached((r) => (next > r ? next : r));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const applyPromo = async () => {
    if (!promoInput.trim()) return;
    setPromoBusy(true);
    try {
      const res = await ordersApi.promoDiscount(promoInput.trim(), subtotal);
      setPromo({ ...res, code: promoInput.trim(), forSubtotal: subtotal });
      toast.success(t.book.promoApplied);
    } catch (e) {
      toast.error(e instanceof ApiError ? e.message : t.common.error);
    } finally {
      setPromoBusy(false);
    }
  };

  const confirm = async () => {
    if (!service || !vehicle || !place || !slot) return;
    const start = new Date(`${day}T${slot}:00+03:00`).toISOString();
    setWorking(0);
    try {
      const order = await ordersApi.create({
        washingServices: [service._id],
        addOns: addOnIds.length ? addOnIds : undefined,
        vehicle: vehicle._id,
        location: {
          latitude: place.latitude.toFixed(6),
          longitude: place.longitude.toFixed(6),
          streetName: place.streetName || place.savedName || cityName(place.city, locale) || '-',
          subAdministrativeArea: place.subAdministrativeArea || undefined,
          country: place.country ?? '',
        },
        startTime: start,
        bookingDate: start,
        timeSlot: slot,
        type: 'SERVICE_BOOKING',
        totalPrice: subtotal,
        paymentType: 'WALLET',
        code: promo?.code,
        isCarFreshened: freshener,
      });
      setWorking(1);
      await ordersApi.pay(order._id);
      setWorking(2);
      await Promise.all([qc.invalidateQueries({ queryKey: ['orders'] }), qc.invalidateQueries({ queryKey: ['profile'] })]);
      toast.success(t.book.done);
      setTimeout(() => router.push(`/${locale}/app/bookings/${order._id}`), 900);
    } catch (e) {
      setWorking(null);
      toast.error(e instanceof ApiError ? e.message : t.common.error);
    }
  };

  const loading = saved.isPending || profile.isPending || vehicles.isPending;

  return (
    <div className="pb-28 lg:pb-0">
      <MultiStepLoader loadingStates={t.book.working.map((text) => ({ text }))} loading={working !== null} value={working ?? 0} loop={false} />
      <PageTitle title={t.book.title} />

      {/* Progress that matches the real steps; finished steps take you back. */}
      <ol className="mb-8 grid grid-cols-4 gap-2" aria-label={t.book.title}>
        {t.book.steps.map((label, i) => {
          const done = i < step;
          const current = i === step;
          const reachable = i <= reached && i !== step;
          return (
            <li key={label}>
              <button
                type="button"
                disabled={!reachable}
                onClick={() => go(i as Step)}
                aria-current={current ? 'step' : undefined}
                className="group grid w-full gap-2 text-start disabled:cursor-default"
              >
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <motion.span
                    className="block h-full rounded-full bg-primary"
                    initial={false}
                    animate={{ width: done || current ? '100%' : '0%' }}
                    transition={{ duration: 0.4 }}
                  />
                </span>
                <span className={cn('flex items-center gap-1.5 text-xs font-medium md:text-sm', current ? 'text-foreground' : 'text-muted-foreground', reachable && 'group-hover:text-primary')}>
                  {done ? <Check className="size-3.5 text-primary" aria-hidden="true" /> : <span className="tabular-nums">{(i + 1).toLocaleString(locale === 'ar' ? 'ar-EG' : 'en')}</span>}
                  <span className="truncate">{label}</span>
                </span>
              </button>
            </li>
          );
        })}
      </ol>

      <div className="grid gap-8 lg:grid-cols-[1fr_320px]">
        <div className="min-w-0">
          {loading ? (
            <div className="grid gap-3">
              {[0, 1, 2].map((i) => (
                <Skeleton key={i} className="h-24 rounded-2xl" />
              ))}
            </div>
          ) : (
            <AnimatePresence mode="wait" initial={false}>
              <motion.div key={step} initial={{ opacity: 0, x: 16 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -16 }} transition={{ duration: 0.2 }}>
                {step === 0 ? (
                  <div className="grid gap-8">
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.chooseService}</h2>
                      {!place ? (
                        <Empty icon={<MapPin />} text={t.book.noPlaces} />
                      ) : services.isPending ? (
                        <Skeleton className="h-28 rounded-2xl" />
                      ) : services.isError ? (
                        <Failed message={services.error.message} onRetry={() => services.refetch()} t={t} />
                      ) : !services.data?.length ? (
                        <Empty icon={<MapPin />} text={t.home.notAvailable} />
                      ) : (
                        <div role="radiogroup" className="grid gap-3 sm:grid-cols-2">
                          {services.data.map((s) => (
                            <Choice key={s._id} selected={s._id === serviceId} onSelect={() => setServiceId(s._id)}>
                              <div className="grid gap-2 pe-8">
                                <span className="font-semibold">{localized(s.name, locale)}</span>
                                {s.description?.length ? (
                                  <span className="line-clamp-2 text-sm text-muted-foreground">{s.description.map((d) => localized(d, locale)).join(' · ')}</span>
                                ) : null}
                                <span className="flex items-center justify-between gap-3">
                                  <Money value={s.price} t={t} className="text-lg font-bold" />
                                  {s.duration ? (
                                    <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
                                      <Clock className="size-3.5" aria-hidden="true" />
                                      {s.duration} {t.common.min}
                                    </span>
                                  ) : null}
                                </span>
                              </div>
                            </Choice>
                          ))}
                        </div>
                      )}
                    </section>

                    {place && service ? (
                      <section>
                        <h2 className="mb-3 text-lg font-semibold">{t.book.extras}</h2>
                        {addOns.isPending ? (
                          <Skeleton className="h-12 rounded-full" />
                        ) : !addOns.data?.length ? (
                          <p className="text-muted-foreground">{t.book.noExtras}</p>
                        ) : (
                          <div className="flex flex-wrap gap-2">
                            {addOns.data.map((a) => {
                              const on = addOnIds.includes(a._id);
                              return (
                                <button
                                  key={a._id}
                                  type="button"
                                  aria-pressed={on}
                                  onClick={() => setAddOnIds((ids) => (on ? ids.filter((x) => x !== a._id) : [...ids, a._id]))}
                                  className={cn(
                                    'inline-flex h-11 items-center gap-2 rounded-full border-2 px-4 text-sm font-medium transition',
                                    on ? 'border-primary bg-secondary text-secondary-foreground' : 'border-transparent bg-card ring-1 ring-border hover:ring-primary/40',
                                  )}
                                >
                                  {on ? <Check className="size-4" aria-hidden="true" /> : <Sparkles className="size-4 text-primary" aria-hidden="true" />}
                                  {localized(a.name, locale)}
                                  <span className="text-muted-foreground">
                                    + <Money value={a.price} t={t} />
                                  </span>
                                </button>
                              );
                            })}
                          </div>
                        )}
                        <label className="mt-4 flex cursor-pointer items-center justify-between gap-4 rounded-2xl bg-card p-4 ring-1 ring-border">
                          <span className="font-medium">{t.book.freshener}</span>
                          <button
                            type="button"
                            role="switch"
                            aria-checked={freshener}
                            onClick={() => setFreshener((v) => !v)}
                            className={cn('relative h-7 w-12 shrink-0 rounded-full transition', freshener ? 'bg-primary' : 'bg-muted')}
                          >
                            <motion.span layout className={cn('absolute top-1 size-5 rounded-full bg-white shadow', freshener ? 'end-1' : 'start-1')} />
                          </button>
                        </label>
                      </section>
                    ) : null}
                  </div>
                ) : null}

                {step === 1 ? (
                  <div className="grid gap-8">
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.chooseCar}</h2>
                      {!vehicles.data?.length ? (
                        <Empty icon={<Car />} text={t.book.noCars} />
                      ) : (
                        <div role="radiogroup" className="grid gap-3 sm:grid-cols-2">
                          {vehicles.data.map((v) => (
                            <Choice key={v._id} selected={v._id === vehicle?._id} onSelect={() => setVehicleId(v._id)}>
                              <span className="flex items-center gap-3 pe-8">
                                <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
                                  <Car className="size-5" aria-hidden="true" />
                                </span>
                                <span className="min-w-0">
                                  <span className="block truncate font-semibold">{[v.brand, v.model].filter(Boolean).join(' ')}</span>
                                  <span className="block truncate text-sm text-muted-foreground" dir="auto">
                                    {[v.color, v.plateNumber].filter(Boolean).join(' · ')}
                                  </span>
                                </span>
                              </span>
                            </Choice>
                          ))}
                        </div>
                      )}
                    </section>
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.choosePlace}</h2>
                      {!places.length ? (
                        <Empty icon={<MapPin />} text={t.book.noPlaces} />
                      ) : (
                        <div role="radiogroup" className="grid gap-3 sm:grid-cols-2">
                          {places.map((l) => (
                            <Choice key={l._id} selected={l._id === place?._id} onSelect={() => setPlaceId(l._id)}>
                              <span className="flex items-center gap-3 pe-8">
                                <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
                                  <MapPin className="size-5" aria-hidden="true" />
                                </span>
                                <span className="min-w-0">
                                  <span className="block truncate font-semibold">{l.savedName || l.streetName}</span>
                                  <span className="block truncate text-sm text-muted-foreground">{[l.streetName, cityName(l.city, locale)].filter(Boolean).join(' · ')}</span>
                                </span>
                              </span>
                            </Choice>
                          ))}
                        </div>
                      )}
                    </section>
                  </div>
                ) : null}

                {step === 2 ? (
                  <div className="grid gap-8">
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.chooseDay}</h2>
                      <div role="radiogroup" className="-mx-1 flex gap-2 overflow-x-auto px-1 pb-2">
                        {days.map((d, i) => {
                          const date = new Date(`${d}T12:00:00+03:00`);
                          const on = d === day;
                          return (
                            <button
                              key={d}
                              type="button"
                              role="radio"
                              aria-checked={on}
                              onClick={() => setDay(d)}
                              className={cn(
                                'grid min-w-18 shrink-0 justify-items-center gap-0.5 rounded-2xl px-3 py-3 transition',
                                on ? 'bg-primary text-primary-foreground shadow-input' : 'bg-card ring-1 ring-border hover:ring-primary/40',
                              )}
                            >
                              <span className="text-xs opacity-80">
                                {i === 0 ? t.book.today : i === 1 ? t.book.tomorrow : new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { weekday: 'short', timeZone: 'Asia/Riyadh' }).format(date)}
                              </span>
                              <span className="text-xl font-bold tabular-nums">{new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { day: 'numeric', timeZone: 'Asia/Riyadh' }).format(date)}</span>
                              <span className="text-xs opacity-80">{new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { month: 'short', timeZone: 'Asia/Riyadh' }).format(date)}</span>
                            </button>
                          );
                        })}
                      </div>
                    </section>
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.chooseTime}</h2>
                      {slots.isPending ? (
                        <div className="grid grid-cols-3 gap-2 sm:grid-cols-4">
                          {Array.from({ length: 8 }, (_, i) => (
                            <Skeleton key={i} className="h-12 rounded-xl" />
                          ))}
                        </div>
                      ) : slots.isError ? (
                        <Failed message={slots.error.message} onRetry={() => slots.refetch()} t={t} />
                      ) : !slots.data?.some((s) => s.isAvailable) ? (
                        <Empty icon={<Clock />} text={t.book.noSlots} />
                      ) : (
                        <div role="radiogroup" className="grid grid-cols-3 gap-2 sm:grid-cols-4">
                          {slots.data.map((s) => (
                            <button
                              key={s.timeSlot}
                              type="button"
                              role="radio"
                              aria-checked={s.timeSlot === slot}
                              disabled={!s.isAvailable}
                              onClick={() => setSlot(s.timeSlot)}
                              className={cn(
                                'grid h-12 place-items-center rounded-xl text-sm font-semibold tabular-nums transition disabled:cursor-not-allowed disabled:opacity-40',
                                s.timeSlot === slot ? 'bg-primary text-primary-foreground shadow-input' : 'bg-card ring-1 ring-border hover:ring-primary/40',
                              )}
                              dir="ltr"
                            >
                              {s.isAvailable ? s.timeSlot : `${s.timeSlot} · ${t.book.full}`}
                            </button>
                          ))}
                        </div>
                      )}
                    </section>
                  </div>
                ) : null}

                {step === 3 ? (
                  <div className="grid gap-6">
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.payWith}</h2>
                      <div role="radiogroup" className="grid gap-3">
                        <Choice selected onSelect={() => undefined}>
                          <span className="flex items-center gap-3 pe-8">
                            <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
                              <Wallet className="size-5" aria-hidden="true" />
                            </span>
                            <span>
                              <span className="block font-semibold">{t.book.wallet}</span>
                              <span className={cn('block text-sm', balance < total ? 'text-destructive' : 'text-muted-foreground')}>
                                {t.book.balance}: <Money value={balance} t={t} />
                              </span>
                            </span>
                          </span>
                        </Choice>
                        <p className="flex items-center gap-2 rounded-2xl bg-muted/60 px-4 py-3 text-sm text-muted-foreground">
                          <CreditCard className="size-4 shrink-0" aria-hidden="true" />
                          {t.book.cardInApp}
                        </p>
                        {balance < total ? <p className="text-sm text-destructive">{t.book.notEnough}</p> : null}
                      </div>
                    </section>
                    <section>
                      <h2 className="mb-3 text-lg font-semibold">{t.book.promo}</h2>
                      {promo ? (
                        <div className="flex items-center justify-between gap-3 rounded-2xl bg-secondary px-4 py-3 text-secondary-foreground">
                          <span className="inline-flex items-center gap-2 font-medium">
                            <Tag className="size-4" aria-hidden="true" />
                            {promo.code}
                          </span>
                          <Button variant="ghost" size="sm" onClick={() => setPromo(null)}>
                            <X />
                            {t.book.promoRemove}
                          </Button>
                        </div>
                      ) : (
                        <form
                          className="flex gap-2"
                          onSubmit={(e) => {
                            e.preventDefault();
                            void applyPromo();
                          }}
                        >
                          <div className="flex-1">
                            <Input value={promoInput} onChange={(e) => setPromoInput(e.target.value)} placeholder={t.book.promo} aria-label={t.book.promo} dir="ltr" />
                          </div>
                          <Button type="submit" variant="secondary" className="h-12 px-5" disabled={promoBusy || !promoInput.trim()}>
                            {promoBusy ? <Loader2 className="animate-spin" /> : null}
                            {t.book.apply}
                          </Button>
                        </form>
                      )}
                    </section>
                  </div>
                ) : null}
              </motion.div>
            </AnimatePresence>
          )}
        </div>

        {/* Price summary: beside the steps on wide screens, a bar at the bottom on phones. */}
        <aside className="hidden lg:block">
          <div className="sticky top-6 grid gap-4 rounded-3xl bg-card p-5 shadow-input">
            <h2 className="font-semibold">{t.book.summary}</h2>
            <dl className="grid gap-2 text-sm">
              {service ? (
                <div className="flex justify-between gap-3">
                  <dt>{localized(service.name, locale)}</dt>
                  <dd>
                    <Money value={service.price} t={t} />
                  </dd>
                </div>
              ) : null}
              {chosenAddOns.map((a) => (
                <div key={a._id} className="flex justify-between gap-3 text-muted-foreground">
                  <dt>+ {localized(a.name, locale)}</dt>
                  <dd>
                    <Money value={a.price} t={t} />
                  </dd>
                </div>
              ))}
              {vehicle && step > 0 ? (
                <div className="flex gap-2 text-muted-foreground">
                  <Car className="size-4 shrink-0" aria-hidden="true" />
                  {[vehicle.brand, vehicle.model].filter(Boolean).join(' ')}
                </div>
              ) : null}
              {place && step > 0 ? (
                <div className="flex gap-2 text-muted-foreground">
                  <MapPin className="size-4 shrink-0" aria-hidden="true" />
                  <span className="truncate">{place.savedName || place.streetName}</span>
                </div>
              ) : null}
              {slot && step > 1 ? (
                <div className="flex gap-2 text-muted-foreground">
                  <Clock className="size-4 shrink-0" aria-hidden="true" />
                  <span>
                    {new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { dateStyle: 'medium', timeZone: 'Asia/Riyadh' }).format(new Date(`${day}T12:00:00+03:00`))}{' '}
                    <span dir="ltr">{slot}</span>
                  </span>
                </div>
              ) : null}
              {promo ? (
                <div className="flex justify-between gap-3 text-success">
                  <dt>{t.book.discount}</dt>
                  <dd>
                    <Money value={-promo.discountAmount} t={t} />
                  </dd>
                </div>
              ) : null}
            </dl>
            <div className="flex items-baseline justify-between border-t pt-4">
              <span className="font-semibold">{t.book.total}</span>
              <Money value={total} t={t} className="text-2xl font-bold" />
            </div>
            <StepActions step={step} canContinue={canContinue} blocker={blocker} onBack={() => go((step - 1) as Step)} onNext={() => (step === 3 ? void confirm() : go((step + 1) as Step))} t={t} busy={working !== null} />
          </div>
        </aside>
      </div>

      <div className="fixed inset-x-0 bottom-[calc(84px+env(safe-area-inset-bottom))] z-30 border-t bg-background/95 px-4 py-3 backdrop-blur-xl md:bottom-0 lg:hidden">
        <div className="mx-auto flex max-w-3xl items-center gap-3">
          <div className="min-w-0 flex-1">
            <p className="text-xs text-muted-foreground">{t.book.total}</p>
            <Money value={total} t={t} className="text-xl font-bold" />
          </div>
          <div className="w-auto">
            <StepActions step={step} canContinue={canContinue} blocker={blocker} onBack={() => go((step - 1) as Step)} onNext={() => (step === 3 ? void confirm() : go((step + 1) as Step))} t={t} busy={working !== null} compact />
          </div>
        </div>
      </div>
    </div>
  );
}

function StepActions({
  step,
  canContinue,
  blocker,
  onBack,
  onNext,
  t,
  busy,
  compact,
}: {
  step: Step;
  canContinue: boolean;
  blocker: string;
  onBack: () => void;
  onNext: () => void;
  t: AppDictionary;
  busy: boolean;
  compact?: boolean;
}) {
  return (
    <div className={cn('grid gap-2', compact && 'flex items-center')}>
      {!compact && !canContinue ? <p className="text-xs text-muted-foreground">{blocker}</p> : null}
      <div className="flex gap-2">
        {step > 0 ? (
          <Button variant="outline" size={compact ? 'chip' : 'xl'} onClick={onBack} aria-label={t.book.back} className={compact ? 'size-12 px-0' : 'px-4'}>
            <ArrowLeft className="rtl:-scale-x-100" />
          </Button>
        ) : null}
        <Button size="xl" onClick={onNext} disabled={!canContinue || busy} className={compact ? 'px-6' : 'flex-1'}>
          {busy ? <Loader2 className="animate-spin" /> : null}
          {step === 3 ? t.book.pay : t.book.continue}
          {step < 3 ? <ArrowRight className="rtl:-scale-x-100" /> : null}
        </Button>
      </div>
    </div>
  );
}
