'use client';

import { CalendarDays, CheckCircle2, Wallet } from 'lucide-react';
import { BalanceCard, Empty, Failed, Money, PageTitle } from '@/components/app/bits';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import { useCommission, useTotalWashes } from '@/lib/kleano/domains/biker';

export function BikerEarnings({ t }: { t: AppDictionary }) {
  const commission = useCommission();
  const washes = useTotalWashes();
  const count = (n?: number) => (
    <span className="text-sm opacity-80">
      <span className="tabular-nums">{n ?? 0}</span> {t.b.washes}
    </span>
  );
  return (
    <div>
      <PageTitle title={t.nav.earnings} />
      {commission.isError ? (
        <Failed message={commission.error.message} onRetry={() => commission.refetch()} t={t} />
      ) : commission.isSuccess && !commission.data?.allTime?.ordersCount ? (
        <Empty icon={<Wallet />} text={t.progress.noEarnings} />
      ) : (
        <div className="grid gap-4 lg:grid-cols-[3fr_2fr]">
          <BalanceCard icon={<Wallet />} label={t.b.allTime} className="min-h-52 content-between">
            {commission.isPending ? <Skeleton className="h-12 w-44 bg-white/20" /> : <Money value={commission.data?.allTime?.totalCommission} t={t} className="text-5xl font-bold tracking-tight" />}
            {count(commission.data?.allTime?.ordersCount)}
          </BalanceCard>
          <div className="grid gap-4">
            {[
              { label: t.b.today, icon: CalendarDays, data: commission.data?.today },
              { label: t.b.weekends, icon: CalendarDays, data: commission.data?.allWeekends },
            ].map((p) => (
              <section key={p.label} className="flex items-center justify-between gap-3 rounded-2xl border bg-card p-4">
                <div className="grid gap-1">
                  <span className="flex items-center gap-2 text-sm text-muted-foreground">
                    <p.icon className="size-4 text-primary" aria-hidden="true" />
                    {p.label}
                  </span>
                  <span className="text-muted-foreground">{count(p.data?.ordersCount)}</span>
                </div>
                {commission.isPending ? <Skeleton className="h-8 w-20" /> : <Money value={p.data?.totalCommission} t={t} className="text-2xl font-bold" />}
              </section>
            ))}
            <section className="flex items-center justify-between gap-3 rounded-2xl border bg-card p-4">
              <span className="flex items-center gap-2 text-sm text-muted-foreground">
                <CheckCircle2 className="size-4 text-primary" aria-hidden="true" />
                {t.b.completedWashes}
              </span>
              {washes.isPending ? <Skeleton className="h-8 w-14" /> : <span className="text-2xl font-bold tabular-nums">{washes.data ?? 0}</span>}
            </section>
          </div>
        </div>
      )}
    </div>
  );
}
