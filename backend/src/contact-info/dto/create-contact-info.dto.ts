import { IsArray, IsOptional, IsString } from 'class-validator';

export class CreateContactInfoDto {
  @IsString()
  @IsOptional()
  contactTitle?: string;

  @IsArray()
  @IsString({ each: true })
  emails: string[];

  @IsArray()
  @IsString({ each: true })
  phoneNumbers: string[];

  @IsString()
  @IsOptional()
  whatsAppNumber?: string;

  @IsString()
  @IsOptional()
  facebookLink?: string;

  @IsString()
  @IsOptional()
  instagramLink?: string;

  @IsString()
  @IsOptional()
  twitterLink?: string;

  @IsString()
  @IsOptional()
  youtubeLink?: string;

  @IsString()
  @IsOptional()
  linkedinLink?: string;

  @IsString()
  @IsOptional()
  tiktokLink?: string;

  @IsString()
  @IsOptional()
  website?: string;
}
