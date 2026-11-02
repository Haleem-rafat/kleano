import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PointsSchema } from './schemas/points.schema';
import { PointController } from './controllers/point.controller';
import { PointService } from './services/point.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: 'points', schema: PointsSchema }]),
  ],
  controllers: [PointController],
  providers: [PointService],
  exports: [PointService],
})
export class PointsModule {}
