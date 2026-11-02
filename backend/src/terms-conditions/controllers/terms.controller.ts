import { Body, Controller, Get, Patch, Post, UseGuards } from '@nestjs/common';
import { SuperAdminGuard, UserAuthGuard } from 'src/auth/guards';
import { CreateTermsAndConditionsDto } from '../dto/create-terms-conditions-dto';
import { TermsService } from '../terms.service';

@Controller('terms')
export class TermsController {
  constructor(private termsService: TermsService) {}

  @Get()
  // @UseGuards(UserAuthGuard, SuperAdminGuard)
  async getTermsAndConditions() {
    const data = await this.termsService.getTermsAndConditions();

    return {
      success: true,
      data,
    };
  }

  @Post()
  @UseGuards(UserAuthGuard, SuperAdminGuard)
  async createTermsAndConditions(@Body() body: CreateTermsAndConditionsDto) {
    await this.termsService.createTermsAndConditions(body);

    return {
      success: true,
    };
  }

  @Patch()
  @UseGuards(UserAuthGuard, SuperAdminGuard)
  async updateTermsAndConditions(@Body() body: CreateTermsAndConditionsDto) {
    await this.termsService.updateTermsAndConditions(body);

    return {
      success: true,
    };
  }
}
