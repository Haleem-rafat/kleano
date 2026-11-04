'use client';

import { ArrowRight, CheckCircle2, ClipboardList, Loader2, MapPin, Power } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { Empty, Failed, Money, PageTitle, StatusBadge, formatWhen } from '@/components/app/bits';
import { RowsSkeleton, Segmented } from '@/components/app/kit';
import { CarThumb, OrderProgress } from '@/components/app/order-parts';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useBikerOrders, useBikerProfile, useSetBikerStatus, type BikerList, type BikerOrder } from '@/lib/kleano/domains/biker';
import { ApiError } from '@/lib/kleano/client';
import { localized } from '@/lib/kleano/types';
import { toast } from 'sonner';

/** One job in a list: what to wash, for whom, when and where. */
export function JobRow({ order, t, locale }: { order: BikerOrder; t: AppDictionary; locale: Locale }) {
  const car = [order.vehicle?.brand, order.vehicle?.model].filter(Boolean).join(' ');
  return (
    <Link href={`/${locale}/biker/orders/${order._id}`} className="group flex gap-3 rounded-2xl border bg-card p-4 transition hover:border-primary/40 hover:shadow-input">
      <CarThumb vehicle={order.vehicle} />
      <div className="grid min-w-0 flex-1 gap-1.5">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <p className="min-w-0 truncate font-semibold">{localized(order.washingServices?.[0]?.name, locale) || '—'}</p>
          <StatusBadge status={order.status} t={t} label={t.b.status[order.status as keyof AppDictionary['b']['status']]} />
        </div>
        <p className="text-sm text-muted-foreground">{[formatWhen(order.startTime, locale), car].filter(Boolean).join(' · ')}</p>
        <div className="flex items-center justify-between gap-3">
          <span className="flex min-w-0 items-center gap-1.5 text-sm text-muted-foreground">
            <MapPin className="size-4 shrink-0 text-primary" aria-hidden="true" />
            <span className="truncate">{order.location?.streetName}</span>
          </span>
          <span className="flex shrink-0 items-center gap-2">
            <Money value={order.totalPay ?? order.totalPrice} t={t} className="font-bold" />
            <ArrowRight className="size-5 text-muted-foreground transition group-hover:text-primary rtl:-scale-x-100" aria-hidden="true" />
          </span>
        </div>
        {order.status !== 'COMPLETED' ? <OrderProgress status={order.status} t={t} compact className="mt-1" /> : null}
      </div>
    </Link>
  );
}

/** Offline bikers get no jobs: say so and offer the switch, as HomeOfflinePrompt does. */
export function OfflinePrompt({ t }: { t: AppDictionary }) {
  const status = useSetBikerStatus();
  return (
    <Empty
      icon={<Power />}
      text={t.b.offlineBody}
      action={
        <Button size="chip" disabled={status.isPending} onClick={() => status.mutate('ONLINE', { onError: (e) => toast.error(e instanceof ApiError ? e.message : t.common.error) })}>
          {status.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {t.b.goOnline}
        </Button>
      }
    />
  );
}

export function BikerOrders({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const [list, setList] = useState<BikerList>('ACTIVE');
  const profile = useBikerProfile();
  const online = profile.data?.status === 'ONLINE';
  const orders = useBikerOrders(list, online);
  const rows = orders.data?.pages.flatMap((p) => p.data ?? []) ?? [];
  return (
    <div>
      <PageTitle title={t.nav.orders} />
      {profile.isPending ? (
        <RowsSkeleton label={t.common.loading} />
      ) : !online ? (
        <OfflinePrompt t={t} />
      ) : (
        <>
          <Segmented
            value={list}
            label={t.nav.orders}
            className="mb-6"
            options={[
              { value: 'ACTIVE', label: t.b.active },
              { value: 'COMPLETED', label: t.b.completed },
            ]}
            onChange={setList}
          />
          {orders.isPending ? (
            <RowsSkeleton label={t.common.loading} />
          ) : orders.isError ? (
            <Failed message={orders.error.message} onRetry={() => orders.refetch()} t={t} />
          ) : rows.length === 0 ? (
            <Empty icon={list === 'ACTIVE' ? <ClipboardList /> : <CheckCircle2 />} text={list === 'ACTIVE' ? t.b.noActive : t.b.noCompleted} />
          ) : (
            <ul className="grid gap-3 lg:grid-cols-2">
              {rows.map((o) => (
                <li key={o._id}>
                  <JobRow order={o} t={t} locale={locale} />
                </li>
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
        </>
      )}
    </div>
  );
}
