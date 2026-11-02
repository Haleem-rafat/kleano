import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { Resources } from '../schemas/banner.schema';

export class UpdateBannerDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  title?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  description?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  externalUrl?: string;

  @IsOptional()
  @IsEnum(Resources)
  resource?: Resources;

  @IsOptional()
  @IsString()
  resourceId?: string;
}
