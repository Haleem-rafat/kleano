import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { TransformTrim } from 'src/common/decorators/transform-trim.decorator';
import { BaseSearchPaginationQuery } from 'src/common/dtos/base-search-pagination.dto';

export enum UserStatusEnum {
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
}

export class ListAllUsers extends BaseSearchPaginationQuery {
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
  @IsEnum(UserStatusEnum)
  status?: UserStatusEnum;

  @IsOptional()
  @IsString()
  @TransformTrim()
  search?: string;
}
