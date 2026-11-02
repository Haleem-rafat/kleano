import { ForbiddenException, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { Socket } from 'socket.io';
import { Roles } from 'src/admin/schemas/admin.schema';
import { FcmTopics } from 'src/common/enums/topics.enum';
import { FCMService } from 'src/common/services/firebase/fcm.service';
import { SmsOtpService } from 'src/common/services/sms-otp.service';
import { PendingUserService } from 'src/user/pending-user.service';
import { UserRepository } from 'src/user/user.repository';
import { AdminService } from '../admin/admin.service';
import { AdminLoginDTO } from '../admin/dto/admin.login.dto';
import { BikerLoginDTO } from '../bikers/dto/bikerLogin.dto';
import { BikerLogoutDTO } from '../bikers/dto/bikerLogout.dto';
import { BikersService } from '../bikers/services/bikers.service';
import { MethodNotAllowedResponse, NotFoundResponse } from '../common/errors';
import { ForbiddenResponse } from '../common/errors/ForbiddenResponse';
import { UnAuthorizedResponse } from '../common/errors/UnAuthorizedResponse';
import { UserLoginDTO, UserRegisterDTO } from '../user/dto';
import { UserLogoutDTO } from '../user/dto/userLogout.dto';
import { UserService } from '../user/user.service';
import { ResetPasswordDTO } from './dtos/resetPassword.dto';
@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private userService: UserService,
    private adminService: AdminService,
    private bikersService: BikersService,
    private fcmService: FCMService,
    private smsOtpService: SmsOtpService,
    private pendingUserService: PendingUserService,
    private userRepository: UserRepository,
  ) {}

  async userRegisteration(userRegisterDTO: UserRegisterDTO) {
    if (await this.userRepository.checkPhoneExistence(userRegisterDTO.phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    if (userRegisterDTO.email) {
      if (
        await this.userRepository.checkEmailIsAlreadyExist(
          userRegisterDTO.email,
        )
      )
        throw new MethodNotAllowedResponse({
          ar: 'البريد الإلكتروني مسجل من قبل',
          en: 'Email is already exist',
        });
    }

    // Create User
    const user = await this.pendingUserService.createPendingUser(
      userRegisterDTO,
    );

    await this.sendRegisterOtp(user.phone);

    return user;
  }

  async verifyRegisterOtp(phoneNumber: string, otp: string) {
    const pendingUser =
      await this.pendingUserService.getPendingUserByPhoneOr404(phoneNumber);

    if (pendingUser.otp !== otp) {
      throw new UnAuthorizedResponse({
        en: 'Incorrect code',
        ar: 'الرمز غير صحيح',
      });
    }

    if (pendingUser.otpExpiresAt < new Date()) {
      throw new UnAuthorizedResponse({
        en: 'Code expired',
        ar: 'الرمز منتهي الصلاحية',
      });
    }

    const user = await this.userService.create({
      userName: pendingUser.userName,
      phone: pendingUser.phone,
      email: pendingUser.email,
      fcmToken: pendingUser.fcmTokens[0],
    });

    await this.pendingUserService.deletePendingUser(phoneNumber);

    // Generate Tokens
    const accessToken = this.generateAccessToken(user._id, 'user');
    const refreshToken = this.generateRefreshToken(user._id, 'user');

    await this.fcmService.subscribeToTopic(
      user.fcmTokens[0],
      FcmTopics.PROMO_CODE_CREATED,
    );

    return {
      ...user.toObject(),
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  //TODO: Add IdToken for login for verification the user
  async userLogin(userLoginDTO: UserLoginDTO) {
    const isPhoneExist = await this.userService.isPhoneExist(
      userLoginDTO.phone,
    );

    if (!isPhoneExist) {
      const pendingUser = await this.pendingUserService.getPendingUserByPhone(
        userLoginDTO.phone,
      );

      if (pendingUser) {
        await this.sendRegisterOtp(userLoginDTO.phone);

        throw new UnAuthorizedResponse({
          en: 'Please verify your phone number',
          ar: 'يرجى تأكيد رقم هاتفك',
        });
      }
    }

    const user = await this.userService.getUserByPhoneOr404(userLoginDTO.phone);

    if (user.isSuspended) {
      throw new ForbiddenException({
        success: false,
        message: {
          en: 'Your account has been suspended',
          ar: 'لقد تم ايقاف حسابك',
        },
      });
    }

    if (user.isAllowNotification) {
      if (!user.fcmTokens?.includes(userLoginDTO.fcmToken)) {
        user.fcmTokens.push(userLoginDTO.fcmToken);
        await user.save();

        await this.fcmService.subscribeToTopic(
          userLoginDTO.fcmToken,
          FcmTopics.PROMO_CODE_CREATED,
        );
      }
    }

    await this.verifyOtp(user.phone, userLoginDTO.otp);

    // Generate Tokens
    const accessToken = this.generateAccessToken(
      user._id,
      'user',
      undefined,
      user.isSuspended,
    );
    const refreshToken = this.generateRefreshToken(user._id, 'user');

    return {
      ...user.toObject(),
      access_token: accessToken,
      refresh_token: refreshToken,
      fcmTokens: undefined,
    };
  }

  async bikerLogin(bikerLoginDTO: BikerLoginDTO) {
    //TODO: Add FcmToken Of Biker To BikerModel but check it Existance
    const biker = await this.bikersService.getBikerByUserNameOr404(
      bikerLoginDTO.userName,
    );

    // Decrypt biker password and Compare
    const isMatch = await bcrypt.compare(
      bikerLoginDTO.password,
      biker.password,
    );
    if (!isMatch)
      throw new UnAuthorizedResponse({
        ar: 'بيانات المستخدم غير صالحة',
        en: 'Invalid user credentials ',
      });

    if (!biker.fcmTokens?.includes(bikerLoginDTO.fcmToken)) {
      biker.fcmTokens.push(bikerLoginDTO.fcmToken);
      await biker.save();
    }

    // Generate Tokens
    const accessToken = this.generateAccessToken(biker._id, 'biker');
    const refreshToken = this.generateRefreshToken(biker._id, 'biker');

    biker.password = undefined;
    return {
      ...biker.toObject(),
      access_token: accessToken,
      refresh_token: refreshToken,
      fcmTokens: undefined,
    };
  }

  async userLogout(userId: string, userLogoutDTO: UserLogoutDTO) {
    await this.userService.removeInvalidFcmToken(
      userId,
      userLogoutDTO.fcmToken,
    );
  }

  async bikerLogout(bikerId: string, bikerLogoutDTO: BikerLogoutDTO) {
    await this.bikersService.removeInvalidFcmTokenForBiker(
      bikerId,
      bikerLogoutDTO.fcmToken,
    );
  }

  async checkUserPhoneExistence(phone: string) {
    return await this.userService.isPhoneExist(phone);
  }

  async checkBikerPhoneExistence(phone: string) {
    const biker = await this.bikersService.checkPhoneNumber(phone);
    if (biker) {
      const token = this.generateAccessToken(biker._id, 'biker', '10m');
      return {
        isExist: true,
        token,
      };
    }

    return {
      isExist: false,
    };
  }

  async resetPasswordForBiker(resetPasswordDTO: ResetPasswordDTO) {
    const payload = this.decodeAccessToken(resetPasswordDTO.token);
    await this.bikersService.resetPassword(
      payload.id,
      resetPasswordDTO.newPassword,
    );
  }

  async adminLogin(adminLoginDTO: AdminLoginDTO) {
    // Get Admin
    const admin = await this.adminService.getAdminByUserNameOr404(
      adminLoginDTO.userName,
    );

    // Decrypt Admin password and Compare
    const isMatch = await bcrypt.compare(
      adminLoginDTO.password,
      admin.password,
    );
    if (!isMatch)
      throw new UnAuthorizedResponse({
        ar: 'بيانات المستخدم غير صالحة',
        en: 'Invalid user credentials ',
      });

    // Generate Tokens
    const accessToken = this.generateAccessToken(
      admin._id,
      admin.isSuperAdmin ? Roles.SuperAdmin : Roles.SubAdmin,
    );
    const refreshToken = this.generateRefreshToken(
      admin._id,
      admin.isSuperAdmin ? Roles.SuperAdmin : Roles.SubAdmin,
    );

    admin.password = undefined;
    return {
      ...admin.toObject(),
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  generateAccessToken(
    id: any,
    role: string,
    expiresIn?: string,
    isSuspended?: boolean,
  ) {
    return this.jwtService.sign(
      {
        id: id,
        role: role,
        isSuspended,
      },
      {
        secret: process.env.ACCESS_TOKEN_SECRET,
        expiresIn: expiresIn ? expiresIn : '30d',
      },
    );
  }

  generateRefreshToken(id: any, role: string) {
    return this.jwtService.sign(
      {
        id: id,
        role: role,
      },
      {
        secret: process.env.REFRESH_TOKEN_SECRET,
        expiresIn: '60d',
      },
    );
  }

  async generateNewTokens(refresh_token: string) {
    if (!refresh_token)
      throw new NotFoundResponse({ ar: 'لا يوجد', en: 'not found' });

    // decode refreshToken
    const payload = this.decodeRefreshToken(refresh_token);

    // Check CLientUser Existence
    const clientProfile = await this.getUserByIdAndRole(
      payload.id,
      payload.role,
    );
    // Generate Tokens
    const accessToken = this.generateAccessToken(
      clientProfile._id.toString(),
      payload.role,
      undefined,
      payload.role === Roles.User ? clientProfile['isSuspended'] : undefined,
    );
    const refreshToken = this.generateRefreshToken(
      clientProfile._id.toString(),
      payload.role,
    );

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  decodeAccessToken(token: string) {
    try {
      return this.jwtService.verify(token, {
        secret: process.env.ACCESS_TOKEN_SECRET,
      });
    } catch {
      throw new ForbiddenException({
        success: false,
        message: {
          en: 'Not Authenticated',
          ar: 'غير مصدق للدخول',
        },
      });
    }
  }
  decodeRefreshToken(refreshToken: string) {
    try {
      return this.jwtService.verify(refreshToken, {
        secret: process.env.REFRESH_TOKEN_SECRET,
      });
    } catch {
      throw new ForbiddenException({
        success: false,
        message: {
          en: 'Not Authenticated',
          ar: 'غير مصدق للدخول',
        },
      });
    }
  }

  async getUserByIdAndRole(clientId: string, role: string) {
    if (role === Roles.SuperAdmin || role === Roles.SubAdmin) {
      const adminProfile = await this.adminService.getByIdOr404(clientId);
      return adminProfile;
    }

    if (role === 'user') {
      const userProfile = await this.userService.getUserByIdOr404(clientId);
      return userProfile;
    }

    if (role === 'biker') {
      const bikerProfile = await this.bikersService.getByIdOr404(clientId);
      return bikerProfile;
    }
  }

  authenticateSocketUser(socket: Socket) {
    if (!socket.handshake.headers['authorization'].split(' ')[1])
      throw new ForbiddenResponse({
        en: 'Not Authenticated',
        ar: 'غير مصدق للدخول',
      });
    try {
      const token = socket.handshake.headers['authorization'].split(' ')[1];
      const payload = this.jwtService.verify(token, {
        secret: process.env.ACCESS_TOKEN_SECRET,
      });
      return { id: payload.id, role: payload.role };
    } catch {
      socket.disconnect();
    }
  }

  async updateUserSocketId(userId: string, role: string, socketId: string) {
    if (role === 'user') {
      await this.userService.updateUserSocketId(userId, socketId);
    }

    if (role === 'biker') {
      await this.bikersService.updateBikerSocketId(userId, socketId);
    }
  }

  async sendOtp(phoneNumber: string) {
    const user = await this.userService.getUserByPhoneOr404(phoneNumber);

    // remove after testing
    if (phoneNumber === '+201202939672' || phoneNumber === '+201284183181') {
      user.otp = '000000';
      user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
      user.otpAttempts = 0;
      await user.save();
      return;
    }

    if (user.otpAttempts >= 3) {
      throw new ForbiddenResponse({
        en: 'You have exceeded the maximum number of attempts, please try again later',
        ar: 'لقد تجاوزت الحد الأقصى لعدد المحاولات ، يرجى المحاولة مرة أخرى لاحقًا',
      });
    }

    const otp = Math.floor(100000 + Math.random() * 900000);
    user.otp = otp.toString();
    user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
    user.otpAttempts++;
    await user.save();

    await this.smsOtpService.sendOtp(phoneNumber, otp.toString());
  }

  async sendRegisterOtp(phoneNumber: string) {
    const user = await this.pendingUserService.getPendingUserByPhoneOr404(
      phoneNumber,
    );

    // remove after testing
    if (phoneNumber === '+201202939672' || phoneNumber === '+201284183181') {
      user.otp = '000000';
      user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
      user.otpAttempts = 0;
      await user.save();
      return;
    }

    if (user.otpAttempts >= 3) {
      throw new ForbiddenResponse({
        en: 'You have exceeded the maximum number of attempts, please try again later',
        ar: 'لقد تجاوزت الحد الأقصى لعدد المحاولات ، يرجى المحاولة مرة أخرى لاحقًا',
      });
    }

    const otp = Math.floor(100000 + Math.random() * 900000);
    user.otp = otp.toString();
    user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
    user.otpAttempts++;
    await user.save();

    await this.smsOtpService.sendOtp(phoneNumber, otp.toString());
  }

  private async verifyOtp(phoneNumber: string, otp: string) {
    const user = await this.userService.getUserByPhoneOr404(phoneNumber);

    if (user.otp !== otp) {
      throw new UnAuthorizedResponse({
        en: 'Incorrect code',
        ar: 'الرمز غير صحيح',
      });
    }

    if (user.otpExpiresAt < new Date()) {
      throw new UnAuthorizedResponse({
        en: 'Code expired',
        ar: 'الرمز منتهي الصلاحية',
      });
    }

    user.otp = null;
    user.otpExpiresAt = null;
    user.otpAttempts = 0;
    await user.save();
  }
}
