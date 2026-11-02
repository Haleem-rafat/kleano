import { HttpModule } from '@nestjs/axios';
import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PaginationService } from 'src/common/services/pagination/pagination.service';
import { PointsModule } from 'src/points/points.module';
import { CityModule } from '../city/city.module';
import { FirebaseModule } from '../common/services/firebase/firebase.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';
import { VehiclesModule } from '../vehicles/vehicles.module';
import { AdminUserRepository } from './adminUser.repository';
import { AdminUserService } from './adminUser.service';
import { AdminUserController } from './controllers/adminUser.controller';
import { UserController } from './controllers/user.controller';
import { PendingUserService } from './pending-user.service';
import {
  pendingUserModelName,
  PendingUserSchema,
} from './schemas/pending-user.schema';
import { userModelName, UserSchema } from './schemas/user.schema';
import { UserCronService } from './services/user-cron.service';
import { UserRepository } from './user.repository';
import { UserService } from './user.service';
import { UserQueriesHelper } from './userQueriesHelper.service';
import { TabbyModule } from 'src/tabby/tabby.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: userModelName, schema: UserSchema }]),
    MongooseModule.forFeature([
      { name: pendingUserModelName, schema: PendingUserSchema },
    ]),
    HttpModule,
    forwardRef(() => VehiclesModule),
    forwardRef(() => SubscriptionsModule),
    FirebaseModule,
    CityModule,
    PointsModule,
    forwardRef(() => TabbyModule),
  ],
  controllers: [UserController, AdminUserController],
  providers: [
    UserService,
    UserRepository,
    UserQueriesHelper,
    AdminUserRepository,
    AdminUserService,
    PaginationService,
    PendingUserService,
    UserCronService,
  ],
  exports: [UserService, UserRepository, MongooseModule, PendingUserService],
})
export class UserModule {}
