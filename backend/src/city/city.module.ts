import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { cityModelName, CitySchema } from './schemas/city.schema';
import { CitiesController } from './city.controller';
import { CitiesService } from './city.service';
import { NearestCityCalculator } from './nearestCityCalculator.service';
import { AdminModule } from '../admin/admin.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: cityModelName, schema: CitySchema }]),
    AdminModule,
  ],
  controllers: [CitiesController],
  providers: [CitiesService, NearestCityCalculator],
  exports: [CitiesService, NearestCityCalculator],
})
export class CityModule {}
