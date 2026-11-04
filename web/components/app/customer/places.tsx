'use client';

import { Loader2, MapPin, MapPinned, Plus, Star, Trash2 } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { toast } from 'sonner';
import { Empty, Failed, PageTitle } from '@/components/app/bits';
import { Confirm, RowsSkeleton } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useClearPlaces, useDeletePlace, useSavedLocations, useSetDefaultPlace } from '@/lib/kleano/queries';
import { cityName, type Location } from '@/lib/kleano/types';

/** Same rules as the app's SavedLocationsScreen: the default place has no delete button. */
export function CustomerPlaces({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const saved = useSavedLocations();
  const setDefault = useSetDefaultPlace();
  const remove = useDeletePlace();
  const clear = useClearPlaces();
  const [target, setTarget] = useState<Location | null>(null);
  const [clearing, setClearing] = useState(false);
  const addHref = `/${locale}/app/places/new`;
  const add = (
    <Button asChild size="chip">
      <Link href={addHref}>
        <Plus />
        {t.places.add}
      </Link>
    </Button>
  );

  return (
    <div>
      <PageTitle
        title={t.places.title}
        action={
          <div className="flex flex-wrap gap-2">
            {saved.data?.length ? (
              <Button variant="destructive" size="chip" onClick={() => setClearing(true)}>
                {t.places.clearAll}
              </Button>
            ) : null}
            {add}
          </div>
        }
      />

      {saved.isPending ? (
        <RowsSkeleton label={t.common.loading} />
      ) : saved.isError ? (
        <Failed message={saved.error.message} onRetry={() => saved.refetch()} t={t} />
      ) : saved.data.length === 0 ? (
        <Empty icon={<MapPinned />} text={t.places.empty} action={add} />
      ) : (
        <ul className="grid gap-3 lg:grid-cols-2">
          {saved.data.map((l) => (
            <li key={l._id} className="flex flex-wrap items-center gap-3 rounded-[var(--radius-card)] border bg-card p-4">
              <span className="grid size-11 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
                <MapPin className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0 flex-1 basis-40">
                <p className="truncate font-semibold">{l.savedName || l.streetName}</p>
                <p className="truncate text-sm text-muted-foreground">{[l.streetName, cityName(l.city, locale)].filter(Boolean).join(' · ')}</p>
              </div>
              {l.isDefault ? (
                <span className="inline-flex h-8 items-center gap-1 rounded-full bg-secondary px-3 text-xs font-semibold text-secondary-foreground">
                  <Star className="size-3.5 fill-current" aria-hidden="true" />
                  {t.places.defaultLabel}
                </span>
              ) : (
                <div className="flex items-center gap-1">
                  <Button
                    variant="ghost"
                    size="chip"
                    onClick={() =>
                      setDefault.mutate(l._id, {
                        onSuccess: () => toast.success(t.places.defaultSet),
                        onError: (e) => toast.error(e.message),
                      })
                    }
                  >
                    {t.places.setDefault}
                  </Button>
                  <button
                    type="button"
                    onClick={() => setTarget(l)}
                    aria-label={`${t.places.delete}: ${l.savedName ?? ''}`}
                    className="grid size-10 place-items-center rounded-full text-muted-foreground transition hover:bg-destructive/10 hover:text-destructive"
                  >
                    <Trash2 className="size-5" aria-hidden="true" />
                  </button>
                </div>
              )}
            </li>
          ))}
        </ul>
      )}

      {clear.isPending ? <Loader2 className="mx-auto mt-4 size-5 animate-spin text-muted-foreground" aria-hidden="true" /> : null}

      <Confirm
        open={Boolean(target)}
        onOpenChange={(open) => !open && setTarget(null)}
        title={t.places.delete}
        description={t.places.deleteBody}
        confirmLabel={t.cars.delete}
        cancelLabel={t.cars.cancel}
        destructive
        onConfirm={() => {
          if (!target) return;
          remove.mutate(target._id, { onSuccess: () => toast.success(t.places.deleted), onError: (e) => toast.error(e.message) });
          setTarget(null);
        }}
      />
      <Confirm
        open={clearing}
        onOpenChange={setClearing}
        title={t.places.clearAll}
        description={t.places.clearBody}
        confirmLabel={t.places.clearAll}
        cancelLabel={t.cars.cancel}
        destructive
        onConfirm={() => {
          clear.mutate(undefined, { onSuccess: () => toast.success(t.places.cleared), onError: (e) => toast.error(e.message) });
          setClearing(false);
        }}
      />
    </div>
  );
}
