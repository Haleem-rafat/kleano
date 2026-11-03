'use client';

import { ArrowRight, CalendarX, Car, Loader2 } from 'lucide-react';
import { motion } from 'motion/react';
import Link from 'next/link';
import { useState } from 'react';
import { Empty, Failed, Loading, Money, PageTitle, StatusBadge, formatWhen } from '@/components/app/bits';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useOrders } from '@/lib/kleano/queries';
import { localized, type OrderGroup } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

const groups: OrderGroup[] = ['ACTIVE', 'SCHEDULED', 'HISTORY'];

export function CustomerBookings({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const [group, setGroup] = useState<OrderGroup>('ACTIVE');
  const orders = useOrders(group);
  const list = orders.data?.pages.flatMap((p) => p.data ?? []) ?? [];

  return (
    <div>
      <PageTitle title={t.bookings.title} />

      {/* Aceternity-style pill tabs: the highlight slides to the chosen tab. */}
      <div role="tablist" aria-label={t.bookings.title} className="mb-6 inline-flex rounded-full bg-muted p-1">
        {groups.map((g) => (
          <button
            key={g}
            role="tab"
            type="button"
            aria-selected={group === g}
            onClick={() => setGroup(g)}
            className="relative rounded-full px-4 py-2 text-sm font-medium"
          >
            {group === g ? (
              <motion.span layoutId="bookings-tab" className="absolute inset-0 rounded-full bg-card shadow-sm" transition={{ type: 'spring', bounce: 0.25, duration: 0.5 }} />
            ) : null}
            <span className={cn('relative', group === g ? 'text-foreground' : 'text-muted-foreground')}>{t.bookings.tabs[g]}</span>
          </button>
        ))}
      </div>

      {orders.isPending ? (
        <Loading label={t.common.loading} />
      ) : orders.isError ? (
        <Failed message={orders.error.message} onRetry={() => orders.refetch()} t={t} />
      ) : list.length === 0 ? (
        <Empty icon={<CalendarX />} text={t.bookings.empty[group]} />
      ) : (
        <ul className="grid gap-3">
          {list.map((o, i) => (
            <motion.li key={o._id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: Math.min(i, 8) * 0.03 }}>
              <Link
                href={`/${locale}/app/bookings/${o._id}`}
                className="group flex items-center gap-4 rounded-2xl border border-border bg-card p-4 transition hover:border-primary/40 hover:shadow-input"
              >
                <span className="grid size-12 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
                  <Car className="size-6" aria-hidden="true" />
                </span>
                <div className="grid min-w-0 flex-1 gap-1">
                  <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                    <p className="truncate font-semibold">{localized(o.washingServices?.[0]?.name, locale) || '—'}</p>
                    <StatusBadge status={o.status} t={t} />
                  </div>
                  <p className="truncate text-sm text-muted-foreground">
                    {[formatWhen(o.startTime, locale), [o.vehicle?.brand, o.vehicle?.model].filter(Boolean).join(' ')].filter(Boolean).join(' · ')}
                  </p>
                </div>
                <div className="hidden text-end sm:block">
                  <Money value={o.totalPay ?? o.totalPrice} t={t} className="font-bold" />
                </div>
                <ArrowRight className="size-5 shrink-0 text-muted-foreground transition group-hover:text-primary rtl:-scale-x-100" aria-hidden="true" />
              </Link>
            </motion.li>
          ))}
        </ul>
      )}

      {orders.hasNextPage ? (
        <div className="mt-6 flex justify-center">
          <Button variant="outline" size="chip" onClick={() => orders.fetchNextPage()} disabled={orders.isFetchingNextPage}>
            {orders.isFetchingNextPage ? <Loader2 className="animate-spin" /> : null}
            {t.common.loadMore}
          </Button>
        </div>
      ) : null}
    </div>
  );
}
