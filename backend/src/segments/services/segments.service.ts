import { Injectable } from '@nestjs/common';
import { CreateSegmentDto } from '../dtos/createSegment.dto';
import { UpdateSegmentDto } from '../dtos/updateSegment.dto';
import { SegmentRepository } from '../repositories/segment.repository';

@Injectable()
export class SegmentsService {
  constructor(private segmentRepository: SegmentRepository) {}

  async createSegment(createSegmentDto: CreateSegmentDto) {
    const { name, users } = createSegmentDto;

    await this.segmentRepository.create(name, users);
  }

  async getAll() {
    return await this.segmentRepository.findAll();
  }

  async getOneById(segmentId: string) {
    return await this.segmentRepository.findOneById(segmentId);
  }

  async getOneByIdForPromoCode(segmentId: string) {
    return await this.segmentRepository.findOneByIdForPromoCode(segmentId);
  }

  async updateOneById(segmentId, body: UpdateSegmentDto) {
    await this.segmentRepository.updateOne(segmentId, body);
  }
}
