import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Model, Types } from 'mongoose';
import { NotificationsService } from '../../notifications/services/notifications.service';
import {
  SegmentModel,
  segmentModelName,
} from '../../segments/schemas/segment.schema';
import { User, UserModel, userModelName } from '../../user/schemas/user.schema';
import { GetPromoCodesDTO } from '../dtos';
import { CreateAggregatorPromoCodeDTO } from '../dtos/createAggregatorPromoCode.dto';
import { CreateAllUsersPromoCodeDTO } from '../dtos/createAllUsersPromoCode.dto';
import { CreateB2bPromoCodeDTO } from '../dtos/createB2bPromoCode.dto';
import { CreateNewComersPromoCodeDTO } from '../dtos/createNewComersPromoCode.dto';
import { CreateOfflinePromoCodeDTO } from '../dtos/createOfflinePromoCode.dto';
import { CreateSegmentPromoCodeDto } from '../dtos/createSegmentPromoCode.dto';
import { ActivePromoCodesRepository } from '../repositories/active-promo-codes.repository';
import { AppliedPromoCodesRepository } from '../repositories/applied-promo-codes.repository';
import { PromoCodesRepository } from '../repositories/promo-code.repository';
import { PromoCode, PromoCodeStatus } from '../schemas/promo-code.schema';

@Injectable()
export class PromoCodesService {
  constructor(
    private promoCodesRepository: PromoCodesRepository,
    private appliedPromoCodesRepository: AppliedPromoCodesRepository,
    private activePromoCodesRepository: ActivePromoCodesRepository,
    @Inject(forwardRef(() => NotificationsService))
    private notificationService: NotificationsService,
    @InjectModel(userModelName) private readonly userModel: Model<UserModel>,
    @InjectModel(segmentModelName)
    private readonly segmentModel: Model<SegmentModel>,
  ) {}

  async createNewComersPromoCode(
    createNewComersPromoCodeDTO: CreateNewComersPromoCodeDTO,
  ) {
    const createdPromoCode =
      await this.promoCodesRepository.createPromoCodeForNewComers(
        createNewComersPromoCodeDTO,
      );

    await this.createActivePromoCodeForNewComer(
      createdPromoCode._id.toString(),
    );

    await this.notificationService.sendNewPromoCodePublishedForNewComers(
      createNewComersPromoCodeDTO.code,
      createNewComersPromoCodeDTO.discountPercentage,
      createNewComersPromoCodeDTO.discountFixedNumber,
    );
  }

  // @Cron(CronExpression.EVERY_5_MINUTES)
  // async assignPromoCodesToNewUsers() {
  //   if (process.env.PROMO_STREAMS_ENABLED === 'false') return;

  //   try {
  //     // Get all users
  //     const allUsers = await this.userModel.find({ isDeleted: false }).lean();

  //     // Get all active newcomer and all-users promo codes
  //     const newcomerCodes =
  //       await this.promoCodesRepository.findActiveNewcomerPromoCodesNotExpired();
  //     const allUsersCodes =
  //       await this.promoCodesRepository.findActiveAllUsersPromoCodesNotExpired();

  //     // For each user, check if they have the promo codes assigned
  //     for (const user of allUsers) {
  //       const userId = (user as any)._id.toString();

  //       // Assign newcomer promo codes if user doesn't have them
  //       for (const promo of newcomerCodes) {
  //         const existingAssignment =
  //           await this.activePromoCodesRepository.findByUserAndPromoCode(
  //             userId,
  //             (promo as any)._id.toString(),
  //           );
  //         if (!existingAssignment) {
  //           try {
  //             await this.activePromoCodesRepository.create(
  //               userId,
  //               (promo as any)._id.toString(),
  //             );
  //           } catch (e) {
  //             console.error(
  //               `Failed to assign newcomer promo code ${
  //                 (promo as any)._id
  //               } to user ${userId}`,
  //               e?.message || e,
  //             );
  //           }
  //         }
  //       }

  //       // Assign all-users promo codes if user doesn't have them
  //       for (const promo of allUsersCodes) {
  //         const existingAssignment =
  //           await this.activePromoCodesRepository.findByUserAndPromoCode(
  //             userId,
  //             (promo as any)._id.toString(),
  //           );
  //         if (!existingAssignment) {
  //           try {
  //             await this.activePromoCodesRepository.create(
  //               userId,
  //               (promo as any)._id.toString(),
  //             );
  //           } catch (e) {
  //             console.error(
  //               `Failed to assign all-users promo code ${
  //                 (promo as any)._id
  //               } to user ${userId}`,
  //               e?.message || e,
  //             );
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     console.error('assign promo codes to new users failed', e?.message || e);
  //   }
  // }

  // @Cron(CronExpression.EVERY_5_MINUTES)
  // async assignPromoCodesToSegmentUsers() {
  //   if (process.env.PROMO_STREAMS_ENABLED === 'false') return;

  //   try {
  //     // Get all segments
  //     const segments = await this.segmentModel.find().lean();

  //     for (const segment of segments) {
  //       const segmentId = (segment as any)._id.toString();
  //       const userIds = ((segment as any).users || []).map((u: any) =>
  //         u.toString(),
  //       );

  //       if (userIds.length === 0) continue;

  //       // Get active segment promo codes for this segment
  //       const segmentPromos =
  //         await this.promoCodesRepository.findActiveSegmentPromoCodesNotExpired(
  //           segmentId,
  //         );

  //       if (!segmentPromos || segmentPromos.length === 0) continue;

  //       // Assign promo codes to users in the segment who don't have them
  //       for (const promo of segmentPromos) {
  //         const promoId = (promo as any)._id.toString();
  //         for (const userId of userIds) {
  //           const existingAssignment =
  //             await this.activePromoCodesRepository.findByUserAndPromoCode(
  //               userId,
  //               promoId,
  //             );
  //           if (!existingAssignment) {
  //             try {
  //               await this.activePromoCodesRepository.create(userId, promoId);
  //             } catch (e) {
  //               console.error(
  //                 `Failed to assign segment promo code ${promoId} to user ${userId}`,
  //                 e?.message || e,
  //               );
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     console.error('assign segment promo codes failed', e?.message || e);
  //   }
  // }

  async createAllUsersPromoCode(
    createAllUsersPromoCodeDTO: CreateAllUsersPromoCodeDTO,
  ) {
    const createdPromoCode =
      await this.promoCodesRepository.createPromoCodeForAllUsers(
        createAllUsersPromoCodeDTO,
      );

    await this.createActivePromoCodeForAllUsers(
      createdPromoCode._id.toString(),
    );

    await this.notificationService.sendNewPromoCodeCreatedNotification(
      createAllUsersPromoCodeDTO.code,
      createAllUsersPromoCodeDTO.discountPercentage,
      createAllUsersPromoCodeDTO.discountFixedNumber,
    );
  }

  async createAggregatorPromoCode(
    createAggregatorPromoCodeDto: CreateAggregatorPromoCodeDTO,
  ) {
    const createdPromoCode =
      await this.promoCodesRepository.createAggregatorPromoCode(
        createAggregatorPromoCodeDto,
      );

    await this.createActivePromoCodeForAggregator(
      createdPromoCode._id.toString(),
      createAggregatorPromoCodeDto.expressionLeftSide,
      createAggregatorPromoCodeDto.operator,
      createAggregatorPromoCodeDto.expressionRightSide,
    );

    await this.notificationService.sendNewPromoCodePublishedForAggregatorUsers(
      createAggregatorPromoCodeDto.code,
      createAggregatorPromoCodeDto.discountPercentage,
      createAggregatorPromoCodeDto.discountFixedNumber,
    );
  }

  async createSegmentPromoCode(
    createSegmentPromoCodeDto: CreateSegmentPromoCodeDto,
  ) {
    const createdPromoCode =
      await this.promoCodesRepository.createSegmentPromoCode(
        createSegmentPromoCodeDto,
      );

    await this.createActivePromoCodeForSegment(
      createdPromoCode._id.toString(),
      createSegmentPromoCodeDto.segment.toString(),
    );

    await this.notificationService.sendNewPromoCodePublishedForSegment(
      createSegmentPromoCodeDto.code,
      createSegmentPromoCodeDto.discountPercentage,
      createSegmentPromoCodeDto.discountFixedNumber,
    );
  }

  async createOfflinePromoCode(
    createOfflinePromoCodeDto: CreateOfflinePromoCodeDTO,
  ) {
    await this.promoCodesRepository.createOfflinePromoCode(
      createOfflinePromoCodeDto,
    );
  }

  async createB2bPromoCode(createB2bPromoCodeDto: CreateB2bPromoCodeDTO) {
    await this.promoCodesRepository.createB2bPromoCode(createB2bPromoCodeDto);
  }

  async getAllForUser(status: string, userId: string) {
    return await this.promoCodesRepository.findAllForUser(status, userId);
  }

  async getAllForAdmin(getPromoCodesDTO: GetPromoCodesDTO) {
    const {
      fromDate,
      toDate,
      status,
      page,
      perPage,
      targetAudience,
      segment,
      city,
      isGraphView,
      promoCodeId,
      business,
    } = getPromoCodesDTO;
    return await this.promoCodesRepository.findAllWithPagination(
      {
        ...(status && { status }),
        ...(targetAudience && { targetAudience: targetAudience }),
        ...(segment && { segment: new Types.ObjectId(segment) }),
        ...(promoCodeId && { _id: new Types.ObjectId(promoCodeId) }),
        ...(business && { business }),
      },
      { page, perPage },
      fromDate,
      toDate,
      city,
      isGraphView,
    );
  }

  async getAllForAdminDropdown() {
    return await this.promoCodesRepository.findAllForAdminDropdown();
  }

  calculateExpiryDate(duration: number) {
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + duration);
    return expiryDate;
  }

  async getByCode(code: string) {
    return await this.promoCodesRepository.findOneByCode(code);
  }

  async getById(promoCodeId: string) {
    return await this.promoCodesRepository.findOneById(promoCodeId);
  }

  async getAggregatorByCode(code: string) {
    return await this.promoCodesRepository.findOneAggregatorPromoCodeByCode(
      code,
    );
  }

  async getSegmentPromoByCode(code: string) {
    return await this.promoCodesRepository.findOneSegmentPromoCodeByCode(code);
  }

  async assignActiveNewcomerPromoCodesToUser(userId: string) {
    const newcomerCodes =
      await this.promoCodesRepository.findActiveNewcomerPromoCodesNotExpired();

    if (!newcomerCodes || newcomerCodes.length === 0) return;

    for (const promo of newcomerCodes) {
      await this.activePromoCodesRepository.create(userId, (promo as any)._id);
    }
  }

  async assignActiveAllUsersPromoCodesToUser(userId: string) {
    const allUsersCodes =
      await this.promoCodesRepository.findActiveAllUsersPromoCodesNotExpired();

    if (!allUsersCodes || allUsersCodes.length === 0) return;

    for (const promo of allUsersCodes) {
      await this.activePromoCodesRepository.create(userId, (promo as any)._id);
    }
  }

  async apply(user: User, promoCode: PromoCode) {
    await this.appliedPromoCodesRepository.applyPromoCode(user, promoCode);
  }

  async updatePromoCode(promoCodeId: string, code: string) {
    await this.promoCodesRepository.updatePromoCode(promoCodeId, code);
  }

  async disablePromoCode(promoCodeId: string) {
    await this.promoCodesRepository.disablePromoCode(promoCodeId);
  }

  async activatePromoCode(promoCodeId: string) {
    await this.promoCodesRepository.activatePromoCode(promoCodeId);
  }

  async createActivePromoCodeForNewComer(promoCodeId: string) {
    // Find all users who haven't made any orders (new comers)
    const newComerUsers = await this.findUsersWithoutOrders();

    if (newComerUsers.length === 0) {
      console.log('No new comer users found to assign promo code');
      return;
    }

    const userIds = newComerUsers.map((user) => user._id.toString());

    await this.activePromoCodesRepository.createForMultipleUsers(
      userIds,
      promoCodeId,
    );

    console.log(
      `Created active promo codes for ${userIds.length} new comer users`,
    );
  }

  async createActivePromoCodeForAllUsers(promoCodeId: string) {
    const allUsers = await this.userModel.find({ isDeleted: false }).lean();

    if (allUsers.length === 0) {
      console.log('No users found to assign promo code');
      return;
    }

    const userIds = allUsers.map((user: any) => user._id.toString());

    await this.activePromoCodesRepository.createForMultipleUsers(
      userIds,
      promoCodeId,
    );

    console.log(`Created active promo codes for ${userIds.length} users`);
  }

  async createActivePromoCodeForSegment(
    promoCodeId: string,
    segmentId: string,
  ) {
    const segmentUsers = await this.userModel
      .find({
        isDeleted: false,
        segment: new Types.ObjectId(segmentId),
      })
      .lean();

    if (segmentUsers.length === 0) {
      console.log('No users found in the selected segment');
      return;
    }

    const userIds = segmentUsers.map((user: any) => user._id.toString());

    await this.activePromoCodesRepository.createForMultipleUsers(
      userIds,
      promoCodeId,
    );

    console.log(
      `Created active promo codes for ${userIds.length} users in segment`,
    );
  }

  async createActivePromoCodeForAggregator(
    promoCodeId: string,
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    // Find users meeting the aggregator criteria based on their order count
    const pipeline: any[] = [
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'user',
          as: 'orders',
        },
      },
      {
        $addFields: { orderCount: { $size: { $ifNull: ['$orders', []] } } },
      },
      {
        $match: { isDeleted: false },
      },
    ];

    if (operator === 'EQUALS') {
      pipeline.push({ $match: { orderCount: { $eq: expressionRightSide } } });
    } else if (operator === 'GREATER_THAN') {
      pipeline.push({ $match: { orderCount: { $gt: expressionRightSide } } });
    } else if (operator === 'LESS_THAN') {
      pipeline.push({ $match: { orderCount: { $lt: expressionRightSide } } });
    }

    const aggregatorUsers = await this.userModel.aggregate(pipeline);

    if (aggregatorUsers.length === 0) {
      console.log('No users found meeting aggregator criteria');
      return;
    }

    // Extract user IDs
    const userIds = aggregatorUsers.map((user: any) => user._id.toString());

    // Create active promo codes for all users meeting criteria
    await this.activePromoCodesRepository.createForMultipleUsers(
      userIds,
      promoCodeId,
    );

    console.log(
      `Created active promo codes for ${userIds.length} users meeting aggregator criteria`,
    );
  }

  private async findUsersWithoutOrders() {
    const res = await this.userModel.aggregate([
      { $match: { isDeleted: false } },
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'user',
          as: 'orders',
        },
      },
      { $match: { orders: { $size: 0 } } },
      { $project: { _id: 1 } },
    ]);
    return res;
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async checkPromoCodeExpiryDateReached() {
    console.log(`PromoCode Expiry Date Reached Started at ${new Date()}`);
    const today = new Date();

    // Get the PromoCodes that today or befor is its expairy date
    const expairedPromoCodes = await this.promoCodesRepository.findAll({
      expiryDate: { $lte: today },
      status: PromoCodeStatus.ACTIVE,
    });

    console.log(
      `Number of PromoCodes to be Exipred at ${new Date()} is ${
        expairedPromoCodes.length
      }`,
    );

    await this.promoCodesRepository.update(
      {
        _id: {
          $in: expairedPromoCodes.map(
            (expiredPromoCode) => expiredPromoCode._id,
          ),
        },
      },
      { status: PromoCodeStatus.EXPIRED },
    );
  }

  async isValidPromoCode(promoCode: PromoCode, user?: User) {
    return await this.appliedPromoCodesRepository.isValidPromoCode(
      promoCode,
      user,
    );
  }
}
