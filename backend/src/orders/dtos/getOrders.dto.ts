import { Transform } from 'class-transformer';
import { IsIn, IsInt, IsNotEmpty, IsString } from 'class-validator';

export class GetOrdersDTO {
  @IsNotEmpty()
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  @IsInt({ message: 'page must be an integer' })
  page: number;

  @IsNotEmpty()
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  @IsInt({ message: 'perPage must be an integer' })
  perPage: number;

  @IsNotEmpty()
  @IsString()
  status: string;
}
