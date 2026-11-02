import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { AdminStatus } from '../schemas/admin.schema';
import { Transform } from 'class-transformer';
import { TransformTrim } from 'src/common/decorators/transform-trim.decorator';

export class GetAdminsDTO {
  @IsNotEmpty()
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  @IsInt({ message: 'page must be an integer' })
  page: number;

  @IsNotEmpty()
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  @IsInt({ message: 'perPage must be an integer' })
  perPage: number;

  @IsOptional()
  @IsString()
  @IsIn([AdminStatus.ACTIVE, AdminStatus.SUSPENDED])
  status: string;

  @IsOptional()
  @IsString()
  @TransformTrim()
  search?: string;
}
