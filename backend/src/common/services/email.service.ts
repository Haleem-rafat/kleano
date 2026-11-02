import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import { EmailType } from '../constants/email-type.constant';
import {
  InvoiceEmailTemplate,
  OrderDetailsEmailTemplate,
} from '../helpers/email-template.helper';
import { EmailOptions } from '../interfaces/email-option.interface';

@Injectable()
export class EmailService {
  private transporter = nodemailer.createTransport({
    host: `${process.env.NODEMAILER_HOST}`,
    secure: true, // true for port 456    false for port 25
    port: 465, // 465 >> secure SSL/TLS   25 >> Unsecure
    auth: {
      user: `${process.env.NODEMAILER_EMAIL_FROM}`,
      pass: `${process.env.NODEMAILER_PASSWORD}`,
    },
  });

  private mailGenerator(
    emailType: EmailType,
    { orderData, invoiceData, email, subject, senderName }: EmailOptions,
  ) {
    let generatedEmailTemplate = '';
    if (emailType === 'ORDER_CREATED') {
      generatedEmailTemplate = OrderDetailsEmailTemplate(orderData);
    } else if (emailType === 'INVOICE_CREATED') {
      generatedEmailTemplate = InvoiceEmailTemplate(invoiceData);
    }
    return {
      from: {
        name: senderName,
        address: `${process.env.NODEMAILER_EMAIL_FROM}`,
      },
      to: email,
      subject: subject,
      html: generatedEmailTemplate,
    };
  }

  async sendEmail(emailType: EmailType, emailOptions: EmailOptions) {
    const mail = this.mailGenerator(emailType, emailOptions);

    try {
      await this.transporter.sendMail(mail);
    } catch (error) {
      throw new ServiceUnavailableException(`Failed to send email: ${error}`);
    }
  }
}
