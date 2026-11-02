import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Query,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { IsAdminGuard } from '../../admin/guard/isAdmin.guard';
import { UserAuthGuard } from '../../auth/guards';
import { Account } from '../../common/decorators/user.decorator';
import { AdminChangeBikerPasswordDto } from '../dto/adminChangeBikerPassword.dto';
import { CreateBikerDTO } from '../dto/createBiker.dto';
import { GetBikerTotalOrdersDTO } from '../dto/getBikerTotalOrders.dto';
import { UpdateBikerDTO } from '../dto/updateBiker.dto';
import { UpdatePasswordDTO } from '../dto/updatePassword.dto';
import { BikersService } from '../services/bikers.service';

@Controller('bikers')
export class BikersController {
  constructor(private bikersService: BikersService) {}

  @Post('')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async createBikerController(
    @Account() account: any,
    @Body() createBikerDTO: CreateBikerDTO,
    @UploadedFile() image: Express.Multer.File,
  ) {
    await this.bikersService.createBiker(account.id, createBikerDTO, image);

    return {
      success: true,
    };
  }

  @Get('')
  @UseGuards(UserAuthGuard)
  async getByIdController(@Account() account: any) {
    return {
      success: true,
      data: await this.bikersService.getByIdOr404(account.id),
    };
  }

  @Delete('')
  @UseGuards(UserAuthGuard)
  async deleteBikerController(@Account() account: any) {
    await this.bikersService.deleteBiker(account.id);

    return {
      success: true,
    };
  }

  @Put('update-info')
  @UseGuards(UserAuthGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async updateBikerPublicInfoController(
    @Account() account: any,
    @Body('userName') userName: string,
    @UploadedFile() image: Express.Multer.File,
  ) {
    await this.bikersService.updatePublicInfo(account.id, userName, image);
    return {
      success: true,
    };
  }

  @Patch('update-credentials')
  @UseGuards(UserAuthGuard)
  async updateBikerCredentialsController(
    @Account() account: any,
    @Body() updatePasswordDTO: UpdatePasswordDTO,
  ) {
    await this.bikersService.updateCredentials(account.id, updatePasswordDTO);
    return {
      success: true,
    };
  }

  @Patch('update-status')
  @UseGuards(UserAuthGuard)
  async updateStatusController(
    @Account() account: any,
    @Body('status') status: string,
  ) {
    await this.bikersService.updateBikerStatus(account.id, status);
    return {
      success: true,
    };
  }

  @Patch('update-language')
  @UseGuards(UserAuthGuard)
  async updateBikerLanguageController(
    @Account() account: any,
    @Body('language') language: string,
  ) {
    await this.bikersService.updateBikerLanguage(account.id, language);
    return {
      success: true,
    };
  }

  @Get('/admin/all')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllBikersController(
    @Account() account: any,
    @Query('search') search?: string,
  ) {
    return {
      success: true,
      data: await this.bikersService.getAll(account.id, account.role, search),
    };
  }

  @Get('/admin/by-area/:areaId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getBikersByAreaController(@Param('areaId') areaId: string) {
    return {
      success: true,
      data: await this.bikersService.getBikersByArea(areaId),
    };
  }

  @Get('/admin/excel')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async exportBikersToExcel(@Res() res: Response) {
    const buffer = await this.bikersService.exportBikersToExcel();

    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    res.setHeader('Content-Disposition', 'attachment; filename="orders.xlsx"');

    return res.send(buffer);
  }

  @Get('/admin/performance-report')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getBikersPerformanceReport(@Query() query: GetBikerTotalOrdersDTO) {
    const data = await this.bikersService.getBikersPerformanceReport(query);
    return {
      success: true,
      data: data,
    };
  }

  @Get(':bikerId')
  @UseGuards(UserAuthGuard)
  async getBikerProfileController(@Param('bikerId') bikerId: string) {
    return {
      success: true,
      data: await this.bikersService.getByIdOr404(bikerId),
    };
  }

  @Get('/:bikerId/performance-report')
  @UseGuards(UserAuthGuard)
  async getBikerProfilePerformanceReport(
    @Account() account: any,
    @Param('bikerId') bikerId: string,
    @Query() query: GetBikerTotalOrdersDTO,
  ) {
    const data = await this.bikersService.getBikerProfilePerformanceReport(
      account.id,
      bikerId,
      query,
    );
    return {
      success: true,
      data: data,
    };
  }

  @Put(':bikerId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async updateBikerController(
    @Param('bikerId') bikerId: string,
    @Account() account: any,
    @Body() updateBikerDTO: UpdateBikerDTO,
    @UploadedFile() image: Express.Multer.File,
  ) {
    return {
      success: true,
      data: await this.bikersService.updateBiker(
        bikerId,
        account.id,
        updateBikerDTO,
        image,
      ),
    };
  }

  @Patch(':bikerId/suspend')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async suspendBikerController(@Param('bikerId') bikerId: string) {
    return {
      success: true,
      data: await this.bikersService.suspendBikerById(bikerId),
    };
  }

  @Patch(':bikerId/restore')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async restoreBikerController(@Param('bikerId') bikerId: string) {
    return {
      success: true,
      data: await this.bikersService.restoreBikerById(bikerId),
    };
  }

  @Patch(':bikerId/admin/change-password')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async changeBikerPassword(
    @Param('bikerId') bikerId: string,
    @Account() account: any,
    @Body() adminChangeBikerPasswordDto: AdminChangeBikerPasswordDto,
  ) {
    const adminId = account.id;
    const { password } = adminChangeBikerPasswordDto;

    await this.bikersService.changeBikerPassword(adminId, bikerId, password);
    return { success: true, message: 'Biker password changed successfully' };
  }
}
