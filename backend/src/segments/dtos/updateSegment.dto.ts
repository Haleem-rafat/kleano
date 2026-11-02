import { IsArray, IsMongoId, IsOptional, IsString } from 'class-validator';
import { Types } from 'mongoose';

export class UpdateSegmentDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  users?: Types.ObjectId[];
}
