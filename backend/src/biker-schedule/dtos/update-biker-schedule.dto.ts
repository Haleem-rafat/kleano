import { PartialType } from '@nestjs/mapped-types';
import { CreateBikerScheduleDto } from './create-biker-schedule.dto';

export class UpdateBikerScheduleDto extends PartialType(
  CreateBikerScheduleDto,
) {}
