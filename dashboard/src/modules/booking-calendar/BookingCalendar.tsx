import { useTranslation } from 'react-i18next';
import React, { useRef, useState } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';
import { Button, HeaderSkeleton, Skeleton } from '@UI/Index';
import useSWR from 'swr';
import bookingService from '@services/booking.service';
import { addDays } from 'date-fns';
import { DateRange } from 'react-day-picker';
import { CalendarIcon } from 'lucide-react';
import { toast } from 'react-toastify';

// Components
import CalendarHeader from './_components/CalendarHeader';

// Utils and Types
import { sprintsToCalendarEvents } from './_utils/dateHelpers';
import { CalendarView, CalendarFilters, EnhancedSprint } from './_types/calendar.types';
import TimeSlotEditorModal from './_components/TimeSlotEditorModal';
import SprintCreatorModal from './_components/SprintCreatorModal';

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

const BookingCalendar = () => {
  const { t } = useTranslation();
  // State management
  const calendarRef = useRef<FullCalendar>(null);
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

  // Calendar event handlers
  const handleEventClick = (eventInfo: any) => {
    const { extendedProps } = eventInfo.event;

    if (extendedProps.type === 'sprint') {
      const sprint = sprints.find((s) => s._id === extendedProps.sprintId);
      if (sprint) {
        setSelectedSprint(sprint);
        setTimeSlotModalOpen(true);
      }
    }
  };

  const handleDateSelect = (selectInfo: any) => {
    // Handle date range selection for new sprint creation
    console.log('Date selected:', selectInfo);
  };

  const handleViewChange = (view: CalendarView) => {
    setCurrentView(view);
    calendarRef.current?.getApi().changeView(view);
    setFilters((prev) => ({ ...prev, view }));
  };

  // Convert sprints to calendar events
  const calendarEvents = sprintsToCalendarEvents(
    filters.showInactive ? sprints : sprints.filter((sprint) => sprint.isActive)
  );

  if (isLoading) {
    return (
      <div className="space-y-4" aria-busy>
        <HeaderSkeleton actions={2} />
        <div className="rounded-lg border border-border bg-card p-4">
          <div className="grid grid-cols-7 gap-2">
            {Array.from({ length: 35 }).map((_, i) => (
              <Skeleton key={i} className="h-20" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex h-full w-full flex-col gap-4 p-4">
      {/* Header with filters and controls */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-4">
          <h1 className="text-2xl font-bold">{t('Booking Calendar')}</h1>

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
        <div className="flex items-center gap-2">
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

      {/* Main Calendar */}
      <div className="flex-1 rounded-lg border bg-card p-4">
        <FullCalendar
          plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin]}
          headerToolbar={{
            left: 'prev,next today',
            center: 'title',
            // Views are switched by CalendarHeader above; no second switcher.
            right: '',
          }}
          ref={calendarRef}
          initialView={currentView}
          datesSet={(info) => setCurrentView(info.view.type as CalendarView)}
          events={calendarEvents}
          eventClick={handleEventClick}
          selectable={true}
          selectMirror={true}
          select={handleDateSelect}
          dayMaxEvents={true}
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
          // Custom styling
          eventClassNames="cursor-pointer hover:opacity-80 transition-opacity"
          dayCellClassNames="hover:bg-muted"
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

export default BookingCalendar;
