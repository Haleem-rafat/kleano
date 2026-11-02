import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { MethodNotAllowedResponse, NotFoundResponse } from 'src/common/errors';
import { UpdateSegmentDto } from '../dtos/updateSegment.dto';
import { SegmentModel, segmentModelName } from '../schemas/segment.schema';

@Injectable()
export class SegmentRepository {
  constructor(
    @InjectModel(segmentModelName)
    private readonly segmentModel: Model<SegmentModel>,
  ) {}

  async create(name: string, users: Types.ObjectId[]) {
    if (await this.segmentModel.exists({ name })) {
      throw new MethodNotAllowedResponse({
        ar: 'الاسم مسجل من قبل',
        en: 'Segment Name Exists',
      });
    }

    await this.segmentModel.create({
      name,
      users,
    });
  }

  async findAll() {
    return await this.segmentModel.find({});
  }

  async findOneById(segmentId: string) {
    const [segment] = await this.segmentModel.aggregate([
      {
        $match: { _id: new Types.ObjectId(segmentId) },
      },
      {
        $lookup: {
          from: 'users',
          localField: 'users',
          foreignField: '_id',
          as: 'users',
        },
      },
      {
        $project: {
          _id: 1,
          name: 1,
          'users._id': 1,
          'users.userName': 1,
          'users.email': 1,
          createdAt: 1,
        },
      },
    ]);

    if (!segment) {
      throw new NotFoundResponse({
        ar: 'الشريحة غير موجودة',
        en: 'Segment Not Found',
      });
    }

    return segment;
  }

  async findOneByIdForPromoCode(segmentId: string) {
    const [segment] = await this.segmentModel.aggregate([
      {
        $match: { _id: new Types.ObjectId(segmentId) },
      },
      {
        $lookup: {
          from: 'users',
          localField: 'users',
          foreignField: '_id',
          as: 'users',
        },
      },
    ]);

    if (!segment) {
      throw new NotFoundResponse({
        ar: 'الشريحة غير موجودة',
        en: 'Segment Not Found',
      });
    }

    return segment;
  }

  async updateOne(segmentId: string, body: UpdateSegmentDto) {
    await this.segmentModel.findByIdAndUpdate(segmentId, body);
  }
}
