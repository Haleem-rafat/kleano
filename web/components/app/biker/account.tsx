'use client';

import { Bell, CalendarDays, Camera, IdCard, KeyRound, Languages, Loader2, LogOut, Pencil, Phone, Star, Wallet } from 'lucide-react';
import { usePathname, useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import { toast } from 'sonner';
import { Failed, PageTitle, formatWhen } from '@/components/app/bits';
import { PersonThumb } from '@/components/app/order-parts';
import { Field } from '@/components/app/field';
import { Row, RowGroup, RowsSkeleton, Sheet } from '@/components/app/kit';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { shrinkImage } from '@/lib/image';
import { ApiError, authApi } from '@/lib/kleano/client';
import { bikerApi, useBikerProfile, useUpdateBiker, type BikerProfile } from '@/lib/kleano/domains/biker';

function EditSheet({ profile, t, onClose }: { profile: BikerProfile; t: AppDictionary; onClose: () => void }) {
  const update = useUpdateBiker();
  const [name, setName] = useState(profile.userName ?? '');
  const [image, setImage] = useState<Blob | null>(null);
  const [preview, setPreview] = useState<string | null>(profile.imageLink ?? null);
  const [error, setError] = useState<string>();
  const save = () => {
    if (name.trim().length < 2) return setError(t.b.nameRequired);
    update.mutate(
      { userName: name.trim(), image },
      {
        onSuccess: () => {
          toast.success(t.b.saved);
          onClose();
        },
        onError: (e) => toast.error(e instanceof ApiError ? e.message : t.common.error),
      },
    );
  };
  return (
    <Sheet
      open
      onOpenChange={(open) => !open && onClose()}
      title={t.b.editProfile}
      closeLabel={t.terms.close}
      footer={
        <Button size="xl" className="w-full" disabled={update.isPending} onClick={save}>
          {update.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {t.b.save}
        </Button>
      }
    >
      <div className="grid gap-5">
        <label className="relative mx-auto grid size-24 cursor-pointer place-items-center overflow-hidden rounded-full bg-secondary text-primary">
          {preview ? (
            // eslint-disable-next-line @next/next/no-img-element -- a local preview or the backend's photo
            <img src={preview} alt="" className="absolute inset-0 size-full object-cover" />
          ) : null}
          <span className="relative grid size-9 place-items-center rounded-full bg-background/80">
            <Camera className="size-5" aria-hidden="true" />
          </span>
          <input
            type="file"
            accept="image/*"
            aria-label={t.b.changePhoto}
            className="sr-only"
            onChange={async (e) => {
              const file = e.target.files?.[0];
              if (!file) return;
              const small = await shrinkImage(file, 800, 0.8);
              setImage(small);
              setPreview(URL.createObjectURL(small));
            }}
          />
        </label>
        <Field id="biker-name" label={t.b.name} value={name} error={error} onChange={(e) => setName(e.target.value)} />
      </div>
    </Sheet>
  );
}

function PasswordSheet({ t, onClose }: { t: AppDictionary; onClose: () => void }) {
  const [oldPassword, setOld] = useState('');
  const [next, setNext] = useState('');
  const [again, setAgain] = useState('');
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);
  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (next.length < 8) return setError(t.biker.minPassword);
    if (next !== again) return setError(t.b.passwordsDiffer);
    setError(undefined);
    setBusy(true);
    try {
      await bikerApi.password(oldPassword, next);
      toast.success(t.b.passwordChanged);
      onClose();
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t.common.error);
    } finally {
      setBusy(false);
    }
  };
  return (
    <Sheet open onOpenChange={(open) => !open && onClose()} title={t.b.editPassword} closeLabel={t.terms.close}>
      <form onSubmit={submit} className="grid gap-4">
        <Field id="old-password" type="password" autoComplete="current-password" label={t.b.oldPassword} value={oldPassword} onChange={(e) => setOld(e.target.value)} />
        <Field id="new-password" type="password" autoComplete="new-password" label={t.b.newPassword} value={next} onChange={(e) => setNext(e.target.value)} />
        <Field id="again-password" type="password" autoComplete="new-password" label={t.b.againPassword} value={again} error={error} onChange={(e) => setAgain(e.target.value)} />
        <Button type="submit" size="xl" className="w-full" disabled={busy || !oldPassword}>
          {busy ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {t.b.save}
        </Button>
      </form>
    </Sheet>
  );
}

export function BikerAccount({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const router = useRouter();
  const pathname = usePathname();
  const profile = useBikerProfile();
  const [sheet, setSheet] = useState<'edit' | 'password' | null>(null);
  const [leaving, setLeaving] = useState(false);
  const base = `/${locale}/biker`;

  const logout = async () => {
    setLeaving(true);
    try {
      await authApi.logout('biker');
    } finally {
      router.replace(`${base}/login`);
      router.refresh();
    }
  };
  const other: Locale = locale === 'ar' ? 'en' : 'ar';
  const language = () => {
    void bikerApi.language(other).catch(() => undefined);
    router.push(`/${other}${pathname.slice(3)}`);
  };

  if (profile.isPending) return <RowsSkeleton label={t.common.loading} />;
  if (profile.isError) return <Failed message={profile.error.message} onRetry={() => profile.refetch()} t={t} />;
  const p = profile.data;

  return (
    <div>
      <PageTitle title={t.nav.profile} />
      <div className="grid gap-4 lg:grid-cols-2">
        <section className="flex items-center gap-4 rounded-2xl border bg-card p-4 lg:col-span-2">
          <PersonThumb src={p.imageLink} name={p.userName} t={t} className="size-16 text-lg" />
          <div className="min-w-0 flex-1">
            <p className="truncate text-lg font-semibold">{p.userName}</p>
            <p className="flex items-center gap-1.5 text-sm text-muted-foreground">
              <Star className="size-3.5 fill-current text-primary" aria-hidden="true" />
              <span className="tabular-nums">{p.rating ?? '—'}</span>
            </p>
          </div>
          <Button variant="outline" size="chip" onClick={() => setSheet('edit')}>
            <Pencil />
            {t.b.edit}
          </Button>
        </section>
        <RowGroup>
          <Row icon={<Phone />} title={t.b.phone} subtitle={<bdi dir="ltr">{p.phone}</bdi>} />
          {p.nationalId ? <Row icon={<IdCard />} title={t.progress.nationalId} subtitle={<bdi dir="ltr">{p.nationalId}</bdi>} /> : null}
          {p.createdAt ? <Row icon={<CalendarDays />} title={t.progress.memberSince} subtitle={formatWhen(p.createdAt, locale)} /> : null}
          <Row icon={<KeyRound />} title={t.b.editPassword} chevron onClick={() => setSheet('password')} />
          <Row icon={<Languages />} title={t.welcome.language} chevron onClick={language} />
        </RowGroup>
        <RowGroup>
          <Row icon={<Wallet />} title={t.nav.earnings} chevron href={`${base}/earnings`} />
          <Row icon={<CalendarDays />} title={t.nav.schedule} chevron href={`${base}/schedule`} />
          <Row icon={<Bell />} title={t.nav.notifications} chevron href={`${base}/notifications`} />
        </RowGroup>
      </div>
      <Button variant="outline" size="xl" className="mt-6 w-full text-destructive sm:w-fit" disabled={leaving} onClick={logout}>
        {leaving ? <Loader2 className="animate-spin" aria-hidden="true" /> : <LogOut className="rtl:-scale-x-100" />}
        {t.nav.logout}
      </Button>

      {sheet === 'edit' ? <EditSheet profile={p} t={t} onClose={() => setSheet(null)} /> : null}
      {sheet === 'password' ? <PasswordSheet t={t} onClose={() => setSheet(null)} /> : null}
    </div>
  );
}
