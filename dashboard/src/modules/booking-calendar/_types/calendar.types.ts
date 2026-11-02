import { DateRange } from 'react-day-picker';

// Enhanced Sprint Model - extending current functionality
export interface EnhancedSprint {
  _id: string;
  title?: string;
  date: string;
  timeSlots: TimeSlot[];
  isActive: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

// Time Slot Model - current structure
export interface TimeSlot {
  _id?: string;
  availableTime: string;
  isActive: boolean;
}

// Calendar Event Model for FullCalendar
export interface CalendarEvent {
  id: string;
  title: string;
  start: Date;
  end: Date;
  backgroundColor?: string;
  borderColor?: string;
  textColor?: string;
  extendedProps: {
    sprintId: string;
    timeSlots: TimeSlot[];
    isActive: boolean;
    capacity?: number;
    type: 'sprint' | 'timeslot';
  };
}

// Calendar View Types
export type CalendarView = 'dayGridMonth' | 'timeGridWeek' | 'timeGridDay' | 'listWeek';

// Calendar Filters
export interface CalendarFilters {
  dateRange?: DateRange;
  showInactive?: boolean;
  view: CalendarView;
}

// Sprint Creation Payload - current API structure
export interface SprintCreationPayload {
  bookingAvailabilityDates: {
    date: string;
    timeSlots: TimeSlot[];
    isActive: boolean;
  }[];
}

// Sprint Update Payload - current API structure
export interface SprintUpdatePayload {
  date: string;
  timeSlots: {
    availableTime: string;
    isActive: boolean;
  }[];
  isActive: boolean;
}
