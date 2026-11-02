import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Roles } from 'src/admin/schemas/admin.schema';
import { City } from '../../city/schemas/city.schema';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { servicesIconModelName } from '../../services-icons/schemas/services-icons.schema';
import { WashingServicesModelName } from '../../washing-services/schemas/washing-services.schema';
import { CreatePlanDTO, UpdatePlanDTO } from '../dtos';
import { Plan, PlansModel, plansModelName } from '../schemas/plans.schema';

@Injectable()
export class PlansRepository {
  // Attributes
  populatedPaths = [
    {
      path: 'washingServices',
      select: 'name',
      model: WashingServicesModelName,
    },
    {
      path: 'icon',
      select: 'iconPath iconLink',
      model: servicesIconModelName,
    },
  ];
  constructor(
    @InjectModel(plansModelName) private readonly plansModel: Model<PlansModel>,
  ) {}

  // Functions
  async create(createPlanDTO: CreatePlanDTO) {
    const createdPlan = await this.plansModel.create({
      type: createPlanDTO.type,
      color: createPlanDTO.color,
      price: createPlanDTO.price,
      duration: createPlanDTO.duration,
      durationUnit: createPlanDTO.durationUnit,
      washingServices: createPlanDTO.washingServices,
      usageCount: createPlanDTO.usageCount,
      icon: createPlanDTO.icon,
      description: createPlanDTO.description,
    });

    return createdPlan;
  }

  async findAllForAdmins(role: string, city?: City[]) {
    const plans = await this.plansModel.aggregate([
      {
        $lookup: {
          from: 'plans-cities',
          let: { planId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$planId', '$plan'] },
                ...(role === Roles.SubAdmin ? { city: { $in: city } } : {}),
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, plan: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.plansModel.populate(plans, this.populatedPaths);

    return plans;
  }

  async findAllForAdminsDropdown(role: string, city?: City[]) {
    const plans = await this.plansModel.aggregate([
      {
        $lookup: {
          from: 'plans-cities',
          let: { planId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$planId', '$plan'] },
                ...(role === Roles.SubAdmin ? { city: { $in: city } } : {}),
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, plan: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
      {
        $project: {
          _id: 1,
          type: 1,
          color: 1,
        },
      },
    ]);

    return plans;
  }

  async findAll(city: City) {
    const plans = await this.plansModel.aggregate([
      {
        $lookup: {
          from: 'plans-cities',
          let: { planId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$planId', '$plan'] },
                isArchived: false,
                city: city,
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, plan: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.plansModel.populate(plans, this.populatedPaths);

    return plans;
  }

  async findByIdOr404(id: string) {
    const plan = await this.plansModel.aggregate([
      {
        $match: { _id: new mongoose.Types.ObjectId(id) },
      },
      {
        $lookup: {
          from: 'plans-cities',
          let: { planId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$planId', '$plan'] },
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, plan: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.plansModel.populate(plan, this.populatedPaths);

    return plan[0];
  }

  async update(id: string, updatePlanDTO: UpdatePlanDTO | any) {
    const plan = await this.findOneByIdOr404(id);

    if (updatePlanDTO.type !== undefined) plan.type = updatePlanDTO.type;
    if (updatePlanDTO.color !== undefined) plan.color = updatePlanDTO.color;
    if (updatePlanDTO.price !== undefined) plan.price = updatePlanDTO.price;
    if (updatePlanDTO.duration !== undefined)
      plan.duration = updatePlanDTO.duration;
    if (updatePlanDTO.durationUnit !== undefined)
      plan.durationUnit = updatePlanDTO.durationUnit;
    if (updatePlanDTO.washingServices !== undefined)
      plan.washingServices = updatePlanDTO.washingServices;
    if (updatePlanDTO.usageCount !== undefined)
      plan.usageCount = updatePlanDTO.usageCount;
    if (updatePlanDTO.icon !== undefined) plan.icon = updatePlanDTO.icon;
    if (updatePlanDTO.description !== undefined)
      plan.description = updatePlanDTO.description;
    if (updatePlanDTO.qoyodProductId !== undefined)
      plan.qoyodProductId = updatePlanDTO.qoyodProductId;

    await plan.save();

    return plan;
  }

  async findOneByIdOr404(id: string) {
    const plan = await this.plansModel.findById(id);
    if (!plan)
      throw new NotFoundResponse({
        ar: 'لا توجد هذه الباقة',
        en: 'Plan Not Found',
      });

    return plan;
  }

  async findOne(id: Plan) {
    return await this.plansModel.findOne({ _id: id });
  }

  async getPlanSubscriberReport(
    startDate?: string,
    endDate?: string,
    planType?: string,
  ) {
    const filter: any = {};

    if (
      startDate &&
      endDate &&
      !isNaN(Date.parse(startDate)) &&
      !isNaN(Date.parse(endDate))
    ) {
      filter.createdAt = {
        $gte: new Date(startDate),
        $lte: new Date(endDate),
      };
    } else if (startDate || endDate) {
      throw new BadRequestException('Invalid date format.');
    }

    if (planType) {
      filter.type = planType;
    }

    const pipeline: any[] = [
      {
        $match: filter,
      },
      {
        $lookup: {
          from: 'subscriptions',
          localField: '_id',
          foreignField: 'plan',
          as: 'subscriptions',
        },
      },
      {
        $addFields: {
          subscriberCount: { $size: '$subscriptions' },
        },
      },
      {
        $lookup: {
          from: 'washing-services',
          localField: 'washingServices',
          foreignField: '_id',
          as: 'washingServicesDetails',
        },
      },
      {
        $project: {
          planType: '$type',
          color: '$color',
          duration: '$duration',
          durationUnit: '$durationUnit',
          price: '$price',
          washes: '$usageCount',
          includedServices: {
            $map: {
              input: '$washingServicesDetails',
              as: 'service',
              in: '$$service.name',
            },
          },
          subscriberCount: 1,
        },
      },
    ];

    const result = await this.plansModel.aggregate(pipeline);
    return result;
  }

  async getSubscribersForPlan(planId: string) {
    const pipeline: any[] = [
      {
        $match: { _id: new mongoose.Types.ObjectId(planId) },
      },
      {
        $lookup: {
          from: 'subscriptions',
          localField: '_id',
          foreignField: 'plan',
          as: 'subscriptions',
        },
      },
      {
        $unwind: '$subscriptions',
      },
      {
        $lookup: {
          from: 'users',
          localField: 'subscriptions.user',
          foreignField: '_id',
          as: 'userDetails',
        },
      },
      {
        $unwind: '$userDetails',
      },
      {
        $project: {
          userName: '$userDetails.name',
          userEmail: '$userDetails.email',
          remainingWashes: '$subscriptions.remainingWashes',
          expiryDate: '$subscriptions.expiryDate',
          status: '$subscriptions.status',
        },
      },
    ];

    const result = await this.plansModel.aggregate(pipeline);
    return result;
  }

  async findAllWithoutQoyodProduct() {
    return await this.plansModel
      .find({
        $or: [{ qoyodProductId: null }, { qoyodProductId: { $exists: false } }],
      })
      .select('_id type price');
  }
}
