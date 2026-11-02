import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AdminController } from './controllers/admin.controller';
import { AdminRepository } from './admin.repository';
import { AdminService } from './admin.service';
import { adminModelName, AdminSchema } from './schemas/admin.schema';
import { PaginationModule } from '../common/services/pagination/pagination.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: adminModelName, schema: AdminSchema }]),
    PaginationModule,
  ],
  controllers: [AdminController],
  providers: [AdminService, AdminRepository],
  exports: [AdminService, AdminRepository],
})
export class AdminModule {}
