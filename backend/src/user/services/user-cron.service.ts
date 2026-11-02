import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Cron } from '@nestjs/schedule';
import { Model } from 'mongoose';
import {
  PendingUserModel,
  pendingUserModelName,
} from '../schemas/pending-user.schema';
import { UserModel, userModelName } from '../schemas/user.schema';

@Injectable()
export class UserCronService {
  private readonly logger = new Logger(UserCronService.name);

  constructor(
    @InjectModel(userModelName) private readonly userModel: Model<UserModel>,
    @InjectModel(pendingUserModelName)
    private readonly pendingUserModel: Model<PendingUserModel>,
  ) {}

  /**
   * Cron job that runs every 30 minutes to reset all users' and pending users' otpAttempts to 0
   */
  @Cron('*/30 * * * *') // Runs every 30 minutes
  async resetOtpAttempts() {
    this.logger.log('Running cron job: Reset OTP attempts');

    try {
      const usersResult = await this.userModel.updateMany(
        { otpAttempts: { $gt: 0 } }, // Only update users with otpAttempts > 0
        { $set: { otpAttempts: 0 } },
      );

      const pendingUsersResult = await this.pendingUserModel.updateMany(
        { otpAttempts: { $gt: 0 } },
        { $set: { otpAttempts: 0 } },
      );

      this.logger.log(
        `OTP attempts reset completed - Updated ${usersResult.modifiedCount} users, ${pendingUsersResult.modifiedCount} pending users`,
      );
    } catch (error) {
      this.logger.error(`Error in resetOtpAttempts cron job: ${error.message}`);
    }
  }
}
