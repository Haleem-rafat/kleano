import { InjectModel } from '@nestjs/mongoose';
import { Biker, BikerModel, bikerModelName } from '../schemas/bikers.schema';
import { Model } from 'mongoose';
import { UserService } from '../../user/user.service';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { UpdateBikerDTO } from '../dto/updateBiker.dto';

export class BikerCrudValidator {
  constructor(
    @InjectModel(bikerModelName) private readonly bikerModel: Model<BikerModel>,
    private userService: UserService,
  ) {}

  async createValidator(phone: string, nationalId: string, userName: string) {
    if (await this.userService.isPhoneExist(phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    if (await this.isPhoneNumberExist(phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    if (await this.isNationalIdExist(nationalId))
      throw new MethodNotAllowedResponse({
        ar: 'رقم البطاقة القومي مسجل من قبل',
        en: 'National Id is already exist',
      });

    if (await this.isUserNameExist(userName))
      throw new MethodNotAllowedResponse({
        ar: 'اسم المستخدم مسجل من قبل',
        en: 'User Name is already exist',
      });
  }

  async isPhoneNumberExist(phone: string) {
    return await this.bikerModel.findOne({ phone: phone, isDeleted: false });
  }

  async isNationalIdExist(nationalId: string) {
    return await this.bikerModel.findOne({
      nationalId: nationalId,
      isDeleted: false,
    });
  }

  async isUserNameExist(userName: string) {
    return await this.bikerModel.findOne({
      userName: userName,
      isDeleted: false,
    });
  }

  async updateBikerValidator(id: string, updateBikerDTO: UpdateBikerDTO) {
    if (await this.userService.isPhoneExist(updateBikerDTO.phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    if (await this.isPhoneNumberExistForAnotherBiker(id, updateBikerDTO.phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    if (
      await this.isNationalIdExistForAnotherBiker(id, updateBikerDTO.nationalId)
    )
      throw new MethodNotAllowedResponse({
        ar: 'رقم البطاقة القومي مسجل من قبل',
        en: 'National Id is already exist',
      });

    if (await this.isUserNameExistForAnotherBiker(id, updateBikerDTO.userName))
      throw new MethodNotAllowedResponse({
        ar: 'رقم البطاقة القومي مسجل من قبل',
        en: 'National Id is already exist',
      });
  }

  async isPhoneNumberExistForAnotherBiker(id: string, phone: string) {
    return await this.bikerModel.findOne({
      _id: { $ne: id },
      phone: phone,
      isDeleted: false,
    });
  }

  async isNationalIdExistForAnotherBiker(id: string, nationalId: string) {
    return await this.bikerModel.findOne({
      _id: { $ne: id },
      nationalId: nationalId,
      isDeleted: false,
    });
  }

  async isUserNameExistForAnotherBiker(id: string, userName: string) {
    return await this.bikerModel.findOne({
      _id: { $ne: id },
      userName: userName,
      isDeleted: false,
    });
  }
}
