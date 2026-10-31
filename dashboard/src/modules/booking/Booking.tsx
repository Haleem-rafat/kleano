import React, { useState, useMemo, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { format } from 'date-fns';
import { CalendarIcon, Loader2 } from 'lucide-react';
import useSWR from 'swr';
import { Form } from '@shadecn/components/ui/form';
import { ROUTES } from '@constants/routes';
import bookingService from '@services/booking.service';
import { MainSelect } from '@UI/Index';
import { formatToFilterDate } from '@app/utils/helper';
import { Calendar } from '@/shadecn/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';
import { Button } from '@/shadecn/components/ui/button';
import { cn } from '@/shadecn/lib/utils';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';
import useGetAreasOptions from '@/hooks/useGetAreasOptions';

const DAYS_OF_WEEK = [
  { value: 'FRIDAY', label: { en: 'Friday', ar: 'الجمعة' } },
  { value: 'SATURDAY', label: { en: 'Saturday', ar: 'السبت' } },
  { value: 'SUNDAY', label: { en: 'Sunday', ar: 'الأحد' } },
  { value: 'MONDAY', label: { en: 'Monday', ar: 'الإثنين' } },
  { value: 'TUESDAY', label: { en: 'Tuesday', ar: 'الثلاثاء' } },
  { value: 'WEDNESDAY', label: { en: 'Wednesday', ar: 'الأربعاء' } },
  { value: 'THURSDAY', label: { en: 'Thursday', ar: 'الخميس' } },
];

// Generate hourly time slots (24 hours) - static timeline
const generateHourlySlots = () => {
  const slots = [];
  for (let hour = 0; hour < 24; hour++) {
    const hour12 = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
    const period = hour < 12 ? 'AM' : 'PM';
    slots.push({
      value: `${hour.toString().padStart(2, '0')}:00`,
      label: `${period} ${hour12}:00`,
      hour24: hour,
      startTime: hour * 60, // minutes from midnight
      endTime: (hour + 1) * 60, // minutes from midnight
    });
  }
  return slots;
};

const HOURLY_SLOTS = generateHourlySlots();

interface BookingTimeSlot {
  bikers: {
    _id: string;
    userName: string;
    phone: string;
    nationalId: string;
  }[];
  timeSlot: string;
}

// Helper function to convert date to day of week
const getDayOfWeekFromDate = (date: Date): string => {
  const dayIndex = date.getDay();
  const dayMap: Record<number, string> = {
    0: 'SUNDAY',
    1: 'MONDAY',
    2: 'TUESDAY',
    3: 'WEDNESDAY',
    4: 'THURSDAY',
    5: 'FRIDAY',
    6: 'SATURDAY',
  };
  return dayMap[dayIndex] || 'SUNDAY';
};

const Booking = () => {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();
  // Get initial values from URL params or use empty strings
  const dayParam = searchParams.get('day') || '';
  const cityParam = searchParams.get('city') || '';
  const areaParam = searchParams.get('area') || '';
  const dateParam = searchParams.get('date') || '';

  const [selectedDay, setSelectedDay] = useState<string>(dayParam);
  const [selectedCity, setSelectedCity] = useState<string>(cityParam);
  const [selectedArea, setSelectedArea] = useState<string>(areaParam);
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(
    dateParam ? new Date(dateParam) : undefined
  );

  // Create form instance for MainSelect context (not used for validation)
  const form = useForm({
    defaultValues: {
      day: '',
      city: '',
      area: '',
    },
  });

  // Convert DAYS_OF_WEEK to options format for MainSelect
  const dayOptions = useMemo(
    () =>
      DAYS_OF_WEEK.map((day) => ({
        label: day.label[lang],
        value: day.value,
      })),
    [lang]
  );

  const { citiesOptions } = useGetCitiesOptions();
  const { AreasOptions, loadingAreasOptions } = useGetAreasOptions(selectedCity);

  // Set default values when options are loaded
  useEffect(() => {
    if (!dayParam && DAYS_OF_WEEK.length > 0 && !selectedDay) {
      const defaultDay = DAYS_OF_WEEK[0].value;
      setSelectedDay(defaultDay);
    }
  }, [dayParam, selectedDay]);

  useEffect(() => {
    if (!cityParam && citiesOptions.length > 0 && !selectedCity) {
      const defaultCity = citiesOptions[0].value;
      setSelectedCity(defaultCity);
    }
  }, [cityParam, citiesOptions, selectedCity]);

  // Clear area when city changes (but not on initial mount)
  const prevCityRef = useRef<string>(selectedCity);
  useEffect(() => {
    if (prevCityRef.current && prevCityRef.current !== selectedCity) {
      setSelectedArea('');
    }
    prevCityRef.current = selectedCity;
  }, [selectedCity]);

  useEffect(() => {
    if (
      selectedCity &&
      !areaParam &&
      AreasOptions.length > 0 &&
      !selectedArea &&
      !loadingAreasOptions
    ) {
      const defaultArea = AreasOptions[0].value;
      setSelectedArea(defaultArea);
    }
  }, [selectedCity, areaParam, AreasOptions, selectedArea, loadingAreasOptions]);

  // Handle date selection - update day and date param
  const handleDateSelect = (date: Date | undefined) => {
    if (date) {
      setSelectedDate(date);
      const dayFromDate = getDayOfWeekFromDate(date);
      setSelectedDay(dayFromDate);
    } else {
      setSelectedDate(undefined);
    }
  };

  // Update URL params when selections change
  useEffect(() => {
    const newParams = new URLSearchParams();
    if (selectedDay) {
      newParams.set('day', selectedDay);
    }
    if (selectedCity) {
      newParams.set('city', selectedCity);
    }
    if (selectedArea) {
      newParams.set('area', selectedArea);
    }
    if (selectedDate) {
      const formattedDate = formatToFilterDate(selectedDate);
      if (formattedDate) {
        newParams.set('date', formattedDate);
      }
    }
    setSearchParams(newParams, { replace: true });
  }, [selectedDay, selectedCity, selectedArea, selectedDate, setSearchParams]);
  const convertTimeSlotTo12HourFormat = (timeSlot: string) => {
    // Parse time slot (e.g., "14:30" -> hour=14, minute=30)
    const timeMatch = timeSlot.match(/^(\d{1,2}):(\d{2})$/);
    if (!timeMatch) return timeSlot;

    const hour = parseInt(timeMatch[1], 10);
    const minute = parseInt(timeMatch[2], 10);

    if (isNaN(hour) || isNaN(minute)) return timeSlot;

    // Convert to 12-hour format
    const hour12 = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
    const period = hour < 12 ? 'AM' : 'PM';
    const minuteStr = minute.toString().padStart(2, '0');

    return `${period} ${hour12}:${minuteStr}`;
  };
  // Fetch bookings when filters are selected
  const { data: bookingsResponse, isLoading } = useSWR(
    ['bookings-list', selectedDay, selectedCity, selectedArea, selectedDate],
    async () => {
      if (!selectedDay || !selectedCity || !selectedArea) return null;
      const params: {
        day: 'FRIDAY' | 'SATURDAY' | 'SUNDAY' | 'MONDAY' | 'TUESDAY' | 'WEDNESDAY' | 'THURSDAY';
        city: string;
        area: string;
        date?: string;
      } = {
        day: selectedDay as
          | 'FRIDAY'
          | 'SATURDAY'
          | 'SUNDAY'
          | 'MONDAY'
          | 'TUESDAY'
          | 'WEDNESDAY'
          | 'THURSDAY',
        city: selectedCity,
        area: selectedArea,
      };
      if (selectedDate) {
        const formattedDate = formatToFilterDate(selectedDate);
        if (formattedDate) {
          params.date = formattedDate;
        }
      }
      const response = (await bookingService.listAllBookings(params)) as unknown;

      // The service returns the axios response.data, which is the API response body
      // API response structure: { success: true, data: [...] }
      if (response && typeof response === 'object') {
        // Check if response has 'data' property (API response structure)
        if ('data' in response && Array.isArray((response as { data: unknown }).data)) {
          return (response as { data: BookingTimeSlot[] }).data;
        }
        // If response is already an array (service might extract data already)
        if (Array.isArray(response)) {
          const firstItem = response[0] as unknown;
          if (
            firstItem &&
            typeof firstItem === 'object' &&
            'timeSlot' in firstItem &&
            'bikers' in firstItem
          ) {
            return response as unknown as BookingTimeSlot[];
          }
        }
      }

      return null;
    }
  );

  // Group bookings by hour - each card goes into the hour slot it belongs to
  // e.g., "14:30" goes into hour 14 (2:00 PM - 3:00 PM slot)
  const bookingsByHour = useMemo(() => {
    if (!bookingsResponse || !Array.isArray(bookingsResponse)) {
      return {};
    }

    const grouped: Record<
      number,
      Array<{ biker: BookingTimeSlot['bikers'][0]; timeSlot: string }>
    > = {};

    bookingsResponse.forEach((timeSlotData) => {
      if (!timeSlotData || typeof timeSlotData !== 'object') return;

      const timeSlot = String((timeSlotData as { timeSlot?: unknown }).timeSlot || '').trim();
      const bikers = (timeSlotData as { bikers?: BookingTimeSlot['bikers'] }).bikers;

      if (!timeSlot || !bikers || !Array.isArray(bikers)) return;

      // Parse time slot (e.g., "14:30" -> hour=14, minute=30)
      // Handle both "HH:MM" and "H:MM" formats
      const timeMatch = timeSlot.match(/^(\d{1,2}):(\d{2})$/);
      if (!timeMatch) {
        return;
      }

      const hourStr = timeMatch[1];
      const minuteStr = timeMatch[2];
      const hour = parseInt(hourStr, 10);
      const minute = parseInt(minuteStr, 10);

      // Validate hour and minute
      if (isNaN(hour) || isNaN(minute) || hour < 0 || hour >= 24 || minute < 0 || minute >= 60) {
        return;
      }

      // Group by hour - all time slots in hour 14 (14:00-14:59) go into the 2:00 PM slot
      if (!grouped[hour]) {
        grouped[hour] = [];
      }

      // Add each biker with their time slot info
      bikers.forEach((biker) => {
        if (biker?._id) {
          grouped[hour].push({
            biker,
            timeSlot,
          });
        }
      });
    });

    return grouped;
  }, [bookingsResponse]);

  // Get bookings for a specific hour
  const getBookingsForHour = (hour: number) => {
    return bookingsByHour[hour] || [];
  };

  // Refs to track heights of each hour row for timeline label synchronization
  const hourRowRefs = useRef<Record<number, HTMLDivElement | null>>({});
  const [hourHeights, setHourHeights] = useState<Record<number, number>>({});

  // Update heights after render
  useEffect(() => {
    const heights: Record<number, number> = {};
    Object.keys(hourRowRefs.current).forEach((hourStr) => {
      const hour = parseInt(hourStr, 10);
      const element = hourRowRefs.current[hour];
      if (element) {
        heights[hour] = element.offsetHeight;
      }
    });
    setHourHeights(heights);
  }, [bookingsByHour]);

  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="mx-auto max-w-7xl">
        {/* Header */}
        <div className="mb-6 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-slate-900">
              {t('bookingSchedule') || 'Booking Schedule'}
            </h1>
            <p className="mt-1 text-sm text-slate-500">
              {t('viewBikerSchedule') || 'View biker schedules by day, city, and area'}
            </p>
          </div>
          {/* Date Calendar */}

          <div className="flex flex-col">
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="default"
                  className={cn('w-full justify-start text-left font-normal')}>
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {selectedDate ? (
                    format(selectedDate, 'PPP')
                  ) : (
                    <span>{t('pickDate') || 'Pick a date'}</span>
                  )}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start">
                <Calendar
                  mode="single"
                  selected={selectedDate}
                  onSelect={handleDateSelect}
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          </div>
        </div>

        {/* Filters */}
        <div className="mb-6 rounded-lg border border-slate-200 bg-white p-4 shadow-sm">
          <Form {...form}>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
              {/* Day Select */}
              <MainSelect
                title={t('day') || 'Day'}
                placeholder={t('selectDay') || 'Select Day'}
                options={dayOptions}
                field={{
                  value: selectedDay
                    ? dayOptions.find((opt) => opt.value === selectedDay) || {
                        label: '',
                        value: '',
                      }
                    : { label: '', value: '' },
                  onChange: (value: { label: string; value: string }) => {
                    setSelectedDay(value.value);
                  },
                  name: 'day',
                  onBlur: () => {
                    // No-op
                  },
                  ref: (_instance: unknown) => {
                    // No-op
                  },
                }}
              />

              {/* City Select */}
              <MainSelect
                title={t('city') || 'City'}
                placeholder={t('selectCity') || 'Select City'}
                options={citiesOptions}
                field={{
                  value: selectedCity
                    ? citiesOptions.find((opt) => opt.value === selectedCity) || {
                        label: '',
                        value: '',
                      }
                    : { label: '', value: '' },
                  onChange: (value: { label: string; value: string }) => {
                    setSelectedCity(value.value);
                    setSelectedArea('');
                  },
                  name: 'city',
                  onBlur: () => {
                    // No-op
                  },
                  ref: () => {
                    // No-op
                  },
                }}
              />

              {/* Area Select */}
              <div className="relative">
                <div className="flex items-center gap-2">
                  <label className="text-text-600 text-sm font-semibold">
                    {t('area') || 'Area'}
                  </label>
                  {loadingAreasOptions && (
                    <Loader2 className="h-4 w-4 animate-spin text-slate-500" />
                  )}
                </div>
                <div className="[&_label]:hidden">
                  <MainSelect
                    title=""
                    placeholder={
                      loadingAreasOptions
                        ? t('loading') || 'Loading...'
                        : t('selectArea') || 'Select Area'
                    }
                    options={AreasOptions}
                    disabled={!selectedCity || loadingAreasOptions}
                    field={{
                      value: selectedArea
                        ? AreasOptions.find((opt) => opt.value === selectedArea) || {
                            label: '',
                            value: '',
                          }
                        : { label: '', value: '' },
                      onChange: (value: { label: string; value: string }) => {
                        setSelectedArea(value.value);
                      },
                      name: 'area',
                      onBlur: () => {
                        // No-op
                      },
                      ref: (_instance: unknown) => {
                        // No-op
                      },
                    }}
                  />
                </div>
              </div>
            </div>
          </Form>
        </div>

        {/* Timeline View */}
        {isLoading ? (
          <div className="flex items-center justify-center rounded-lg border border-slate-200 bg-white p-12">
            <div className="text-slate-600">{t('loading') || 'Loading...'}</div>
          </div>
        ) : !selectedDay || !selectedCity || !selectedArea ? (
          <div className="flex items-center justify-center rounded-lg border border-slate-200 bg-white p-12">
            <div className="text-slate-500">
              {t('selectFilters') || 'Please select day, city, and area to view schedule'}
            </div>
          </div>
        ) : (
          <div className="rounded-lg border border-slate-200 bg-white shadow-sm">
            <div className="flex h-[calc(100vh-300px)] overflow-y-auto">
              {/* Timeline Content Area */}
              <div className="no-scrollbar flex-1">
                <div className="relative">
                  {/* Hourly Grid - Static 24-hour timeline - ALL 24 HOURS ALWAYS VISIBLE */}
                  {HOURLY_SLOTS.map((slot) => {
                    const bookings = getBookingsForHour(slot.hour24);
                    const hasBookings = bookings.length > 0;

                    return (
                      <div
                        key={slot.value}
                        ref={(el) => {
                          if (el) hourRowRefs.current[slot.hour24] = el;
                        }}
                        className="relative border-b border-slate-400"
                        style={{ minHeight: '100px' }}>
                        {/* Time Slot Content */}
                        <div className="flex min-h-full">
                          {/* Left padding to align with timeline */}
                          <div className="w-24 flex-shrink-0" />

                          {/* Content Area */}
                          <div className="flex-1 p-4">
                            {hasBookings ? (
                              <div className="flex flex-wrap gap-2">
                                {bookings.map((bookingItem, index) => {
                                  const { biker, timeSlot } = bookingItem;
                                  return (
                                    <div
                                      onClick={() => {
                                        navigate(
                                          `${ROUTES.BIKERS_SCHEDULE.replace(':bikerId', biker._id)}`
                                        );
                                      }}
                                      key={`${biker._id}-${timeSlot}-${index}`}
                                      className="group relative flex-shrink-0 cursor-pointer rounded-lg border-l-4 border-green-500 bg-green-50 p-2 shadow-sm transition-shadow hover:shadow-md"
                                      style={{ minWidth: '300px', maxWidth: '380px' }}>
                                      <div className="flex flex-col">
                                        <div className="flex items-start justify-between gap-2">
                                          <div className="min-w-0 flex-1">
                                            <h3 className="truncate text-sm font-medium text-slate-900">
                                              {biker.userName}
                                            </h3>
                                            <p className="mt-0.5 text-xs text-slate-500">
                                              {/* convert timeSlot to 12 hour format */}
                                              {t('time') || 'Time'}:{' '}
                                              {convertTimeSlotTo12HourFormat(timeSlot)}
                                            </p>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                  );
                                })}
                              </div>
                            ) : (
                              <div className="h-12" />
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Timeline Labels (Right Side) - Scrolls with content */}
              <div className="w-24 flex-shrink-0 border-l border-slate-200 bg-slate-50">
                {HOURLY_SLOTS.map((slot) => {
                  const rowHeight = hourHeights[slot.hour24] || 100;

                  return (
                    <div
                      key={slot.value}
                      className="flex items-start border-b border-slate-400 px-3 py-2"
                      style={{ minHeight: '100px', height: `${rowHeight}px` }}>
                      <span className="text-sm font-medium text-slate-600">{slot.label}</span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Booking;
