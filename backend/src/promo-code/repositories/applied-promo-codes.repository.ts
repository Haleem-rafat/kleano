import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  Order,
  OrderStatus,
  ordersModelName,
} from 'src/orders/schemas/orders.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { User, userModelName } from '../../user/schemas/user.schema';
import {
  AppliedPromoCodeModel,
  appliedPromoCodeModelName,
} from '../schemas/applied-promo-codes.schema';
import {
  PromoCode,
  PromoCodeStatus,
  PromoCodeTargetAudienceEnum,
  PromoCodeUsesTypeEnum,
} from '../schemas/promo-code.schema';

@Injectable()
export class AppliedPromoCodesRepository {
  constructor(
    @InjectModel(appliedPromoCodeModelName)
    private readonly appliedPromoCodeModel: Model<AppliedPromoCodeModel>,
    @InjectModel(userModelName)
    private readonly userModel: Model<User>,
    @InjectModel(ordersModelName)
    private readonly orderModel: Model<Order>,
  ) {}

  async applyPromoCode(user: User, promoCode: PromoCode) {
    await this.isValidPromoCode(promoCode, user);
    // const isAlreadyApplied = await this.appliedPromoCodeModel
    //   .findOne({
    //     user,
    //     promoCode,
    //   })
    //   ;
    // if (isAlreadyApplied)
    //   throw new MethodNotAllowedResponse({
    //     ar: 'البرومو كود مستخدم من قبل',
    //     en: 'Promo Code is already applied',
    //   });

    await this.appliedPromoCodeModel.create({
      user: user,
      promoCode: promoCode,
    });
  }

  async isValidPromoCode(promoCode: PromoCode, user?: User) {
    const isExpired =
      promoCode.status === PromoCodeStatus.EXPIRED ? true : false;

    const isDisabled =
      promoCode.status === PromoCodeStatus.DISABLED ? true : false;

    if (isExpired || isDisabled)
      throw new MethodNotAllowedResponse({
        ar: 'برومو كود غير متاح',
        en: 'Promo Code is Not Available',
      });

    // Check if promo code is for new comers and validate user eligibility
    if (promoCode.targetAudience === PromoCodeTargetAudienceEnum.NEW_COMERS) {
      if (!user) {
        throw new MethodNotAllowedResponse({
          ar: 'يجب تسجيل الدخول لاستخدام هذا البرومو كود',
          en: 'User must be logged in to use this promo code',
        });
      }

      // Check if user has any completed orders
      const completedOrdersCount = await this.orderModel.countDocuments({
        user: user,
        status: OrderStatus.COMPLETED,
      });

      if (completedOrdersCount > 0) {
        throw new MethodNotAllowedResponse({
          ar: 'هذا البرومو كود مخصص للعملاء الجدد فقط',
          en: 'This promo code is only for new customers',
        });
      }
    }

    if (promoCode.usesType === PromoCodeUsesTypeEnum.PER_CODE) {
      const codeUses = await this.appliedPromoCodeModel
        .find({ promoCode: promoCode })
        .count();

      if (promoCode.numberOfUses <= codeUses) {
        throw new MethodNotAllowedResponse({
          ar: 'لقد تخطيت الحد المسموح للاستخدام',
          en: 'Exceeded Promo Code number of uses',
        });
      }

      if (promoCode.userLimit) {
        const codeUses = await this.appliedPromoCodeModel
          .find({ user: user, promoCode: promoCode })
          .count();

        if (promoCode.userLimit <= codeUses) {
          throw new MethodNotAllowedResponse({
            ar: 'لقد تخطيت الحد المسموح للاستخدام',
            en: 'Exceeded Promo Code number of uses',
          });
        }
      }
    }

    const numberOfExistingDocs = await this.appliedPromoCodeModel
      .find({
        user: user,
        promoCode: promoCode,
      })
      .count();

    if (promoCode.numberOfUses <= numberOfExistingDocs) {
      throw new MethodNotAllowedResponse({
        ar: 'لقد تخطيت الحد المسموح للاستخدام',
        en: 'Exceeded Promo Code number of uses',
      });
    }
  }
}
