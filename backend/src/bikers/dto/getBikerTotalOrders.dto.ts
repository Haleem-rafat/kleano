import { IsOptional, IsString } from 'class-validator';
import { TransformTrim } from 'src/common/decorators/transform-trim.decorator';

export class GetBikerTotalOrdersDTO {
  @IsString()
  @IsOptional()
  bikerId?: string;

  @IsOptional()
  fromDate?: Date;

  @IsOptional()
  toDate?: Date;

  @IsOptional()
  @IsString()
  @TransformTrim()
  search?: string;
}
