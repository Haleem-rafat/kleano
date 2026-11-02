import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ContactInfoController } from './controllers/contact-info.controller';
import { ContactInfoRepository } from './repositories/contact-info.repository';
import {
  contactInfoModelName,
  ContactInfoSchema,
} from './schemas/contact-info.schema';
import { ContactInfoService } from './services/contact-info.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: contactInfoModelName, schema: ContactInfoSchema },
    ]),
  ],
  providers: [ContactInfoService, ContactInfoRepository],
  controllers: [ContactInfoController],
  exports: [],
})
export class ContactInfoModule {}
