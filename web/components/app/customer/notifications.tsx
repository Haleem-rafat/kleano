'use client';

import { BellOff, BellRing, CalendarCheck, Loader2, TicketPercent } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { Empty, Failed, PageTitle, formatWhen } from '@/components/app/bits';
import { RowsSkeleton, Switch } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useNotificationPermission, useNotifications, useProfile, useReadNotification } from '@/lib/kleano/queries';
import type { KleanoNotification } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

export function CustomerNotifications({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const router = useRouter();
  const profile = useProfile();
  const permission = useNotificationPermission();
  const notifications = useNotifications();
  const read = useReadNotification();
  const list = notifications.data?.pages.flatMap((p) => p.data ?? []) ?? [];

  const open = (n: KleanoNotification) => {
    if (!n.isRead) read.mutate(n._id);
    if (n.orderId) router.push(`/${locale}/app/bookings/${n.orderId}`);
  };

  return (
    <div>
      <PageTitle title={t.alerts.title} />

      <section className="mb-6 flex items-center gap-4 rounded-[var(--radius-card)] border bg-card p-5">
        <div className="min-w-0 flex-1">
          <p className="font-semibold">{t.alerts.enable}</p>
          <p className="text-sm text-muted-foreground">{t.alerts.enableBody}</p>
          <p className="mt-1 text-xs text-muted-foreground">{t.alerts.browserNote}</p>
        </div>
        <Switch
          checked={profile.data?.isAllowNotification ?? false}
          disabled={profile.isPending}
          label={t.alerts.enable}
          onChange={(on) => permission.mutate(on, { onError: (e) => toast.error(e.message) })}
        />
      </section>

      {notifications.isPending ? (
        <RowsSkeleton label={t.common.loading} />
      ) : notifications.isError ? (
        <Failed message={notifications.error.message} onRetry={() => notifications.refetch()} t={t} />
      ) : list.length === 0 ? (
        <Empty icon={<BellOff />} text={t.alerts.empty} />
      ) : (
        <ul className="grid gap-3">
          {list.map((n) => {
            const title = locale === 'ar' ? n.message?.arTitle : n.message?.enTitle;
            const body = locale === 'ar' ? n.message?.arBody : n.message?.enBody;
            const Icon = n.orderId ? CalendarCheck : n.type?.includes('PROMO') ? TicketPercent : BellRing;
            return (
              <li key={n._id}>
                <button type="button" onClick={() => open(n)} className={cn('flex w-full items-start gap-4 rounded-2xl border bg-card p-4 text-start transition hover:border-primary/40', !n.isRead && 'border-primary/50')}>
                  <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
                    <Icon className="size-5" aria-hidden="true" />
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="flex items-center gap-2">
                      <span className={cn('min-w-0 truncate', n.isRead ? 'font-medium' : 'font-bold')}>{title}</span>
                      {!n.isRead ? <span className="size-2 shrink-0 rounded-full bg-primary" aria-hidden="true" /> : null}
                    </span>
                    {body ? <span className="block text-sm text-muted-foreground">{body}</span> : null}
                    <span className="mt-1 block text-xs text-muted-foreground">{formatWhen(n.createdAt, locale)}</span>
                  </span>
                </button>
              </li>
            );
          })}
        </ul>
      )}

      {notifications.hasNextPage ? (
        <div className="mt-6 flex justify-center">
          <Button variant="outline" size="chip" onClick={() => notifications.fetchNextPage()} disabled={notifications.isFetchingNextPage}>
            {notifications.isFetchingNextPage ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {t.common.loadMore}
          </Button>
        </div>
      ) : null}
    </div>
  );
}
