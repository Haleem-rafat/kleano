'use client';

import { Car, Loader2, Trash2 } from 'lucide-react';
import { useState } from 'react';
import { toast } from 'sonner';
import { Empty, Failed, Loading, PageTitle } from '@/components/app/bits';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { HoverEffect } from '@/components/ui/card-hover-effect';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useDeleteVehicle, useVehicles } from '@/lib/kleano/queries';
import type { Vehicle } from '@/lib/kleano/types';

export function CustomerCars({ t }: { t: AppDictionary; locale: Locale }) {
  const vehicles = useVehicles();
  const remove = useDeleteVehicle();
  const [target, setTarget] = useState<Vehicle | null>(null);

  const confirm = () => {
    if (!target) return;
    remove.mutate(target._id, {
      onSuccess: () => toast.success(t.cars.deleted),
      onError: (e) => toast.error(e.message),
      onSettled: () => setTarget(null),
    });
  };

  return (
    <div>
      <PageTitle title={t.cars.title} subtitle={t.cars.addInApp} />
      {vehicles.isPending ? (
        <Loading label={t.common.loading} />
      ) : vehicles.isError ? (
        <Failed message={vehicles.error.message} onRetry={() => vehicles.refetch()} t={t} />
      ) : vehicles.data.length === 0 ? (
        <Empty icon={<Car />} text={t.cars.empty} />
      ) : (
        <HoverEffect
          className="-mx-2"
          items={vehicles.data.map((v) => ({
            id: v._id,
            content: (
              <div className="grid gap-4">
                <div className="flex items-start justify-between gap-3">
                  {v.imageLink ? (
                    // eslint-disable-next-line @next/next/no-img-element -- car photos come from the backend's storage
                    <img src={v.imageLink} alt="" className="size-16 rounded-xl object-cover" />
                  ) : (
                    <span className="grid size-16 place-items-center rounded-xl bg-secondary text-primary">
                      <Car className="size-8" aria-hidden="true" />
                    </span>
                  )}
                  <button
                    type="button"
                    onClick={() => setTarget(v)}
                    aria-label={`${t.cars.delete}: ${[v.brand, v.model].filter(Boolean).join(' ')}`}
                    className="grid size-10 place-items-center rounded-full text-muted-foreground transition hover:bg-destructive/10 hover:text-destructive"
                  >
                    <Trash2 className="size-5" aria-hidden="true" />
                  </button>
                </div>
                <div>
                  <h3 className="text-lg font-semibold">{[v.brand, v.model].filter(Boolean).join(' ')}</h3>
                  <p className="text-sm text-muted-foreground">{[v.color, v.type].filter(Boolean).join(' · ')}</p>
                </div>
                {v.plateNumber ? (
                  <span className="w-fit rounded-lg border-2 border-foreground/80 px-3 py-1 font-mono text-sm font-bold tracking-widest" dir="ltr">
                    {v.plateNumber}
                  </span>
                ) : null}
              </div>
            ),
          }))}
        />
      )}

      <AlertDialog open={Boolean(target)} onOpenChange={(open) => !open && setTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{t.cars.delete}</AlertDialogTitle>
            <AlertDialogDescription>{t.cars.confirmDelete}</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>{t.cars.cancel}</AlertDialogCancel>
            <AlertDialogAction onClick={(e) => { e.preventDefault(); confirm(); }} className="bg-destructive text-white hover:bg-destructive/90" disabled={remove.isPending}>
              {remove.isPending ? <Loader2 className="animate-spin" /> : null}
              {t.cars.delete}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
