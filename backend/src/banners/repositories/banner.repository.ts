import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { MethodNotAllowedResponse } from 'src/common/errors';
import { FirebaseService } from 'src/common/services/firebase/firebase.service';
import { CreateBannerDto } from '../dto/createBanner.dto';
import { UpdateBannerDto } from '../dto/updateBanner.dto';
import { BannerModel, bannerModelName } from '../schemas/banner.schema';

@Injectable()
export class BannerRepository {
  constructor(
    @InjectModel(bannerModelName)
    private readonly bannerModel: Model<BannerModel>,
    private firebaseService: FirebaseService,
  ) {}

  async createBanner(
    createBannerDto: CreateBannerDto,
    image: Express.Multer.File,
    imageAr?: Express.Multer.File,
  ) {
    const { title, description, externalUrl, resource, resourceId } =
      createBannerDto;
    if (!image)
      throw new MethodNotAllowedResponse({
        ar: 'قم برفع صورة للافتة',
        en: 'Upload banner image',
      });

    const { fileLink, filePath } = await this.firebaseService.uploadImage(
      image,
    );

    let imageLinkAr: string | undefined;
    let imagePathAr: string | undefined;

    if (imageAr) {
      const { fileLink: arFileLink, filePath: arFilePath } =
        await this.firebaseService.uploadImage(imageAr);
      imageLinkAr = arFileLink;
      imagePathAr = arFilePath;
    }

    const banner = await this.bannerModel.create({
      title,
      description,
      externalUrl,
      resource,
      resourceId,
      imageLink: fileLink,
      imagePath: filePath,
      imageLinkAr,
      imagePathAr,
    });

    return banner;
  }

  async listAllBanners() {
    const banners = await this.bannerModel.find(
      {},
      {
        title: 1,
        description: 1,
        imageLink: 1,
        imageLinkAr: 1,
        isActive: 1,
        externalUrl: 1,
        resource: 1,
        resourceId: 1,
      },
    );

    return banners;
  }

  async getActiveBanners() {
    const activeBanners = await this.bannerModel.find(
      { isActive: true },
      {
        title: 1,
        description: 1,
        imageLink: 1,
        imageLinkAr: 1,
        isActive: 1,
        externalUrl: 1,
        resource: 1,
        resourceId: 1,
      },
    );

    // if (activeBanners.length < 1) {
    //   throw new NotFoundException({
    //     ar: 'لا يوجد لافتة نشطة في الوقت الحالي',
    //     en: 'There is no active banner right now',
    //   });
    // }

    return activeBanners;
  }

  async getBannerById(bannerId: string) {
    const banner = await this.bannerModel.findById(bannerId, {
      title: 1,
      description: 1,
      imageLink: 1,
      imageLinkAr: 1,
      isActive: 1,
      externalUrl: 1,
      resource: 1,
      resourceId: 1,
    });

    if (!banner) {
      throw new NotFoundException({
        ar: 'اللافتة غير موجوجة',
        en: 'Banner not found',
      });
    }

    return banner;
  }

  async updateBanner(
    bannerId: string,
    updateBannerDto: UpdateBannerDto,
    image?: Express.Multer.File,
    imageAr?: Express.Multer.File,
  ) {
    const banner = await this.bannerModel.findById(bannerId);

    if (!banner) {
      throw new NotFoundException({
        ar: 'اللافتة غير موجوجة',
        en: 'Banner not found',
      });
    }

    banner.set(updateBannerDto);
    await banner.save();

    if (image) {
      if (banner.imagePath) {
        await this.firebaseService.deleteFileFromStorage(banner.imagePath);
      }

      const { fileLink, filePath } = await this.firebaseService.uploadImage(
        image,
      );

      banner.set({ imageLink: fileLink, imagePath: filePath });
      await banner.save();
    }

    if (imageAr) {
      if (banner.imagePathAr) {
        await this.firebaseService.deleteFileFromStorage(banner.imagePathAr);
      }

      const { fileLink: arFileLink, filePath: arFilePath } =
        await this.firebaseService.uploadImage(imageAr);

      banner.set({ imageLinkAr: arFileLink, imagePathAr: arFilePath });
      await banner.save();
    }

    return banner;
  }

  async activateBanner(bannerId: string) {
    const banner = await this.bannerModel.findById(bannerId);
    // await this.bannerModel.updateMany(
    //   {
    //     _id: { $ne: new Types.ObjectId(bannerId) },
    //   },
    //   { isActive: false },
    // );

    if (!banner) {
      throw new NotFoundException({
        ar: 'اللافتة غير موجوجة',
        en: 'Banner not found',
      });
    }

    banner.set({ isActive: true });
    await banner.save();

    return banner;
  }

  async deactivateBanner(bannerId: string) {
    const banner = await this.bannerModel.findById(bannerId);

    if (!banner) {
      throw new NotFoundException({
        ar: 'اللافتة غير موجوجة',
        en: 'Banner not found',
      });
    }

    banner.set({ isActive: false });
    await banner.save();

    return banner;
  }

  async deleteBanner(bannerId: string) {
    const banner = await this.bannerModel.findById(bannerId);

    if (!banner) {
      throw new NotFoundException({
        ar: 'اللافتة غير موجوجة',
        en: 'Banner not found',
      });
    }

    await this.bannerModel.deleteOne({ _id: new Types.ObjectId(bannerId) });
  }
}
