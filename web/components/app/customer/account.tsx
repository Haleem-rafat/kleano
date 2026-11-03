'use client';

import { Coins, Mail, MapPin, Phone, Star, Wallet } from 'lucide-react';
import { Failed, Loading, Money, PageTitle, SectionTitle } from '@/components/app/bits';
import { BentoGrid, BentoGridItem } from '@/components/ui/bento-grid';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useProfile, useSavedLocations } from '@/lib/kleano/queries';
import { cityName } from '@/lib/kleano/types';

export function CustomerAccount({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const profile = useProfile();
  const saved = useSavedLocations();

  if (profile.isPending) return <Loading label={t.common.loading} />;
  if (profile.isError) return <Failed message={profile.error.message} onRetry={() => profile.refetch()} t={t} />;
  const p = profile.data;
  const initials = p.userName?.trim().split(/\s+/).map((w) => w[0]).slice(0, 2).join('') ?? '';

  return (
    <div>
      <PageTitle title={t.account.title} />

      <div className="mb-6 flex items-center gap-4 rounded-3xl bg-card p-5 shadow-input">
        {p.imageLink ? (
          // eslint-disable-next-line @next/next/no-img-element -- profile photo from the backend's storage
          <img src={p.imageLink} alt="" className="size-16 rounded-full object-cover" />
        ) : (
          <span className="grid size-16 place-items-center rounded-full bg-primary text-xl font-bold text-primary-foreground">{initials}</span>
        )}
        <div className="min-w-0">
          <p className="truncate text-xl font-semibold">{p.userName}</p>
          <p className="inline-flex items-center gap-1.5 text-sm text-muted-foreground" dir="ltr">
            <Phone className="size-4" aria-hidden="true" />
            {p.phone}
          </p>
          {p.email ? (
            <p className="inline-flex items-center gap-1.5 text-sm text-muted-foreground">
              <Mail className="size-4" aria-hidden="true" />
              {p.email}
            </p>
          ) : null}
        </div>
      </div>

      <BentoGrid className="max-w-none md:auto-rows-[9rem] md:grid-cols-2">
        <BentoGridItem
          icon={<Wallet className="size-5 text-primary" aria-hidden="true" />}
          title={t.account.wallet}
          description={<Money value={p.walletBalance} t={t} className="text-2xl font-bold text-foreground" />}
        />
        <BentoGridItem
          icon={<Coins className="size-5 text-primary" aria-hidden="true" />}
          title={t.account.points}
          description={<span className="text-2xl font-bold text-foreground tabular-nums">{p.points ?? 0}</span>}
        />
      </BentoGrid>

      <SectionTitle title={t.account.savedPlaces} />
      {saved.isPending ? (
        <Loading label={t.common.loading} />
      ) : !saved.data?.length ? (
        <p className="text-muted-foreground">{t.account.noPlaces}</p>
      ) : (
        <ul className="grid gap-2">
          {saved.data.map((l) => (
            <li key={l._id} className="flex items-center gap-3 rounded-2xl border border-border bg-card p-4">
              <MapPin className="size-5 shrink-0 text-primary" aria-hidden="true" />
              <div className="min-w-0 flex-1">
                <p className="truncate font-medium">{l.savedName || l.streetName}</p>
                <p className="truncate text-sm text-muted-foreground">{[l.streetName, cityName(l.city, locale)].filter(Boolean).join(' · ')}</p>
              </div>
              {l.isDefault ? (
                <span className="inline-flex items-center gap-1 rounded-full bg-secondary px-2.5 py-1 text-xs font-semibold text-secondary-foreground">
                  <Star className="size-3" aria-hidden="true" />
                  {t.account.default}
                </span>
              ) : null}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
