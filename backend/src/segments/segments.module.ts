import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { SegmentsController } from './controllers/segments.controllers';
import { SegmentRepository } from './repositories/segment.repository';
import { SegmentSchema, segmentModelName } from './schemas/segment.schema';
import { SegmentsService } from './services/segments.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: segmentModelName, schema: SegmentSchema },
    ]),
  ],
  controllers: [SegmentsController],
  providers: [SegmentsService, SegmentRepository],
  exports: [SegmentsService],
})
export class SegmentsModule {}
