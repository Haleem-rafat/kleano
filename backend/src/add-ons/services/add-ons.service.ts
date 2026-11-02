import { BadRequestException, Injectable } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { Roles } from 'src/admin/schemas/admin.schema';
import { NearestAreaCalculator } from 'src/area/nearestAreaCalculator.service';
import { AdminService } from '../../admin/admin.service';
import { CitiesService } from '../../city/city.service';
import { NearestCityCalculator } from '../../city/nearestCityCalculator.service';
import { City } from '../../city/schemas/city.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { ServicesIconsService } from '../../services-icons/services-icons.service';
import { UserService } from '../../user/user.service';
import { QueryParamsDTO } from '../dtos/add-ons-queryParams.dto';
import { CreateAddOnsDTO } from '../dtos/createAddOns.dto';
import { UpdateAddOnsDTO } from '../dtos/updateAddOns.dto';
import { AddOnsCitiesRepository } from '../repositories/add-ons-cities.repository';
import { AddOnsRepository } from '../repositories/add-ons.repository';
import { AddOns } from '../schemas/add-ons.schema';

@Injectable()
export class AddOnsService {
  constructor(
    private addOnsRepository: AddOnsRepository,
    private addOnsCitiesRepository: AddOnsCitiesRepository,
    private servicesIconsService: ServicesIconsService,
    private citiesService: CitiesService,
    private adminService: AdminService,
    private userService: UserService,
    private nearestCityCalculator: NearestCityCalculator,
    private nearestAreaCalculator: NearestAreaCalculator,
    private eventEmitter: EventEmitter2,
  ) {}

  async createAddOns(
    createAddOnsDTO: CreateAddOnsDTO,
    adminId: string,
    role: string,
  ) {
    if (
      !(await this.servicesIconsService.isExist(String(createAddOnsDTO.icon)))
    )
      throw new NotFoundResponse({
        ar: 'لاتوجد هذه الايقونة',
        en: 'Icon Not Found',
      });

    if (!createAddOnsDTO.selectAll && !createAddOnsDTO.cities)
      throw new MethodNotAllowedResponse({
        ar: 'ادخل المدن',
        en: 'Select cities',
      });

    let addOns;

    switch (role) {
      case Roles.SuperAdmin:
        addOns = await this.createAddOnsSuperAdmin(createAddOnsDTO);
        break;
      case Roles.SubAdmin:
        addOns = await this.createAddOnsSubAdmin(createAddOnsDTO, adminId);
        break;
      default:
        throw new MethodNotAllowedResponse({
          ar: 'غير مصرح لك',
          en: 'Not Auth',
        });
    }

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('add-ons.created', {
        addOnsId: addOns.id,
        addOnsName: addOns.name,
        addOnsPrice: addOns.price,
      });
    }
  }

  async createAddOnsSuperAdmin(createAddOnsDTO: CreateAddOnsDTO) {
    if (!createAddOnsDTO.selectAll) {
      // check cities Active status
      for (const city of createAddOnsDTO.cities) {
        await this.citiesService.checkCityExistence(city);
      }
    }
    const createdAddOns = await this.addOnsRepository.create(createAddOnsDTO);

    await this.addOnsCitiesRepository.insertMany(
      createdAddOns,
      createAddOnsDTO.selectAll
        ? await this.citiesService.getAdminCities(Roles.SuperAdmin)
        : createAddOnsDTO.cities,
    );

    return createdAddOns;
  }

  async createAddOnsSubAdmin(
    createAddOnsDTO: CreateAddOnsDTO,
    adminId: string,
  ) {
    if (!createAddOnsDTO.selectAll) {
      // Check Cities Permissions
      await this.adminService.CitiesPermissionCreation(
        adminId,
        createAddOnsDTO.cities,
      );
      // check cities Active status
      for (const city of createAddOnsDTO.cities) {
        await this.citiesService.checkCityExistence(city);
      }
    }

    const createdAddOns = await this.addOnsRepository.create(createAddOnsDTO);

    await this.addOnsCitiesRepository.insertMany(
      createdAddOns,
      createAddOnsDTO.selectAll
        ? await this.citiesService.getAdminCities(Roles.SubAdmin, adminId)
        : createAddOnsDTO.cities,
    );

    return createdAddOns;
  }

  async getAllAddOnsForUser(userId: string, queryParamsDTO: QueryParamsDTO) {
    if (queryParamsDTO.country.toLowerCase() !== 'saudi arabia') {
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

    const city = await this.nearestCityCalculator.findNearestCity(
      Number(queryParamsDTO.latitude),
      Number(queryParamsDTO.longitude),
    );

    if (!userAreaLocation) {
      return {
        addOnses: [],
        message:
          user.language === 'en'
            ? 'Our services are not available in your location.'
            : 'خدماتنا غير متوفرة في موقعك',
      };
    }

    const addOnses = await this.addOnsRepository.findAll(city['city']._id);

    const formatedAddOnses = this.addOnsFormaterForUser(addOnses);

    return {
      addOnses: formatedAddOnses,
      message: !formatedAddOnses.length
        ? 'Our Service Not Exist Waiting for us soon..'
        : '',
    };
  }

  async getAllAddOnsForGuest(queryParamsDTO: QueryParamsDTO) {
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

    if (!userAreaLocation) {
      return {
        addOnses: [],
        message: 'Our services are not available in your location.',
      };
    }

    const addOnses = await this.addOnsRepository.findAll(city['city']._id);

    const formatedAddOnses = this.addOnsFormaterForUser(addOnses);

    return {
      addOnses: formatedAddOnses,
      message: !formatedAddOnses.length
        ? 'Our Service Not Exist Waiting for us soon..'
        : '',
    };
  }

  addOnsFormaterForUser(addOnsList: any) {
    const filtered = addOnsList.filter(
      (addOns: any) => addOns.cities.length >= 1,
    );

    filtered.forEach((addOns) => {
      addOns.cities = undefined;
    });
    return filtered;
  }

  async getAllForAdmin(role: string, adminId: string) {
    switch (role) {
      case Roles.SuperAdmin:
        const addOnsesForSuperAdmin =
          await this.addOnsRepository.findAllForAdmins(role);
        addOnsesForSuperAdmin.forEach((addOns) => {
          addOns.cities = undefined;
        });
        return addOnsesForSuperAdmin;
      case Roles.SubAdmin:
        const admin = await this.adminService.getById(adminId);
        const addOnsesForSubAdmin =
          await this.addOnsRepository.findAllForAdmins(role, admin.city);

        return this.addOnsFormaterForUser(addOnsesForSubAdmin);
      default:
        return [];
    }
  }

  async getByIdOr404(id: string) {
    return await this.addOnsRepository.findByIdOr404(id);
  }

  async updateAddOns(id: string, updateAddOnsDTO: UpdateAddOnsDTO) {
    const updatedFields = {
      name: updateAddOnsDTO.name,
      price: updateAddOnsDTO.price,
      icon: updateAddOnsDTO.icon,
    };

    await this.addOnsRepository.update(id, updatedFields);
    const addOn = await this.addOnsRepository.findByIdOr404(id);

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('add-ons.updated', {
        addOnsQoyodProductId: addOn.qoyodProductId,
        addOnsName: addOn.name,
        addOnsPrice: addOn.price,
      });
    }

    return addOn;
  }

  async addToNewCity(addOns: AddOns, city: City) {
    await this.addOnsCitiesRepository.insertOne(addOns, city);
  }

  async deleteOneFromCity(addOns: AddOns, city: City) {
    return await this.addOnsCitiesRepository.deleteOne(addOns, city);
  }

  async archiveOneFromCity(addOns: AddOns, city: City) {
    const addOnsDocument = await this.addOnsCitiesRepository.findOne(
      addOns,
      city,
    );
    if (!addOnsDocument)
      throw new NotFoundResponse({
        ar: 'لا توجد',
        en: 'Not Found',
      });

    addOnsDocument.isArchived = true;
    await addOnsDocument.save();
  }

  async activateOneFromCity(addOns: AddOns, city: City) {
    const addOnsDocument = await this.addOnsCitiesRepository.findOne(
      addOns,
      city,
    );
    if (!addOnsDocument)
      throw new NotFoundResponse({
        ar: 'لا توجد',
        en: 'Not Found',
      });

    addOnsDocument.isArchived = false;
    await addOnsDocument.save();
  }

  async getAddOnsReport() {
    return this.addOnsRepository.getAddOnsReport();
  }

  async suspendAllFromCities(addOnsId: string): Promise<void> {
    const addOnsDocuments = await this.addOnsCitiesRepository.findByAddOnsId(
      addOnsId,
    );

    if (addOnsDocuments.length === 0) {
      throw new NotFoundResponse({
        ar: 'لا توجد',
        en: 'Not Found',
      });
    }

    const suspendedAt = new Date();
    await this.addOnsCitiesRepository.suspendAddOnsInCities(
      addOnsId,
      suspendedAt,
    );
  }
}
