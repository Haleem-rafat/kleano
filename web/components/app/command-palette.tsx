'use client';

import { useQueryClient, type InfiniteData } from '@tanstack/react-query';
import { Car, ClipboardList, MapPin, Plus, Search, type LucideIcon } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { Dialog as DialogPrimitive } from 'radix-ui';
import { useMemo, useState } from 'react';
import { customerNav } from '@/components/app/app-shell';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { localized, type Location, type Order, type Paged, type Vehicle } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

type Entry = { id: string; label: string; hint?: string; href: string; icon: LucideIcon };

/** Cmd+K and "/": jump to any screen, or to a car, place or booking already loaded. Esc closes it. */
export function CommandPalette({ open, onOpenChange, locale, t }: { open: boolean; onOpenChange: (open: boolean) => void; locale: Locale; t: AppDictionary }) {
  const router = useRouter();
  const qc = useQueryClient();
  const [query, setQuery] = useState('');
  const [active, setActive] = useState(0);
  const base = `/${locale}/app`;

  const entries = useMemo<Entry[]>(() => {
    if (!open) return [];
    const pages: Entry[] = [
      { id: 'book', label: t.home.bookNow, href: `${base}/book`, icon: Plus },
      ...customerNav(locale, t).map((n) => ({ id: n.href, label: n.label, href: n.href, icon: n.icon })),
    ];
    const cars = (qc.getQueryData<Vehicle[]>(['vehicles']) ?? []).map<Entry>((v) => ({
      id: v._id,
      label: [v.brand, v.model].filter(Boolean).join(' '),
      hint: v.plateNumber,
      href: `${base}/cars`,
      icon: Car,
    }));
    const places = (qc.getQueryData<Location[]>(['saved-locations']) ?? []).map<Entry>((l) => ({
      id: l._id,
      label: l.savedName || l.streetName || '',
      hint: l.streetName,
      href: `${base}/places`,
      icon: MapPin,
    }));
    const bookings = (['ACTIVE', 'SCHEDULED', 'HISTORY'] as const)
      .flatMap((g) => qc.getQueryData<InfiniteData<Paged<Order>>>(['orders', g])?.pages.flatMap((p) => p.data ?? []) ?? [])
      .map<Entry>((o) => ({ id: o._id, label: localized(o.washingServices?.[0]?.name, locale) || t.nav.bookings, hint: t.status[o.status], href: `${base}/bookings/${o._id}`, icon: ClipboardList }));
    return [...pages, ...cars, ...places, ...bookings];
  }, [open, qc, base, locale, t]);

  const found = useMemo(() => {
    const q = query.trim().toLowerCase();
    return q ? entries.filter((e) => `${e.label} ${e.hint ?? ''}`.toLowerCase().includes(q)) : entries;
  }, [entries, query]);

  const go = (entry: Entry | undefined) => {
    if (!entry) return;
    close(false);
    router.push(entry.href);
  };
  const close = (next: boolean) => {
    if (!next) {
      setQuery('');
      setActive(0);
    }
    onOpenChange(next);
  };

  return (
    <DialogPrimitive.Root open={open} onOpenChange={close}>
      <DialogPrimitive.Portal>
        <DialogPrimitive.Overlay className="fixed inset-0 z-50 bg-black/50" />
        <DialogPrimitive.Content aria-describedby={undefined} className="fixed inset-x-4 top-[12vh] z-50 mx-auto max-w-xl overflow-hidden rounded-[var(--radius-card)] border bg-popover text-popover-foreground shadow-xl outline-none">
          <DialogPrimitive.Title className="sr-only">{t.palette.title}</DialogPrimitive.Title>
          <div className="flex items-center gap-3 border-b px-4">
            <Search className="size-5 shrink-0 text-muted-foreground" aria-hidden="true" />
            <input
              autoFocus
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setActive(0);
              }}
              onKeyDown={(e) => {
                if (e.key === 'ArrowDown') {
                  e.preventDefault();
                  setActive((i) => Math.min(i + 1, found.length - 1));
                } else if (e.key === 'ArrowUp') {
                  e.preventDefault();
                  setActive((i) => Math.max(i - 1, 0));
                } else if (e.key === 'Enter') {
                  e.preventDefault();
                  go(found[active]);
                }
              }}
              placeholder={t.palette.placeholder}
              aria-label={t.palette.placeholder}
              className="h-14 w-full bg-transparent text-base outline-none placeholder:text-muted-foreground"
            />
          </div>
          {found.length === 0 ? (
            <p className="px-4 py-10 text-center text-muted-foreground">{t.signup.noResults}</p>
          ) : (
            <ul className="max-h-[50vh] overflow-y-auto p-2">
              {found.map((e, i) => (
                <li key={e.id}>
                  <button
                    type="button"
                    onMouseEnter={() => setActive(i)}
                    onClick={() => go(e)}
                    className={cn('flex min-h-11 w-full items-center gap-3 rounded-xl px-3 py-2 text-start', i === active && 'bg-muted')}
                  >
                    <e.icon className="size-4.5 shrink-0 text-primary" aria-hidden="true" />
                    <span className="min-w-0 flex-1 truncate">{e.label}</span>
                    {e.hint ? <span className="max-w-[40%] shrink-0 truncate text-sm text-muted-foreground">{e.hint}</span> : null}
                  </button>
                </li>
              ))}
            </ul>
          )}
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  );
}
