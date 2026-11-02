import { HttpModule } from '@nestjs/axios';
import { Global, Module, forwardRef } from '@nestjs/common';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { AdminService } from 'src/admin/admin.service';
import { PaginationService } from 'src/common/services/pagination/pagination.service';
import { SmsOtpService } from 'src/common/services/sms-otp.service';
import { UserRepository } from 'src/user/user.repository';
import { AdminModule } from '../admin/admin.module';
import { BikersModule } from '../bikers/bikers.module';
import { FirebaseModule } from '../common/services/firebase/firebase.module';
import { UserModule } from '../user/user.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Global()
@Module({
  imports: [
    forwardRef(() => UserModule),
    AdminModule,
    forwardRef(() => BikersModule),
    JwtModule.register({}),
    FirebaseModule,
    HttpModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtService,
    AdminService,
    PaginationService,
    SmsOtpService,
    UserRepository,
  ],
  exports: [AuthService, JwtModule, AdminService],
})
export class AuthModule {}
