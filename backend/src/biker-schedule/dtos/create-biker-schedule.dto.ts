import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { Day } from '../schemas/biker-schedule.schema';

export class ShiftDto {
  @IsNotEmpty()
  @IsString()
  timeSlot: string; // Format: 'HH:MM' (e.g., '00:15', '14:30')

  @IsNotEmpty()
  @IsMongoId()
  city: string;

  @IsNotEmpty()
  @IsMongoId()
  area: string;

  @IsNotEmpty()
  @IsEnum(Day)
  day: Day;

  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  @Max(3)
  priorityLevel: number;
}

export class CreateBikerScheduleDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ShiftDto)
  shifts: ShiftDto[];

  @IsOptional()
  @IsArray()
  @IsEnum(Day, { each: true })
  weekends?: Day[];

  @IsNotEmpty()
  @IsMongoId()
  biker: string;
}
