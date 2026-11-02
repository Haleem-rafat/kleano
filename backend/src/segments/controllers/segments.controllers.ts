import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { IsAdminGuard } from 'src/admin/guard';
import { UserAuthGuard } from 'src/auth/guards';
import { CreateSegmentDto } from '../dtos/createSegment.dto';
import { UpdateSegmentDto } from '../dtos/updateSegment.dto';
import { SegmentsService } from '../services/segments.service';

@Controller('segments')
export class SegmentsController {
  constructor(private segmentsService: SegmentsService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createSegmentController(@Body() body: CreateSegmentDto) {
    await this.segmentsService.createSegment(body);
    return {
      success: true,
    };
  }

  @Get()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllSegmentsController() {
    return {
      success: true,
      data: await this.segmentsService.getAll(),
    };
  }

  @Get(':segmentId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getById(@Param('segmentId') segmentId: string) {
    return {
      success: true,
      data: await this.segmentsService.getOneById(segmentId),
    };
  }

  @Patch(':segmentId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updateSegment(
    @Param('segmentId') segmentId,
    @Body() body: UpdateSegmentDto,
  ) {
    return {
      success: true,
      data: await this.segmentsService.updateOneById(segmentId, body),
    };
  }
}
