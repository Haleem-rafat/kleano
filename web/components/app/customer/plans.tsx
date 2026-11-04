'use client';

import { BadgeCheck, CreditCard, Loader2, MapPin, Wallet } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { toast } from 'sonner';
import { Empty, Failed, Money, PageTitle, SectionTitle } from '@/components/app/bits';
import { CardsSkeleton, Sheet } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError } from '@/lib/kleano/client';
import { pickLocation, useMySubscription, usePlans, useProfile, useSavedLocations, useSubscribe } from '@/lib/kleano/queries';
import { localized, type Plan } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

const dateFormat = (locale: Locale) => new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { dateStyle: 'medium' });

function duration(p: Plan, t: AppDictionary) {
  if (!p.duration) return '';
  const unit = t.plans.durationUnits[(p.durationUnit ?? '').toUpperCase() as keyof AppDictionary['plans']['durationUnits']] ?? p.durationUnit ?? '';
  return `${p.duration} ${unit}`;
}

/** Same screen as the app's PlansSubscriptionScreen: your plan on top, then what's available here. */
export function CustomerPlans({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  const saved = useSavedLocations();
  const location = pickLocation(saved.data, profile.data);
  const plans = usePlans(location);
  const mine = useMySubscription();
  const [choosing, setChoosing] = useState<Plan | null>(null);
  const base = `/${locale}/app`;
  const hasPlan = Boolean(mine.data);
  const loading = saved.isPending || profile.isPending || (Boolean(location) && plans.isPending);

  return (
    <div>
      <PageTitle title={t.plans.title} />

      {mine.isPending ? (
        <Skeleton className="mb-6 h-40 rounded-[var(--radius-card)]" />
      ) : mine.data ? (
        <section className="mb-2 grid gap-4 rounded-[var(--radius-card)] border bg-card p-5 md:grid-cols-[1fr_1fr] md:items-center">
          <div className="grid gap-2">
            <p className="text-sm text-muted-foreground">{t.plans.current}</p>
            <h2 className="flex items-center gap-2 text-2xl font-bold">
              <BadgeCheck className="size-6 text-primary" aria-hidden="true" />
              {localized(mine.data.plan?.type, locale)}
            </h2>
            {mine.data.expiryDate ? (
              <p className="text-sm text-muted-foreground">
                {t.plans.expiry}: {dateFormat(locale).format(new Date(mine.data.expiryDate))}
              </p>
            ) : null}
          </div>
          <div className="grid gap-2">
            <p className="flex items-baseline justify-between gap-3 text-sm text-muted-foreground">
              {t.plans.remaining}
              <span className="text-lg font-bold text-foreground tabular-nums">
                {mine.data.remainingWashes ?? 0} <span className="text-sm font-normal text-muted-foreground">/ {mine.data.washesCount ?? mine.data.plan?.usageCount ?? 0}</span>
              </span>
            </p>
            <span className="h-2 overflow-hidden rounded-full bg-muted" aria-hidden="true">
              <span
                className="block h-full rounded-full bg-primary"
                style={{ width: `${Math.min(100, ((mine.data.remainingWashes ?? 0) / Math.max(1, mine.data.washesCount ?? mine.data.plan?.usageCount ?? 1)) * 100)}%` }}
              />
            </span>
            <Button asChild size="chip" className="mt-1 w-fit">
              <Link href={`${base}/book`}>{t.plans.bookOnPlan}</Link>
            </Button>
          </div>
        </section>
      ) : null}

      {hasPlan ? <SectionTitle title={t.home.plans} /> : null}

      {loading ? (
        <CardsSkeleton label={t.common.loading} />
      ) : !location ? (
        <Empty
          icon={<MapPin />}
          text={t.plans.noPlace}
          action={
            <Button asChild size="chip">
              <Link href={`${base}/places/new`}>{t.plans.addPlace}</Link>
            </Button>
          }
        />
      ) : plans.isError ? (
        <Failed message={plans.error.message} onRetry={() => plans.refetch()} t={t} />
      ) : !plans.data?.length ? (
        <Empty icon={<CreditCard />} text={t.plans.empty} />
      ) : (
        <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {plans.data.map((p) => {
            const active = p.isSubscribed || mine.data?.plan?._id === p._id;
            return (
              <li key={p._id} className={cn('flex flex-col gap-4 rounded-[var(--radius-card)] border bg-card p-5', active && 'border-primary')}>
                <div className="flex items-center justify-between gap-3">
                  <h3 className="flex min-w-0 items-center gap-2 text-lg font-semibold">
                    <span className="size-3 shrink-0 rounded-full" style={{ background: p.color || 'var(--primary)' }} aria-hidden="true" />
                    <span className="truncate">{localized(p.type, locale)}</span>
                  </h3>
                  {active ? <span className="shrink-0 rounded-full bg-secondary px-3 py-1 text-xs font-semibold text-secondary-foreground">{t.plans.subscribed}</span> : null}
                </div>
                <div>
                  <Money value={p.price} t={t} className="text-3xl font-bold" />
                  <p className="text-sm text-muted-foreground">
                    {[p.usageCount ? `${p.usageCount} ${t.plans.washes}` : '', duration(p, t)].filter(Boolean).join(' · ')}
                  </p>
                </div>
                {p.description?.length ? (
                  <ul className="grid gap-1 text-sm text-muted-foreground">
                    {p.description.map((d, i) => (
                      <li key={i}>• {localized(d, locale)}</li>
                    ))}
                  </ul>
                ) : null}
                {p.washingServices?.length ? (
                  <p className="text-sm">
                    <span className="font-medium">{t.plans.services}: </span>
                    {p.washingServices.map((s) => localized(s.name, locale)).join('، ')}
                  </p>
                ) : null}
                <Button
                  variant="secondary"
                  size="xl"
                  className="mt-auto w-full"
                  onClick={() => (hasPlan ? toast.info(t.plans.alreadySubscribed) : setChoosing(p))}
                >
                  {active ? t.plans.subscribed : t.plans.subscribe}
                </Button>
              </li>
            );
          })}
        </ul>
      )}

      {choosing ? <SubscribeSheet plan={choosing} balance={profile.data?.walletBalance ?? 0} t={t} locale={locale} onClose={() => setChoosing(null)} /> : null}
    </div>
  );
}

function SubscribeSheet({ plan, balance, t, locale, onClose }: { plan: Plan; balance: number; t: AppDictionary; locale: Locale; onClose: () => void }) {
  const subscribe = useSubscribe();
  const enough = balance >= plan.price;
  return (
    <Sheet
      open
      onOpenChange={(open) => !open && onClose()}
      title={t.plans.confirmTitle}
      closeLabel={t.terms.close}
      footer={
        enough ? (
          <Button
            size="xl"
            className="w-full"
            disabled={subscribe.isPending}
            onClick={() =>
              subscribe.mutate(plan._id, {
                onSuccess: () => {
                  toast.success(t.plans.success);
                  onClose();
                },
                onError: (e) => toast.error(e instanceof ApiError ? e.message : t.common.error),
              })
            }
          >
            {subscribe.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {t.plans.pay}
          </Button>
        ) : (
          <Button asChild size="xl" className="w-full">
            <Link href={`/${locale}/app/wallet`}>{t.plans.goToWallet}</Link>
          </Button>
        )
      }
    >
      <div className="grid gap-4">
        <div className="flex items-baseline justify-between gap-3">
          <h3 className="text-lg font-semibold">{localized(plan.type, locale)}</h3>
          <Money value={plan.price} t={t} className="text-2xl font-bold" />
        </div>
        <div className="flex items-center gap-3 rounded-2xl bg-muted p-4">
          <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
            <Wallet className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <p className="font-medium">{t.plans.payFromWallet}</p>
            <p className={cn('text-sm', enough ? 'text-muted-foreground' : 'text-destructive')}>
              {t.book.balance}: <Money value={balance} t={t} />
            </p>
          </div>
        </div>
        {!enough ? <p className="text-sm text-destructive">{t.plans.notEnough}</p> : null}
        <p className="text-sm text-muted-foreground">{t.book.cardInApp}</p>
      </div>
    </Sheet>
  );
}
