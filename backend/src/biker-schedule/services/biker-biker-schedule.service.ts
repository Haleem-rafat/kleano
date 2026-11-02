import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  BikerScheduleModel,
  bikerScheduleModelName,
} from '../schemas/biker-schedule.schema';

@Injectable()
export class BikerBikerScheduleService {
  constructor(
    @InjectModel(bikerScheduleModelName)
    private readonly bikerScheduleModel: Model<BikerScheduleModel>,
  ) {}

  async getBikerSchedule(bikerId: string) {
    return await this.bikerScheduleModel
      .findOne({ biker: new Types.ObjectId(bikerId) })
      .populate('shifts.city', 'name')
      .populate('shifts.area', 'name')
      .lean();
  }
}
