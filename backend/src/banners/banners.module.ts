import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BannerController } from './controllers/banner.controller';
import { BannerRepository } from './repositories/banner.repository';
import { BannerSchema, bannerModelName } from './schemas/banner.schema';
import { BannerService } from './services/banner.service';
import { FirebaseService } from 'src/common/services/firebase/firebase.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: bannerModelName, schema: BannerSchema },
    ]),
  ],
  providers: [BannerService, BannerRepository, FirebaseService],
  controllers: [BannerController],
  exports: [],
})
export class BannersModule {}
