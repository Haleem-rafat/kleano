import { Transform } from 'class-transformer';
import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class GetSubscriptionsDTO {
  @IsOptional()
  @IsString()
  status?: string;
}
