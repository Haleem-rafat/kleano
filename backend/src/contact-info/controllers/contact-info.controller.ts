import {
  Body,
  Controller,
  Delete,
  Get,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { IsAdminGuard } from 'src/admin/guard';
import { UserAuthGuard } from 'src/auth/guards';
import { CreateContactInfoDto } from '../dto/create-contact-info.dto';
import { UpdateContactInfoDto } from '../dto/update-contact-info.dto';
import { ContactInfoService } from '../services/contact-info.service';

@Controller('contact-info')
export class ContactInfoController {
  constructor(private contactInfoService: ContactInfoService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createNewContactInfo(@Body() body: CreateContactInfoDto) {
    await this.contactInfoService.createNewContactInfo(body);

    return {
      success: true,
    };
  }

  @Get()
  @UseGuards()
  async listAllContactInfo() {
    const result = await this.contactInfoService.listAllContactInfo();

    return {
      success: true,
      data: result,
    };
  }

  // @Get(':contactId')
  // @UseGuards()
  // async getBannerById(@Param('contactId') contactId: string) {
  //   const result = await this.contactInfoService.getContactById(contactId);

  //   return {
  //     success: true,
  //     data: result,
  //   };
  // }

  @Patch()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updateContactInfo(@Body() body: UpdateContactInfoDto) {
    const result = await this.contactInfoService.updateContactInfo(body);

    return {
      success: true,
      data: result,
    };
  }

  @Delete()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deleteContactInfo() {
    await this.contactInfoService.deleteContactInfo();

    return {
      success: true,
    };
  }
}
