import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateContactInfoDto } from '../dto/create-contact-info.dto';
import { UpdateContactInfoDto } from '../dto/update-contact-info.dto';
import {
  ContactInfoModel,
  contactInfoModelName,
} from '../schemas/contact-info.schema';

@Injectable()
export class ContactInfoRepository {
  constructor(
    @InjectModel(contactInfoModelName)
    private readonly contactInfoModel: Model<ContactInfoModel>,
  ) {}

  async createNewContactInfo(body: CreateContactInfoDto) {
    if ((await this.contactInfoModel.find()).length > 1) {
      throw new ConflictException({
        ar: 'جهة الاتصال موجودة بالفعل',
        en: 'Another Contact Info already exist',
      });
    }
    const contactInfo = await this.contactInfoModel.create(body);

    return contactInfo;
  }

  async listAllContactInfo() {
    const [contactInfo] = await this.contactInfoModel.find(
      {},
      {
        contactTitle: 1,
        emails: 1,
        phoneNumbers: 1,
        whatsAppNumber: 1,
        facebookLink: 1,
        instagramLink: 1,
        twitterLink: 1,
        youtubeLink: 1,
        linkedinLink: 1,
        tiktokLink: 1,
        website: 1,
      },
    );

    if (!contactInfo) {
      throw new NotFoundException({
        ar: 'جهة الاتصال غير موجودة',
        en: 'contactInfo not found',
      });
    }

    return contactInfo;
  }

  // async getContactInfoById(contactId: string) {
  //   const contactInfo = await this.contactInfoModel.findById(contactId, {
  //     contactTitle: 1,
  //     emails: 1,
  //     phoneNumbers: 1,
  //     whatsAppNumber: 1,
  //     facebookLink: 1,
  //     instagramLink: 1,
  //     twitterLink: 1,
  //     youtubeLink: 1,
  //     linkedinLink: 1,
  //     tiktokLink: 1,
  //   });

  //   if (!contactInfo) {
  //     throw new NotFoundException({
  //       ar: 'جهة الاتصال غير موجوجة',
  //       en: 'contactInfo not found',
  //     });
  //   }

  //   return contactInfo;
  // }

  async updateContactInfo(body: UpdateContactInfoDto) {
    const contactInfo = await this.contactInfoModel.findOne();

    if (!contactInfo) {
      throw new NotFoundException({
        ar: 'جهة الاتصال غير موجودة',
        en: 'contactInfo not found',
      });
    }

    contactInfo.set(body);
    await contactInfo.save();

    return contactInfo;
  }

  async deleteContactInfo() {
    await this.contactInfoModel.deleteMany();
  }
}
