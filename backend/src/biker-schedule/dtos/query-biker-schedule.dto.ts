import { IsEnum, IsMongoId, IsOptional, IsString } from 'class-validator';
import { Day } from '../schemas/biker-schedule.schema';

export class QueryBikerScheduleDto {
  @IsOptional()
  @IsMongoId()
  biker?: string;

  @IsOptional()
  @IsMongoId()
  city?: string;

  @IsOptional()
  @IsMongoId()
  area?: string;

  @IsOptional()
  @IsEnum(Day)
  day?: Day;

  @IsOptional()
  @IsString()
  date?: string; // ISO date string for availability calculation
}
