import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CarController } from './car.controller';
import { CarsService } from './car.service';
import { CarSchema, carModelName } from './schemas/car.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: carModelName, schema: CarSchema }]),
  ],
  controllers: [CarController],
  providers: [CarsService],
})
export class CarModule {}
