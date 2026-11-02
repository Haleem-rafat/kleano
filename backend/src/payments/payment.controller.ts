import { Controller, Post, Req, HttpCode } from '@nestjs/common';
import { Request } from 'express';
import { PaymentService } from './payment.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post('webhook-listener')
  @HttpCode(200)
  async webhookHandler(@Req() request: Request) {
    console.log('Moyasar Webhook Listener Triggered');
    // const signature = request.header('x-moyasar-signature') || '';

    // const secret = process.env.MOYASAR_WEBHOOK_SECRET;

    // if (!signature || !secret) {
    //   return { success: false, message: 'Missing signature or secret' };
    // }

    // const payload = JSON.stringify(request.body);
    // const expectedSignature = createHmac('sha256', secret)
    //   .update(payload)
    //   .digest('hex');

    // if (signature !== expectedSignature) {
    //   return { success: false, message: 'Invalid signature' };
    // }

    await this.paymentService.webhookListener(request);

    return { success: true };
  }

  @Post('tamara-webhook')
  @HttpCode(200)
  async tamaraWebhookHandler(@Req() request: Request) {
    console.log('Tamara Webhook Listener Triggered');

    await this.paymentService.tamaraWebhookListener(request);

    return { success: true };
  }

  @Post('tabby-webhook')
  @HttpCode(200)
  async tabbyWebhookHandler(@Req() request: Request) {
    console.log('Tabby Webhook Listener Triggered');

    await this.paymentService.tabbyWebhookListener(request);

    return { success: true };
  }
}
