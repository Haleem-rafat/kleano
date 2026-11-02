import { IsOptional, IsString } from 'class-validator';

export class UpdateProductDto {
  @IsOptional()
  @IsString()
  name_ar?: string;

  @IsOptional()
  @IsString()
  name_en?: string;

  @IsOptional()
  @IsString()
  selling_price?: string;
}
