import { Injectable } from '@nestjs/common';
import { CreateContactInfoDto } from '../dto/create-contact-info.dto';
import { ContactInfoRepository } from '../repositories/contact-info.repository';
import { UpdateContactInfoDto } from '../dto/update-contact-info.dto';

@Injectable()
export class ContactInfoService {
  constructor(private contactInfoRepository: ContactInfoRepository) {}

  async createNewContactInfo(body: CreateContactInfoDto) {
    const contactInfo = await this.contactInfoRepository.createNewContactInfo(
      body,
    );

    return contactInfo;
  }

  async listAllContactInfo() {
    const contactInfoList =
      await this.contactInfoRepository.listAllContactInfo();

    return contactInfoList;
  }

  // async getContactById(contactId: string) {
  //   const contactInfo = await this.contactInfoRepository.getContactInfoById(
  //     contactId,
  //   );

  //   return contactInfo;
  // }

  async updateContactInfo(body: UpdateContactInfoDto) {
    const updatedContact = await this.contactInfoRepository.updateContactInfo(
      body,
    );

    return updatedContact;
  }

  async deleteContactInfo() {
    await this.contactInfoRepository.deleteContactInfo();
  }
}
