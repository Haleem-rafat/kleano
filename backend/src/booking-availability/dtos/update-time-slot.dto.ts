import { Transform, Type } from 'class-transformer';
import { IsArray, IsBoolean, IsDate, ValidateNested } from 'class-validator';
import { TimeSlotDto } from './create-booking-availability.dto';

export class UpdateBookingAvailabilityTimeSlotDto {
  @Transform(({ value }) => new Date(value), { toClassOnly: true })
  @IsDate()
  date: Date;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TimeSlotDto)
  timeSlots: TimeSlotDto[];

  @IsBoolean()
  isActive: boolean;
}
