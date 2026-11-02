import {
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { IsAdminGuard } from '../admin/guard/isAdmin.guard';
import { UserAuthGuard } from '../auth/guards/userAuthentication.guard';
import { ServicesIconsService } from './services-icons.service';

@Controller('services-icons')
export class ServicesIconsController {
  constructor(private servicesIconsService: ServicesIconsService) {}

  @Post('')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  @UseInterceptors(FileInterceptor('file', { dest: 'icons/' }))
  async createNewIcon(@UploadedFile() file: Express.Multer.File) {
    return {
      success: true,
      data: await this.servicesIconsService.createNewIcon(file),
    };
  }

  @Get('')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getIconsController() {
    return {
      success: true,
      data: await this.servicesIconsService.getAll(),
    };
  }

  @Delete(':id')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deleteIcon(@Param('id') id: string) {
    return await this.servicesIconsService.deleteIcon(id);
  }
}
