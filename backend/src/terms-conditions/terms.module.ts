import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { TermsSchema, termsModelName } from './schemas/terms.schema';
import { TermsService } from './terms.service';
import { TermsController } from './controllers/terms.controller';
import { TermsRepository } from './terms.repository';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: termsModelName, schema: TermsSchema }]),
  ],
  providers: [TermsService, TermsRepository],
  controllers: [TermsController],
  exports: [],
})
export class TermsModule {}
