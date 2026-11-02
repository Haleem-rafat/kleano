import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPhoneNumber,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { CommissionType } from '../schemas/bikers.schema';

export class UpdateBikerDTO {
  @IsNotEmpty()
  @IsOptional()
  @IsString()
  userName?: string;

  @IsString()
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @IsNotEmpty()
  @IsOptional()
  @IsString()
  nationalId?: string;

  @IsOptional()
  @IsNotEmpty()
  @IsEnum(CommissionType)
  commissionType?: CommissionType;

  @IsOptional()
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @Max(100)
  @Transform(({ value }) => Number(value))
  commission?: number;

  @IsOptional()
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @Transform(({ value }) => Number(value))
  ordersBeforeCommission?: number;

  @IsOptional()
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @Transform(({ value }) => Number(value))
  minimumCommission?: number;

  @IsOptional()
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @Transform(({ value }) => Number(value))
  weekendCommission?: number;
}
