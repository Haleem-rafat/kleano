import { IsNotEmpty, IsNumber, IsObject } from 'class-validator';
import mongoose from 'mongoose';

export class CreateAreaDto {
  @IsObject()
  name: Record<string, any>;

  @IsNotEmpty()
  city: mongoose.Schema.Types.ObjectId;

  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;
}
