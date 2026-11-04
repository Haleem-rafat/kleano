'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { Camera, Car, Check, Loader2, Pencil, Plus, Trash2 } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { Controller, useForm, useWatch } from 'react-hook-form';
import { toast } from 'sonner';
import { Empty, Failed, PageTitle } from '@/components/app/bits';
import { CarThumb } from '@/components/app/order-parts';
import { Field } from '@/components/app/field';
import { CardsSkeleton, Confirm, PickerField, Sheet } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import { HoverEffect } from '@/components/ui/card-hover-effect';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { shrinkImage } from '@/lib/image';
import { ApiError } from '@/lib/kleano/client';
import { useCarBrands, useCarModels, useDeleteVehicle, useSaveVehicle, useVehicles } from '@/lib/kleano/queries';
import type { Vehicle } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';
import { vehicleSchema, type VehicleForm } from '@/lib/validation';

/** The app's list (my_vehicles/data/model/color_model.dart). These are paint colours, not theme colours; the backend stores the English name. */
const paints: { name: string; swatch: string }[] = [
  { name: 'White', swatch: '#ffffff' },
  { name: 'Gray', swatch: '#9b9ba1' },
  { name: 'Red', swatch: '#e5383b' },
  { name: 'Black', swatch: '#111113' },
  { name: 'Blue', swatch: '#2f6fed' },
  { name: 'Green', swatch: '#2f9e44' },
  { name: 'Orange', swatch: '#f08c00' },
  { name: 'Yellow', swatch: '#fcc419' },
  { name: 'Purple', swatch: '#543063' },
];

export function CustomerCars({ t }: { t: AppDictionary; locale: Locale }) {
  const vehicles = useVehicles();
  const remove = useDeleteVehicle();
  const [target, setTarget] = useState<Vehicle | null>(null);
  const [editing, setEditing] = useState<Vehicle | 'new' | null>(null);

  const confirm = () => {
    if (!target) return;
    const id = target._id;
    setTarget(null);
    remove.mutate(id, {
      onSuccess: () => toast.success(t.cars.deleted),
      onError: (e) => toast.error(e.message),
    });
  };

  const add = (
    <Button size="chip" onClick={() => setEditing('new')}>
      <Plus />
      {t.cars.add}
    </Button>
  );

  return (
    <div>
      <PageTitle title={t.cars.title} action={add} />
      {vehicles.isPending ? (
        <CardsSkeleton label={t.common.loading} />
      ) : vehicles.isError ? (
        <Failed message={vehicles.error.message} onRetry={() => vehicles.refetch()} t={t} />
      ) : vehicles.data.length === 0 ? (
        <Empty icon={<Car />} text={t.cars.empty} action={add} />
      ) : (
        <HoverEffect
          className="-mx-2"
          items={vehicles.data.map((v) => ({
            id: v._id,
            content: (
              <div className="grid gap-4">
                <div className="flex items-start justify-between gap-3">
                  <CarThumb vehicle={v} t={t} />
                  <div className="flex gap-1">
                    <button
                      type="button"
                      onClick={() => setEditing(v)}
                      aria-label={`${t.cars.edit}: ${[v.brand, v.model].filter(Boolean).join(' ')}`}
                      className="grid size-10 place-items-center rounded-full text-muted-foreground transition hover:bg-muted hover:text-foreground"
                    >
                      <Pencil className="size-5" aria-hidden="true" />
                    </button>
                    <button
                      type="button"
                      onClick={() => setTarget(v)}
                      aria-label={`${t.cars.delete}: ${[v.brand, v.model].filter(Boolean).join(' ')}`}
                      className="grid size-10 place-items-center rounded-full text-muted-foreground transition hover:bg-destructive/10 hover:text-destructive"
                    >
                      <Trash2 className="size-5" aria-hidden="true" />
                    </button>
                  </div>
                </div>
                <div>
                  <h3 className="text-lg font-semibold">{[v.brand, v.model].filter(Boolean).join(' ')}</h3>
                  <p className="text-sm text-muted-foreground">{[v.color && (t.cars.colors[v.color as keyof AppDictionary['cars']['colors']] ?? v.color), v.type].filter(Boolean).join(' · ')}</p>
                </div>
                {v.plateNumber ? (
                  <span className="w-fit rounded-md border border-foreground/30 bg-muted/60 px-2.5 py-0.5 font-mono text-sm font-bold tracking-widest" dir="ltr">
                    {v.plateNumber}
                  </span>
                ) : null}
              </div>
            ),
          }))}
        />
      )}

      <Confirm
        open={Boolean(target)}
        onOpenChange={(open) => !open && setTarget(null)}
        title={t.cars.delete}
        description={t.cars.confirmDelete}
        confirmLabel={t.cars.delete}
        cancelLabel={t.cars.cancel}
        destructive
        onConfirm={confirm}
      />
      {editing ? <CarSheet key={editing === 'new' ? 'new' : editing._id} t={t} vehicle={editing === 'new' ? null : editing} onClose={() => setEditing(null)} /> : null}
    </div>
  );
}

/** Add or edit: POST or PUT /vehicles as multipart, with the same required fields as the app. */
function CarSheet({ t, vehicle, onClose }: { t: AppDictionary; vehicle: Vehicle | null; onClose: () => void }) {
  const save = useSaveVehicle();
  const brands = useCarBrands();
  const schema = useMemo(() => vehicleSchema(t), [t]);
  const {
    control,
    register,
    handleSubmit,
    setValue,
    formState: { errors },
  } = useForm<VehicleForm>({
    resolver: zodResolver(schema),
    defaultValues: { brand: vehicle?.brand ?? '', model: vehicle?.model ?? '', plateNumber: vehicle?.plateNumber ?? '', color: vehicle?.color ?? paints[0].name },
  });
  const brand = useWatch({ control, name: 'brand' });
  const color = useWatch({ control, name: 'color' });
  const brandId = brands.data?.find((b) => b.brand === brand)?._id;
  const models = useCarModels(brandId);
  const [photo, setPhoto] = useState<File | null>(null);
  const preview = useMemo(() => (photo ? URL.createObjectURL(photo) : vehicle?.imageLink), [photo, vehicle]);
  useEffect(() => () => {
    if (photo && preview) URL.revokeObjectURL(preview);
  }, [photo, preview]);

  const submit = handleSubmit(async (values) => {
    try {
      await save.mutateAsync({ id: vehicle?._id, input: { ...values, image: photo ? await shrinkImage(photo) : null } });
      toast.success(vehicle ? t.cars.updated : t.cars.added);
      onClose();
    } catch (e) {
      toast.error(e instanceof ApiError ? e.message : t.common.error);
    }
  });

  const pickerText = { searchLabel: t.signup.searchCountry, emptyText: t.signup.noResults, closeLabel: t.terms.close };

  return (
    <Sheet
      open
      onOpenChange={(open) => !open && onClose()}
      title={vehicle ? t.cars.edit : t.cars.addTitle}
      closeLabel={t.terms.close}
      footer={
        <Button size="xl" className="w-full" disabled={save.isPending} onClick={() => void submit()}>
          {save.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {vehicle ? t.cars.save : t.cars.add}
        </Button>
      }
    >
      <form onSubmit={submit} className="grid gap-5" noValidate>
        <label className="group relative grid aspect-[16/9] cursor-pointer place-items-center overflow-hidden rounded-2xl bg-muted">
          <input
            type="file"
            accept="image/*"
            className="sr-only"
            aria-label={t.cars.photo}
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) setPhoto(file);
            }}
          />
          {preview ? (
            // eslint-disable-next-line @next/next/no-img-element -- a local preview or the backend's storage
            <img src={preview} alt="" className="absolute inset-0 size-full object-cover" />
          ) : null}
          <span className={cn('relative inline-flex items-center gap-2 rounded-full bg-card px-4 py-2 text-sm font-medium shadow-input transition group-hover:bg-secondary', preview && 'absolute end-3 bottom-3')}>
            <Camera className="size-4" aria-hidden="true" />
            {t.cars.photo}
          </span>
        </label>

        <Controller
          control={control}
          name="brand"
          render={({ field }) => (
            <PickerField
              id="brand"
              label={t.cars.brand}
              value={field.value || undefined}
              placeholder={t.cars.chooseBrand}
              options={(brands.data ?? []).map((b) => ({ value: b.brand, label: b.brand }))}
              loading={brands.isPending}
              onChange={(v) => {
                field.onChange(v);
                setValue('model', '');
              }}
              error={errors.brand?.message}
              {...pickerText}
            />
          )}
        />
        <Controller
          control={control}
          name="model"
          render={({ field }) => (
            <PickerField
              id="model"
              label={t.cars.model}
              value={field.value || undefined}
              placeholder={t.cars.chooseModel}
              options={(models.data ?? []).map((m) => ({ value: m, label: m }))}
              loading={Boolean(brandId) && models.isPending}
              disabled={!brand}
              onChange={field.onChange}
              error={errors.model?.message}
              {...pickerText}
            />
          )}
        />
        <Controller
          control={control}
          name="plateNumber"
          render={({ field }) => (
            <Field
              id="plateNumber"
              label={t.cars.plateNumber}
              placeholder="AAA 123"
              dir="ltr"
              autoCapitalize="characters"
              autoComplete="off"
              name={field.name}
              ref={field.ref}
              onBlur={field.onBlur}
              value={field.value}
              // Same as the app's CarPlateFormatter: English letters and numbers, in capitals.
              onChange={(e) => field.onChange(e.target.value.replace(/[^a-zA-Z0-9]/g, '').toUpperCase())}
              error={errors.plateNumber?.message}
            />
          )}
        />
        <fieldset className="grid gap-2">
          <legend className="mb-2 text-sm font-medium">{t.cars.color}</legend>
          <input type="hidden" {...register('color')} />
          <div className="grid grid-cols-5 gap-3 sm:grid-cols-9 md:grid-cols-5">
            {paints.map((p) => (
              <button key={p.name} type="button" aria-pressed={color === p.name} onClick={() => setValue('color', p.name)} className="grid justify-items-center gap-1 text-xs text-muted-foreground">
                <span className={cn('grid size-10 place-items-center rounded-full border-2', color === p.name ? 'border-primary' : 'border-border')} style={{ background: p.swatch }}>
                  {color === p.name ? <Check className={cn('size-5', ['White', 'Yellow'].includes(p.name) ? 'text-black' : 'text-white')} aria-hidden="true" /> : null}
                </span>
                {t.cars.colors[p.name as keyof AppDictionary['cars']['colors']]}
              </button>
            ))}
          </div>
        </fieldset>
      </form>
    </Sheet>
  );
}
