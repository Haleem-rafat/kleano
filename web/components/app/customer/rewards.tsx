'use client';

import { ArrowRight, Coins, Copy, Smartphone, Sprout, TicketPercent, Wallet } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { toast } from 'sonner';
import { BalanceCard, SAUDI_TIME, Empty, Failed, Money, PageTitle, SectionTitle } from '@/components/app/bits';
import { RowsSkeleton, Segmented } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { usePoints, useProfile, usePromoCodes, type PromoStatus } from '@/lib/kleano/queries';
import type { PromoCode } from '@/lib/kleano/types';

/** Balance from GET /users. Top-up stays in the app: the web takes no raw card numbers (MISSING_API.md). */
export function CustomerWallet({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  return (
    <div>
      <PageTitle title={t.wallet.title} />
      {profile.isError ? (
        <Failed message={profile.error.message} onRetry={() => profile.refetch()} t={t} />
      ) : (
        <div className="grid items-start gap-4 lg:grid-cols-[3fr_2fr]">
          <BalanceCard icon={<Wallet />} label={t.wallet.balance} className="min-h-56 content-between">
            {profile.isPending ? <Skeleton className="h-12 w-44 bg-white/20" /> : <Money value={profile.data.walletBalance} t={t} className="text-5xl font-bold tracking-tight" />}
            <Button asChild size="xl" className="w-full bg-white text-[#2c1838] hover:bg-white/90 sm:w-fit">
              <Link href={`/${locale}/app/book`}>
                {t.wallet.use}
                <ArrowRight className="rtl:-scale-x-100" aria-hidden="true" />
              </Link>
            </Button>
          </BalanceCard>
          <section className="flex gap-4 rounded-[var(--radius-card)] border bg-card p-5">
            <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
              <Smartphone className="size-5" aria-hidden="true" />
            </span>
            <div className="grid gap-1">
              <h2 className="font-semibold">{t.wallet.topUpTitle}</h2>
              <p className="text-sm text-muted-foreground">{t.wallet.topUpBody}</p>
            </div>
          </section>
        </div>
      )}
    </div>
  );
}

export function CustomerPoints({ t }: { t: AppDictionary; locale: Locale }) {
  const info = usePoints();
  const steps = [
    { icon: Sprout, title: t.points.growTitle, body: t.points.growBody },
    { icon: Coins, title: t.points.redeemTitle, body: t.points.redeemBody },
  ];
  return (
    <div>
      <PageTitle title={t.points.title} />
      {info.isPending ? (
        <Skeleton className="h-44 rounded-[var(--radius-card)]" />
      ) : info.isError ? (
        <Failed message={info.error.message} onRetry={() => info.refetch()} t={t} />
      ) : (
        <BalanceCard icon={<Coins />} label={t.points.points}>
          <div className="flex flex-wrap items-end justify-between gap-4">
            <p className="text-5xl font-bold tracking-tight tabular-nums">{info.data.points}</p>
            <div className="text-end">
              <p className="text-sm text-white/75">{t.points.worth}</p>
              <Money value={info.data.pointsExchange} t={t} className="text-2xl font-bold" />
            </div>
          </div>
          <div className="grid gap-2">
            <span className="h-2 overflow-hidden rounded-full bg-white/20" aria-hidden="true">
              <span className="block h-full rounded-full bg-white" style={{ width: `${Math.min(100, (info.data.points / Math.max(1, info.data.redeemLimit)) * 100)}%` }} />
            </span>
            <p className="text-sm text-white/80">
              {info.data.points >= info.data.redeemLimit ? (
                t.points.canRedeem
              ) : (
                <>
                  {t.points.earn} <span className="tabular-nums">{info.data.redeemLimit - info.data.points}</span> {t.points.pt} {t.points.more}
                </>
              )}
            </p>
          </div>
        </BalanceCard>
      )}
      <SectionTitle title={t.points.how} />
      <ul className="grid gap-4 md:grid-cols-2">
        {steps.map((s) => (
          <li key={s.title} className="flex gap-4 rounded-[var(--radius-card)] border bg-card p-5">
            <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
              <s.icon className="size-5" aria-hidden="true" />
            </span>
            <div>
              <h3 className="font-semibold">{s.title}</h3>
              <p className="text-sm text-muted-foreground">{s.body}</p>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

function discount(p: PromoCode, t: AppDictionary) {
  if (p.discountFixedNumber != null) return `${p.discountFixedNumber} ${t.common.sar}`;
  if (p.discountPercentage != null) return `${p.discountPercentage}%`;
  return '';
}

export function CustomerPromos({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const [status, setStatus] = useState<PromoStatus>('ACTIVE');
  const codes = usePromoCodes(status);
  const statuses: PromoStatus[] = ['ACTIVE', 'USED', 'EXPIRED'];
  const date = new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { dateStyle: 'medium', timeZone: SAUDI_TIME });

  const copy = async (code: string) => {
    try {
      await navigator.clipboard.writeText(code);
      toast.success(t.promos.copied);
    } catch {
      toast.info(code);
    }
  };

  return (
    <div>
      <PageTitle title={t.promos.title} />
      <Segmented value={status} label={t.promos.title} className="mb-6" options={statuses.map((s) => ({ value: s, label: t.promos.tabs[s] }))} onChange={setStatus} />
      {codes.isPending ? (
        <RowsSkeleton count={3} label={t.common.loading} />
      ) : codes.isError ? (
        <Failed message={codes.error.message} onRetry={() => codes.refetch()} t={t} />
      ) : codes.data.length === 0 ? (
        <Empty icon={<TicketPercent />} text={t.promos.empty} />
      ) : (
        <ul className="grid gap-3 lg:grid-cols-2">
          {codes.data.map((p) => (
            <li key={p._id} className="relative flex items-stretch overflow-hidden rounded-[var(--radius-card)] border bg-card">
              <div className="min-w-0 flex-1 p-4 md:p-5">
                <p className="text-2xl font-bold text-primary tabular-nums">
                  {discount(p, t)} <span className="text-sm font-medium text-foreground">{t.promos.off}</span>
                </p>
                <p className="mt-1 text-xs text-muted-foreground md:text-sm">
                  {[p.expiryDate ? `${t.promos.expires} ${date.format(new Date(p.expiryDate))}` : '', p.numberOfUses != null ? `${t.promos.uses}: ${p.numberOfUses}` : ''].filter(Boolean).join(' · ')}
                </p>
              </div>
              {/* The tear line of a ticket, with its two punched holes. */}
              <span aria-hidden="true" className="relative w-px border-s border-dashed">
                <span className="absolute -top-2 -start-2 size-4 rounded-full border bg-background" />
                <span className="absolute -bottom-2 -start-2 size-4 rounded-full border bg-background" />
              </span>
              <button type="button" onClick={() => void copy(p.code)} aria-label={`${t.promos.copy}: ${p.code}`} className="grid shrink-0 content-center justify-items-center gap-1 px-4 font-mono text-sm font-bold tracking-widest transition hover:bg-muted md:px-5" dir="ltr">
                {p.code}
                <Copy className="size-4 text-muted-foreground" aria-hidden="true" />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
