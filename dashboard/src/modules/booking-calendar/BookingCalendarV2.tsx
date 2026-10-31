import { useTranslation } from 'react-i18next';
import React, { useState, useRef } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';

import { Button, ThreeDotsLoader } from '@UI/Index';
import useSWR from 'swr';
import bookingService from '@services/booking.service';
import { addDays, format, parseISO } from 'date-fns';
import { formatInTimeZone } from 'date-fns-tz';
import { DateRange } from 'react-day-picker';
import { CalendarIcon } from 'lucide-react';
import { toast } from 'react-toastify';

// Components
import CalendarHeader from './_components/CalendarHeader';
import SprintCreatorModal from './_components/SprintCreatorModal';
import TimeSlotEditorModal from './_components/TimeSlotEditorModal';

// Types
import { CalendarView, CalendarFilters, EnhancedSprint } from './_types/calendar.types';

// Shadcn UI
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';
import { cn } from '@/shadecn/lib/utils';
import { Calendar } from '@/shadecn/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';

// Convert sprints to FullCalendar events
const convertSprintsToEvents = (sprints: EnhancedSprint[]) => {
  const events: any[] = [];

  sprints.forEach((sprint) => {
    const sprintDate = parseISO(sprint.date);

    // Create main sprint event (all-day)
    events.push({
      id: `sprint-${sprint._id}`,
      title: `Sprint ${format(sprintDate, 'MMM dd')} (${
        sprint.timeSlots.filter((slot) => slot.isActive).length
      } slots)`,
      start: format(sprintDate, 'yyyy-MM-dd'),
      backgroundColor: sprint.isActive ? '#dcfce7' : '#fef2f2',
      borderColor: sprint.isActive ? '#16a34a' : '#dc2626',
      textColor: sprint.isActive ? '#166534' : '#991b1b',
      allDay: true,
      className: sprint.isActive ? 'sprint-active' : 'sprint-inactive',
      extendedProps: {
        sprintId: sprint._id,
        type: 'sprint',
        isActive: sprint.isActive,
        timeSlots: sprint.timeSlots,
        totalSlots: sprint.timeSlots.length,
        activeSlots: sprint.timeSlots.filter((slot) => slot.isActive).length,
      },
    });

    // Create individual time slot events for time grid views
    if (sprint.isActive) {
      sprint.timeSlots
        .filter((slot) => slot.isActive)
        .forEach((slot, index) => {
          const slotTime = parseISO(slot.availableTime);
          const endTime = new Date(slotTime.getTime() + 30 * 60000); // 30 minutes

          events.push({
            id: `slot-${sprint._id}-${index}`,
            title: `Available ${formatInTimeZone(slotTime, 'UTC', 'HH:mm')}`,
            start: slot.availableTime,
            end: endTime.toISOString(),
            backgroundColor: '#f0fdf4',
            borderColor: '#22c55e',
            textColor: '#15803d',
            allDay: false,
            className: 'timeslot-available',
            extendedProps: {
              sprintId: sprint._id,
              type: 'timeslot',
              slot: slot,
            },
          });
        });
    }
  });

  return events;
};

const BookingCalendarV2 = () => {
  const { t } = useTranslation();
  // State management
  const [currentView, setCurrentView] = useState<CalendarView>('dayGridMonth');
  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: new Date(),
    to: addDays(new Date(), 14),
  });
  const [filters, setFilters] = useState<CalendarFilters>({
    dateRange,
    showInactive: true,
    view: currentView,
  });

  // Modal states
  const [sprintModalOpen, setSprintModalOpen] = useState(false);
  const [timeSlotModalOpen, setTimeSlotModalOpen] = useState(false);
  const [selectedSprint, setSelectedSprint] = useState<EnhancedSprint | null>(null);

  // FullCalendar ref
  const calendarRef = useRef<FullCalendar>(null);

  // Data fetching
  const fetchSprints = async () => {
    try {
      const response = await bookingService.getBookings(dateRange);
      return response.data as EnhancedSprint[];
    } catch (error) {
      console.error('Error fetching sprints:', error);
      toast.error('Failed to load booking data');
      return [];
    }
  };

  const {
    data: sprints = [],
    isLoading,
    mutate,
  } = useSWR(['booking-calendar-sprints', dateRange], fetchSprints);

  // Event handlers
  const handleEventClick = (eventInfo: any) => {
    const { extendedProps } = eventInfo.event;

    if (extendedProps.type === 'sprint' || extendedProps.type === 'timeslot') {
      const sprint = sprints.find((s) => s._id === extendedProps.sprintId);
      if (sprint) {
        setSelectedSprint(sprint);
        setTimeSlotModalOpen(true);
      }
    }
  };

  const handleDateSelect = (selectInfo: any) => {
    // Could be used for quick sprint creation in the future
    console.log('Date selected:', selectInfo);
  };

  const handleViewChange = (view: CalendarView) => {
    setCurrentView(view);
    setFilters((prev) => ({ ...prev, view }));

    // Change the FullCalendar view programmatically
    if (calendarRef.current) {
      const calendarApi = calendarRef.current.getApi();
      calendarApi.changeView(view);
    }
  };

  const handleNavigate = (action: 'prev' | 'next' | 'today') => {
    if (calendarRef.current) {
      const calendarApi = calendarRef.current.getApi();
      switch (action) {
        case 'prev':
          calendarApi.prev();
          break;
        case 'next':
          calendarApi.next();
          break;
        case 'today':
          calendarApi.today();
          break;
      }
    }
  };

  // Convert sprints to calendar events
  const calendarEvents = convertSprintsToEvents(
    filters.showInactive ? sprints : sprints.filter((sprint) => sprint.isActive)
  );

  if (isLoading) {
    return (
      <div className="flex h-96 items-center justify-center">
        <ThreeDotsLoader />
      </div>
    );
  }

  return (
    <div className="flex h-full w-full flex-col gap-4 p-4">
      {/* Header with filters and controls */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap items-center gap-4">
          <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('Booking Calendar')}</h1>

          {/* Date Range Picker */}
          <Popover>
            <PopoverTrigger asChild>
              <Button
                variant="secondary"
                className={cn(
                  'w-[300px] justify-start text-left font-normal',
                  !dateRange && 'text-muted-foreground'
                )}>
                <CalendarIcon className="mr-2 h-4 w-4" />
                {dateRange?.from ? (
                  dateRange.to ? (
                    <>
                      {dateRange.from.toLocaleDateString()} - {dateRange.to.toLocaleDateString()}
                    </>
                  ) : (
                    dateRange.from.toLocaleDateString()
                  )
                ) : (
                  <span>{t('Pick a date range')}</span>
                )}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-auto p-0" align="start">
              <Calendar
                initialFocus
                mode="range"
                defaultMonth={dateRange?.from}
                selected={dateRange}
                onSelect={setDateRange}
                numberOfMonths={2}
              />
            </PopoverContent>
          </Popover>
        </div>

        {/* Actions */}
        <div className="flex flex-wrap items-center gap-2">
          <Dialog open={sprintModalOpen} onOpenChange={setSprintModalOpen}>
            <DialogTrigger asChild>
              <Button>{t('Create Sprint')}</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
              <DialogHeader>
                <DialogTitle>{t('Create New Sprint')}</DialogTitle>
                <DialogDescription>
                  Create a new 14-day booking sprint with available time slots.
                </DialogDescription>
              </DialogHeader>
              <SprintCreatorModal
                onClose={() => setSprintModalOpen(false)}
                onSuccess={() => {
                  mutate();
                  setSprintModalOpen(false);
                }}
              />
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {/* Calendar Header with View Controls */}
      <CalendarHeader
        currentView={currentView}
        onViewChange={handleViewChange}
        filters={filters}
        onFiltersChange={setFilters}
      />

      {/* Stats */}
      <div className="flex gap-4 text-sm text-gray-600">
        <span>Total Sprints: {sprints.length}</span>
        <span>Active Sprints: {sprints.filter((s) => s.isActive).length}</span>
        <span>
          Total Time Slots:{' '}
          {sprints.reduce((acc, s) => acc + s.timeSlots.filter((slot) => slot.isActive).length, 0)}
        </span>
      </div>

      {/* Main FullCalendar */}
      <div className="flex-1 rounded-lg border bg-white p-4">
        <FullCalendar
          ref={calendarRef}
          plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin]}
          headerToolbar={false}
          initialView={currentView}
          events={calendarEvents}
          eventClick={handleEventClick}
          selectable={true}
          selectMirror={true}
          select={handleDateSelect}
          dayMaxEvents={3}
          moreLinkClick="popover"
          weekends={true}
          height="auto"
          eventDisplay="block"
          eventTimeFormat={{
            hour: '2-digit',
            minute: '2-digit',
            hour12: false,
          }}
          slotMinTime="06:00:00"
          slotMaxTime="22:00:00"
          allDaySlot={true}
          expandRows={true}
          stickyHeaderDates={true}
          nowIndicator={true}
          businessHours={{
            daysOfWeek: [1, 2, 3, 4, 5, 6, 0], // Monday - Sunday
            startTime: '09:00',
            endTime: '18:00',
          }}
          // Custom styling
          eventClassNames="cursor-pointer hover:opacity-80 transition-opacity"
          dayCellClassNames="hover:bg-gray-50"
          // Event content customization
          eventContent={(eventInfo) => {
            const { event } = eventInfo;
            const { extendedProps } = event;

            if (extendedProps.type === 'sprint') {
              return (
                <div className="p-1">
                  <div className="text-xs font-semibold">{event.title}</div>
                  <div className="text-xs opacity-75">
                    {extendedProps.activeSlots}/{extendedProps.totalSlots} active
                  </div>
                </div>
              );
            }

            return <div className="p-1 text-xs">{event.title}</div>;
          }}
        />
      </div>

      {/* Time Slot Editor Modal */}
      {selectedSprint && (
        <TimeSlotEditorModal
          open={timeSlotModalOpen}
          onClose={() => {
            setTimeSlotModalOpen(false);
            setSelectedSprint(null);
          }}
          sprint={selectedSprint}
          onSuccess={() => {
            mutate();
            setTimeSlotModalOpen(false);
            setSelectedSprint(null);
          }}
        />
      )}
    </div>
  );
};

export default BookingCalendarV2;
