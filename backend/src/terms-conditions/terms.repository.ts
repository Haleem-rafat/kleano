import {
  Injectable,
  MethodNotAllowedException,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateTermsAndConditionsDto } from './dto/create-terms-conditions-dto';
import { TermsModel, termsModelName } from './schemas/terms.schema';

@Injectable()
export class TermsRepository {
  constructor(
    @InjectModel(termsModelName) private readonly termsModel: Model<TermsModel>,
  ) {}

  async getTermsAndConditions() {
    const [termsAndConditions] = await this.termsModel.find({}, { content: 1 });

    if (!termsAndConditions) {
      throw new NotFoundException('terms and conditions not found');
    }

    return termsAndConditions;
  }

  async createTermsAndConditions({ content }: CreateTermsAndConditionsDto) {
    const termsExists = await this.termsModel.find();
    if (termsExists.length) {
      throw new MethodNotAllowedException(
        'Terms and Conditions already exists',
      );
    }
    return await this.termsModel.create({ content });
  }

  async editTermsAndConditions({ content }: CreateTermsAndConditionsDto) {
    const [terms] = await this.termsModel.find();

    terms.content = content;
    await terms.save();
  }
}
