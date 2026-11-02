import {
  BadRequestException,
  Inject,
  Injectable,
  forwardRef,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { NearestAreaCalculator } from 'src/area/nearestAreaCalculator.service';
import { BikersRepository } from 'src/bikers/repositories/bikers.repository';
import { BikerModel, bikerModelName } from 'src/bikers/schemas/bikers.schema';
import { AdminService } from '../../admin/admin.service';
import { Roles } from '../../admin/schemas/admin.schema';
import { CitiesService } from '../../city/city.service';
import { NearestCityCalculator } from '../../city/nearestCityCalculator.service';
import { City } from '../../city/schemas/city.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { SubscriptionsService } from '../../subscriptions/services/subscriptions.service';
import { UserService } from '../../user/user.service';
import { UpdatePlanDTO } from '../dtos';
import { CreatePlanDTO } from '../dtos/createPlan.dto';
import { QueryParamsDTO } from '../dtos/queryParams.dto';
import { PlansCitiesRepository } from '../repositories/plans-cities.repository';
import { PlansRepository } from '../repositories/plans.repoistory';
import { Plan } from '../schemas/plans.schema';

@Injectable()
export class PlansService {
  constructor(
    private plansRepository: PlansRepository,
    private plansCitiesRepository: PlansCitiesRepository,
    private citiesService: CitiesService,
    @Inject(forwardRef(() => UserService))
    private userService: UserService,
    private nearestCityCalculator: NearestCityCalculator,
    private adminService: AdminService,
    @Inject(forwardRef(() => SubscriptionsService))
    private subscriptionsService: SubscriptionsService,
    private nearestAreaCalculator: NearestAreaCalculator,
    @InjectModel(bikerModelName) private readonly bikerModel: Model<BikerModel>,
    private bikersRepository: BikersRepository,
    private eventEmitter: EventEmitter2,
  ) {}

  async createPlan(
    createPlanDTO: CreatePlanDTO,
    adminId: string,
    role: string,
  ) {
    if (!createPlanDTO.selectAll && !createPlanDTO.cities)
      throw new MethodNotAllowedResponse({
        ar: 'ادخل المدن',
        en: 'Select cities',
      });

    let plan;

    switch (role) {
      case Roles.SuperAdmin:
        plan = await this.createPlanSuperAdmin(createPlanDTO);
        break;
      case Roles.SubAdmin:
        plan = await this.createPlanSubAdmin(createPlanDTO, adminId);
        break;
      default:
        throw new MethodNotAllowedResponse({
          ar: 'غير مصرح لك',
          en: 'Not Auht',
        });
    }

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('plans.created', {
        planId: plan.id,
        planType: plan.type,
        planPrice: plan.price,
      });
    }
  }

  async createPlanSuperAdmin(createPlanDTO: CreatePlanDTO) {
    if (!createPlanDTO.selectAll) {
      // check cities Active status
      for (const city of createPlanDTO.cities) {
        await this.citiesService.checkCityExistence(city);
      }
    }
    const createdPlan = await this.plansRepository.create(createPlanDTO);

    await this.plansCitiesRepository.insertMany(
      createdPlan,
      createPlanDTO.selectAll
        ? await this.citiesService.getAdminCities(Roles.SuperAdmin)
        : createPlanDTO.cities,
    );

    return createdPlan;
  }

  async createPlanSubAdmin(createPlanDTO: CreatePlanDTO, adminId: string) {
    if (!createPlanDTO.selectAll) {
      // check admin permissions
      await this.adminService.CitiesPermissionCreation(
        adminId,
        createPlanDTO.cities,
      );
      // check cities Active status
      for (const city of createPlanDTO.cities) {
        await this.citiesService.checkCityExistence(city);
      }
    }

    const createdPlan = await this.plansRepository.create(createPlanDTO);

    await this.plansCitiesRepository.insertMany(
      createdPlan,
      createPlanDTO.selectAll
        ? await this.citiesService.getAdminCities(Roles.SubAdmin, adminId)
        : createPlanDTO.cities,
    );

    return createdPlan;
  }

  async getAllForUser(userId: string, queryParamsDTO: QueryParamsDTO) {
    const user = await this.userService.getUserById(userId);

    if (queryParamsDTO.country.toLowerCase() !== 'saudi arabia') {
      throw new BadRequestException({
        ar: 'خدماتنا غير متوفرة في موقعك',
        en: 'Our services are not available in your location.',
      });
    }

    const [userAreaLocation] = await Promise.all([
      this.nearestAreaCalculator.findAreaByPoint(
        Number(queryParamsDTO.latitude),
        Number(queryParamsDTO.longitude),
      ),
    ]);

    if (
      !userAreaLocation ||
      !(
        await this.bikersRepository.findAllByArea(String(userAreaLocation._id))
      ).length
    ) {
      throw new BadRequestException({
        ar: 'خدماتنا غير متوفرة في موقعك',
        en: 'Our services are not available in your location.',
      });
    }

    const city = await this.nearestCityCalculator.findNearestCity(
      Number(queryParamsDTO.latitude),
      Number(queryParamsDTO.longitude),
    );

    const plans = await this.plansRepository.findAll(city['city']._id);

    const userSubscribedPlan =
      await this.subscriptionsService.isUserHasSubscription(user);

    const formattedPlans = this.plansFormaterForUser(plans);

    formattedPlans.forEach((plan) => {
      if (plan._id.toString() === userSubscribedPlan?.plan.toString())
        plan.isSubscribed = true;
      else plan.isSubscribed = false;
    });

    return {
      plans: formattedPlans,
      message: !formattedPlans.length
        ? 'Our Service Not Exist Waiting for us soon..'
        : '',
    };
  }

  async getAllForGuest(queryParamsDTO: QueryParamsDTO) {
    const city = await this.nearestCityCalculator.findNearestCity(
      Number(queryParamsDTO.latitude),
      Number(queryParamsDTO.longitude),
    );

    if (!city['city'])
      return {
        plans: [],
        message: 'Our Service Not Exist Waiting for us soon..',
      };

    const userAreaLocation = await this.nearestAreaCalculator.findAreaByPoint(
      Number(queryParamsDTO.latitude),
      Number(queryParamsDTO.longitude),
    );

    if (
      !userAreaLocation ||
      !(
        await this.bikersRepository.findAllByArea(String(userAreaLocation._id))
      ).length
    ) {
      return {
        plans: [],
        message: 'Our services are not available in your location.',
      };
    }

    const plans = await this.plansRepository.findAll(city['city']._id);

    const formattedPlans = this.plansFormaterForUser(plans);

    return {
      plans: formattedPlans,
      message: !formattedPlans.length
        ? 'Our Service Not Exist Waiting for us soon..'
        : '',
    };
  }

  async getAllForAdmin(adminId: string, role: string) {
    switch (role) {
      case Roles.SuperAdmin:
        const plansForSuperAdmin = await this.plansRepository.findAllForAdmins(
          role,
        );
        plansForSuperAdmin.forEach((plan) => {
          plan.cities = undefined;
        });
        return plansForSuperAdmin;
      case Roles.SubAdmin:
        const admin = await this.adminService.getById(adminId);
        const plans = await this.plansRepository.findAllForAdmins(
          role,
          admin.city,
        );
        return this.plansFormaterForUser(plans);
      default:
        return [];
    }
  }

  async getAllForAdminDropdown(adminId: string, role: string) {
    switch (role) {
      case Roles.SuperAdmin:
        const plansForSuperAdmin =
          await this.plansRepository.findAllForAdminsDropdown(role);
        plansForSuperAdmin.forEach((plan) => {
          plan.cities = undefined;
        });
        return plansForSuperAdmin;
      case Roles.SubAdmin:
        const admin = await this.adminService.getById(adminId);
        const plans = await this.plansRepository.findAllForAdminsDropdown(
          role,
          admin.city,
        );
        return this.plansFormaterForUser(plans);
      default:
        return [];
    }
  }

  plansFormaterForUser(plansList: any[]) {
    const filtered = plansList.filter((plan: any) => plan.cities.length >= 1);

    filtered.forEach((plan: any) => {
      plan.cities = undefined;
    });
    return filtered;
  }

  async getById(id: string) {
    return await this.plansRepository.findOneByIdOr404(id);
  }

  async getPlanById(id: Plan) {
    return await this.plansRepository.findOne(id);
  }

  async getPlanByIdForAdmin(id: string) {
    return await this.plansRepository.findByIdOr404(id);
  }

  async updatePlan(id: string, updatePlanDTO: UpdatePlanDTO) {
    const plan = await this.plansRepository.update(id, updatePlanDTO);

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('plans.updated', {
        planQoyodProductId: plan.qoyodProductId,
        planType: plan.type,
        planPrice: plan.price,
      });
    }

    return plan;
  }

  async addPlanToNewCity(plan: Plan, city: City, adminId: string) {
    // TODO:
    await this.adminService.CityPermissionForCreation(adminId, city);
    await this.citiesService.checkCityExistence(city);
    await this.plansCitiesRepository.insertOne(plan, city);
  }

  async deletePlanFromCity(plan: Plan, city: City) {
    // TODO:
    await this.plansCitiesRepository.deleteOne(plan, city);
  }

  async archivePlanFromCity(plan: Plan, city: City) {
    const planDocument = await this.plansCitiesRepository.findOne(plan, city);
    if (!planDocument)
      throw new NotFoundResponse({
        ar: 'الباقة لاتوجد في هذه المدينة',
        en: 'Plan is not Exist in this city',
      });

    planDocument.isArchived = true;
    await planDocument.save();
  }

  async activatePlanFromCity(plan: Plan, city: City) {
    const planDocument = await this.plansCitiesRepository.findOne(plan, city);

    if (!planDocument)
      throw new NotFoundResponse({
        ar: 'الباقة لاتوجد في هذه المدينة',
        en: 'Plan is not Exist in this city',
      });

    planDocument.isArchived = false;
    await planDocument.save();
  }

  async checkPlanExistenceWithCity(plan: Plan, city: City) {
    return await this.plansCitiesRepository.findOne(plan, city);
  }

  async getPlanReport(startDate?: string, endDate?: string, planType?: string) {
    return await this.plansRepository.getPlanSubscriberReport(
      startDate,
      endDate,
      planType,
    );
  }

  async getSubscribersForPlan(planId: string) {
    return await this.plansRepository.getSubscribersForPlan(planId);
  }
}
