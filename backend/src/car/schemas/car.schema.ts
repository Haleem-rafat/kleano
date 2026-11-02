import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

export type CarModel = Car & Document;
export const carModelName = 'car';

@Schema()
export class Car {
  @Prop()
  brand: string;

  @Prop({
    type: [{ type: String, required: true }],
  })
  models: string[];
}

export const CarSchema = SchemaFactory.createForClass(Car);
