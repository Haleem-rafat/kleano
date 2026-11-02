import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { MethodNotAllowedResponse, NotFoundResponse } from 'src/common/errors';
import { PointsModel } from '../schemas/points.schema';

@Injectable()
export class PointService {
  constructor(
    @InjectModel('points') private readonly pointsModel: Model<PointsModel>,
  ) {}

  async createPointsPercentages(
    totalPayPercentage: number,
    exchangePercentage: number,
    redeemLimit: number,
  ) {
    const pointSystem = await this.pointsModel.findOne();
    if (pointSystem)
      throw new MethodNotAllowedResponse({
        en: 'Poinst System Is Already Implemented',
        ar: 'نظام النقط تم تفعيله',
      });

    return await this.pointsModel.create({
      totalPayPercentage,
      exchangePercentage,
      redeemLimit,
    });
  }

  async updatePointsPercentage(
    totalPayPercentage: number,
    exchangePercentage: number,
    redeemLimit: number,
  ) {
    const pointSystem = await this.pointsModel.findOne();
    if (!pointSystem)
      throw new NotFoundResponse({
        en: 'Points System Not Exist, Please Implement Points System',
        ar: 'نظام النقاط غير مغعل حاليا',
      });

    pointSystem.exchangePercentage = exchangePercentage;
    pointSystem.totalPayPercentage = totalPayPercentage;
    pointSystem.redeemLimit = redeemLimit;

    await pointSystem.save();
  }

  async getPointsSystem() {
    return await this.pointsModel.findOne();
  }

  async calculateEarningPoints(totalPay: number) {
    const pointSystem = await this.pointsModel.findOne();

    const numberOfPoints = (pointSystem.totalPayPercentage / 100) * totalPay;
    return Number(numberOfPoints.toFixed(0));
  }

  async calculatePointsExchange(numberOfPoints: number) {
    const pointSystem = await this.pointsModel.findOne();
    // console.log(pointSystem.exchangePercentage / 100);
    // console.log(numberOfPoints);
    return Number(((pointSystem.exchangePercentage / 100) * numberOfPoints).toFixed(2));
  }

  async calculatePointsDiscountAmount(points: number) {
    const pointSystem = await this.pointsModel.findOne();

    if (!pointSystem) {
      throw new NotFoundResponse({
        en: 'Points System Not Exist, Please Implement Points System',
        ar: 'نظام النقاط غير مفعل حاليا',
      });
    }

    // Validate that points meet the minimum redeem limit
    if (points < pointSystem.redeemLimit) {
      throw new MethodNotAllowedResponse({
        en: `Minimum points required to redeem is ${pointSystem.redeemLimit}`,
        ar: `الحد الأدنى من النقاط المطلوبة للاستبدال هو ${pointSystem.redeemLimit}`,
      });
    }

    // Calculate discount amount using the exchange percentage formula
    const discountAmount = (pointSystem.exchangePercentage / 100) * points;

    return {
      points,
      discountAmount: Number(discountAmount.toFixed(2)),
      redeemLimit: pointSystem.redeemLimit,
      exchangePercentage: pointSystem.exchangePercentage,
    };
  }
}
