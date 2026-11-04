'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { useQueryClient } from '@tanstack/react-query';
import { Bell, Camera, Coins, CreditCard, Info, Languages, Loader2, LogOut, Mail, MapPin, Moon, Pencil, Phone, TicketPercent, Trash2, Wallet } from 'lucide-react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useTheme } from 'next-themes';
import { useEffect, useMemo, useState } from 'react';
import { Controller, useForm } from 'react-hook-form';
import { toast } from 'sonner';
import { Failed, Money, PageTitle, SectionTitle } from '@/components/app/bits';
import { Field } from '@/components/app/field';
import { Confirm, PickerField, Row, RowGroup, Segmented, Sheet } from '@/components/app/kit';
import { PhoneField } from '@/components/app/phone-field';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { shrinkImage } from '@/lib/image';
import { ApiError, authApi } from '@/lib/kleano/client';
import { accountApi } from '@/lib/kleano/domains/account';
import { useChangePhone, useDeleteAccount, useProfile, useUpdateProfile } from '@/lib/kleano/queries';
import type { Profile } from '@/lib/kleano/types';
import { useMedia } from '@/lib/use-media';
import { buildInternationalPhone, cleanPhoneInput, defaultDialCode } from '@/lib/phone';
import { phoneSchema, profileSchema, type PhoneForm, type ProfileForm } from '@/lib/validation';

function Avatar({ profile, size }: { profile: Profile; size: 'lg' | 'sm' }) {
  const initials = profile.userName?.trim().split(/\s+/).map((w) => w[0]).slice(0, 2).join('') ?? '';
  const px = size === 'lg' ? 64 : 48;
  const box = size === 'lg' ? 'size-16 text-xl' : 'size-12 text-base';
  if (profile.imageLink) {
    // eslint-disable-next-line @next/next/no-img-element -- profile photo from the backend's storage
    return <img src={profile.imageLink} alt="" width={px} height={px} className={`${box} rounded-full object-cover`} />;
  }
  return <span className={`${box} grid shrink-0 place-items-center rounded-full bg-primary font-bold text-primary-foreground`}>{initials}</span>;
}

export function CustomerAccount({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  const router = useRouter();
  const pathname = usePathname();
  const qc = useQueryClient();
  const remove = useDeleteAccount();
  const { theme, setTheme } = useTheme();
  const mounted = useMedia('all');
  const [editing, setEditing] = useState(false);
  const [changingPhone, setChangingPhone] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [leaving, setLeaving] = useState(false);
  const base = `/${locale}/app`;

  if (profile.isError) return <Failed message={profile.error.message} onRetry={() => profile.refetch()} t={t} />;
  const p = profile.data;

  const logout = async () => {
    setLeaving(true);
    try {
      await authApi.logout('customer');
    } finally {
      qc.clear();
      router.replace(`${base}/login`);
      router.refresh();
    }
  };

  const language = (next: Locale) => {
    if (next === locale) return;
    void accountApi.language(next).catch(() => undefined);
    router.push(`/${next}${pathname.slice(3)}`);
  };

  return (
    <div>
      <PageTitle title={t.profile.title} />

      <section className="mb-4 flex flex-wrap items-center gap-4 rounded-[var(--radius-card)] border bg-card p-5">
        {p ? <Avatar profile={p} size="lg" /> : <Skeleton className="size-16 rounded-full" />}
        <div className="min-w-0 flex-1 basis-40">
          {p ? (
            <>
              <p className="truncate text-xl font-semibold">{p.userName}</p>
              {p.email ? (
                <p className="flex items-center gap-1.5 text-sm text-muted-foreground">
                  <Mail className="size-4 shrink-0" aria-hidden="true" />
                  <span className="truncate">{p.email}</span>
                </p>
              ) : null}
              <p className="text-sm text-muted-foreground">{[p.gender === 'Male' ? t.profile.male : p.gender === 'Female' ? t.profile.female : '', p.dob].filter(Boolean).join(' · ')}</p>
            </>
          ) : (
            <div className="grid gap-2">
              <Skeleton className="h-6 w-40" />
              <Skeleton className="h-4 w-52" />
            </div>
          )}
        </div>
        <Button variant="outline" size="chip" disabled={!p} onClick={() => setEditing(true)}>
          <Pencil />
          {t.profile.edit}
        </Button>
      </section>

      <div className="grid grid-cols-2 gap-4">
        <Link href={`${base}/wallet`} className="grid gap-2 rounded-[var(--radius-card)] border bg-card p-5 transition hover:border-primary/40">
          <Wallet className="size-5 text-primary" aria-hidden="true" />
          <span className="text-sm text-muted-foreground">{t.account.wallet}</span>
          {p ? <Money value={p.walletBalance} t={t} className="text-xl font-bold sm:text-2xl" /> : <Skeleton className="h-8 w-20" />}
        </Link>
        <Link href={`${base}/points`} className="grid gap-2 rounded-[var(--radius-card)] border bg-card p-5 transition hover:border-primary/40">
          <Coins className="size-5 text-primary" aria-hidden="true" />
          <span className="text-sm text-muted-foreground">{t.account.points}</span>
          {p ? <span className="text-xl font-bold tabular-nums sm:text-2xl">{p.points ?? 0}</span> : <Skeleton className="h-8 w-16" />}
        </Link>
      </div>

      <SectionTitle title={t.profile.title} />
      <RowGroup>
        <Row
          icon={<Phone />}
          title={t.profile.phone}
          subtitle={<span dir="ltr">{p?.phone}</span>}
          onClick={() => setChangingPhone(true)}
          trailing={<span className="text-sm font-medium text-primary">{t.profile.edit}</span>}
        />
        <Row icon={<MapPin />} title={t.places.title} href={`${base}/places`} />
        <Row icon={<CreditCard />} title={t.nav.plans} href={`${base}/plans`} />
        <Row icon={<TicketPercent />} title={t.nav.promos} href={`${base}/promos`} />
        <Row icon={<Bell />} title={t.nav.notifications} href={`${base}/notifications`} />
        <Row icon={<Info />} title={t.profile.about} href={`${base}/about`} />
      </RowGroup>

      <SectionTitle title={t.profile.settings} />
      <RowGroup>
        <div className="grid gap-3 px-4 py-3 sm:flex sm:items-center sm:justify-between">
          <span className="flex items-center gap-3 font-medium">
            <span className="grid size-10 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
              <Languages className="size-5" aria-hidden="true" />
            </span>
            {t.profile.language}
          </span>
          <Segmented
            value={locale}
            label={t.profile.language}
            className="flex sm:inline-flex"
            options={[
              { value: 'ar' as Locale, label: t.profile.arabic },
              { value: 'en' as Locale, label: t.profile.english },
            ]}
            onChange={language}
          />
        </div>
        <div className="grid gap-3 px-4 py-3 sm:flex sm:items-center sm:justify-between">
          <span className="flex items-center gap-3 font-medium">
            <span className="grid size-10 shrink-0 place-items-center rounded-xl bg-secondary text-primary">
              <Moon className="size-5" aria-hidden="true" />
            </span>
            {t.profile.appearance}
          </span>
          <Segmented
            value={mounted ? (theme ?? 'dark') : 'dark'}
            label={t.profile.appearance}
            className="flex sm:inline-flex"
            options={[
              { value: 'light', label: t.profile.themeLight },
              { value: 'dark', label: t.profile.themeDark },
              { value: 'system', label: t.profile.themeSystem },
            ]}
            onChange={setTheme}
          />
        </div>
      </RowGroup>

      <div className="mt-6 grid gap-2">
        <RowGroup>
          <Row icon={<LogOut className="rtl:-scale-x-100" />} title={t.profile.logout} onClick={leaving ? undefined : () => void logout()} />
          <Row icon={<Trash2 />} title={t.profile.deleteAccount} destructive onClick={() => setDeleting(true)} />
        </RowGroup>
      </div>

      {editing && p ? <EditProfileSheet t={t} profile={p} onClose={() => setEditing(false)} /> : null}
      {changingPhone ? <ChangePhoneSheet t={t} locale={locale} onClose={() => setChangingPhone(false)} /> : null}
      <Confirm
        open={deleting}
        onOpenChange={setDeleting}
        title={t.profile.deleteAccount}
        description={t.profile.deleteBody}
        confirmLabel={t.common.delete}
        cancelLabel={t.cars.cancel}
        destructive
        busy={remove.isPending}
        onConfirm={() =>
          remove.mutate(undefined, {
            onSuccess: async () => {
              await authApi.clearSession();
              qc.clear();
              toast.success(t.profile.deleted);
              router.replace(`${base}/welcome`);
              router.refresh();
            },
            onError: (e) => {
              toast.error(e.message);
              setDeleting(false);
            },
          })
        }
      />
    </div>
  );
}

/** PUT /users as multipart: same fields as the app's ChangePersonalInformation. */
function EditProfileSheet({ t, profile, onClose }: { t: AppDictionary; profile: Profile; onClose: () => void }) {
  const update = useUpdateProfile();
  const schema = useMemo(() => profileSchema(t), [t]);
  const {
    control,
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ProfileForm>({
    resolver: zodResolver(schema),
    defaultValues: { userName: profile.userName ?? '', email: profile.email ?? '', gender: profile.gender === '---' ? '' : (profile.gender ?? ''), dob: profile.dob?.slice(0, 10) ?? '' },
  });
  const [photo, setPhoto] = useState<File | null>(null);
  const preview = useMemo(() => (photo ? URL.createObjectURL(photo) : profile.imageLink), [photo, profile.imageLink]);
  useEffect(() => () => {
    if (photo && preview) URL.revokeObjectURL(preview);
  }, [photo, preview]);

  const submit = handleSubmit(async (values) => {
    try {
      await update.mutateAsync({ userName: values.userName.trim(), email: values.email?.trim() || undefined, gender: values.gender || undefined, dob: values.dob || undefined, image: photo ? await shrinkImage(photo, 800) : null });
      toast.success(t.profile.saved);
      onClose();
    } catch (e) {
      toast.error(e instanceof ApiError ? e.message : t.common.error);
    }
  });

  return (
    <Sheet
      open
      onOpenChange={(open) => !open && onClose()}
      title={t.profile.editTitle}
      closeLabel={t.terms.close}
      footer={
        <Button size="xl" className="w-full" disabled={update.isPending} onClick={() => void submit()}>
          {update.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {t.profile.save}
        </Button>
      }
    >
      <form onSubmit={submit} className="grid gap-5" noValidate>
        <label className="flex cursor-pointer items-center gap-4">
          <input
            type="file"
            accept="image/*"
            className="sr-only"
            aria-label={t.profile.photo}
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) setPhoto(file);
            }}
          />
          <Avatar profile={{ ...profile, imageLink: preview }} size="lg" />
          <span className="inline-flex items-center gap-2 rounded-full bg-muted px-4 py-2 text-sm font-medium transition hover:bg-secondary">
            <Camera className="size-4" aria-hidden="true" />
            {t.profile.photo}
          </span>
        </label>
        <Field id="userName" label={t.profile.name} autoComplete="name" error={errors.userName?.message} {...register('userName')} />
        <Field id="email" label={t.profile.email} type="email" inputMode="email" autoComplete="email" dir="ltr" error={errors.email?.message} {...register('email')} />
        <Controller
          control={control}
          name="gender"
          render={({ field }) => (
            <PickerField
              id="gender"
              label={t.profile.gender}
              value={field.value || undefined}
              placeholder={t.profile.chooseGender}
              // The backend stores the app's English values.
              options={[
                { value: 'Male', label: t.profile.male },
                { value: 'Female', label: t.profile.female },
              ]}
              onChange={field.onChange}
              searchLabel={t.signup.searchCountry}
              emptyText={t.signup.noResults}
              closeLabel={t.terms.close}
            />
          )}
        />
        <Field id="dob" label={t.profile.dob} type="date" max={new Date().toISOString().slice(0, 10)} dir="ltr" error={errors.dob?.message} {...register('dob')} />
      </form>
    </Sheet>
  );
}

/** PATCH /users/phone-number. The backend asks for no code, so the number is confirmed before sending. */
function ChangePhoneSheet({ t, locale, onClose }: { t: AppDictionary; locale: Locale; onClose: () => void }) {
  const change = useChangePhone();
  const schema = useMemo(() => phoneSchema(t), [t]);
  const [dialCode, setDialCode] = useState(defaultDialCode);
  const [pending, setPending] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<PhoneForm>({ resolver: zodResolver(schema), defaultValues: { phone: '' } });

  const submit = handleSubmit((values) => setPending(buildInternationalPhone(cleanPhoneInput(values.phone), dialCode)));

  return (
    <>
      <Sheet
        open
        onOpenChange={(open) => !open && onClose()}
        title={t.profile.changePhone}
        closeLabel={t.terms.close}
        footer={
          <Button size="xl" className="w-full" onClick={() => void submit()}>
            {t.customer.continue}
          </Button>
        }
      >
        <form onSubmit={submit} noValidate>
          <PhoneField t={t} locale={locale} dialCode={dialCode} onDialCode={setDialCode} id="newPhone" label={t.profile.phone} error={errors.phone?.message} {...register('phone')} />
        </form>
      </Sheet>
      <Confirm
        open={Boolean(pending)}
        onOpenChange={(open) => !open && setPending(null)}
        title={t.profile.changePhone}
        description={
          <>
            {t.profile.changePhoneBody}{' '}
            <span dir="ltr" className="font-semibold">
              {pending}
            </span>
          </>
        }
        confirmLabel={t.profile.confirm}
        cancelLabel={t.cars.cancel}
        busy={change.isPending}
        onConfirm={() =>
          change.mutate(pending!, {
            onSuccess: () => {
              toast.success(t.profile.phoneChanged);
              onClose();
            },
            onError: (e) => {
              toast.error(e.message);
              setPending(null);
            },
          })
        }
      />
    </>
  );
}
