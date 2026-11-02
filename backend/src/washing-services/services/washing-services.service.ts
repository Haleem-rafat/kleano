import {
  BadRequestException,
  forwardRef,
  Inject,
  Injectable,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import mongoose from 'mongoose';
import { NearestAreaCalculator } from 'src/area/nearestAreaCalculator.service';
import { BikersService } from 'src/bikers/services/bikers.service';
import { SubscriptionsService } from 'src/subscriptions/services/subscriptions.service';
import { AdminService } from '../../admin/admin.service';
import { Roles } from '../../admin/schemas/admin.schema';
import { CitiesService } from '../../city/city.service';
import { NearestCityCalculator } from '../../city/nearestCityCalculator.service';
import { City } from '../../city/schemas/city.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { ServicesIconsService } from '../../services-icons/services-icons.service';
import { UserService } from '../../user/user.service';
import { CreateWashingServiceDTO, UpdateWashingServiceDTO } from '../dtos';
import { QueryParamsDTO } from '../dtos/queryParams.dto';
import { ServicesCitiesRepository } from '../repositories/services-cities.repository';
import { WashingServicesRepository } from '../repositories/washing-services.repository';
import { WashingService } from '../schemas/washing-services.schema';

@Injectable()
export class WashingServicesService {
  constructor(
    private washingServicesRepository: WashingServicesRepository,
    private servicesIconsService: ServicesIconsService,
    private citiesService: CitiesService,
    private nearestCityCalculator: NearestCityCalculator,
    private nearestAreaCalculator: NearestAreaCalculator,
    private userService: UserService,
    private servicesCitiesRepository: ServicesCitiesRepository,
    private adminService: AdminService,
    private bikersService: BikersService,
    @Inject(forwardRef(() => SubscriptionsService))
    private subscriptionsService: SubscriptionsService,
    private eventEmitter: EventEmitter2,
  ) {}

  async createWashingService(
    createWashingServiceDTO: CreateWashingServiceDTO,
    adminId: string,
    role: string,
  ) {
    if (
      !(await this.servicesIconsService.isExist(
        String(createWashingServiceDTO.icon),
      ))
    )
      throw new NotFoundResponse({
        ar: 'لاتوجد هذه الايقونة',
        en: 'Icon Not Found',
      });

    if (!createWashingServiceDTO.selectAll && !createWashingServiceDTO.cities)
      throw new MethodNotAllowedResponse({
        ar: 'ادخل المدن',
        en: 'Select cities',
      });

    let washingService;

    switch (role) {
      case Roles.SuperAdmin:
        washingService = await this.createWashingServiceSuperAdmin(
          createWashingServiceDTO,
        );
        break;
      case Roles.SubAdmin:
        washingService = await this.createWashingServiceSubAdmin(
          createWashingServiceDTO,
          adminId,
        );
        break;
      default:
        throw new MethodNotAllowedResponse({
          ar: 'غير مصرح لك',
          en: 'Not Auth',
        });
    }

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('washing-services.created', {
        washingServiceId: washingService.id,
        washingServiceName: washingService.name,
        washingServicePrice: washingService.price,
      });
    }
  }

  async createWashingServiceSuperAdmin(
    createWashingServiceDTO: CreateWashingServiceDTO,
  ) {
    if (!createWashingServiceDTO.selectAll) {
      // check cities Active status
      for (const city of createWashingServiceDTO.cities) {
        await this.citiesService.checkCityExistence(city);
      }
    }
    const createdWashingService = await this.washingServicesRepository.create(
      createWashingServiceDTO,
    );
    await this.servicesCitiesRepository.insertMany(
      createdWashingService,
      createWashingServiceDTO.selectAll
        ? await this.citiesService.getAdminCities(Roles.SuperAdmin)
        : createWashingServiceDTO.cities,
    );
  }

  async createWashingServiceSubAdmin(
    createWashingServiceDTO: CreateWashingServiceDTO,
    adminId: string,
  ) {
    if (!createWashingServiceDTO.selectAll) {
      // Check Cities Permissions
      await this.adminService.CitiesPermissionCreation(
        adminId,
        createWashingServiceDTO.cities,
      );
      // check cities Active status
      for (const city of createWashingServiceDTO.cities) {
        await this.citiesService.checkCityExistence(city);
      }
    }

    const createdWashingService = await this.washingServicesRepository.create(
      createWashingServiceDTO,
    );
    await this.servicesCitiesRepository.insertMany(
      createdWashingService,
      createWashingServiceDTO.selectAll
        ? await this.citiesService.getAdminCities(Roles.SubAdmin, adminId)
        : createWashingServiceDTO.cities,
    );
  }

  async getAllWashingServicesForAdmin(role: string, adminId: string) {
    switch (role) {
      case Roles.SuperAdmin:
        const washingServicesForSuperAdmin =
          await this.washingServicesRepository.findAllForAdmins(role);
        washingServicesForSuperAdmin.forEach((washingService) => {
          washingService.cities = undefined;
        });
        return washingServicesForSuperAdmin;
      case Roles.SubAdmin:
        const admin = await this.adminService.getById(adminId);
        const washingServices =
          await this.washingServicesRepository.findAllForAdmins(
            role,
            admin.city,
          );

        return this.washingServicesFormater(washingServices);
      default:
        return [];
    }
  }

  /** TODO:- For User (Active Service & his city) and when view orders return any status
   *             Biker Return Only Active Service
   *             Admin Return All
   *
   *
   *
   */

  async getAllWashingServicesForUser(
    userId: string,
    queryParamsDTO: QueryParamsDTO,
    type: string,
  ) {
    if (queryParamsDTO.country.toLowerCase() !== 'saudi arabia') {
      // console.log(queryParamsDTO.country);
      throw new BadRequestException({
        ar: 'خدماتنا غير متوفرة في بلدك',
        en: 'Our services are not available in your country.',
      });
    }

    const user = await this.userService.getUserById(userId);

    const [userAreaLocation] = await Promise.all([
      this.nearestAreaCalculator.findAreaByPoint(
        Number(queryParamsDTO.latitude),
        Number(queryParamsDTO.longitude),
      ),
    ]);

    if (
      !userAreaLocation ||
      !(await this.bikersService.getBikersByArea(String(userAreaLocation._id)))
        .length
    ) {
      return {
        washingServices: [],
        message:
          user.language === 'en'
            ? 'Our services are not available in your location.'
            : 'خدماتنا غير متوفرة في موقعك',
      };
    }

    const city = await this.nearestCityCalculator.findNearestCity(
      Number(queryParamsDTO.latitude),
      Number(queryParamsDTO.longitude),
    );

    const washingServices = await this.washingServicesRepository.findAll(
      city['city']._id,
      type,
    );

    const formatedWashingServices =
      this.washingServicesFormater(washingServices);

    const userSubscriptionNotPop =
      await this.subscriptionsService.isUserHasSubscription(user);

    if (userSubscriptionNotPop) {
      const userSubscription =
        await this.subscriptionsService.getSubscriptionByIdPopulated(
          (userSubscriptionNotPop as any)._id,
        );

      const userWashingServiceIds = new Set(
        (userSubscription as any)?.plan.washingServices?.map((service) =>
          service.toString(),
        ) || [],
      );

      const availableWashingServices: [any] = formatedWashingServices.filter(
        (service) => !userWashingServiceIds.has(service._id.toString()),
      );

      availableWashingServices.push({
        _id: '682f42e71d293e437947159c',
        name: '1',
        description: [],
        duration: 30,
        durationUnit: 'min',
        price: 3,
        type: 'main',
        icon: {
          _id: '673333cd9b41be9fae2040be',
          iconPath: 'uploadedIcon-3ef7d0ec-b31e-4603-8741-bfa9f49e0297',
          iconLink:
            'https://firebasestorage.googleapis.com/v0/b/the-washer-dev.appspot.com/o/uploadedIcon-3ef7d0ec-b31e-4603-8741-bfa9f49e0297?alt=media&token=3ef7d0ec-b31e-4603-8741-bfa9f49e0297',
        },
        createdAt: '2025-05-22T15:29:43.894Z',
        updatedAt: '2025-05-22T15:29:43.894Z',
        __v: 0,
      });

      return {
        washingServices: availableWashingServices,
        message: !availableWashingServices.length
          ? 'Our Service Not Exist Waiting for us soon..'
          : '',
      };
    }
    return {
      washingServices: formatedWashingServices,
      message: !formatedWashingServices.length
        ? 'Our Service Not Exist Waiting for us soon..'
        : '',
    };
  }

  async getAllWashingServicesForGuest(
    queryParamsDTO: QueryParamsDTO,
    type: string,
  ) {
    if (queryParamsDTO.country.toLowerCase() !== 'saudi arabia') {
      throw new BadRequestException({
        ar: 'خدماتنا غير متوفرة في بلدك',
        en: 'Our services are not available in your country.',
      });
    }

    const [userAreaLocation] = await Promise.all([
      this.nearestAreaCalculator.findAreaByPoint(
        Number(queryParamsDTO.latitude),
        Number(queryParamsDTO.longitude),
      ),
    ]);

    const city = await this.nearestCityCalculator.findNearestCity(
      Number(queryParamsDTO.latitude),
      Number(queryParamsDTO.longitude),
    );

    if (
      !userAreaLocation ||
      !(await this.bikersService.getBikersByArea(String(userAreaLocation._id)))
        .length
    ) {
      return {
        washingServices: [],
        message: 'Our services are not available in your location.',
      };
    }

    const washingServices = await this.washingServicesRepository.findAll(
      city['city']._id,
      type,
    );

    const formatedWashingServices =
      this.washingServicesFormater(washingServices);

    return {
      washingServices: formatedWashingServices,
      message: !formatedWashingServices.length
        ? 'Our Service Not Exist Waiting for us soon..'
        : '',
    };
  }

  washingServicesFormater(servicesList: any) {
    const filtered = servicesList.filter(
      (washingService: any) => washingService.cities.length >= 1,
    );

    filtered.forEach((washingService) => {
      washingService.cities = undefined;
    });
    return filtered;
  }

  async getWashingServiceByIdForAdmin(id: string) {
    return await this.washingServicesRepository.findOneByIdOr404(id);
  }

  async getWashingServiceById(id: string) {
    return await this.washingServicesRepository.findOneOr404(id);
  }

  async update(id: string, updateWashingServiceDTO: UpdateWashingServiceDTO) {
    if (
      await this.servicesIconsService.isExist(
        String(updateWashingServiceDTO.icon),
      )
    ) {
      const washingService = await this.washingServicesRepository.update(
        id,
        updateWashingServiceDTO,
      );

      if (process.env.NODE_ENV === 'prod') {
        this.eventEmitter.emit('washing-services.updated', {
          washingServiceQoyodProductId: washingService.qoyodProductId,
          washingServiceName: washingService.name,
          washingServicePrice: washingService.price,
        });
      }

      return washingService;
    }
  }

  async addWashingServiceToNewCity(
    washingService: WashingService,
    city: City,
    adminId: string,
  ) {
    // TODO: Check city permission for admin and active status for city
    await this.adminService.CityPermissionForCreation(adminId, city);
    await this.citiesService.checkCityExistence(city);
    await this.servicesCitiesRepository.insertOne(washingService, city);
  }

  async deleteWashingServiceFromCity(
    washingService: WashingService,
    city: City,
  ) {
    // TODO:
    await this.servicesCitiesRepository.deleteOne(washingService, city);
  }

  async archiveWashingServiceFromCity(
    washingService: WashingService,
    city: City,
  ) {
    const washingServiceCity = await this.servicesCitiesRepository.findOne(
      washingService,
      city,
    );
    if (!washingServiceCity)
      throw new NotFoundResponse({
        ar: 'الخدمة لاتوجد في هذه المدينة',
        en: 'Washing Service is not Exist in this city',
      });

    washingServiceCity.isArchived = true;
    await washingServiceCity.save();
  }

  async activateWashingServiceFromCity(
    washingService: WashingService,
    city: City,
  ) {
    const washingServiceCity = await this.servicesCitiesRepository.findOne(
      washingService,
      city,
    );
    if (!washingServiceCity)
      throw new NotFoundResponse({
        ar: 'الخدمة لاتوجد في هذه المدينة',
        en: 'Washing Service is not Exist in this city',
      });

    washingServiceCity.isArchived = false;
    await washingServiceCity.save();
  }

  async getTotalDurationForWashingServices(washingServices: any[]) {
    const parsedWashingServices = [];
    for (const item of washingServices) {
      parsedWashingServices.push(new mongoose.Types.ObjectId(item));
    }
    const orderWashingServices =
      await this.washingServicesRepository.findOrderWashingServices(
        parsedWashingServices,
      );

    let totalDuration = 0;
    orderWashingServices.forEach((washingService) => {
      totalDuration += washingService.duration;
    });

    return totalDuration;
  }

  async getServicesReport() {
    return this.washingServicesRepository.getServicesReport();
  }

  async suspendAllFromCities(servicesId: string) {
    const servicesDocuments =
      await this.servicesCitiesRepository.findByServicesId(servicesId);

    if (servicesDocuments.length === 0) {
      throw new NotFoundResponse({
        ar: 'لا توجد',
        en: 'Not Found',
      });
    }

    const suspendedAt = new Date();
    await this.servicesCitiesRepository.suspendServicesInCities(
      servicesId,
      suspendedAt,
    );
  }
}
