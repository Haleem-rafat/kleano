'use client';

import { ArrowRight, CalendarX, Car, ClipboardList, Loader2 } from 'lucide-react';
import { motion } from 'motion/react';
import Link from 'next/link';
import { useState } from 'react';
import { Empty, Failed, Money, PageTitle, StatusBadge, formatWhen } from '@/components/app/bits';
import { BookingDetails } from '@/components/app/customer/booking-details';
import { RowsSkeleton, Segmented, Sheet } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useOrders } from '@/lib/kleano/queries';
import { localized, type OrderGroup } from '@/lib/kleano/types';
import { useMedia } from '@/lib/use-media';
import { cn } from '@/lib/utils';

const groups: OrderGroup[] = ['ACTIVE', 'SCHEDULED', 'HISTORY'];

/** Master and detail side by side on desktop, a slide-over on tablet, its own page on phones. */
export function CustomerBookings({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const [group, setGroup] = useState<OrderGroup>('ACTIVE');
  const [selected, setSelected] = useState<string | null>(null);
  const orders = useOrders(group);
  const list = orders.data?.pages.flatMap((p) => p.data ?? []) ?? [];
  const desktop = useMedia('(min-width: 1280px)');
  const tablet = useMedia('(min-width: 768px)');

  const master = (
    <div className="min-w-0">
      <Segmented
        value={group}
        label={t.bookings.title}
        className="mb-6"
        options={groups.map((g) => ({ value: g, label: t.bookings.tabs[g] }))}
        onChange={(g) => {
          setGroup(g);
          setSelected(null);
        }}
      />

      {orders.isPending ? (
        <RowsSkeleton label={t.common.loading} />
      ) : orders.isError ? (
        <Failed message={orders.error.message} onRetry={() => orders.refetch()} t={t} />
      ) : list.length === 0 ? (
        <Empty
          icon={<CalendarX />}
          text={t.bookings.empty[group]}
          action={
            <Button asChild size="chip">
              <Link href={`/${locale}/app/book`}>{t.home.bookNow}</Link>
            </Button>
          }
        />
      ) : (
        <ul className="grid gap-3">
          {list.map((o, i) => (
            <motion.li key={o._id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: Math.min(i, 8) * 0.03 }}>
              <Link
                href={`/${locale}/app/bookings/${o._id}`}
                aria-current={desktop && selected === o._id ? 'true' : undefined}
                onClick={(e) => {
                  if (!tablet || e.metaKey || e.ctrlKey) return;
                  e.preventDefault();
                  setSelected(o._id);
                }}
                className={cn(
                  'group flex items-center gap-4 rounded-2xl border bg-card p-4 transition hover:border-primary/40 hover:shadow-input',
                  desktop && selected === o._id && 'border-primary',
                )}
              >
                <span className="hidden size-12 shrink-0 place-items-center rounded-xl bg-secondary text-primary sm:grid">
                  <Car className="size-6" aria-hidden="true" />
                </span>
                <div className="grid min-w-0 flex-1 gap-1">
                  <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                    <p className="min-w-0 truncate font-semibold">{localized(o.washingServices?.[0]?.name, locale) || '—'}</p>
                    <StatusBadge status={o.status} t={t} />
                  </div>
                  <p className="line-clamp-2 text-sm text-muted-foreground">
                    {[formatWhen(o.startTime, locale), [o.vehicle?.brand, o.vehicle?.model].filter(Boolean).join(' ')].filter(Boolean).join(' · ')}
                  </p>
                </div>
                <div className={cn('hidden text-end sm:block', desktop && 'xl:hidden')}>
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
            {orders.isFetchingNextPage ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {t.common.loadMore}
          </Button>
        </div>
      ) : null}
    </div>
  );

  return (
    <div>
      <PageTitle title={t.bookings.title} />
      {desktop ? (
        <div className="grid grid-cols-[minmax(0,5fr)_minmax(0,7fr)] items-start gap-6">
          {master}
          <div className="sticky top-24 max-h-[calc(100dvh-7rem)] min-w-0 overflow-y-auto">
            {selected ? (
              <BookingDetails key={selected} id={selected} t={t} locale={locale} embedded />
            ) : (
              <Empty icon={<ClipboardList />} text={t.order.selectHint} />
            )}
          </div>
        </div>
      ) : (
        master
      )}
      {tablet && !desktop && selected ? (
        <Sheet open onOpenChange={(open) => !open && setSelected(null)} title={t.bookings.details} closeLabel={t.terms.close} wide>
          <BookingDetails key={selected} id={selected} t={t} locale={locale} embedded />
        </Sheet>
      ) : null}
    </div>
  );
}
