import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import {
  AdminModel,
  adminModelName,
  AdminStatus,
} from './schemas/admin.schema';
import { Model } from 'mongoose';
import { CreateSubAdminDTO } from './dto/admin.createSubAdmin.dto';
import { MethodNotAllowedResponse } from '../common/errors/MethodNotAllowedResponse';
import { NotFoundResponse } from '../common/errors/NotFoundResponse';
import { cityModelName } from '../city/schemas/city.schema';

@Injectable()
export class AdminRepository {
  populatedPath = [{ path: 'city', model: cityModelName, select: 'name' }];
  constructor(
    @InjectModel(adminModelName) private readonly adminModel: Model<AdminModel>,
  ) {}

  async createSubAdmin(
    createSubAdminDTO: CreateSubAdminDTO,
    hashedPassword: string,
  ) {
    if (await this.userNameIsAlreadyExits(createSubAdminDTO.userName))
      throw new MethodNotAllowedResponse({
        ar: 'اسم المستخدم مسجل من قبل',
        en: 'User Name is already exist',
      });

    if (await this.phoneIsAlreadyExist(createSubAdminDTO.phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    if (await this.nationalIdIsAlreadyExist(createSubAdminDTO.nationalId))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم القومي مسجل من قبل',
        en: 'National Id is already exist',
      });

    await this.adminModel.create({
      userName: createSubAdminDTO.userName,
      phone: createSubAdminDTO.phone,
      city: createSubAdminDTO.city,
      password: hashedPassword,
      nationalId: createSubAdminDTO.nationalId,
      isSuperAdmin: true,
    });
  }

  async findAdminByUserNameOr404(userName: string) {
    const admin = await this.adminModel
      .findOne({
        userName: userName,
        isDeleted: false,
        status: AdminStatus.ACTIVE,
      })
      .select('+password');
    if (!admin)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا المستخدم',
        en: 'User not found',
      });

    return admin;
  }

  async findById(id: string) {
    return await this.adminModel.findOne({ _id: id, isDeleted: false });
  }

  async findByIdOr404(id: string) {
    const admin = await this.adminModel.findOne({ _id: id, isDeleted: false });
    if (!admin)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا المشرف',
        en: 'Admin Account Not Found',
      });
    return admin;
  }

  async findByIdOr404Populated(id: string) {
    const admin = await this.adminModel
      .findOne({ _id: id, isDeleted: false })
      .populate(this.populatedPath);
    if (!admin)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا المشرف',
        en: 'Admin Account Not Found',
      });
    return admin;
  }

  async findAll(status: string, skip: number, limit: number, search?: string) {
    const searchConditions: any = {
      isDeleted: false,
      ...(status ? { status } : {}),
      ...(search
        ? {
            $or: [
              {
                userName: {
                  $regex: '.*' + search.trim() + '.*',
                  $options: 'i',
                },
              },
              { phone: { $regex: '.*' + search.trim() + '.*', $options: 'i' } },
            ],
          }
        : {}),
    };

    const admins = await this.adminModel
      .find(searchConditions)
      .skip(skip)
      .limit(limit)
      .populate(this.populatedPath);

    const count = await this.adminModel.countDocuments(searchConditions);

    return { admins, count };
  }

  async phoneIsAlreadyExist(phone: string) {
    const adminWithPhoneNumber = await this.adminModel.findOne({
      phone: phone,
      isDeleted: false,
    });
    return adminWithPhoneNumber ? true : false;
  }
  async userNameIsAlreadyExits(userName: string) {
    const isExist = await this.adminModel.findOne({
      userName: userName,
      isDeleted: false,
    });
    return isExist ? true : false;
  }

  async nationalIdIsAlreadyExist(nationalId: string) {
    const isExist = await this.adminModel.findOne({
      nationalId: nationalId,
      isDeleted: false,
    });
    return isExist ? true : false;
  }

  async update(adminId: string, updatedFields: any) {
    await this.findByIdOr404(adminId);
    await this.adminModel.updateOne(
      { _id: adminId, isDeleted: false },
      {
        $set: { ...updatedFields },
      },
    );
  }

  async delete(adminId: string) {
    const admin = await this.findByIdOr404(adminId);
    admin.userName = '-d' + admin.userName;
    admin.phone = '-d' + admin.phone;
    admin.nationalId = '-d' + admin.nationalId;
    admin.isDeleted = true;
    admin.city = [];

    await admin.save();
  }

  async findAllWithQuery(query: any) {
    return await this.adminModel.find(query);
  }

  async injectSuperAdmin(hashedPassword: string) {
    const checkIfSuperIsExist = await this.adminModel.findOne({
      isSuperAdmin: true,
    });
    if (checkIfSuperIsExist) return;

    await this.adminModel.create({
      userName: 'super admin',
      isSuperAdmin: true,
      password: hashedPassword,
    });
  }
}
