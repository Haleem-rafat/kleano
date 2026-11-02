import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { IsAdminGuard } from 'src/admin/guard';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { Account } from '../../common/decorators/user.decorator';
import { VehiclesService } from '../../vehicles/vehicles.service';
import {
  UpdatePhoneNumberDTO,
  UpdateUserLocation,
  UserUpdateProfileDTO,
} from '../dto';
import { WalletTopUpDto } from '../dto/wallet-topup.dto';
import { ProfileOwnerGuard, UserAuthorizedGuard } from '../guard';
import { UserService } from '../user.service';

@Controller('users')
export class UserController {
  constructor(
    private vehiclesService: VehiclesService,
    private userService: UserService,
  ) {}

  @Get('vehicles')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async getAllUserVehicles(@Account() account: any) {
    return {
      success: true,
      data: await this.vehiclesService.getAll(account.id),
    };
  }

  @Get('admin')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getUserForAdmin() {
    return {
      success: true,
      data: await this.userService.getAllForAdmin(),
    };
  }

  @Get('points-system')
  @UseGuards(UserAuthGuard)
  async getUserPointSystem(@Account() account: any) {
    return {
      success: true,
      data: await this.userService.getUserPointSystem(account.id),
    };
  }

  @Get('/admin/:id')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getUserDetails(@Param('id') userId: string) {
    const userDetails = await this.userService.getUserDetails(userId);
    return userDetails;
  }

  @Put('')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async updateProfileController(
    @Account() account: any,
    @Body() userUpdateProfileDTO: UserUpdateProfileDTO,
    @UploadedFile() image: Express.Multer.File,
  ) {
    const userProfile = await this.userService.update(
      account.id,
      userUpdateProfileDTO,
      image,
    );
    return {
      success: true,
      data: {
        ...userProfile.toObject(),
        fcmTokens: undefined,
      },
    };
  }

  @Delete('')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async deleteProfileController(@Account() account: any) {
    await this.userService.delete(account.id);
    return {
      success: true,
    };
  }

  @Get('')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async getProfileController(@Account() account: any) {
    const profile = await this.userService.getUserByIdOr404(account.id);
    return {
      success: true,
      data: {
        ...profile,
        fcmTokens: undefined,
      },
    };
  }

  @Patch('phone-number')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async updatePhoneNumberController(
    @Account() account: any,
    @Body() updatePhoneNumberDTO: UpdatePhoneNumberDTO,
  ) {
    const userProfile = await this.userService.updatePhoneNumber(
      account.id,
      updatePhoneNumberDTO,
    );
    return {
      success: true,
      data: {
        ...userProfile.toObject(),
        fcmTokens: undefined,
      },
    };
  }
  @Patch('user-location')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async updateUserLocationController(
    @Account() account: any,
    @Body() updateUserLocation: UpdateUserLocation,
  ) {
    return {
      success: true,
      message: await this.userService.updateUserLocation(
        account.id,
        updateUserLocation,
      ),
    };
  }
  @Patch('user-language')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async updateUserLanguageController(
    @Account() account: any,
    @Body('language') language: string,
  ) {
    return {
      success: true,
      data: await this.userService.updateUserLanguage(account.id, language),
    };
  }

  @Patch('notification-permission')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async updateNotificationPermissions(
    @Account() account: any,
    @Body('allow') allow: string,
  ) {
    return {
      success: true,
      data: await this.userService.updateUserNotificationPermission(
        account.id,
        allow,
      ),
    };
  }

  @Get('export-users-excel')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async exportUsers(@Res() res: Response) {
    const buffer = await this.userService.exportUsersToExcel();

    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    res.setHeader('Content-Disposition', 'attachment; filename="users.xlsx"');

    return res.send(buffer);
  }

  @Post('wallet/topup')
  @UseGuards(UserAuthGuard, ProfileOwnerGuard)
  async topUpWallet(
    @Account() account: any,
    @Body() walletTopUpDto: WalletTopUpDto,
    @Body('paymentMethod') paymentMethod?: 'CREDIT' | 'TAMARA' | 'TABBY',
    @Body('paymentDetails')
    paymentDetails?: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    if (paymentMethod === 'TAMARA') {
      const paymentUrl = await this.userService.createWalletTamaraTopUp(
        account.id,
        walletTopUpDto.amount,
      );
      return {
        success: true,
        data: { paymentUrl },
      };
    }

    if (paymentMethod === 'TABBY') {
      const paymentUrl = await this.userService.createWalletTabbyTopUp(
        account.id,
        walletTopUpDto.amount,
      );
      return {
        success: true,
        data: { paymentUrl },
      };
    }

    if (!paymentDetails) {
      throw new BadRequestException({
        ar: 'تفاصيل الدفع مطلوبة لشحن المحفظة بالبطاقة.',
        en: 'Payment details are required for card wallet top-up.',
      });
    }

    const paymentData = await this.userService.createWalletTopUpPayment(
      account.id,
      walletTopUpDto.amount,
      paymentDetails,
    );

    return {
      success: true,
      data: paymentData,
    };
  }
}
