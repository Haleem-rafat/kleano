import { IsOptional, IsString } from 'class-validator';
import { TransformTrim } from '../decorators/transform-trim.decorator';
import { BasePaginationQuery } from './base-pagination.dto';

export class BaseSearchPaginationQuery extends BasePaginationQuery {
  @IsOptional()
  @IsString()
  @TransformTrim()
  search?: string;
}
