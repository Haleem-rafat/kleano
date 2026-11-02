import { Transform } from 'class-transformer';
import { IsDate } from 'class-validator';

export class GetBookingsAvailDto {
  @Transform(({ value }) => new Date(value), { toClassOnly: true })
  @IsDate()
  from: Date;

  @Transform(({ value }) => new Date(value), { toClassOnly: true })
  @IsDate()
  to: Date;
}
