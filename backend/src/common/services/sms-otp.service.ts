import { HttpService } from '@nestjs/axios';
import { Injectable, InternalServerErrorException } from '@nestjs/common';

@Injectable()
export class SmsOtpService {
  private readonly apiKey: string;
  private readonly baseUrl: string;
  private readonly senderName: string;

  constructor(private readonly httpService: HttpService) {
    this.senderName = process.env.OURSMS_SOURCE;
    this.apiKey = process.env.OURSMS_API_KEY;
    this.baseUrl =
      process.env.OURSMS_BASE_URL || 'https://api.oursms.com/msgs/sms';
  }

  async sendOtp(phoneNumber: string, otp: string) {
    try {
      const response = await this.httpService.axiosRef.post(
        `${this.baseUrl}`,
        {
          src: this.senderName,
          body: `Your OTP is ${otp}`,
          dests: [`${phoneNumber}`],
        },
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${this.apiKey}`,
          },
        },
      );
      return response.data;
    } catch (error) {
      console.error('SMS OTP Service Error:', error.response?.data || error);
      throw new InternalServerErrorException({
        ar: 'فشل في إرسال الرمز المرجعي',
        en: 'Failed to send OTP',
      });
    }
  }
}
