import { useState, useMemo, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  IoArrowBack,
  IoCopyOutline,
  IoSearchOutline,
  IoCheckmark,
  IoClose,
  IoTrashOutline,
} from 'react-icons/io5';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import useSWR, { mutate } from 'swr';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@shadecn/components/ui/dialog';
import { Switch } from '@shadecn/components/ui/switch';
import { Input } from '@shadecn/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@shadecn/components/ui/select';
import bikersService from '@services/bikers.service';
import staticService from '@services/static.service';
import { IBikers } from '@servicesTypes/bikers.types';
import { ROUTES } from '@constants/routes';
import { Icities } from '@servicesTypes/cities.types';
import {
  Button,
  MainAvatar,
  SectionCard,
  PageSkeleton,
  TilesSkeleton,
  CardSkeleton,
  Skeleton,
} from '@UI/Index';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';
import { cn } from '@/shadecn/lib/utils';

const TIME_SLOTS = Array.from(
  { length: 96 },
  (_, i) =>
    `${Math.floor(i / 4)
      .toString()
      .padStart(2, '0')}:${((i % 4) * 15).toString().padStart(2, '0')}`
);

/** Quick ranges an admin usually wants; `to` is exclusive. */
const PRESETS = [
  { key: 'morning', from: '08:00', to: '12:00' },
  { key: 'afternoon', from: '12:00', to: '17:00' },
  { key: 'evening', from: '17:00', to: '22:00' },
  { key: 'fullDay', from: '08:00', to: '22:00' },
];

const DAYS_OF_WEEK = [
  { value: 'saturday', label: { en: 'Saturday', ar: 'السبت' } },
  { value: 'sunday', label: { en: 'Sunday', ar: 'الأحد' } },
  { value: 'monday', label: { en: 'Monday', ar: 'الإثنين' } },
  { value: 'tuesday', label: { en: 'Tuesday', ar: 'الثلاثاء' } },
  { value: 'wednesday', label: { en: 'Wednesday', ar: 'الأربعاء' } },
  { value: 'thursday', label: { en: 'Thursday', ar: 'الخميس' } },
  { value: 'friday', label: { en: 'Friday', ar: 'الجمعة' } },
];

type LocalName = { en: string; ar: string };

interface ScheduleData {
  areas: string[];
  timeSlots: string[];
  areaPriorities: Record<string, number>;
  areaCities: Record<string, string>;
  areaNames: Record<string, LocalName>;
}

interface Shift {
  day?: string;
  area?: { _id: string; name?: LocalName } | string;
  city?: { _id: string } | string;
  timeSlot?: string;
  priorityLevel?: number;
}

const emptyDay = (): ScheduleData => ({
  areas: [],
  timeSlots: [],
  areaPriorities: {},
  areaCities: {},
  areaNames: {},
});

const emptyWeek = () =>
  Object.fromEntries(DAYS_OF_WEEK.map((d) => [d.value, emptyDay()])) as Record<
    string,
    ScheduleData
  >;

/** Builds the editor state straight from the saved shifts (names come with the shift). */
const parseShifts = (shifts: Shift[]) => {
  const week = emptyWeek();
  shifts.forEach((shift) => {
    const day = week[shift?.day?.toLowerCase() ?? ''];
    const areaId = typeof shift?.area === 'object' ? shift.area?._id : shift?.area;
    const cityId = typeof shift?.city === 'object' ? shift.city?._id : shift?.city;
    if (!day || !areaId || !cityId) return;
    if (!day.areas.includes(areaId)) day.areas.push(areaId);
    if (shift.timeSlot && !day.timeSlots.includes(shift.timeSlot)) {
      day.timeSlots.push(shift.timeSlot);
    }
    day.areaPriorities[areaId] = shift.priorityLevel || 1;
    day.areaCities[areaId] = cityId;
    day.areaNames[areaId] =
      typeof shift.area === 'object' && shift.area?.name
        ? shift.area.name
        : { en: areaId, ar: areaId };
  });
  return week;
};

const toMinutes = (slot: string) => {
  if (!slot) return 0;
  const [h, m] = slot.split(':').map(Number);
  return h * 60 + m;
};
const fromMinutes = (min: number) =>
  `${Math.floor(min / 60)
    .toString()
    .padStart(2, '0')}:${(min % 60).toString().padStart(2, '0')}`;

/** "08:00–12:00, 14:00–18:00" from a set of 15-minute slots. */
const summarizeSlots = (slots: string[]) => {
  const sorted = [...slots].sort((a, b) => toMinutes(a) - toMinutes(b));
  const ranges: string[] = [];
  let start: number | null = null;
  let prev = -1;
  sorted.forEach((slot) => {
    const min = toMinutes(slot);
    if (start === null) start = min;
    else if (min !== prev + 15) {
      ranges.push(`${fromMinutes(start)}–${fromMinutes(prev + 15)}`);
      start = min;
    }
    prev = min;
  });
  if (start !== null) ranges.push(`${fromMinutes(start)}–${fromMinutes(prev + 15)}`);
  return ranges;
};

const rangesOf = (slots: string[]) =>
  summarizeSlots(slots).map((r) => {
    const [from, to] = r.split('–');
    return { from, to };
  });

/** 270 → "4h 30m" */
const formatDuration = (min: number) => {
  const h = Math.floor(min / 60);
  const m = min % 60;
  return [h ? `${h}h` : '', m ? `${m}m` : ''].filter(Boolean).join(' ') || '0h';
};

const END_TIMES = [...TIME_SLOTS.slice(1), '24:00'];

/** Design-system select for a time value. */
const TimeSelect = ({
  value,
  options,
  label,
  onChange,
}: {
  value: string;
  options: string[];
  label: string;
  onChange: (v: string) => void;
}) => (
  <Select value={value} onValueChange={onChange}>
    <SelectTrigger className="h-9 w-28 tabular-nums" aria-label={label}>
      <SelectValue />
    </SelectTrigger>
    <SelectContent className="max-h-64">
      {options.map((o) => (
        <SelectItem key={o} value={o} className="tabular-nums">
          {o}
        </SelectItem>
      ))}
    </SelectContent>
  </Select>
);

const slotsBetween = (from: string, to: string) =>
  TIME_SLOTS.filter((s) => toMinutes(s) >= toMinutes(from) && toMinutes(s) < toMinutes(to));

export default function BikersSchedule() {
  const { bikerId } = useParams();
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const nameOf = (name?: LocalName | string) =>
    typeof name === 'string' ? name : name?.[lang] || name?.en || '';

  const { data: bikerData, isLoading: isLoadingBiker } = useSWR(
    bikerId ? ['get-biker-details', bikerId] : null,
    () => bikersService.getBikerById(bikerId).then((data) => data?.data as IBikers)
  );

  const {
    data: scheduleData,
    error: scheduleError,
    isLoading: isLoadingSchedule,
  } = useSWR(bikerId ? ['get-biker-schedule', bikerId] : null, () =>
    bikersService.getBikerSchedule(bikerId)
  );

  const { citiesOptions } = useGetCitiesOptions();
  const [selectedCityId, setSelectedCityId] = useState('');
  const [areaSearchQuery, setAreaSearchQuery] = useState('');

  const { data: areasData, isLoading: isLoadingAreas } = useSWR(
    selectedCityId ? ['get-Areas', selectedCityId] : null,
    () => staticService.getAreasOptions(selectedCityId)
  );

  const areas = useMemo(
    () =>
      ((areasData?.data as Icities[]) ?? [])
        .filter((area) => area?._id)
        .map((area) => ({ id: area._id, name: area.name as unknown as LocalName })),
    [areasData]
  );

  const filteredAreas = useMemo(() => {
    const query = areaSearchQuery.toLowerCase().trim();
    if (!query) return areas;
    return areas.filter(
      (area) => area.name?.en?.toLowerCase().includes(query) || area.name?.ar?.includes(query)
    );
  }, [areas, areaSearchQuery]);

  const [activeDay, setActiveDay] = useState('saturday');
  const [schedule, setSchedule] = useState<Record<string, ScheduleData>>(emptyWeek);
  const [weekends, setWeekends] = useState<string[]>([]);
  const [isScheduleLoaded, setIsScheduleLoaded] = useState(false);
  const [isDirty, setIsDirty] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isCopyDialogOpen, setIsCopyDialogOpen] = useState(false);
  const [copyToDays, setCopyToDays] = useState<string[]>([]);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  // Load once the request settles, whether the biker has a schedule or not.
  useEffect(() => {
    if (isScheduleLoaded || isLoadingSchedule) return;
    if (scheduleData === undefined && !scheduleError) return;
    const saved = scheduleData?.data;
    const shifts: Shift[] = Array.isArray(saved?.shifts) ? saved.shifts : [];
    setSchedule(parseShifts(shifts));
    setWeekends(Array.isArray(saved?.weekends) ? saved.weekends : []);
    const firstCity = shifts.find((s) => s?.city)?.city;
    const cityId = typeof firstCity === 'object' ? firstCity?._id : firstCity;
    if (cityId) setSelectedCityId(cityId);
    setIsScheduleLoaded(true);
  }, [scheduleData, scheduleError, isLoadingSchedule, isScheduleLoaded]);

  // Default the city to the biker's own city when nothing is saved yet.
  useEffect(() => {
    if (!isScheduleLoaded || selectedCityId) return;
    const fallback = bikerData?.city?._id || citiesOptions[0]?.value;
    if (fallback) setSelectedCityId(fallback);
  }, [isScheduleLoaded, selectedCityId, bikerData, citiesOptions]);

  const updateDay = (day: string, update: (d: ScheduleData) => ScheduleData) => {
    setSchedule((prev) => ({ ...prev, [day]: update(prev[day]) }));
    setIsDirty(true);
  };

  const setAreasSelected = (day: string, ids: string[], selected: boolean) =>
    updateDay(day, (d) => {
      const next = {
        ...d,
        areaPriorities: { ...d.areaPriorities },
        areaCities: { ...d.areaCities },
        areaNames: { ...d.areaNames },
      };
      if (selected) {
        next.areas = [...new Set([...d.areas, ...ids])];
        ids.forEach((id) => {
          if (d.areas.includes(id)) return;
          next.areaPriorities[id] = 1;
          next.areaCities[id] = selectedCityId;
          const area = areas.find((a) => a.id === id);
          if (area) next.areaNames[id] = area.name;
        });
      } else {
        next.areas = d.areas.filter((id) => !ids.includes(id));
        ids.forEach((id) => {
          delete next.areaPriorities[id];
          delete next.areaCities[id];
          delete next.areaNames[id];
        });
      }
      return next;
    });

  const setPriority = (day: string, areaId: string, priority: number) =>
    updateDay(day, (d) => ({ ...d, areaPriorities: { ...d.areaPriorities, [areaId]: priority } }));

  const setSlots = (day: string, slots: string[], selected: boolean) =>
    updateDay(day, (d) => ({
      ...d,
      timeSlots: selected
        ? [...new Set([...d.timeSlots, ...slots])]
        : d.timeSlots.filter((s) => !slots.includes(s)),
    }));

  const toggleWeekend = (day: string) => {
    const name = day.toUpperCase();
    setWeekends((prev) => (prev.includes(name) ? prev.filter((d) => d !== name) : [...prev, name]));
    setIsDirty(true);
  };

  const hasExistingSchedule = !!scheduleData?.data?._id;

  const handleSave = async () => {
    if (!bikerId || !bikerData) {
      toast.error(t('bikerNotFound'));
      return;
    }
    const shifts = DAYS_OF_WEEK.flatMap((day) => {
      const d = schedule[day.value];
      return d.areas.flatMap((areaId) => {
        const city = d.areaCities[areaId];
        if (!city) return [];
        return d.timeSlots.map((timeSlot) => ({
          timeSlot,
          city,
          area: areaId,
          day: day.value.toUpperCase(),
          priorityLevel: d.areaPriorities[areaId] || 1,
        }));
      });
    });
    const incomplete = DAYS_OF_WEEK.filter((day) => {
      const d = schedule[day.value];
      return (
        !weekends.includes(day.value.toUpperCase()) && d.areas.length > 0 !== d.timeSlots.length > 0
      );
    });
    if (incomplete.length) {
      toast.warning(
        `${t('scheduleIncomplete')}: ${incomplete.map((d) => d.label[lang]).join(', ')}`
      );
      return;
    }

    setIsSaving(true);
    try {
      const payload = { biker: bikerId, shifts, weekends };
      const response = hasExistingSchedule
        ? await bikersService.updateBikerSchedule(bikerId, payload)
        : await bikersService.createBikerSchedule(payload);
      if (response?.success) {
        toast.success(t('scheduleSaved'));
        setIsDirty(false);
        mutate(['get-biker-schedule', bikerId]);
      } else {
        toast.error(t('scheduleSaveError'));
      }
    } catch {
      toast.error(t('scheduleSaveError'));
    } finally {
      setIsSaving(false);
    }
  };

  const handleCopyConfirm = () => {
    if (copyToDays.length === 0) {
      toast.warning(t('selectDaysToCopy'));
      return;
    }
    const source = schedule[activeDay];
    setSchedule((prev) => {
      const updated = { ...prev };
      copyToDays.forEach((day) => {
        updated[day] = {
          areas: [...source.areas],
          timeSlots: [...source.timeSlots],
          areaPriorities: { ...source.areaPriorities },
          areaCities: { ...source.areaCities },
          areaNames: { ...source.areaNames },
        };
      });
      return updated;
    });
    setIsDirty(true);
    setIsCopyDialogOpen(false);
    setCopyToDays([]);
    toast.success(t('scheduleCopied'));
  };

  const handleDeleteSchedule = async () => {
    if (!bikerId) return;
    setIsDeleting(true);
    try {
      const response = await bikersService.deleteBikerSchedule(bikerId);
      if (response?.success) {
        toast.success(t('scheduleDeleted'));
        mutate(['get-biker-schedule', bikerId]);
        setIsDeleteDialogOpen(false);
        navigate(ROUTES.BIKERS);
      } else {
        toast.error(t('scheduleDeleteError'));
      }
    } catch {
      toast.error(t('scheduleDeleteError'));
    } finally {
      setIsDeleting(false);
    }
  };

  const day = schedule[activeDay];
  const activeLabel = DAYS_OF_WEEK.find((d) => d.value === activeDay)?.label[lang];
  const isDayOff = weekends.includes(activeDay.toUpperCase());
  const cityName = (id: string) => citiesOptions.find((c) => c.value === id)?.label ?? '';
  const dayRanges = rangesOf(day.timeSlots);

  const replaceRange = (index: number, from: string, to: string) => {
    if (toMinutes(to) <= toMinutes(from)) {
      toast.warning(t('endAfterStart'));
      return;
    }
    const others = dayRanges.filter((_, i) => i !== index);
    updateDay(activeDay, (d) => ({
      ...d,
      timeSlots: [
        ...new Set([
          ...others.flatMap((r) => slotsBetween(r.from, r.to)),
          ...slotsBetween(from, to),
        ]),
      ],
    }));
  };

  const addNextRange = () => {
    const last = dayRanges[dayRanges.length - 1];
    const start = last ? Math.min(toMinutes(last.to) + 60, 23 * 60) : 8 * 60;
    const end = Math.min(start + 4 * 60, 24 * 60);
    setSlots(activeDay, slotsBetween(fromMinutes(start), fromMinutes(end)), true);
  };

  const allFilteredSelected =
    filteredAreas.length > 0 && filteredAreas.every((a) => day.areas.includes(a.id));

  if (isLoadingBiker) {
    return <PageSkeleton kind="details" />;
  }

  if (!bikerData) {
    return <div className="py-24 text-center text-destructive">{t('bikerNotFound')}</div>;
  }

  return (
    <div className="space-y-5 pb-24">
      {/* Header */}
      <header className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex min-w-0 items-center gap-3">
          <button
            type="button"
            onClick={() => navigate(-1)}
            aria-label={t('back')}
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-muted text-foreground hover:bg-accent">
            <IoArrowBack className="h-4 w-4 rtl:rotate-180" />
          </button>
          <MainAvatar src={bikerData.imageLink} name={bikerData.userName} className="h-10 w-10" />
          <div className="min-w-0">
            <h1 className="truncate text-xl font-semibold tracking-tight text-foreground">
              {t('bikerSchedule')} · {bikerData.userName}
            </h1>
            <p className="text-[13px] text-muted-foreground">
              {bikerData.phone}
              {bikerData.city?.name?.[lang] ? ` · ${bikerData.city.name[lang]}` : ''}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {hasExistingSchedule && (
            <Button variant="dangerOutline" size="md" onClick={() => setIsDeleteDialogOpen(true)}>
              <IoTrashOutline className="me-1.5 h-4 w-4" />
              {t('deleteSchedule')}
            </Button>
          )}
          <Button
            size="md"
            onClick={handleSave}
            loading={isSaving}
            disabled={!isScheduleLoaded || isSaving || !isDirty}>
            {t('save')}
          </Button>
        </div>
      </header>

      {!isScheduleLoaded ? (
        <div className="space-y-5">
          <TilesSkeleton count={4} />
          <CardSkeleton rows={6} />
        </div>
      ) : (
        <>
          {/* Week overview: pick a day, see what each day has at a glance */}
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-4 xl:grid-cols-7">
            {DAYS_OF_WEEK.map((d) => {
              const s = schedule[d.value];
              const off = weekends.includes(d.value.toUpperCase());
              const ranges = summarizeSlots(s.timeSlots);
              const active = d.value === activeDay;
              return (
                <button
                  key={d.value}
                  type="button"
                  onClick={() => {
                    setActiveDay(d.value);
                    setAreaSearchQuery('');
                  }}
                  aria-pressed={active}
                  className={cn(
                    'min-w-0 rounded-lg border p-3 text-start transition-colors',
                    active
                      ? 'border-primary bg-accent ring-1 ring-primary'
                      : 'border-border bg-card hover:bg-muted'
                  )}>
                  <p className="text-sm font-semibold text-foreground">{d.label[lang]}</p>
                  {off ? (
                    <p className="mt-1 text-xs font-medium text-warning">{t('dayOff')}</p>
                  ) : s.areas.length || s.timeSlots.length ? (
                    <>
                      <p className="mt-1 truncate text-xs text-foreground">
                        {ranges.length ? ranges.join(', ') : '—'}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {s.areas.length} {t('areas')}
                      </p>
                    </>
                  ) : (
                    <p className="mt-1 text-xs text-muted-foreground">{t('notScheduled')}</p>
                  )}
                </button>
              );
            })}
          </div>

          {/* Day editor */}
          <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-border bg-card px-5 py-3">
            <div>
              <h2 className="text-base font-semibold text-foreground">{activeLabel}</h2>
              <p className="text-[13px] text-muted-foreground">
                {isDayOff
                  ? t('dayOffHint')
                  : `${day.areas.length} ${t('areas')} · ${
                      summarizeSlots(day.timeSlots).join(', ') || t('noHoursSelected')
                    }`}
              </p>
            </div>
            <div className="flex items-center gap-3">
              <label className="flex cursor-pointer items-center gap-2 text-[13px] font-medium text-foreground">
                <Switch checked={isDayOff} onCheckedChange={() => toggleWeekend(activeDay)} />
                {t('dayOff')}
              </label>
              <Button
                variant="secondary"
                size="sm"
                disabled={!day.areas.length && !day.timeSlots.length}
                onClick={() => {
                  setCopyToDays([]);
                  setIsCopyDialogOpen(true);
                }}>
                <IoCopyOutline className="me-1.5 h-4 w-4" />
                {t('copyTo')}
              </Button>
            </div>
          </div>

          <div className={cn('grid gap-5 xl:grid-cols-2', isDayOff && 'opacity-60')}>
            {/* Step 1: areas */}
            <SectionCard
              title={`1 · ${t('chooseAreas')}`}
              action={
                <Select
                  value={selectedCityId}
                  onValueChange={(v) => {
                    setSelectedCityId(v);
                    setAreaSearchQuery('');
                  }}>
                  <SelectTrigger className="h-9 w-44" aria-label={t('city')}>
                    <SelectValue placeholder={t('city')} />
                  </SelectTrigger>
                  <SelectContent>
                    {citiesOptions.map((c) => (
                      <SelectItem key={c.value} value={c.value}>
                        {c.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              }>
              <div className="space-y-3">
                <div className="flex items-center gap-2">
                  <label className="relative min-w-0 flex-1">
                    <IoSearchOutline className="pointer-events-none absolute start-3 top-1/2 z-10 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                    <Input
                      type="search"
                      value={areaSearchQuery}
                      onChange={(e) => setAreaSearchQuery(e.target.value)}
                      placeholder={t('searchAreas')}
                      aria-label={t('searchAreas')}
                      className="h-9 ps-9"
                    />
                  </label>
                  <Button
                    variant="secondary"
                    size="md"
                    disabled={!filteredAreas.length}
                    onClick={() =>
                      setAreasSelected(
                        activeDay,
                        filteredAreas.map((a) => a.id),
                        !allFilteredSelected
                      )
                    }>
                    {allFilteredSelected ? t('deselectAll') : t('selectAll')}
                  </Button>
                </div>
                <div className="h-80 overflow-y-auto rounded-md border border-border">
                  {isLoadingAreas ? (
                    <div className="space-y-2 p-3">
                      {Array.from({ length: 6 }).map((_, i) => (
                        <Skeleton key={i} className="h-8 w-full" />
                      ))}
                    </div>
                  ) : !filteredAreas.length ? (
                    <p className="p-6 text-center text-[13px] text-muted-foreground">
                      {areas.length ? t('noAreasFound') : t('noAreasAvailable')}
                    </p>
                  ) : (
                    <ul className="divide-y divide-border">
                      {filteredAreas.map((area) => {
                        const selected = day.areas.includes(area.id);
                        return (
                          <li key={area.id}>
                            <button
                              type="button"
                              onClick={() => setAreasSelected(activeDay, [area.id], !selected)}
                              aria-pressed={selected}
                              className={cn(
                                'flex w-full items-center gap-3 px-3 py-2.5 text-start text-sm hover:bg-muted',
                                selected && 'bg-accent/60'
                              )}>
                              <span
                                className={cn(
                                  'flex h-[18px] w-[18px] shrink-0 items-center justify-center rounded border',
                                  selected
                                    ? 'border-primary bg-primary text-primary-foreground'
                                    : 'border-input bg-card'
                                )}>
                                {selected && <IoCheckmark className="h-3 w-3" />}
                              </span>
                              <span className="truncate text-foreground">{nameOf(area.name)}</span>
                            </button>
                          </li>
                        );
                      })}
                    </ul>
                  )}
                </div>
              </div>
            </SectionCard>

            {/* Step 2: priority */}
            <SectionCard title={`2 · ${t('priority')}`}>
              <p className="mb-3 text-[13px] text-muted-foreground">{t('priorityHint')}</p>
              {day.areas.length === 0 ? (
                <div className="flex h-72 items-center justify-center rounded-md border border-dashed border-border text-[13px] text-muted-foreground">
                  {t('pickAreasFirst')}
                </div>
              ) : (
                <ul className="max-h-80 divide-y divide-border overflow-y-auto rounded-md border border-border">
                  {day.areas.map((id) => (
                    <li key={id} className="flex items-center gap-3 px-3 py-2">
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-medium text-foreground">
                          {nameOf(day.areaNames[id]) || id}
                        </p>
                        <p className="truncate text-xs text-muted-foreground">
                          {cityName(day.areaCities[id])}
                        </p>
                      </div>
                      <div
                        role="radiogroup"
                        aria-label={t('priority')}
                        className="flex shrink-0 rounded-md bg-muted p-0.5">
                        {[1, 2, 3, 4, 5].map((p) => {
                          const on = (day.areaPriorities[id] || 1) === p;
                          return (
                            <button
                              key={p}
                              type="button"
                              role="radio"
                              aria-checked={on}
                              onClick={() => setPriority(activeDay, id, p)}
                              className={cn(
                                'h-7 w-7 rounded text-xs font-semibold tabular-nums transition-colors',
                                on
                                  ? 'bg-primary text-primary-foreground shadow-sm'
                                  : 'text-muted-foreground hover:text-foreground'
                              )}>
                              {p}
                            </button>
                          );
                        })}
                      </div>
                      <button
                        type="button"
                        onClick={() => setAreasSelected(activeDay, [id], false)}
                        aria-label={t('remove')}
                        title={t('remove')}
                        className="rounded-full p-1 text-muted-foreground hover:bg-destructive/10 hover:text-destructive">
                        <IoClose className="h-4 w-4" />
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </SectionCard>

            {/* Step 3: hours */}
            <SectionCard
              className="xl:col-span-2"
              title={`3 · ${t('workingHours')}`}
              action={
                day.timeSlots.length > 0 && (
                  <Button
                    variant="tertiary"
                    size="sm"
                    onClick={() => setSlots(activeDay, TIME_SLOTS, false)}>
                    {t('clear')}
                  </Button>
                )
              }>
              <div className="space-y-5">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <p className="text-[13px] text-muted-foreground">
                    {t('hoursHint', { day: activeLabel })}
                  </p>
                  {dayRanges.length > 0 && (
                    <span className="rounded-full bg-accent px-3 py-1 text-xs font-semibold text-primary">
                      {t('hoursTotal', {
                        hours: formatDuration(day.timeSlots.length * 15),
                        count: dayRanges.length,
                      })}
                    </span>
                  )}
                </div>

                {/* Day timeline: one block per shift on a 24h scale */}
                <div>
                  <div className="relative h-10 rounded-md bg-muted">
                    {[3, 6, 9, 12, 15, 18, 21].map((h) => (
                      <span
                        key={h}
                        className="absolute inset-y-0 w-px bg-border"
                        style={{ insetInlineStart: `${(h / 24) * 100}%` }}
                      />
                    ))}
                    {dayRanges.map((r) => {
                      const start = toMinutes(r.from);
                      const len = toMinutes(r.to) - start;
                      return (
                        <span
                          key={`${r.from}-${r.to}`}
                          title={`${r.from}–${r.to}`}
                          className="absolute inset-y-1 flex items-center justify-center overflow-hidden rounded bg-primary px-1 text-[11px] font-medium tabular-nums text-primary-foreground"
                          style={{
                            insetInlineStart: `${(start / 1440) * 100}%`,
                            width: `${(len / 1440) * 100}%`,
                          }}>
                          {len >= 180 && `${r.from}–${r.to}`}
                        </span>
                      );
                    })}
                  </div>
                  <div className="relative mt-1 h-4 text-[11px] tabular-nums text-muted-foreground">
                    {[0, 3, 6, 9, 12, 15, 18, 21, 24].map((h) => (
                      <span
                        key={h}
                        className={cn(
                          'absolute',
                          h === 0
                            ? ''
                            : h === 24
                            ? '-translate-x-full rtl:translate-x-full'
                            : '-translate-x-1/2 rtl:translate-x-1/2'
                        )}
                        style={{ insetInlineStart: `${(h / 24) * 100}%` }}>
                        {h.toString().padStart(2, '0')}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Shifts */}
                {dayRanges.length === 0 ? (
                  <div className="rounded-md border border-dashed border-border px-4 py-6 text-center">
                    <p className="text-sm font-medium text-foreground">{t('noHoursSelected')}</p>
                    <p className="mt-1 text-[13px] text-muted-foreground">{t('noHoursHint')}</p>
                  </div>
                ) : (
                  <ul className="divide-y divide-border rounded-md border border-border">
                    {dayRanges.map((r, i) => (
                      <li
                        key={`${r.from}-${r.to}`}
                        className="flex flex-wrap items-center gap-x-3 gap-y-2 px-3 py-2.5">
                        <span className="w-16 shrink-0 text-[13px] font-semibold text-foreground">
                          {t('shift')} {i + 1}
                        </span>
                        <div className="flex items-center gap-2">
                          <TimeSelect
                            value={r.from}
                            options={TIME_SLOTS}
                            label={t('from')}
                            onChange={(v) => replaceRange(i, v, r.to)}
                          />
                          <span className="text-[13px] text-muted-foreground">{t('to')}</span>
                          <TimeSelect
                            value={r.to}
                            options={END_TIMES}
                            label={t('to')}
                            onChange={(v) => replaceRange(i, r.from, v)}
                          />
                        </div>
                        <span className="text-[13px] tabular-nums text-muted-foreground">
                          {formatDuration(toMinutes(r.to) - toMinutes(r.from))}
                        </span>
                        <button
                          type="button"
                          onClick={() => setSlots(activeDay, slotsBetween(r.from, r.to), false)}
                          aria-label={t('remove')}
                          title={t('remove')}
                          className="ms-auto rounded-full p-1.5 text-muted-foreground hover:bg-destructive/10 hover:text-destructive">
                          <IoTrashOutline className="h-4 w-4" />
                        </button>
                      </li>
                    ))}
                  </ul>
                )}

                <div className="space-y-2">
                  <Button variant="secondary" size="sm" onClick={addNextRange}>
                    + {t('addShift')}
                  </Button>
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="text-[13px] text-muted-foreground">{t('quickAdd')}</span>
                    {PRESETS.map((p) => (
                      <button
                        key={p.key}
                        type="button"
                        onClick={() => setSlots(activeDay, slotsBetween(p.from, p.to), true)}
                        className="rounded-full border border-input bg-card px-3 py-1 text-xs text-foreground hover:bg-accent">
                        {t(p.key)}{' '}
                        <span className="tabular-nums text-muted-foreground">
                          {p.from}–{p.to}
                        </span>
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </SectionCard>
          </div>
        </>
      )}

      {/* Unsaved changes bar */}
      {isDirty && (
        <div className="fixed inset-x-0 bottom-4 z-40 mx-auto flex w-fit items-center gap-3 rounded-full border border-border bg-card px-4 py-2 shadow-lg">
          <span className="text-[13px] text-foreground">{t('unsavedChanges')}</span>
          <Button size="sm" onClick={handleSave} loading={isSaving} disabled={isSaving}>
            {t('save')}
          </Button>
        </div>
      )}

      {/* Delete Schedule Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t('deleteSchedule')}</DialogTitle>
            <DialogDescription>{t('deleteScheduleConfirmation')}</DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="secondary" onClick={() => setIsDeleteDialogOpen(false)}>
              {t('cancel')}
            </Button>
            <Button variant="danger" onClick={handleDeleteSchedule} loading={isDeleting}>
              {t('delete')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Copy To Dialog */}
      <Dialog open={isCopyDialogOpen} onOpenChange={setIsCopyDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {t('copyScheduleTo')} · {activeLabel}
            </DialogTitle>
            <DialogDescription>{t('selectDaysToCopySchedule')}</DialogDescription>
          </DialogHeader>
          <div className="grid grid-cols-2 gap-2">
            {DAYS_OF_WEEK.filter((d) => d.value !== activeDay).map((d) => {
              const selected = copyToDays.includes(d.value);
              return (
                <button
                  key={d.value}
                  type="button"
                  aria-pressed={selected}
                  onClick={() =>
                    setCopyToDays((prev) =>
                      selected ? prev.filter((x) => x !== d.value) : [...prev, d.value]
                    )
                  }
                  className={cn(
                    'flex items-center gap-2 rounded-md border px-3 py-2 text-start text-sm',
                    selected
                      ? 'border-primary bg-accent text-primary'
                      : 'border-border bg-card text-foreground hover:bg-muted'
                  )}>
                  <span
                    className={cn(
                      'flex h-4 w-4 shrink-0 items-center justify-center rounded border',
                      selected
                        ? 'border-primary bg-primary text-primary-foreground'
                        : 'border-input'
                    )}>
                    {selected && <IoCheckmark className="h-3 w-3" />}
                  </span>
                  {d.label[lang]}
                </button>
              );
            })}
          </div>
          <DialogFooter>
            <Button variant="secondary" onClick={() => setIsCopyDialogOpen(false)}>
              {t('cancel')}
            </Button>
            <Button onClick={handleCopyConfirm} disabled={!copyToDays.length}>
              {t('copy')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
