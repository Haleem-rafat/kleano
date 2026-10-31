import { useState, useMemo, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  IoArrowBackCircleOutline,
  IoCalendarOutline,
  IoPersonCircleOutline,
  IoTimeOutline,
  IoLocationOutline,
  IoCopyOutline,
  IoSearchOutline,
  IoCheckmarkCircle,
  IoTrashOutline,
} from 'react-icons/io5';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import useSWR, { mutate } from 'swr';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@shadecn/components/ui/tabs';
import { Button } from '@shadecn/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@shadecn/components/ui/dialog';
import bikersService from '@services/bikers.service';
import staticService from '@services/static.service';
import { IBikers } from '@servicesTypes/bikers.types';
import { ROUTES } from '@constants/routes';
import { Icities } from '@servicesTypes/cities.types';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';

// Generate time slots for 24 hours in 15-minute intervals
const generateTimeSlots = () => {
  const slots = [];
  for (let hour = 0; hour < 24; hour++) {
    for (let minute = 0; minute < 60; minute += 15) {
      const timeString = `${hour.toString().padStart(2, '0')}:${minute
        .toString()
        .padStart(2, '0')}`;
      slots.push(timeString);
    }
  }
  return slots;
};

const TIME_SLOTS = generateTimeSlots();

const DAYS_OF_WEEK = [
  { value: 'saturday', label: { en: 'SATURDAY', ar: 'السبت' } },
  { value: 'sunday', label: { en: 'SUNDAY', ar: 'الأحد' } },
  { value: 'monday', label: { en: 'MONDAY', ar: 'الإثنين' } },
  { value: 'tuesday', label: { en: 'TUESDAY', ar: 'الثلاثاء' } },
  { value: 'wednesday', label: { en: 'WEDNESDAY', ar: 'الأربعاء' } },
  { value: 'thursday', label: { en: 'THURSDAY', ar: 'الخميس' } },
  { value: 'friday', label: { en: 'FRIDAY', ar: 'الجمعة' } },
];

interface ScheduleData {
  areas: string[];
  timeSlots: string[];
  areaPriorities: Record<string, number>;
  areaCities: Record<string, string>;
  areaNames: Record<string, { en: string; ar: string }>;
}

export default function BikersSchedule() {
  const { bikerId } = useParams();
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data: bikerData, isLoading: isLoadingBiker } = useSWR(
    ['get-biker-details', bikerId],
    () => bikerId && bikersService.getBikerById(bikerId).then((data) => data?.data as IBikers)
  );

  const { data: scheduleData } = useSWR(
    ['get-biker-schedule', bikerId],
    () => bikerId && bikersService.getBikerSchedule(bikerId)
  );

  const { citiesOptions } = useGetCitiesOptions();
  const [selectedCityId, setSelectedCityId] = useState<string>('');
  const [citySearchQuery, setCitySearchQuery] = useState<string>('');
  const [areaSearchQuery, setAreaSearchQuery] = useState<string>('');

  const { data: areasData, isLoading: isLoadingAreas } = useSWR(
    ['get-Areas', selectedCityId],
    () => selectedCityId && staticService.getAreasOptions(selectedCityId)
  );

  const areas = useMemo(() => {
    if (!areasData?.data) return [];
    return (areasData.data as Icities[]).map((area) => ({
      id: area?._id,
      name: area?.name,
    }));
  }, [areasData]);

  const filteredCities = useMemo(() => {
    if (!citySearchQuery.trim()) return citiesOptions;
    const query = citySearchQuery.toLowerCase().trim();
    return citiesOptions.filter((city) => city.label.toLowerCase().includes(query));
  }, [citiesOptions, citySearchQuery]);

  const filteredAreas = useMemo(() => {
    if (!areaSearchQuery.trim()) return areas;
    const query = areaSearchQuery.toLowerCase().trim();
    return areas.filter(
      (area) => area?.name.en.toLowerCase().includes(query) || area?.name.ar.includes(query)
    );
  }, [areas, areaSearchQuery]);

  const [activeDay, setActiveDay] = useState('saturday');
  const [schedule, setSchedule] = useState<Record<string, ScheduleData>>(() => {
    const initialSchedule: Record<string, ScheduleData> = {};
    DAYS_OF_WEEK.forEach((day) => {
      initialSchedule[day.value] = {
        areas: [],
        timeSlots: [],
        areaPriorities: {},
        areaCities: {},
        areaNames: {},
      };
    });
    return initialSchedule;
  });
  const [isSaving, setIsSaving] = useState(false);
  const [isCopyDialogOpen, setIsCopyDialogOpen] = useState(false);
  const [copyToDays, setCopyToDays] = useState<string[]>([]);
  const [sourceDay, setSourceDay] = useState<string>('');
  const [isScheduleLoaded, setIsScheduleLoaded] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);
  const [weekends, setWeekends] = useState<string[]>([]);

  useEffect(() => {
    if (scheduleData?.data?.weekends && Array.isArray(scheduleData.data.weekends)) {
      setWeekends(scheduleData.data.weekends);
    }
  }, [scheduleData]);

  useEffect(() => {
    if (
      scheduleData?.data &&
      scheduleData.data.shifts &&
      scheduleData.data.shifts.length > 0 &&
      !isScheduleLoaded
    ) {
      const shifts = scheduleData.data.shifts;
      const firstShift = shifts[0];
      const cityId = firstShift.city?._id || firstShift.city;

      if (cityId && !selectedCityId) {
        setSelectedCityId(cityId);
      }
    } else if (scheduleData?.data === null && !isScheduleLoaded) {
      setIsScheduleLoaded(true);
    }
  }, [scheduleData, isScheduleLoaded, selectedCityId]);

  useEffect(() => {
    if (
      scheduleData?.data?.shifts &&
      scheduleData.data.shifts.length > 0 &&
      !isScheduleLoaded &&
      selectedCityId &&
      areas.length > 0
    ) {
      const shifts = scheduleData.data.shifts;
      const parsedSchedule: Record<string, ScheduleData> = {};
      DAYS_OF_WEEK.forEach((day) => {
        parsedSchedule[day.value] = {
          areas: [],
          timeSlots: [],
          areaPriorities: {},
          areaCities: {},
          areaNames: {},
        };
      });

      shifts.forEach(
        (shift: {
          day: string;
          area: { _id: string; name?: { en: string; ar: string } } | string;
          city: { _id: string } | string;
          timeSlot: string;
          priorityLevel?: number;
        }) => {
          const dayName = shift?.day.toLowerCase();
          const areaId = typeof shift?.area === 'object' ? shift?.area?._id : shift?.area;
          const areaName =
            typeof shift?.area === 'object' && shift?.area?.name
              ? shift?.area?.name
              : { en: areaId, ar: areaId };
          const cityId = typeof shift?.city === 'object' ? shift?.city?._id : shift?.city;
          const timeSlot = shift?.timeSlot;
          const priorityLevel = shift?.priorityLevel || 1;

          if (parsedSchedule[dayName]) {
            if (!parsedSchedule[dayName].areas.includes(areaId)) {
              parsedSchedule[dayName].areas.push(areaId);
            }
            if (!parsedSchedule[dayName].timeSlots.includes(timeSlot)) {
              parsedSchedule[dayName].timeSlots.push(timeSlot);
            }
            parsedSchedule[dayName].areaPriorities[areaId] = priorityLevel;
            parsedSchedule[dayName].areaCities[areaId] = cityId;
            parsedSchedule[dayName].areaNames[areaId] = areaName;
          }
        }
      );

      setSchedule(parsedSchedule);
      setIsScheduleLoaded(true);
    }
  }, [scheduleData, isScheduleLoaded, selectedCityId, areas]);

  const toggleArea = (day: string, areaId: string) => {
    setSchedule((prev) => {
      const daySchedule = prev[day];
      const isSelected = daySchedule.areas.includes(areaId);
      const newAreas = isSelected
        ? daySchedule.areas.filter((id) => id !== areaId)
        : [...daySchedule.areas, areaId];
      const newPriorities = { ...daySchedule.areaPriorities };
      const newAreaCities = { ...daySchedule.areaCities };
      const newAreaNames = { ...daySchedule.areaNames };
      if (isSelected) {
        delete newPriorities[areaId];
        delete newAreaCities[areaId];
        delete newAreaNames[areaId];
      } else {
        const area = areas.find((a) => a.id === areaId);
        newPriorities[areaId] = 1;
        newAreaCities[areaId] = selectedCityId;
        if (area) {
          newAreaNames[areaId] = area?.name;
        }
      }
      return {
        ...prev,
        [day]: {
          ...daySchedule,
          areas: newAreas,
          areaPriorities: newPriorities,
          areaCities: newAreaCities,
          areaNames: newAreaNames,
        },
      };
    });
  };

  const handleSelectAllAreas = (day: string) => {
    const daySchedule = schedule[day];
    const filteredAreaIds = filteredAreas.map((area) => area.id);
    const allSelected = filteredAreaIds.every((id) => daySchedule.areas.includes(id));

    if (allSelected) {
      setSchedule((prev) => {
        const daySchedule = prev[day];
        const newAreas = daySchedule.areas.filter((id) => !filteredAreaIds.includes(id));
        const newPriorities = { ...daySchedule.areaPriorities };
        const newAreaCities = { ...daySchedule.areaCities };
        const newAreaNames = { ...daySchedule.areaNames };
        filteredAreaIds.forEach((id) => {
          delete newPriorities[id];
          delete newAreaCities[id];
          delete newAreaNames[id];
        });
        return {
          ...prev,
          [day]: {
            ...daySchedule,
            areas: newAreas,
            areaPriorities: newPriorities,
            areaCities: newAreaCities,
            areaNames: newAreaNames,
          },
        };
      });
    } else {
      setSchedule((prev) => {
        const daySchedule = prev[day];
        const newAreas = [...new Set([...daySchedule.areas, ...filteredAreaIds])];
        const newPriorities = { ...daySchedule.areaPriorities };
        const newAreaCities = { ...daySchedule.areaCities };
        const newAreaNames = { ...daySchedule.areaNames };
        filteredAreaIds.forEach((id) => {
          if (!daySchedule.areas.includes(id)) {
            newPriorities[id] = 1;
            newAreaCities[id] = selectedCityId;
            const area = areas.find((a) => a.id === id);
            if (area) {
              newAreaNames[id] = area?.name;
            }
          }
        });
        return {
          ...prev,
          [day]: {
            ...daySchedule,
            areas: newAreas,
            areaPriorities: newPriorities,
            areaCities: newAreaCities,
            areaNames: newAreaNames,
          },
        };
      });
    }
  };

  const updateAreaPriority = (day: string, areaId: string, priority: number) => {
    setSchedule((prev) => {
      const daySchedule = prev[day];
      return {
        ...prev,
        [day]: {
          ...daySchedule,
          areaPriorities: {
            ...daySchedule.areaPriorities,
            [areaId]: priority,
          },
        },
      };
    });
  };

  const toggleTimeSlot = (day: string, timeSlot: string) => {
    setSchedule((prev) => {
      const daySchedule = prev[day];
      const isSelected = daySchedule.timeSlots.includes(timeSlot);
      return {
        ...prev,
        [day]: {
          ...daySchedule,
          timeSlots: isSelected
            ? daySchedule.timeSlots.filter((time) => time !== timeSlot)
            : [...daySchedule.timeSlots, timeSlot],
        },
      };
    });
  };

  const hasExistingSchedule = useMemo(() => !!scheduleData?.data?._id, [scheduleData]);

  const handleSave = async () => {
    setIsSaving(true);

    if (!bikerId || !bikerData) {
      toast.error(t('bikerNotFound'));
      setIsSaving(false);
      return;
    }

    const bikerIdValue = bikerId;

    const shifts: Array<{
      timeSlot: string;
      city: string;
      area: string;
      day: string;
      priorityLevel: number;
    }> = [];

    DAYS_OF_WEEK.forEach((day) => {
      const daySchedule = schedule[day.value];
      const dayName = day.label.en.toUpperCase();

      daySchedule.areas.forEach((areaId) => {
        const priorityLevel = daySchedule.areaPriorities[areaId] || 1;
        const cityId = daySchedule.areaCities[areaId];

        if (!cityId) {
          return;
        }

        daySchedule.timeSlots.forEach((timeSlot) => {
          shifts.push({
            timeSlot,
            city: cityId,
            area: areaId,
            day: dayName,
            priorityLevel,
          });
        });
      });
    });

    const apiPayload: {
      biker: string;
      shifts: Array<{
        timeSlot: string;
        city: string;
        area: string;
        day: string;
        priorityLevel: number;
      }>;
      weekends?: string[];
    } = {
      biker: bikerIdValue,
      shifts,
    };

    if (weekends.length > 0) {
      apiPayload.weekends = weekends;
    }
    try {
      const response = hasExistingSchedule
        ? await bikersService.updateBikerSchedule(bikerIdValue, apiPayload)
        : await bikersService.createBikerSchedule(apiPayload);
      if (response.success) {
        toast.success(t('scheduleSaved'));
        mutate(['get-biker-schedule', bikerIdValue]);
      } else {
        toast.error(t('scheduleSaved'));
      }
    } catch (error) {
      toast.error(t('scheduleSaved'));
    } finally {
      setIsSaving(false);
    }
  };

  const handleCopyToClick = (day: string) => {
    setSourceDay(day);
    setCopyToDays([]);
    setIsCopyDialogOpen(true);
  };

  const toggleCopyToDay = (dayValue: string) => {
    setCopyToDays((prev) =>
      prev.includes(dayValue) ? prev.filter((d) => d !== dayValue) : [...prev, dayValue]
    );
  };

  const handleCopyConfirm = () => {
    if (copyToDays.length === 0) {
      toast.warning(t('selectDaysToCopy'));
      return;
    }

    const sourceSchedule = schedule[sourceDay];
    setSchedule((prev) => {
      const updated = { ...prev };
      copyToDays.forEach((day) => {
        updated[day] = {
          areas: [...sourceSchedule.areas],
          timeSlots: [...sourceSchedule.timeSlots],
          areaPriorities: { ...sourceSchedule.areaPriorities },
          areaCities: { ...sourceSchedule.areaCities },
          areaNames: { ...sourceSchedule.areaNames },
        };
      });
      return updated;
    });

    setIsCopyDialogOpen(false);
    setCopyToDays([]);
    toast.success(t('scheduleCopied'));
  };

  const getOtherDays = (currentDay: string) => {
    return DAYS_OF_WEEK.filter((day) => day.value !== currentDay);
  };

  const handleDeleteSchedule = async () => {
    if (!bikerId) {
      toast.error(t('bikerNotFound'));
      return;
    }

    setIsDeleting(true);
    try {
      const response = await bikersService.deleteBikerSchedule(bikerId);
      if (response.success) {
        toast.success(t('scheduleDeleted'));
        mutate(['get-biker-schedule', bikerId]);
        setSchedule(() => {
          const initialSchedule: Record<string, ScheduleData> = {};
          DAYS_OF_WEEK.forEach((day) => {
            initialSchedule[day.value] = {
              areas: [],
              timeSlots: [],
              areaPriorities: {},
              areaCities: {},
              areaNames: {},
            };
          });
          return initialSchedule;
        });
        setWeekends([]);
        setSelectedCityId('');
        setIsScheduleLoaded(false);
        setIsDeleteDialogOpen(false);
        navigate(ROUTES.BIKERS);
      } else {
        toast.error(t('scheduleDeleteError'));
      }
    } catch (error) {
      toast.error(t('scheduleDeleteError'));
    } finally {
      setIsDeleting(false);
    }
  };

  const selectedAreasByCity = useMemo(() => {
    const daySchedule = schedule[activeDay];
    const grouped: Record<
      string,
      { cityName: string; areas: Array<{ id: string; name: { en: string; ar: string } }> }
    > = {};

    daySchedule.areas.forEach((areaId) => {
      const cityId = daySchedule.areaCities[areaId];
      if (!cityId) return;

      const city = citiesOptions.find((c) => c.value === cityId);
      if (!city) return;

      if (!grouped[cityId]) {
        grouped[cityId] = {
          cityName: city.label,
          areas: [],
        };
      }

      const storedName = daySchedule.areaNames[areaId];
      if (storedName) {
        grouped[cityId].areas.push({
          id: areaId,
          name: storedName,
        });
      } else {
        const area = areas.find((a) => a.id === areaId);
        if (area) {
          grouped[cityId].areas.push(area);
        } else {
          grouped[cityId].areas.push({
            id: areaId,
            name: { en: areaId, ar: areaId },
          });
        }
      }
    });

    return Object.values(grouped);
  }, [schedule, activeDay, citiesOptions, areas]);

  if (isLoadingBiker) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-lg text-slate-600">{t('loading')}...</div>
      </div>
    );
  }

  if (!bikerData) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-lg text-red-600">{t('bikerNotFound')}</div>
      </div>
    );
  }

  return (
    <div className="space-y-1">
      {/* Professional Header */}
      <div className="pb-4">
        <div>
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 transition-colors duration-200 hover:bg-slate-200">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('bikerSchedule')}</h1>
                <p className="mt-1 text-sm text-slate-500">
                  {t('bikerId')}: #{bikerId?.slice(-4) || bikerData?._id?.slice(-4)}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2 space-x-3 ">
              {hasExistingSchedule && (
                <Button
                  type="button"
                  onClick={() => setIsDeleteDialogOpen(true)}
                  variant="destructive"
                  className="bg-red-600 hover:bg-red-700">
                  <IoTrashOutline className="mr-2 h-4 w-4" />
                  {t('deleteSchedule')}
                </Button>
              )}
              <Button
                onClick={handleSave}
                disabled={isSaving}
                className="bg-primary hover:bg-primary">
                {isSaving ? t('saving') : t('save')}
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="pt-1">
        <div className="w-full">
          {/* Weekend Selection Card */}
          <div className="mb-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
            <div className="border-b border-slate-100 bg-white px-5 py-3">
              <div className="flex items-center space-x-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                  <IoCalendarOutline className="h-4 w-4 text-primary" />
                </div>
                <div>
                  <h2 className="text-sm font-semibold text-slate-900">{t('weekendDays')}</h2>
                  <p className="text-sm text-slate-500">{t('selectWeekendDays')}</p>
                </div>
              </div>
            </div>
            <div className="p-6">
              <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-7">
                {DAYS_OF_WEEK.map((day) => {
                  const dayName = day.label.en.toUpperCase();
                  const isSelected = weekends.includes(dayName);
                  return (
                    <button
                      key={day.value}
                      type="button"
                      onClick={() => {
                        setWeekends((prev) =>
                          isSelected ? prev.filter((d) => d !== dayName) : [...prev, dayName]
                        );
                      }}
                      className={`flex items-center space-x-2 rounded-lg border-2 p-3 text-left transition-all duration-200 ${
                        isSelected
                          ? 'border-primary bg-brandTint text-primary'
                          : 'border-slate-200 bg-white text-slate-700 hover:border-primary/30 hover:bg-brandTint'
                      }`}>
                      <div
                        className={`flex h-5 w-5 items-center justify-center rounded border-2 ${
                          isSelected
                            ? 'border-primary bg-primary'
                            : 'border-slate-300 bg-white'
                        }`}>
                        {isSelected && (
                          <svg
                            className="h-3 w-3 text-white"
                            fill="none"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            viewBox="0 0 24 24"
                            stroke="currentColor">
                            <path d="M5 13l4 4L19 7" />
                          </svg>
                        )}
                      </div>
                      <span className="text-sm font-medium">{day.label[lang]}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            {/* Schedule Card */}
            <div className="xl:col-span-2">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoCalendarOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('bikerSchedule')}</h2>
                      <p className="text-sm text-slate-500">{t('manageWeeklySchedule')}</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <Tabs value={activeDay} onValueChange={setActiveDay} className="w-full">
                    <TabsList className="mb-6 grid w-full grid-cols-7">
                      {DAYS_OF_WEEK.map((day) => (
                        <TabsTrigger
                          key={day.value}
                          value={day.value}
                          className="text-xs data-[state=active]:shadow-md">
                          {day.label[lang]}
                        </TabsTrigger>
                      ))}
                    </TabsList>

                    {DAYS_OF_WEEK.map((day) => (
                      <TabsContent key={day.value} value={day.value} className="space-y-6">
                        {/* Copy To Button */}
                        <div className="flex justify-end">
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleCopyToClick(day.value)}
                            className="flex items-center space-x-2 border-primary/30 text-primary hover:bg-brandTint">
                            <IoCopyOutline className="h-4 w-4" />
                            <span>{t('copyTo')}</span>
                          </Button>
                        </div>
                        {/* Selected Areas Summary Card */}
                        {selectedAreasByCity.length > 0 && (
                          <div className="mb-6 rounded-lg border-2 border-primary/30 bg-brandTint p-4">
                            <div className="mb-3 flex items-center space-x-2">
                              <IoCheckmarkCircle className="h-5 w-5 text-primary" />
                              <h3 className="text-base font-semibold text-primary">
                                {t('selectedAreas')} ({day.label[lang]})
                              </h3>
                            </div>
                            <div className="space-y-3">
                              {selectedAreasByCity.map((cityGroup) => (
                                <div
                                  key={cityGroup.cityName}
                                  className="rounded-lg border border-primary/30 bg-white p-3">
                                  <div className="mb-2 flex items-center justify-between">
                                    <div className="flex items-center space-x-2">
                                      <IoLocationOutline className="h-4 w-4 text-primary" />
                                      <span className="text-sm font-semibold text-slate-900">
                                        {cityGroup.cityName}
                                      </span>
                                    </div>
                                    <span className="text-xs font-medium text-slate-500">
                                      {cityGroup.areas.length} {t('areas')}
                                    </span>
                                  </div>
                                  <div className="flex flex-wrap gap-2">
                                    {cityGroup.areas.map((area) => {
                                      const priority =
                                        schedule[day.value].areaPriorities[area.id] || 1;
                                      return (
                                        <div
                                          key={area.id}
                                          className="flex items-center space-x-1.5 rounded-md border border-primary/30 bg-brandTint px-2.5 py-1">
                                          <span className="text-xs font-medium text-primary">
                                            {area?.name[lang]}
                                          </span>
                                          <span className="text-xs font-semibold text-primary">
                                            (P{priority})
                                          </span>
                                        </div>
                                      );
                                    })}
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}

                        {/* City Selection */}
                        <div>
                          <div className="mb-4 flex items-center space-x-2">
                            <IoLocationOutline className="h-5 w-5 text-primary" />
                            <h3 className="text-sm font-semibold text-slate-900">{t('city')}</h3>
                          </div>
                          {citiesOptions.length === 0 ? (
                            <div className="flex items-center justify-center py-8">
                              <div className="text-sm text-slate-500">{t('loading')}...</div>
                            </div>
                          ) : (
                            <>
                              {/* Search Bar */}
                              <div className="mb-4">
                                <div className="relative">
                                  <IoSearchOutline className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
                                  <input
                                    type="text"
                                    placeholder={t('searchCities')}
                                    value={citySearchQuery}
                                    onChange={(e) => setCitySearchQuery(e.target.value)}
                                    className="w-full rounded-lg border border-slate-300 bg-white py-2.5 pl-10 pr-4 text-sm text-slate-700 placeholder-slate-400 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/40 focus:ring-offset-1"
                                  />
                                </div>
                              </div>

                              {/* Cities Grid */}
                              {filteredCities.length === 0 ? (
                                <div className="mb-6 flex items-center justify-center py-8">
                                  <div className="text-sm text-slate-500">{t('noCitiesFound')}</div>
                                </div>
                              ) : (
                                <div className="mb-6 grid max-h-96 grid-cols-2 gap-3 overflow-y-auto sm:grid-cols-3 md:grid-cols-4">
                                  {filteredCities.map((city) => {
                                    const isSelected = selectedCityId === city.value;
                                    return (
                                      <button
                                        key={city.value}
                                        type="button"
                                        onClick={() => {
                                          setSelectedCityId(city.value);
                                          setAreaSearchQuery('');
                                        }}
                                        className={`flex w-full items-center space-x-2 rounded-lg border-2 p-3 text-left transition-all duration-200 ${
                                          isSelected
                                            ? 'border-primary bg-brandTint text-primary'
                                            : 'border-slate-200 bg-white text-slate-700 hover:border-primary/30 hover:bg-brandTint'
                                        }`}>
                                        <div
                                          className={`flex h-5 w-5 items-center justify-center rounded border-2 ${
                                            isSelected
                                              ? 'border-primary bg-primary'
                                              : 'border-slate-300 bg-white'
                                          }`}>
                                          {isSelected && (
                                            <svg
                                              className="h-3 w-3 text-white"
                                              fill="none"
                                              strokeLinecap="round"
                                              strokeLinejoin="round"
                                              strokeWidth="2"
                                              viewBox="0 0 24 24"
                                              stroke="currentColor">
                                              <path d="M5 13l4 4L19 7" />
                                            </svg>
                                          )}
                                        </div>
                                        <span className="text-sm font-medium">{city.label}</span>
                                      </button>
                                    );
                                  })}
                                </div>
                              )}
                            </>
                          )}
                        </div>

                        {/* Areas Section */}
                        <div>
                          <div className="mb-4 flex items-center space-x-2">
                            <IoLocationOutline className="h-5 w-5 text-primary" />
                            <h3 className="text-sm font-semibold text-slate-900">
                              {t('selectAreas')}
                            </h3>
                          </div>
                          {!selectedCityId ? (
                            <div className="flex items-center justify-center py-8">
                              <div className="text-sm text-slate-500">
                                {t('pleaseSelectCityFirst')}
                              </div>
                            </div>
                          ) : isLoadingAreas ? (
                            <div className="flex items-center justify-center py-8">
                              <div className="text-sm text-slate-500">{t('loading')}...</div>
                            </div>
                          ) : areas.length === 0 ? (
                            <div className="flex items-center justify-center py-8">
                              <div className="text-sm text-slate-500">{t('noAreasAvailable')}</div>
                            </div>
                          ) : (
                            <>
                              {/* Search Bar and Select All */}
                              <div className="mb-4 space-y-3">
                                <div className="relative">
                                  <IoSearchOutline className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
                                  <input
                                    type="text"
                                    placeholder={t('searchAreas')}
                                    value={areaSearchQuery}
                                    onChange={(e) => setAreaSearchQuery(e.target.value)}
                                    className="w-full rounded-lg border border-slate-300 bg-white py-2.5 pl-10 pr-4 text-sm text-slate-700 placeholder-slate-400 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/40 focus:ring-offset-1"
                                  />
                                </div>
                                {filteredAreas.length > 0 && (
                                  <Button
                                    type="button"
                                    variant="outline"
                                    onClick={() => handleSelectAllAreas(day.value)}
                                    className="w-full border-primary/30 text-primary hover:bg-brandTint">
                                    {filteredAreas.every((area) =>
                                      schedule[day.value].areas.includes(area.id)
                                    )
                                      ? t('deselectAll')
                                      : t('selectAll')}
                                  </Button>
                                )}
                              </div>

                              {/* Areas Grid */}
                              {filteredAreas.length === 0 ? (
                                <div className="flex items-center justify-center py-8">
                                  <div className="text-sm text-slate-500">{t('noAreasFound')}</div>
                                </div>
                              ) : (
                                <div className="grid max-h-96 grid-cols-2 gap-3 overflow-y-auto sm:grid-cols-3 md:grid-cols-4">
                                  {filteredAreas.map((area) => {
                                    const isSelected = schedule[day.value].areas.includes(area.id);
                                    const priority =
                                      schedule[day.value].areaPriorities[area.id] || 1;
                                    return (
                                      <div key={area.id} className="space-y-2">
                                        <button
                                          type="button"
                                          onClick={() => toggleArea(day.value, area.id)}
                                          className={`flex w-full items-center space-x-2 rounded-lg border-2 p-3 text-left transition-all duration-200 ${
                                            isSelected
                                              ? 'border-primary bg-brandTint text-primary'
                                              : 'border-slate-200 bg-white text-slate-700 hover:border-primary/30 hover:bg-brandTint'
                                          }`}>
                                          <div
                                            className={`flex h-5 w-5 items-center justify-center rounded border-2 ${
                                              isSelected
                                                ? 'border-primary bg-primary'
                                                : 'border-slate-300 bg-white'
                                            }`}>
                                            {isSelected && (
                                              <svg
                                                className="h-3 w-3 text-white"
                                                fill="none"
                                                strokeLinecap="round"
                                                strokeLinejoin="round"
                                                strokeWidth="2"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor">
                                                <path d="M5 13l4 4L19 7" />
                                              </svg>
                                            )}
                                          </div>
                                          <span className="text-sm font-medium">
                                            {area?.name[lang]}
                                          </span>
                                        </button>
                                        {isSelected && (
                                          <div className="flex items-center space-x-2">
                                            <label className="text-xs font-medium text-slate-600">
                                              {t('priority')}:
                                            </label>
                                            <select
                                              value={priority}
                                              onChange={(e) =>
                                                updateAreaPriority(
                                                  day.value,
                                                  area.id,
                                                  parseInt(e.target.value, 10)
                                                )
                                              }
                                              onClick={(e) => e.stopPropagation()}
                                              className="h-8 rounded border border-slate-300 bg-white px-2 text-xs font-medium text-slate-700 focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary/40">
                                              <option value={1}>1</option>
                                              <option value={2}>2</option>
                                              <option value={3}>3</option>
                                            </select>
                                          </div>
                                        )}
                                      </div>
                                    );
                                  })}
                                </div>
                              )}
                            </>
                          )}
                        </div>

                        {/* Time Slots Section */}
                        <div>
                          <div className="mb-4 flex items-center space-x-2">
                            <IoTimeOutline className="h-5 w-5 text-primary" />
                            <h3 className="text-sm font-semibold text-slate-900">
                              {t('selectTimeSlots')}
                            </h3>
                          </div>
                          <div className="max-h-96 space-y-2 overflow-y-auto rounded-lg border border-slate-200 bg-slate-50 p-4">
                            <div className="grid grid-cols-4 gap-2 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10">
                              {TIME_SLOTS.map((timeSlot) => {
                                const isSelected = schedule[day.value].timeSlots.includes(timeSlot);
                                return (
                                  <button
                                    key={timeSlot}
                                    type="button"
                                    onClick={() => toggleTimeSlot(day.value, timeSlot)}
                                    className={`rounded-md border-2 px-2 py-1.5 text-xs font-medium transition-all duration-200 ${
                                      isSelected
                                        ? 'border-primary bg-primary text-white'
                                        : 'border-slate-200 bg-white text-slate-700 hover:border-primary/30 hover:bg-brandTint'
                                    }`}>
                                    {timeSlot}
                                  </button>
                                );
                              })}
                            </div>
                          </div>
                        </div>
                      </TabsContent>
                    ))}
                  </Tabs>
                </div>
              </div>
            </div>{' '}
            {/* Biker Information Card */}
            <div className="xl:col-span-1">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoPersonCircleOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('bikerInfo')}</h2>
                      <p className="text-sm text-slate-500">{t('basicInformation')}</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="space-y-4">
                    <div className="flex justify-center">
                      <img
                        className="h-24 w-24 rounded-full object-cover"
                        src={bikerData?.imageLink || 'https://via.placeholder.com/150'}
                        alt={t('bikerProfile')}
                      />
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-xs font-medium uppercase tracking-wide text-slate-500">
                        {t('name')}
                      </h4>
                      <p className="text-sm font-semibold text-slate-900">{bikerData?.userName}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-xs font-medium uppercase tracking-wide text-slate-500">
                        {t('phone')}
                      </h4>
                      <p className="text-sm font-semibold text-slate-900">{bikerData?.phone}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-xs font-medium uppercase tracking-wide text-slate-500">
                        {t('city')}
                      </h4>
                      <p className="text-sm font-semibold text-slate-900">
                        {bikerData?.city?.name?.[lang] || '-'}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Delete Schedule Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold text-slate-900">
              {t('deleteSchedule')}
            </DialogTitle>
            <DialogDescription className="text-sm text-slate-500">
              {t('deleteScheduleConfirmation')}
            </DialogDescription>
          </DialogHeader>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => setIsDeleteDialogOpen(false)}
              disabled={isDeleting}>
              {t('cancel')}
            </Button>
            <Button
              type="button"
              onClick={handleDeleteSchedule}
              disabled={isDeleting}
              variant="destructive"
              className="bg-red-600 hover:bg-red-700">
              {isDeleting ? t('deleting') : t('delete')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Copy To Dialog */}
      <Dialog open={isCopyDialogOpen} onOpenChange={setIsCopyDialogOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold text-slate-900">
              {t('copyScheduleTo')}
            </DialogTitle>
            <DialogDescription className="text-sm text-slate-500">
              {t('selectDaysToCopySchedule')}
            </DialogDescription>
          </DialogHeader>

          <div className="py-4">
            <div className="space-y-2">
              {getOtherDays(sourceDay).map((day) => {
                const isSelected = copyToDays.includes(day.value);
                return (
                  <button
                    key={day.value}
                    type="button"
                    onClick={() => toggleCopyToDay(day.value)}
                    className={`flex w-full items-center space-x-3 rounded-lg border-2 p-3 text-left transition-all duration-200 ${
                      isSelected
                        ? 'border-primary bg-brandTint text-primary'
                        : 'border-slate-200 bg-white text-slate-700 hover:border-primary/30 hover:bg-brandTint'
                    }`}>
                    <div
                      className={`flex h-5 w-5 items-center justify-center rounded border-2 ${
                        isSelected ? 'border-primary bg-primary' : 'border-slate-300 bg-white'
                      }`}>
                      {isSelected && (
                        <svg
                          className="h-3 w-3 text-white"
                          fill="none"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth="2"
                          viewBox="0 0 24 24"
                          stroke="currentColor">
                          <path d="M5 13l4 4L19 7" />
                        </svg>
                      )}
                    </div>
                    <span className="text-sm font-medium">{day.label[lang]}</span>
                  </button>
                );
              })}
            </div>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                setIsCopyDialogOpen(false);
                setCopyToDays([]);
              }}>
              {t('cancel')}
            </Button>
            <Button
              type="button"
              onClick={handleCopyConfirm}
              className="bg-primary hover:bg-primary">
              {t('copy')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
