import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  ActivePromoCodes,
  activePromoCodesModelName,
} from '../schemas/active-promo-codes.schema';

@Injectable()
export class ActivePromoCodesRepository {
  constructor(
    @InjectModel(activePromoCodesModelName)
    private activePromoCodesModel: Model<ActivePromoCodes>,
  ) {}

  async create(userId: string, promoCodeId: string): Promise<ActivePromoCodes> {
    const activePromoCode = new this.activePromoCodesModel({
      user: userId,
      promoCode: promoCodeId,
    });
    return activePromoCode.save();
  }

  async createForMultipleUsers(
    userIds: string[],
    promoCodeId: string,
  ): Promise<ActivePromoCodes[]> {
    const activePromoCodes = userIds.map((userId) => ({
      user: userId,
      promoCode: promoCodeId,
    }));

    return this.activePromoCodesModel.insertMany(activePromoCodes);
  }

  async findByUser(userId: string): Promise<ActivePromoCodes[]> {
    return this.activePromoCodesModel
      .find({ user: userId })
      .populate('promoCode')
      .exec();
  }

  async findByPromoCode(promoCodeId: string): Promise<ActivePromoCodes[]> {
    return this.activePromoCodesModel
      .find({ promoCode: promoCodeId })
      .populate('user')
      .exec();
  }

  async findByUserAndPromoCode(
    userId: string,
    promoCodeId: string,
  ): Promise<ActivePromoCodes | null> {
    return this.activePromoCodesModel
      .findOne({ user: userId, promoCode: promoCodeId })
      .exec();
  }

  async deleteByUserAndPromoCode(
    userId: string,
    promoCodeId: string,
  ): Promise<boolean> {
    const result = await this.activePromoCodesModel
      .deleteOne({ user: userId, promoCode: promoCodeId })
      .exec();
    return result.deletedCount > 0;
  }

  async deleteByPromoCode(promoCodeId: string): Promise<number> {
    const result = await this.activePromoCodesModel
      .deleteMany({ promoCode: promoCodeId })
      .exec();
    return result.deletedCount;
  }

  async countByPromoCode(promoCodeId: string): Promise<number> {
    return this.activePromoCodesModel.countDocuments({
      promoCode: promoCodeId,
    });
  }
}
