import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model, Types } from 'mongoose';
import { PaginationService } from 'src/common/services/pagination/pagination.service';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { IsGraphViewEnum } from '../dtos';
import { CreateAggregatorPromoCodeDTO } from '../dtos/createAggregatorPromoCode.dto';
import { CreateAllUsersPromoCodeDTO } from '../dtos/createAllUsersPromoCode.dto';
import { CreateB2bPromoCodeDTO } from '../dtos/createB2bPromoCode.dto';
import { CreateNewComersPromoCodeDTO } from '../dtos/createNewComersPromoCode.dto';
import { CreateOfflinePromoCodeDTO } from '../dtos/createOfflinePromoCode.dto';
import { CreateSegmentPromoCodeDto } from '../dtos/createSegmentPromoCode.dto';
import {
  ActivePromoCodes,
  activePromoCodesModelName,
} from '../schemas/active-promo-codes.schema';
import {
  AggregatorPromoCodeModel,
  aggregatorPromoCodeModelName,
} from '../schemas/aggregator-promo-code.schema';
import {
  AllUsersPromoCodeModel,
  allUsersPromoCodeModelName,
} from '../schemas/all-users-promo-code.schema';
import {
  B2bPromoCodeModel,
  b2bPromoCodeModelName,
} from '../schemas/b2b-promo-code.schema';
import {
  NewComersPromoCodeModel,
  newComersPromoCodeModelName,
} from '../schemas/new-comers-promo-code.schema';
import {
  OfflinePromoCodeModel,
  offlinePromoCodeModelName,
} from '../schemas/offline-promo-code.schema';
import {
  PromoCodeStatus,
  PromoCodeTargetAudienceEnum,
  PromoCodeUsesTypeEnum,
  PromoCodesModel,
  promoCodeModelName,
} from '../schemas/promo-code.schema';
import {
  SegmentPromoCodeModel,
  segmentPromoCodeModelName,
} from '../schemas/segment-promo-code.schema';

@Injectable()
export class PromoCodesRepository {
  constructor(
    @InjectModel(promoCodeModelName)
    private readonly promoCodesModel: Model<PromoCodesModel>,
    @InjectModel(newComersPromoCodeModelName)
    private readonly newComersPromoCodeModel: Model<NewComersPromoCodeModel>,
    @InjectModel(allUsersPromoCodeModelName)
    private readonly allUsersPromoCodeModel: Model<AllUsersPromoCodeModel>,
    @InjectModel(aggregatorPromoCodeModelName)
    private readonly aggregatorPromoCodeModel: Model<AggregatorPromoCodeModel>,
    @InjectModel(segmentPromoCodeModelName)
    private readonly segmentPromoCodeModel: Model<SegmentPromoCodeModel>,
    @InjectModel(offlinePromoCodeModelName)
    private readonly offlinePromoCodeModel: Model<OfflinePromoCodeModel>,
    @InjectModel(b2bPromoCodeModelName)
    private readonly b2bPromoCodeModel: Model<B2bPromoCodeModel>,
    @InjectModel(activePromoCodesModelName)
    private readonly activePromoCodesModel: Model<ActivePromoCodes>,
    private readonly paginationService: PaginationService,
  ) {}

  async createPromoCodeForNewComers(
    createNewComersPromoCodeDTO: CreateNewComersPromoCodeDTO,
  ) {
    const {
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
      validWithin,
      duration,
    } = createNewComersPromoCodeDTO;

    let expiryDate;

    if (userLimit && usesType === PromoCodeUsesTypeEnum.PER_USER) {
      throw new ConflictException(
        `UserLimit should not have a value when usesType is not 'PER_CODE'`,
      );
    }

    if (userLimit && userLimit > numberOfUses) {
      throw new ConflictException(
        `UserLimit should not have a value bigger than numberOfUses`,
      );
    }

    if (discountFixedNumber && discountPercentage) {
      throw new BadRequestException('Must choose only one type of discount');
    }

    if (!discountFixedNumber && !discountPercentage) {
      throw new BadRequestException(
        'Must choose at least one type of discount',
      );
    }

    if (duration) {
      expiryDate = this.calculateExpiryDate(duration);
    }

    if (await this.findOneByCode(code)) {
      throw new MethodNotAllowedResponse({
        ar: 'كود مسجل من قبل',
        en: 'Promo Code Exists',
      });
    }

    return await this.newComersPromoCodeModel.create({
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
      validWithin,
      expiryDate,
    });
  }

  async createPromoCodeForAllUsers(
    createAllUsersPromoCodeDTO: CreateAllUsersPromoCodeDTO,
  ) {
    const {
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
      duration,
    } = createAllUsersPromoCodeDTO;

    let expiryDate;

    if (userLimit && usesType === PromoCodeUsesTypeEnum.PER_USER) {
      throw new ConflictException(
        `UserLimit should not have a value when usesType is not 'PER_CODE'`,
      );
    }

    if (userLimit && userLimit > numberOfUses) {
      throw new ConflictException(
        `UserLimit should not have a value bigger than numberOfUses`,
      );
    }

    if (discountFixedNumber && discountPercentage) {
      throw new BadRequestException('Must choose only one type of discount');
    }

    if (!discountFixedNumber && !discountPercentage) {
      throw new BadRequestException(
        'Must choose at least one type of discount',
      );
    }

    if (duration) {
      expiryDate = this.calculateExpiryDate(duration);
    }

    if (await this.findOneByCode(code)) {
      throw new MethodNotAllowedResponse({
        ar: 'كود مسجل من قبل',
        en: 'Promo Code Exists',
      });
    }

    return await this.allUsersPromoCodeModel.create({
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
      expiryDate,
    });
  }

  async createAggregatorPromoCode(
    createAggregatorPromoCodeDto: CreateAggregatorPromoCodeDTO,
  ) {
    const {
      code,
      discountPercentage,
      discountFixedNumber,
      expressionLeftSide,
      expressionRightSide,
      numberOfUses,
      usesType,
      userLimit,
      operator,
      duration,
    } = createAggregatorPromoCodeDto;

    let expiryDate;

    if (userLimit && usesType === PromoCodeUsesTypeEnum.PER_USER) {
      throw new ConflictException(
        `UserLimit should not have a value when usesType is not 'PER_CODE'`,
      );
    }

    if (userLimit && userLimit > numberOfUses) {
      throw new ConflictException(
        `UserLimit should not have a value bigger than numberOfUses`,
      );
    }

    if (discountFixedNumber && discountPercentage) {
      throw new BadRequestException('Must choose only one type of discount');
    }

    if (!discountFixedNumber && !discountPercentage) {
      throw new BadRequestException(
        'Must choose at least one type of discount',
      );
    }

    if (duration) {
      expiryDate = this.calculateExpiryDate(duration);
    }

    if (await this.findOneByCode(code)) {
      throw new MethodNotAllowedResponse({
        ar: 'كود مسجل من قبل',
        en: 'Promo Code Exists',
      });
    }

    return await this.aggregatorPromoCodeModel.create({
      code,
      discountPercentage,
      discountFixedNumber,
      expressionLeftSide,
      expressionRightSide,
      numberOfUses,
      usesType,
      userLimit,
      operator,
      expiryDate,
    });
  }

  async createSegmentPromoCode(
    createSegmentPromoCodeDto: CreateSegmentPromoCodeDto,
  ) {
    const {
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
      segment,
      duration,
    } = createSegmentPromoCodeDto;

    let expiryDate;

    if (userLimit && usesType === PromoCodeUsesTypeEnum.PER_USER) {
      throw new ConflictException(
        `UserLimit should not have a value when usesType is not 'PER_CODE'`,
      );
    }

    if (userLimit && userLimit > numberOfUses) {
      throw new ConflictException(
        `UserLimit should not have a value bigger than numberOfUses`,
      );
    }

    if (discountFixedNumber && discountPercentage) {
      throw new BadRequestException('Must choose only one type of discount');
    }

    if (!discountFixedNumber && !discountPercentage) {
      throw new BadRequestException(
        'Must choose at least one type of discount',
      );
    }

    if (duration) {
      expiryDate = this.calculateExpiryDate(duration);
    }

    if (await this.findOneByCode(code)) {
      throw new MethodNotAllowedResponse({
        ar: 'كود مسجل من قبل',
        en: 'Promo Code Exists',
      });
    }

    return await this.segmentPromoCodeModel.create({
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
      segment,
      expiryDate,
    });
  }

  async createOfflinePromoCode(
    createOfflinePromoCodeDTO: CreateOfflinePromoCodeDTO,
  ) {
    const {
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
    } = createOfflinePromoCodeDTO;

    if (userLimit && usesType === PromoCodeUsesTypeEnum.PER_USER) {
      throw new ConflictException(
        `UserLimit should not have a value when usesType is not 'PER_CODE'`,
      );
    }

    if (userLimit && userLimit > numberOfUses) {
      throw new ConflictException(
        `UserLimit should not have a value bigger than numberOfUses`,
      );
    }

    if (discountFixedNumber && discountPercentage) {
      throw new BadRequestException('Must choose only one type of discount');
    }

    if (!discountFixedNumber && !discountPercentage) {
      throw new BadRequestException(
        'Must choose at least one type of discount',
      );
    }

    if (await this.findOneByCode(code)) {
      throw new MethodNotAllowedResponse({
        ar: 'كود مسجل من قبل',
        en: 'Promo Code Exists',
      });
    }

    await this.offlinePromoCodeModel.create({
      code,
      discountPercentage,
      discountFixedNumber,
      numberOfUses,
      usesType,
      userLimit,
    });
  }

  async createB2bPromoCode(createB2bPromoCodeDto: CreateB2bPromoCodeDTO) {
    const {
      code,
      business,
      quantity,
      numberOfUses,
      usesType,
      discountFixedNumber,
      discountPercentage,
      duration,
      userLimit,
    } = createB2bPromoCodeDto;

    let expiryDate;

    if (userLimit && usesType === PromoCodeUsesTypeEnum.PER_USER) {
      throw new ConflictException(
        `UserLimit should not have a value when usesType is not 'PER_CODE'`,
      );
    }

    if (userLimit && userLimit > numberOfUses) {
      throw new ConflictException(
        `UserLimit should not have a value bigger than numberOfUses`,
      );
    }

    if (discountFixedNumber && discountPercentage) {
      throw new BadRequestException('Must choose only one type of discount');
    }

    if (!discountFixedNumber && !discountPercentage) {
      throw new BadRequestException(
        'Must choose at least one type of discount',
      );
    }

    if (duration) {
      expiryDate = this.calculateExpiryDate(duration);
    }

    if (await this.findOneByCode(code)) {
      throw new MethodNotAllowedResponse({
        ar: 'كود مسجل من قبل',
        en: 'Promo Code Exists',
      });
    }

    const iterations = quantity ? quantity : 1;
    const createdCodes: string[] = [];

    // First, get all existing codes that start with the base code to find the highest number
    const existingCodes = await this.getAllCodesStartingWith(code);
    const existingNumbers = existingCodes
      .map((existingCode) => {
        const match = existingCode.match(
          new RegExp(`^${code.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(\\d+)$`),
        );
        return match ? parseInt(match[1], 10) : 0;
      })
      .filter((num) => num > 0);

    let startingNumber =
      existingNumbers.length > 0 ? Math.max(...existingNumbers) + 1 : 1;

    for (let i = 0; i < iterations; i++) {
      let codeName: string;
      let attempts = 0;
      const maxAttempts = 100; // Prevent infinite loops

      do {
        codeName = `${code}${startingNumber + i}`;
        attempts++;

        if (attempts > maxAttempts) {
          throw new Error(
            `Unable to generate unique promo code after ${maxAttempts} attempts`,
          );
        }

        // Check if we already created this code in this batch
        if (createdCodes.includes(codeName)) {
          startingNumber++;
          continue;
        }

        // Check if it exists in database
        if (await this.findOneByCode(codeName)) {
          startingNumber++;
          continue;
        }

        break;
      } while (true);

      createdCodes.push(codeName);

      await this.b2bPromoCodeModel.create({
        code: codeName,
        business,
        discountPercentage,
        discountFixedNumber,
        numberOfUses,
        usesType,
        userLimit,
        expiryDate,
      });
    }
  }

  async findOneByCode(code: string) {
    const isCodeExist = await this.promoCodesModel.findOne({
      code: code,
      status: PromoCodeStatus.ACTIVE,
    });
    return isCodeExist;
  }

  async getAllCodesStartingWith(baseCode: string): Promise<string[]> {
    const escapedCode = baseCode.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp(`^${escapedCode}\\d+$`);

    const existingCodes = await this.allUsersPromoCodeModel
      .find({
        code: { $regex: regex },
        status: PromoCodeStatus.ACTIVE,
      })
      .select('code')
      .lean();

    return existingCodes.map((doc) => (doc as any).code);
  }

  async findOneAggregatorPromoCodeByCode(code: string) {
    const isCodeExist = await this.aggregatorPromoCodeModel.findOne({
      code: code,
      status: PromoCodeStatus.ACTIVE,
    });
    return isCodeExist;
  }

  async findOneSegmentPromoCodeByCode(code: string) {
    const isCodeExist = await this.segmentPromoCodeModel.findOne({
      code: code,
      status: PromoCodeStatus.ACTIVE,
    });
    return isCodeExist;
  }

  async findOneById(promoCodeId: string) {
    return await this.promoCodesModel.findById(promoCodeId);
  }

  async findAllForUser(status: string, userId: string) {
    if (status === 'USED')
      return await this.appliedPromoCodesQueryForUser(userId);

    if (status === PromoCodeStatus.ACTIVE)
      return await this.findActivePromoCodes(userId);

    return await this.promoCodesModel.find({
      status: PromoCodeStatus.EXPIRED,
    });
  }

  async findAllWithPagination(
    filter: any,
    pagination: { page: string; perPage: string },
    fromDate: Date,
    toDate: Date,
    city: string,
    isGraphView: string,
  ) {
    const page = +pagination.page || 1;
    const limit = +pagination.perPage || 10;

    const [data, [{ total = 0 } = {}]] = await Promise.all([
      this.promoCodesModel.aggregate([
        {
          $match: {
            ...filter,
            ...(isGraphView === IsGraphViewEnum.FALSE &&
              fromDate &&
              toDate && {
                createdAt: {
                  $gte: new Date(fromDate), // from date
                  $lte: new Date(toDate), // to date
                },
              }),
          },
        },
        {
          $lookup: {
            from: 'applied-promo-codes',
            let: { promoCodeId: '$_id' },
            pipeline: [
              {
                $match: {
                  $expr: {
                    $eq: ['$promoCode', '$$promoCodeId'],
                  },
                  ...(isGraphView === IsGraphViewEnum.TRUE && {
                    ...(fromDate &&
                      toDate && {
                        createdAt: {
                          $gte: new Date(fromDate), // from date
                          $lte: new Date(toDate), // to date
                        },
                      }),
                  }),
                },
              },
            ],
            as: 'applied',
          },
        },
        // {
        //   $match: {
        //     applied: { $ne: [] }, // Filters out promo codes without applied entries
        //   },
        // },
        {
          $lookup: {
            from: 'orders',
            let: { promoCodeId: '$_id' },
            pipeline: [
              {
                $match: {
                  $expr: {
                    $eq: ['$promoCode', '$$promoCodeId'],
                  },
                },
              },
              {
                $lookup: {
                  from: 'locations',
                  localField: 'location',
                  foreignField: '_id',
                  pipeline: [
                    {
                      $match: {
                        ...(city && { city: new Types.ObjectId(city) }),
                      },
                    },
                    {
                      $project: {
                        city: 1,
                      },
                    },
                  ],
                  as: 'location',
                },
              },
              {
                $project: {
                  promoCode: 1,
                  location: 1,
                },
              },
            ],
            as: 'cityPromoCodes',
          },
        },
        // {
        //   $match: {
        //     cityPromoCodes: { $ne: [] }, // Filters out promo codes without applied entries
        //   },
        // },
        {
          $sort: { createdAt: -1 },
        },
        {
          $project: {
            _id: 1,
            code: 1,
            expiryDate: 1,
            discountPercentage: 1,
            discountFixedNumber: 1,
            targetAudience: 1,
            segment: 1,
            status: 1,
            numberOfUses: 1,
            business: 1,
            createdAt: 1,
            appliedCount: {
              $cond: {
                if: { $eq: [!!city, true] },
                then: {
                  $cond: {
                    if: { $isArray: '$cityPromoCodes' }, // Check if cityPromoCodes is an array
                    then: { $size: '$cityPromoCodes' }, // Apply $size if it's an array
                    else: 0, // Return 0 if it's not an array
                  },
                },
                else: {
                  $cond: {
                    if: { $isArray: '$applied' }, // Check if applied is an array
                    then: { $size: '$applied' }, // Apply $size if it's an array
                    else: 0, // Return 0 if it's not an array
                  },
                },
              },
            },
          },
        },
        ...(isGraphView === IsGraphViewEnum.FALSE
          ? [{ $skip: (page - 1) * limit }, { $limit: limit }]
          : []),
      ]),
      this.promoCodesModel
        .aggregate([
          {
            $match: {
              ...filter,
              ...(isGraphView === IsGraphViewEnum.FALSE &&
                fromDate &&
                toDate && {
                  createdAt: {
                    $gte: new Date(fromDate), // from date
                    $lte: new Date(toDate), // to date
                  },
                }),
            },
          },
          {
            $lookup: {
              from: 'applied-promo-codes',
              let: { promoCodeId: '$_id' },
              pipeline: [
                {
                  $match: {
                    $expr: {
                      $eq: ['$promoCode', '$$promoCodeId'],
                    },
                    ...(isGraphView === IsGraphViewEnum.TRUE && {
                      ...(fromDate &&
                        toDate && {
                          createdAt: {
                            $gte: new Date(fromDate), // from date
                            $lte: new Date(toDate), // to date
                          },
                        }),
                    }),
                  },
                },
              ],
              as: 'applied',
            },
          },
          // {
          //   $match: {
          //     applied: { $ne: [] }, // Filters out promo codes without applied entries
          //   },
          // },
          {
            $lookup: {
              from: 'orders',
              let: { promoCodeId: '$_id' },
              pipeline: [
                {
                  $match: {
                    $expr: {
                      $eq: ['$promoCode', '$$promoCodeId'],
                    },
                  },
                },
                {
                  $lookup: {
                    from: 'locations',
                    localField: 'location',
                    foreignField: '_id',
                    pipeline: [
                      {
                        $match: {
                          ...(city && { city: new Types.ObjectId(city) }),
                        },
                      },
                      {
                        $project: {
                          city: 1,
                        },
                      },
                    ],
                    as: 'location',
                  },
                },

                {
                  $project: {
                    promoCode: 1,
                    location: 1,
                  },
                },
              ],
              as: 'cityPromoCodes',
            },
          },
          // {
          //   $match: {
          //     cityPromoCodes: { $ne: [] }, // Filters out promo codes without applied entries
          //   },
          // },
        ])
        .count('total'),
    ]);

    return isGraphView === IsGraphViewEnum.FALSE
      ? this.paginationService.paginate(data, total, page, limit)
      : data;
  }

  async findAllForAdminDropdown() {
    const promoCodes = await this.promoCodesModel
      .find({
        status: PromoCodeStatus.ACTIVE,
      })
      .select('_id code');

    return promoCodes;
  }

  async findAll(filter: any) {
    return await this.promoCodesModel.find({
      ...filter,
    });
  }

  async findActiveNewcomerPromoCodesNotExpired() {
    const now = new Date();
    return await this.promoCodesModel
      .find({
        status: PromoCodeStatus.ACTIVE,
        targetAudience: PromoCodeTargetAudienceEnum.NEW_COMERS,
        $or: [{ expiryDate: { $exists: false } }, { expiryDate: { $gt: now } }],
      })
      .select('_id code')
      .lean();
  }

  async findActiveAllUsersPromoCodesNotExpired() {
    const now = new Date();
    return await this.promoCodesModel
      .find({
        status: PromoCodeStatus.ACTIVE,
        targetAudience: PromoCodeTargetAudienceEnum.ALL_USERS,
        $or: [{ expiryDate: { $exists: false } }, { expiryDate: { $gt: now } }],
      })
      .select('_id code')
      .lean();
  }

  async findActiveSegmentPromoCodesNotExpired(segmentId: string) {
    const now = new Date();
    return await this.promoCodesModel
      .find({
        status: PromoCodeStatus.ACTIVE,
        targetAudience: PromoCodeTargetAudienceEnum.SEGMENT,
        segment: new Types.ObjectId(segmentId),
        $or: [{ expiryDate: { $exists: false } }, { expiryDate: { $gt: now } }],
      })
      .select('_id code')
      .lean();
  }

  async update(filter: any, updatedData: any) {
    await this.promoCodesModel.updateMany(
      {
        ...filter,
      },
      { $set: updatedData },
    );
  }

  async updatePromoCode(promoCodeId: string, code: string) {
    const promoCode = await this.promoCodesModel.findById(promoCodeId);

    if (!promoCode) {
      throw new NotFoundException({
        ar: 'رمز الترويج غير موجود',
        en: 'Promo Code not found',
      });
    }

    promoCode.set({ code });
    await promoCode.save();
  }

  async disablePromoCode(promoCodeId: string) {
    const promoCode = await this.promoCodesModel.findOne({
      _id: new Types.ObjectId(promoCodeId),
      status: PromoCodeStatus.ACTIVE,
    });

    if (!promoCode) {
      throw new NotFoundException({
        ar: 'رمز الترويج غير موجود',
        en: 'Promo Code not found',
      });
    }

    promoCode.set({ status: PromoCodeStatus.DISABLED });
    await promoCode.save();
  }

  async activatePromoCode(promoCodeId: string) {
    const promoCode = await this.promoCodesModel.findOne({
      _id: new Types.ObjectId(promoCodeId),
      status: PromoCodeStatus.DISABLED,
    });

    if (!promoCode) {
      throw new NotFoundException({
        ar: 'رمز الترويج غير موجود',
        en: 'Promo Code not found',
      });
    }

    promoCode.set({ status: PromoCodeStatus.ACTIVE });
    await promoCode.save();
  }

  async appliedPromoCodesQueryForUser(userId: string) {
    const res = await this.promoCodesModel.aggregate([
      {
        $lookup: {
          from: 'applied-promo-codes',
          let: { promoCodeId: '$_id' },
          pipeline: [
            { $match: { $expr: { $eq: ['$$promoCodeId', '$promoCode'] } } },
            {
              $lookup: {
                from: 'users',
                let: { userId: '$user' },
                pipeline: [
                  {
                    $match: {
                      $expr: {
                        $and: [
                          { $eq: ['$$userId', '$_id'] },
                          {
                            $eq: [
                              '$$userId',
                              new mongoose.Types.ObjectId(userId),
                            ],
                          },
                        ],
                      },
                    },
                  },
                ],
                as: 'user',
              },
            },
            {
              $project: { _id: 0, promoCode: 0, createdAt: 0, updatedAt: 0 },
            },
            { $unwind: '$user' },
          ],
          as: 'user_applied',
        },
      },
    ]);
    return this.appliedPromoCodesFormater(res);
  }

  async findActivePromoCodes(userId: string) {
    const res = await this.activePromoCodesModel.aggregate([
      {
        $match: { user: new mongoose.Types.ObjectId(userId) },
      },
      {
        $lookup: {
          from: 'promo-codes',
          localField: 'promoCode',
          foreignField: '_id',
          as: 'promoCodeDetails',
        },
      },
      {
        $unwind: '$promoCodeDetails',
      },
      {
        $match: { 'promoCodeDetails.status': PromoCodeStatus.ACTIVE },
      },
      {
        $lookup: {
          from: 'applied-promo-codes',
          let: { promoCodeId: '$promoCode' },
          pipeline: [
            {
              $match: {
                $expr: {
                  $and: [
                    { $eq: ['$$promoCodeId', '$promoCode'] },
                    { $eq: ['$user', new mongoose.Types.ObjectId(userId)] },
                  ],
                },
              },
            },
          ],
          as: 'applied',
        },
      },
      {
        $match: { applied: { $size: 0 } },
      },
      {
        $replaceRoot: { newRoot: '$promoCodeDetails' },
      },
    ]);

    return res;
  }

  appliedPromoCodesFormater(promoCodes: any[]) {
    const filtered = promoCodes.filter(
      (promoCode: any) => promoCode.user_applied.length >= 1,
    );

    filtered.forEach((promoCode) => {
      promoCode.user_applied = undefined;
    });
    return filtered;
  }

  calculateExpiryDate(duration: number) {
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + duration);
    return expiryDate;
  }
}
