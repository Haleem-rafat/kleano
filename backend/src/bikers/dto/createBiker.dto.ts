import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPhoneNumber,
  IsString,
  Length,
  Max,
  Min,
} from 'class-validator';
import { CommissionType } from '../schemas/bikers.schema';

export class CreateBikerDTO {
  @IsNotEmpty()
  @IsString()
  userName: string;

  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  password: string;

  @IsString()
  @IsPhoneNumber()
  phone: string;

  @IsNotEmpty()
  @IsString()
  nationalId: string;

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
