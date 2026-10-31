import React, { useState } from 'react';
import { Button, ThreeDotsLoader } from '@UI/Index';
import useSWR from 'swr';
import bookingService from '@services/booking.service';
import { addDays, format, parseISO } from 'date-fns';
import { DateRange } from 'react-day-picker';
import { CalendarIcon } from 'lucide-react';
import { toast } from 'react-toastify';

// FullCalendar imports - simplified
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';

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

// Simple event conversion without complex utils
const convertSprintsToEvents = (sprints: EnhancedSprint[]) => {
  const events: any[] = [];

  sprints.forEach((sprint) => {
    const sprintDate = parseISO(sprint.date);

    // Create main sprint event
    events.push({
      id: `sprint-${sprint._id}`,
      title: `Sprint ${format(sprintDate, 'MMM dd')}`,
      date: format(sprintDate, 'yyyy-MM-dd'),
      backgroundColor: sprint.isActive ? '#c8e6c9' : '#ffcdd2',
      borderColor: sprint.isActive ? '#4caf50' : '#f44336',
      extendedProps: {
        sprintId: sprint._id,
        type: 'sprint',
        isActive: sprint.isActive,
        timeSlots: sprint.timeSlots,
      },
    });
  });

  return events;
};

const BookingCalendarFixed = () => {
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

    if (extendedProps.type === 'sprint') {
      const sprint = sprints.find((s) => s._id === extendedProps.sprintId);
      if (sprint) {
        setSelectedSprint(sprint);
        setTimeSlotModalOpen(true);
      }
    }
  };

  const handleViewChange = (view: CalendarView) => {
    setCurrentView(view);
    setFilters((prev) => ({ ...prev, view }));
  };

  // Convert sprints to calendar events
  const calendarEvents = convertSprintsToEvents(sprints);

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
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <h1 className="text-2xl font-bold">Booking Calendar</h1>
          <div className="rounded bg-green-100 px-2 py-1 text-xs text-green-800">
            FullCalendar Enabled
          </div>

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
                  <span>Pick a date range</span>
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
              <Button>Create Sprint</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
              <DialogHeader>
                <DialogTitle>Create New Sprint</DialogTitle>
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
      <div className="flex-1 rounded-lg border bg-white p-4">
        <FullCalendar
          plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin]}
          headerToolbar={{
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay',
          }}
          initialView={currentView}
          events={calendarEvents}
          eventClick={handleEventClick}
          height="auto"
          dayMaxEvents={true}
          eventDisplay="block"
          weekends={true}
          nowIndicator={true}
          eventClassNames="cursor-pointer hover:opacity-80 transition-opacity"
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

export default BookingCalendarFixed;
