import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { Account } from 'src/common/decorators/user.decorator';
import { IsAdminGuard } from '../../admin/guard/isAdmin.guard';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { CreateAggregatorPromoCodeDTO } from '../dtos/createAggregatorPromoCode.dto';
import { CreateAllUsersPromoCodeDTO } from '../dtos/createAllUsersPromoCode.dto';
import { CreateB2bPromoCodeDTO } from '../dtos/createB2bPromoCode.dto';
import { CreateNewComersPromoCodeDTO } from '../dtos/createNewComersPromoCode.dto';
import { CreateOfflinePromoCodeDTO } from '../dtos/createOfflinePromoCode.dto';
import { CreateSegmentPromoCodeDto } from '../dtos/createSegmentPromoCode.dto';
import { GetPromoCodesDTO } from '../dtos/getAll.dto';
import { PromoCodesService } from '../services/promo-code.service';

@Controller('promo-codes')
export class PromoCodesController {
  constructor(private promoCodesService: PromoCodesService) {}

  @Post('new-comers')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createNewComersPromoCodeController(
    @Body() createNewComersPromoCodeDTO: CreateNewComersPromoCodeDTO,
  ) {
    await this.promoCodesService.createNewComersPromoCode(
      createNewComersPromoCodeDTO,
    );
    return {
      success: true,
    };
  }

  @Post('all-users')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createAllUsersPromoCodeController(
    @Body() createAllUsersPromoCodeDTO: CreateAllUsersPromoCodeDTO,
  ) {
    await this.promoCodesService.createAllUsersPromoCode(
      createAllUsersPromoCodeDTO,
    );
    return {
      success: true,
    };
  }

  @Post('aggregator')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createAggregatorPromoCodeController(
    @Body() createAggregatorPromoCodeDto: CreateAggregatorPromoCodeDTO,
  ) {
    await this.promoCodesService.createAggregatorPromoCode(
      createAggregatorPromoCodeDto,
    );
    return {
      success: true,
    };
  }

  @Post('segment')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createSegmentPromoCodeController(
    @Body() createSegmentPromoCodeDto: CreateSegmentPromoCodeDto,
  ) {
    await this.promoCodesService.createSegmentPromoCode(
      createSegmentPromoCodeDto,
    );
    return {
      success: true,
    };
  }

  @Post('offline')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createOfflinePromoCodeController(
    @Body() createOfflinePromoCodeDto: CreateOfflinePromoCodeDTO,
  ) {
    await this.promoCodesService.createOfflinePromoCode(
      createOfflinePromoCodeDto,
    );
    return {
      success: true,
    };
  }

  @Post('b2b')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createB2bPromoCodeController(
    @Body() createB2bPromoCodeDTO: CreateB2bPromoCodeDTO,
  ) {
    await this.promoCodesService.createB2bPromoCode(createB2bPromoCodeDTO);
    return {
      success: true,
    };
  }

  @Get('user')
  @UseGuards(UserAuthGuard)
  async getAllForUserController(
    @Query('status') status: string,
    @Account() account: any,
  ) {
    return {
      success: true,
      data: await this.promoCodesService.getAllForUser(status, account.id),
    };
  }

  @Get('admin')
  @UseGuards(UserAuthGuard)
  async getAllForAdminController(@Query() getPromoCodesDTO: GetPromoCodesDTO) {
    return {
      success: true,
      data: await this.promoCodesService.getAllForAdmin(getPromoCodesDTO),
    };
  }

  @Get('admin/dropdown')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllForAdminDropdown() {
    return {
      success: true,
      data: await this.promoCodesService.getAllForAdminDropdown(),
    };
  }

  @Patch(':promoCodeId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updatePromoCode(
    @Param('promoCodeId') promoCodeId: string,
    @Body() body: any,
  ) {
    await this.promoCodesService.updatePromoCode(promoCodeId, body.code);
    return {
      success: true,
    };
  }

  @Post(':promoCodeId/disable')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async disablePromoCode(@Param('promoCodeId') promoCodeId: string) {
    await this.promoCodesService.disablePromoCode(promoCodeId);
    return {
      success: true,
    };
  }

  @Post(':promoCodeId/activate')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async activatePromoCode(@Param('promoCodeId') promoCodeId: string) {
    await this.promoCodesService.activatePromoCode(promoCodeId);
    return {
      success: true,
    };
  }
}
