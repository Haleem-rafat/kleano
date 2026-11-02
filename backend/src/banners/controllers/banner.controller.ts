import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import { IsAdminGuard } from 'src/admin/guard';
import { UserAuthGuard } from 'src/auth/guards';
import { CreateBannerDto } from '../dto/createBanner.dto';
import { UpdateBannerDto } from '../dto/updateBanner.dto';
import { BannerService } from '../services/banner.service';

@Controller('banners')
export class BannerController {
  constructor(private bannerService: BannerService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  @UseInterceptors(AnyFilesInterceptor({ dest: 'uploads/' }))
  async createBanner(
    @Body() createBannerDTO: CreateBannerDto,
    @UploadedFiles() files: Express.Multer.File[],
  ) {
    const image = files.find((file) => file.fieldname === 'image');
    const imageAr = files.find((file) => file.fieldname === 'imageAr');

    await this.bannerService.createBanner(createBannerDTO, image, imageAr);

    return {
      success: true,
    };
  }

  @Get()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async listAllBanners() {
    const banners = await this.bannerService.listAllBanners();

    return {
      success: true,
      data: banners,
    };
  }

  @Get('active-banner')
  async getActiveBanners() {
    const banners = await this.bannerService.getActiveBanners();

    return {
      success: true,
      data: banners,
    };
  }

  @Get(':bannerId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getBannerById(@Param('bannerId') bannerId: string) {
    const banner = await this.bannerService.getBannerById(bannerId);

    return {
      success: true,
      data: banner,
    };
  }

  @Patch(':bannerId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  @UseInterceptors(AnyFilesInterceptor({ dest: 'uploads/' }))
  async updateBanner(
    @Param('bannerId') bannerId: string,
    @Body() body: UpdateBannerDto,
    @UploadedFiles() files: Express.Multer.File[],
  ) {
    const image = files.find((file) => file.fieldname === 'image');
    const imageAr = files.find((file) => file.fieldname === 'imageAr');

    const banner = await this.bannerService.updateBanner(
      bannerId,
      body,
      image,
      imageAr,
    );

    return {
      success: true,
      data: banner,
    };
  }

  @Post(':bannerId/activate')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async activateBanner(@Param('bannerId') bannerId: string) {
    const banner = await this.bannerService.activateBanner(bannerId);

    return {
      success: true,
      data: banner,
    };
  }

  @Post(':bannerId/deactivate')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deactivateBanner(@Param('bannerId') bannerId: string) {
    const banner = await this.bannerService.deactivateBanner(bannerId);

    return {
      success: true,
      data: banner,
    };
  }

  @Delete(':bannerId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deleteBanner(@Param('bannerId') bannerId: string) {
    await this.bannerService.deleteBanner(bannerId);

    return {
      success: true,
    };
  }
}
