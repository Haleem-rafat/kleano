import { Day } from '../schemas/biker-schedule.schema';

const SAUDI_OFFSET_MS = 3 * 60 * 60 * 1000;

const DAY_MAP: Day[] = [
  Day.SUNDAY,
  Day.MONDAY,
  Day.TUESDAY,
  Day.WEDNESDAY,
  Day.THURSDAY,
  Day.FRIDAY,
  Day.SATURDAY,
];

/**
 * Same day derivation as `OrderGateway.assignBikerToOrder`: startTime in DB plus Saudi
 * offset, then JS weekday. Used for schedule availability so shift `day` matches assignment.
 */
export function getAssignmentDayFromOrderStartTime(
  startTime: Date | string | number,
): Day {
  const localStart = new Date(
    new Date(startTime as any).getTime() + SAUDI_OFFSET_MS,
  );
  return DAY_MAP[localStart.getUTCDay()];
}

/**
 * For a calendar booking date and slot label (no full order `startTime` yet), use the
 * same wall-clock interpretation as typical ISO strings with a +03:00 offset.
 */
export function getAssignmentDayFromDateAndTimeSlot(
  dateYmd: string,
  timeSlot: string,
): Day {
  const d = dateYmd.slice(0, 10);
  return getAssignmentDayFromOrderStartTime(
    new Date(`${d}T${timeSlot}:00+03:00`),
  );
}
