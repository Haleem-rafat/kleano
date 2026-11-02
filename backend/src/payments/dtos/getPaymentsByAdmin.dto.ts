import { Transform } from 'class-transformer';
import {
  IsArray,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { MoyasarPaymentStatus } from '../schemas/payments.schema';
import { TransformTrim } from 'src/common/decorators/transform-trim.decorator';

export class GetPaymentsByAdminDTO {
  @IsNotEmpty()
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  @IsInt({ message: 'page must be an integer' })
  page: number;

  @IsNotEmpty()
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  @IsInt({ message: 'perPage must be an integer' })
  perPage: number;

  @IsOptional()
  @IsArray()
  status: MoyasarPaymentStatus[];

  @IsOptional()
  @IsString()
  @TransformTrim()
  search?: string;
}
