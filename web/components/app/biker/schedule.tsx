'use client';

import { CalendarOff, CalendarX, Clock, MapPin } from 'lucide-react';
import { Empty, Failed, PageTitle } from '@/components/app/bits';
import { RowsSkeleton } from '@/components/app/kit';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useSchedule } from '@/lib/kleano/domains/biker';
import { localized } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

const DAYS = ['saturday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday'] as const;

/** The week as the biker's manager set it: shifts per day, and days off. */
export function BikerSchedule({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const schedule = useSchedule();
  const shifts = schedule.data?.shifts ?? [];
  const weekends = (schedule.data?.weekends ?? []).map((d) => d.toLowerCase());
  return (
    <div>
      <PageTitle title={t.nav.schedule} />
      {schedule.isPending ? (
        <RowsSkeleton label={t.common.loading} />
      ) : schedule.isError ? (
        <Failed message={schedule.error.message} onRetry={() => schedule.refetch()} t={t} />
      ) : !shifts.length && !weekends.length ? (
        <Empty icon={<CalendarX />} text={t.b.noSchedule} />
      ) : (
        <ul className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {DAYS.map((day) => {
            const off = weekends.includes(day);
            const today = shifts.filter((s) => s.day?.toLowerCase() === day);
            return (
              <li key={day} className={cn('grid content-start gap-3 rounded-2xl border bg-card p-4', off && 'bg-muted/40')}>
                <div className="flex items-center justify-between gap-2">
                  <h2 className="font-semibold">{t.b.days[day]}</h2>
                  {off ? (
                    <span className="inline-flex items-center gap-1.5 rounded-full bg-muted px-2.5 py-1 text-xs font-medium text-muted-foreground">
                      <CalendarOff className="size-3.5" aria-hidden="true" />
                      {t.b.weekend}
                    </span>
                  ) : null}
                </div>
                {today.length ? (
                  <ul className="grid gap-2">
                    {today.map((s, i) => (
                      <li key={i} className="grid gap-1 rounded-xl bg-secondary/60 p-3 text-sm">
                        <span className="flex items-center gap-1.5 font-semibold" dir="ltr">
                          <Clock className="size-3.5 text-primary" aria-hidden="true" />
                          {s.timeSlot}
                        </span>
                        <span className="flex items-center gap-1.5 text-muted-foreground">
                          <MapPin className="size-3.5 shrink-0" aria-hidden="true" />
                          {[localized(s.area?.name, locale), localized(s.city?.name, locale)].filter(Boolean).join(' · ')}
                        </span>
                      </li>
                    ))}
                  </ul>
                ) : off ? null : (
                  <p className="text-sm text-muted-foreground">{t.b.noShifts}</p>
                )}
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
