import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { areaModelName, AreaSchema } from './schemas/area.schema';
import { AreasService } from './area.service';
import { AdminModule } from '../admin/admin.module';
import { AreasController } from './area.controller';
import { NearestAreaCalculator } from './nearestAreaCalculator.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: areaModelName, schema: AreaSchema }]),
    AdminModule,
  ],
  controllers: [AreasController],
  providers: [AreasService, NearestAreaCalculator],
  exports: [AreasService, NearestAreaCalculator],
})
export class AreaModule {}
