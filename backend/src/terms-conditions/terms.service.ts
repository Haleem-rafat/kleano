import { Injectable } from '@nestjs/common';
import { TermsRepository } from './terms.repository';
import { CreateTermsAndConditionsDto } from './dto/create-terms-conditions-dto';

@Injectable()
export class TermsService {
  constructor(private termsRepository: TermsRepository) {}

  async getTermsAndConditions() {
    return await this.termsRepository.getTermsAndConditions();
  }

  async createTermsAndConditions(body: CreateTermsAndConditionsDto) {
    return await this.termsRepository.createTermsAndConditions(body);
  }

  async updateTermsAndConditions(body: CreateTermsAndConditionsDto) {
    return await this.termsRepository.editTermsAndConditions(body);
  }
}
