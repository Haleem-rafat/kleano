import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as fs from 'fs';
import { Model } from 'mongoose';
import { NotFoundResponse } from '../common/errors/NotFoundResponse';
import { FirebaseService } from '../common/services/firebase/firebase.service';
import {
  servicesIconModelName,
  ServicesIconsModel,
} from './schemas/services-icons.schema';

@Injectable()
export class ServicesIconsService {
  constructor(
    @InjectModel(servicesIconModelName)
    private readonly servicesIconsModel: Model<ServicesIconsModel>,
    private firebaseService: FirebaseService,
  ) {}

  async createNewIcon(file: Express.Multer.File) {
    const { fileLink, filePath } = await this.firebaseService.uploadIcon(
      file.filename,
    );

    await this.servicesIconsModel.create({
      iconLink: fileLink,
      iconPath: filePath,
    });
  }

  async getAll() {
    return await this.servicesIconsModel.find();
  }

  async getCount() {
    return await this.servicesIconsModel.count();
  }

  async getByIdOr404(id: string) {
    const icon = await this.servicesIconsModel.findById(id);
    if (!icon)
      throw new NotFoundResponse({
        ar: 'لاتوجد هذه الصورة',
        en: 'Icon not found',
      });

    return icon;
  }

  async isExist(id: string) {
    const icon = await this.servicesIconsModel.findById(id);

    return icon ? true : false;
  }

  async deleteIcon(id: string) {
    const icon = await this.servicesIconsModel.findById(id);
    if (!icon) {
      throw new Error('Icon not found');
    }

    // Delete icon from Firebase
    await this.firebaseService.deleteFileFromStorage(icon.iconPath);

    // Remove from MongoDB
    return await this.servicesIconsModel.findByIdAndDelete(id);
  }
}
