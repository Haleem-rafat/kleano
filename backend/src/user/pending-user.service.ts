import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { NotFoundResponse } from '../common/errors';
import { UserRegisterDTO } from './dto';
import {
  PendingUserModel,
  pendingUserModelName,
} from './schemas/pending-user.schema';

@Injectable()
export class PendingUserService {
  constructor(
    @InjectModel(pendingUserModelName)
    private readonly pendingUserModel: Model<PendingUserModel>,
  ) {}

  async createPendingUser(pendingUser: UserRegisterDTO) {
    const existingPendingUser = await this.pendingUserModel.findOne({
      phone: pendingUser.phone,
    });

    if (existingPendingUser) {
      const updatedPendingUser = existingPendingUser.set({
        userName: pendingUser.userName,
        email: pendingUser.email,
        fcmTokens: [pendingUser.fcmToken],
      });

      await updatedPendingUser.save();

      return updatedPendingUser;
    }

    return this.pendingUserModel.create({
      userName: pendingUser.userName,
      phone: pendingUser.phone,
      email: pendingUser.email,
      fcmTokens: [pendingUser.fcmToken],
    });
  }

  async getPendingUserByPhone(phone: string) {
    return this.pendingUserModel.findOne({ phone }).select('+fcmTokens');
  }

  async getPendingUserByPhoneOr404(phone: string) {
    const pendingUser = await this.getPendingUserByPhone(phone);
    if (!pendingUser)
      throw new NotFoundResponse({
        ar: 'لا يوجد طلب تسجيل لهذا الرقم، يرجى التسجيل أولاً',
        en: 'No pending registration found for this phone, please register first',
      });

    return pendingUser;
  }

  async deletePendingUser(phone: string) {
    return this.pendingUserModel.findOneAndDelete({ phone });
  }
}
