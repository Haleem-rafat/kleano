import { format, parseISO, addDays } from 'date-fns';
import { formatInTimeZone } from 'date-fns-tz';
import { CalendarEvent, EnhancedSprint, TimeSlot } from '../_types/calendar.types';

/**
 * Convert sprint data to FullCalendar events
 */
export const sprintsToCalendarEvents = (sprints: EnhancedSprint[]): CalendarEvent[] => {
  const events: CalendarEvent[] = [];

  sprints.forEach((sprint) => {
    const sprintDate = parseISO(sprint.date);

    // Create a main sprint event (all-day)
    events.push({
      id: `sprint-${sprint._id}`,
      title: `Sprint ${format(sprintDate, 'MMM dd')}`,
      start: sprintDate,
      end: sprintDate,
      backgroundColor: sprint.isActive
        ? 'hsl(var(--success) / 0.15)'
        : 'hsl(var(--destructive) / 0.12)',
      borderColor: sprint.isActive ? 'hsl(var(--success))' : 'hsl(var(--destructive))',
      textColor: '#333',
      extendedProps: {
        sprintId: sprint._id,
        timeSlots: sprint.timeSlots,
        isActive: sprint.isActive,
        capacity: sprint.timeSlots.filter((slot) => slot.isActive).length,
        type: 'sprint',
      },
    });

    // Create individual time slot events
    sprint.timeSlots
      .filter((slot) => slot.isActive)
      .forEach((slot, index) => {
        const slotTime = parseISO(slot.availableTime);
        const endTime = new Date(slotTime.getTime() + 30 * 60000); // 30 minutes

        events.push({
          id: `slot-${sprint._id}-${index}`,
          title: formatInTimeZone(slotTime, 'UTC', 'HH:mm'),
          start: slotTime,
          end: endTime,
          backgroundColor: 'hsl(var(--success) / 0.12)',
          borderColor: 'hsl(var(--success))',
          textColor: 'hsl(var(--success))',
          extendedProps: {
            sprintId: sprint._id,
            timeSlots: [slot],
            isActive: slot.isActive,
            type: 'timeslot',
          },
        });
      });
  });

  return events;
};

/**
 * Generate time slots for a given date (every 30 minutes from 00:00 to 23:30)
 */
export const generateTimeSlots = (date: string): string[] => {
  const slots: string[] = [];
  const baseDate = date.split('T')[0];

  for (let hour = 0; hour < 24; hour++) {
    for (let minute = 0; minute < 60; minute += 30) {
      const timeString = `${hour.toString().padStart(2, '0')}:${minute
        .toString()
        .padStart(2, '0')}`;
      slots.push(timeString);
    }
  }

  return slots;
};

/**
 * Create date objects for sprint creation (current API format)
 */
export const createSprintDates = (startDate: Date, endDate: Date) => {
  const sprintLength =
    Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;

  const days = Array.from({ length: sprintLength }, (_, i) => {
    const date = addDays(startDate, i);
    return {
      date: format(date, 'yyyy-MM-dd') + 'T00:00:00.000Z',
      timeSlots: [],
      isActive: true,
    };
  });

  return days;
};

/**
 * Format time slot for display
 */
export const formatTimeSlot = (availableTime: string): string => {
  return formatInTimeZone(parseISO(availableTime), 'UTC', 'HH:mm');
};

/**
 * Create time slot payload for API
 */
export const createTimeSlotPayload = (date: string, selectedHours: string[]) => {
  return selectedHours.map((time) => ({
    availableTime: `${date.split('T')[0]}T${time}:00.000Z`,
    isActive: true,
  }));
};

/**
 * Extract hours from time slots for editing
 */
export const extractHoursFromTimeSlots = (timeSlots: TimeSlot[]): string[] => {
  return timeSlots
    .filter((slot) => slot.isActive)
    .map((slot) => formatInTimeZone(parseISO(slot.availableTime), 'UTC', 'HH:mm'));
};
