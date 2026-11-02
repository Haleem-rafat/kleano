import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Type } from 'class-transformer';
import { IsEnum, IsNumber } from 'class-validator';

export type NewComersPromoCodeModel = NewComersPromoCode & Document;

export const newComersPromoCodeModelName = 'new-comers-promo-code';

export enum DurationEnum {
  DAY = 'day',
  WEEK = 'week',
  MONTH = 'month',
  YEAR = 'year',
}

@Schema({_id: false})
export class ValidWithin {
  @Prop({ enum: DurationEnum, required: true })
  @IsEnum(DurationEnum)
  durationName: DurationEnum;

  @Prop({ type: Number, min: 1, required: true })
  @IsNumber()
  durationNumber: number;
}

export const ValidWithinSchema = SchemaFactory.createForClass(ValidWithin);

@Schema()
export class NewComersPromoCode {
  @Prop({ type: ValidWithinSchema, required: true })
  @Type(() => ValidWithin)
  validWithin: ValidWithin;
}

export const NewComersPromoCodeSchema =
  SchemaFactory.createForClass(NewComersPromoCode);
