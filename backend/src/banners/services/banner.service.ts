import { Injectable } from '@nestjs/common';
import { CreateBannerDto } from '../dto/createBanner.dto';
import { UpdateBannerDto } from '../dto/updateBanner.dto';
import { BannerRepository } from '../repositories/banner.repository';

@Injectable()
export class BannerService {
  constructor(private bannerRepository: BannerRepository) {}

  async createBanner(
    createBannerDto: CreateBannerDto,
    image: Express.Multer.File,
    imageAr?: Express.Multer.File,
  ) {
    const banner = await this.bannerRepository.createBanner(
      createBannerDto,
      image,
      imageAr,
    );

    return banner;
  }

  async listAllBanners() {
    const banners = await this.bannerRepository.listAllBanners();

    return banners;
  }

  async getActiveBanners() {
    const activeBanners = await this.bannerRepository.getActiveBanners();

    return activeBanners;
  }

  async getBannerById(bannerId: string) {
    const banner = await this.bannerRepository.getBannerById(bannerId);

    return banner;
  }

  async updateBanner(
    bannerId: string,
    updateBannerDto: UpdateBannerDto,
    image?: Express.Multer.File,
    imageAr?: Express.Multer.File,
  ) {
    const updatedBanner = await this.bannerRepository.updateBanner(
      bannerId,
      updateBannerDto,
      image,
      imageAr,
    );

    return updatedBanner;
  }

  async activateBanner(bannerId: string) {
    const banner = await this.bannerRepository.activateBanner(bannerId);

    return banner;
  }

  async deactivateBanner(bannerId: string) {
    const banner = await this.bannerRepository.deactivateBanner(bannerId);

    return banner;
  }

  async deleteBanner(bannerId: string) {
    await this.bannerRepository.deleteBanner(bannerId);
  }
}
