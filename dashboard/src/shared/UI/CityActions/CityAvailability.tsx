import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import { IoAdd, IoLocationOutline } from 'react-icons/io5';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@shadecn/components/ui/select';
import { Button, SectionCard } from '@UI/Index';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';
import { cn } from '@/shadecn/lib/utils';

interface ICityRow {
  city?: { _id: string; name?: { en?: string; ar?: string } };
  isArchived?: boolean;
}

interface ICityAvailabilityProps {
  /** `item.cities` from the API: [{ city, isArchived }]. */
  cities?: ICityRow[];
  add: (cityId: string) => Promise<unknown>;
  activate: (cityId: string) => Promise<unknown>;
  archive: (cityId: string) => Promise<unknown>;
  /** Refresh the page data after a change. */
  onChanged: () => void;
  title?: string;
  description?: string;
}

const errorText = (e: unknown, lang: 'en' | 'ar', fallback: string) => {
  const msg = (e as { response?: { data?: { message?: unknown } } })?.response?.data?.message;
  if (Array.isArray(msg)) return msg.join('\n');
  if (msg && typeof msg === 'object') return (msg as Record<string, string>)[lang] || fallback;
  return typeof msg === 'string' ? msg : fallback;
};

/**
 * Where an item (service, plan, add-on) is offered: each city with its status,
 * pause/resume in place, and an add row that only lists cities not added yet.
 */
export default function CityAvailability({
  cities = [],
  add,
  activate,
  archive,
  onChanged,
  title,
  description,
}: ICityAvailabilityProps) {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const { citiesOptions } = useGetCitiesOptions();
  const [busy, setBusy] = useState<string | null>(null);
  const [newCity, setNewCity] = useState('');

  const rows = cities.filter((c) => c?.city?._id);
  const activeCount = rows.filter((c) => !c.isArchived).length;
  const available = useMemo(
    () => citiesOptions.filter((o) => !rows.some((r) => r.city?._id === o.value)),
    [citiesOptions, rows]
  );

  const run = async (key: string, action: () => Promise<unknown>, success: string) => {
    setBusy(key);
    try {
      await action();
      toast.success(success);
      onChanged();
    } catch (e) {
      toast.error(errorText(e, lang, t('somethingWentWrong')));
    } finally {
      setBusy(null);
    }
  };

  return (
    <SectionCard
      title={title || t('availableCities')}
      action={
        rows.length > 0 && (
          <span className="rounded-full bg-accent px-2.5 py-0.5 text-xs font-medium text-primary">
            {t('activeOfTotal', { active: activeCount, total: rows.length })}
          </span>
        )
      }>
      {description && <p className="-mt-2 mb-4 text-[13px] text-muted-foreground">{description}</p>}

      {rows.length === 0 ? (
        <div className="flex flex-col items-center gap-2 rounded-md border border-dashed border-border px-4 py-8 text-center">
          <IoLocationOutline className="h-6 w-6 text-muted-foreground" />
          <p className="text-sm font-medium text-foreground">{t('noCitiesYet')}</p>
          <p className="text-[13px] text-muted-foreground">{t('noCitiesYetHint')}</p>
        </div>
      ) : (
        <ul className="divide-y divide-border rounded-md border border-border">
          {rows.map((row) => {
            const id = row.city!._id;
            const paused = !!row.isArchived;
            return (
              <li key={id} className="flex items-center gap-3 px-3 py-2.5">
                <span
                  className={cn(
                    'flex h-8 w-8 shrink-0 items-center justify-center rounded-full',
                    paused ? 'bg-muted text-muted-foreground' : 'bg-accent text-primary'
                  )}>
                  <IoLocationOutline className="h-4 w-4" />
                </span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-foreground">
                    {row.city?.name?.[lang] || row.city?.name?.en || '—'}
                  </p>
                  <span
                    className={cn(
                      'mt-0.5 inline-flex items-center gap-1 text-xs font-medium',
                      paused ? 'text-warning' : 'text-success'
                    )}>
                    <span
                      className={cn(
                        'h-1.5 w-1.5 rounded-full',
                        paused ? 'bg-warning' : 'bg-success'
                      )}
                    />
                    {paused ? t('paused') : t('active')}
                  </span>
                </div>
                <Button
                  variant={paused ? 'secondary' : 'dangerOutline'}
                  size="sm"
                  loading={busy === id}
                  disabled={!!busy}
                  onClick={() =>
                    paused
                      ? run(id, () => activate(id), t('cityResumed'))
                      : run(id, () => archive(id), t('cityPaused'))
                  }>
                  {paused ? t('resume') : t('pause')}
                </Button>
              </li>
            );
          })}
        </ul>
      )}

      <div className="mt-4 flex flex-col gap-2 border-t border-border pt-4 sm:flex-row sm:items-center">
        <Select
          value={newCity || undefined}
          onValueChange={setNewCity}
          disabled={!available.length || !!busy}>
          <SelectTrigger className="sm:flex-1" aria-label={t('addCity')}>
            <SelectValue
              placeholder={available.length ? t('chooseCityToAdd') : t('allCitiesAdded')}
            />
          </SelectTrigger>
          <SelectContent>
            {available.map((o) => (
              <SelectItem key={o.value} value={o.value}>
                {o.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Button
          size="md"
          disabled={!newCity || !!busy}
          loading={busy === 'add'}
          onClick={() => run('add', () => add(newCity), t('cityAdded')).then(() => setNewCity(''))}>
          <IoAdd className="me-1 h-4 w-4" />
          {t('addCity')}
        </Button>
      </div>
    </SectionCard>
  );
}
