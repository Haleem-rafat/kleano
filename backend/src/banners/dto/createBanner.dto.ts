import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { Resources } from '../schemas/banner.schema';

export class CreateBannerDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  description: string;

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
