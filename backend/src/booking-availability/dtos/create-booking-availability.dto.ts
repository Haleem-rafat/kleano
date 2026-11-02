import {
  IsBoolean,
  IsArray,
  ValidateNested,
  IsDate,
  ArrayMaxSize,
  ArrayNotEmpty,
  ArrayMinSize,
  IsString,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class TimeSlotDto {
  @Transform(({ value }) => new Date(value), { toClassOnly: true })
  @IsDate()
  availableTime: Date;

  @IsBoolean()
  isActive: boolean;
}

class BookingAvailabilityDate {
  @IsString()
  date: string;

  @IsArray()
  // @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => TimeSlotDto)
  timeSlots: TimeSlotDto[];

  @IsBoolean()
  isActive: boolean;
}

export class CreateBookingAvailabilityDto {
  @IsArray()
  @ArrayNotEmpty()
  @ArrayMinSize(14)
  @ArrayMaxSize(14)
  @ValidateNested({ each: true })
  @Type(() => BookingAvailabilityDate)
  bookingAvailabilityDates: BookingAvailabilityDate[];
}
