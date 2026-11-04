'use client';

import { ArrowRight, Banknote, CheckCircle2, ClipboardList, Loader2, MessageCircle, Star } from 'lucide-react';
import Link from 'next/link';
import { toast } from 'sonner';
import { Empty, Failed, Money, SectionTitle } from '@/components/app/bits';
import { JobRow, OfflinePrompt } from '@/components/app/biker/orders';
import { RowsSkeleton } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError } from '@/lib/kleano/client';
import { useBikerOrders, useBikerProfile, useCommission, useSetBikerStatus, useTotalWashes } from '@/lib/kleano/domains/biker';
import { cn } from '@/lib/utils';

/** The app's support number (biker-app home_screen.dart). */
const SUPPORT = 'https://wa.me/966533720654';

function Stat({ icon, label, loading, children }: { icon: React.ReactNode; label: string; loading: boolean; children: React.ReactNode }) {
  return (
    <div className="rounded-2xl border bg-card p-4">
      <span className="flex items-center gap-2 text-sm text-muted-foreground [&_svg]:size-4 [&_svg]:text-primary">
        {icon}
        <span className="truncate">{label}</span>
      </span>
      <div className="mt-2 text-2xl font-bold tracking-tight">{loading ? <Skeleton className="h-8 w-20" /> : children}</div>
    </div>
  );
}

export function BikerHome({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useBikerProfile();
  const commission = useCommission();
  const washes = useTotalWashes();
  const online = profile.data?.status === 'ONLINE';
  const orders = useBikerOrders('ACTIVE', online);
  const status = useSetBikerStatus();
  const rows = orders.data?.pages[0]?.data ?? [];
  const firstName = profile.data?.userName?.split(' ')[0];

  const toggle = () =>
    status.mutate(online ? 'OFFLINE' : 'ONLINE', {
      onError: (e) => toast.error(e instanceof ApiError ? e.message : t.common.error),
    });

  return (
    <div className="grid gap-4">
      <section className={cn('relative isolate overflow-hidden rounded-3xl p-5 text-white transition-colors duration-500 md:p-8', online ? 'bg-gradient-to-br from-[#6b3f80] via-[#543063] to-[#2c1838]' : 'bg-gradient-to-br from-[#3a3840] to-[#1c1b1e]')}>
        <span aria-hidden="true" className="absolute -end-16 -top-20 -z-10 size-64 rounded-full bg-white/10 blur-2xl" />
        <div className="flex flex-wrap items-end justify-between gap-5">
          <div className="grid gap-2">
            <span className="inline-flex w-fit items-center gap-2 rounded-full bg-white/15 px-3 py-1 text-sm font-medium">
              <span className={cn('size-2 rounded-full', online ? 'animate-pulse bg-[#30d158] motion-reduce:animate-none' : 'bg-white/50')} aria-hidden="true" />
              {profile.isPending ? '…' : online ? t.b.online : t.b.offline}
            </span>
            <h1 className="text-3xl font-bold text-balance md:text-4xl">
              {t.home.hello}
              {firstName ? `${locale === 'ar' ? '، ' : ', '}${firstName}` : ''}
            </h1>
            <p className="text-white/80">{online ? t.b.onlineBody : t.b.offlineBody}</p>
          </div>
          <Button size="xl" disabled={profile.isPending || status.isPending} onClick={toggle} className="w-full bg-white text-[#2c1838] hover:bg-white/90 sm:w-fit">
            {status.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {online ? t.b.goOffline : t.b.goOnline}
          </Button>
        </div>
      </section>

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Stat icon={<Banknote />} label={t.b.todayEarnings} loading={commission.isPending}>
          <Money value={commission.data?.today?.totalCommission} t={t} />
        </Stat>
        <Stat icon={<ClipboardList />} label={t.b.todayWashes} loading={commission.isPending}>
          <span className="tabular-nums">{commission.data?.today?.ordersCount ?? 0}</span>
        </Stat>
        <Stat icon={<CheckCircle2 />} label={t.b.completedWashes} loading={washes.isPending}>
          <span className="tabular-nums">{washes.data ?? 0}</span>
        </Stat>
        <Stat icon={<Star />} label={t.b.rating} loading={profile.isPending}>
          <span className="tabular-nums">{profile.data?.rating ?? '—'}</span>
        </Stat>
      </div>

      <div>
        <SectionTitle
          title={t.b.activeJobs}
          action={
            <Link href={`/${locale}/biker/orders`} className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline">
              {t.common.viewAll}
              <ArrowRight className="size-4 rtl:-scale-x-100" aria-hidden="true" />
            </Link>
          }
        />
        {profile.isPending || (online && orders.isPending) ? (
          <RowsSkeleton count={2} label={t.common.loading} />
        ) : !online ? (
          <OfflinePrompt t={t} />
        ) : orders.isError ? (
          <Failed message={orders.error.message} onRetry={() => orders.refetch()} t={t} />
        ) : rows.length === 0 ? (
          <Empty icon={<ClipboardList />} text={t.b.noActive} />
        ) : (
          <ul className="grid gap-3 lg:grid-cols-2">
            {rows.slice(0, 4).map((o) => (
              <li key={o._id}>
                <JobRow order={o} t={t} locale={locale} />
              </li>
            ))}
          </ul>
        )}
      </div>

      <a href={SUPPORT} target="_blank" rel="noreferrer" className="mt-2 flex items-center gap-3 rounded-2xl border bg-card p-4 transition hover:border-primary/40">
        <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
          <MessageCircle className="size-5" aria-hidden="true" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block font-semibold">{t.b.support}</span>
          <span className="block text-sm text-muted-foreground">{t.b.supportBody}</span>
        </span>
        <ArrowRight className="size-5 shrink-0 text-muted-foreground rtl:-scale-x-100" aria-hidden="true" />
      </a>
    </div>
  );
}
