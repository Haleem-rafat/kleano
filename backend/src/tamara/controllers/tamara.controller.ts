import { Body, Controller, Post } from '@nestjs/common';
import { CreateCheckoutSessionDto } from '../dto/create-checkout-session.dto';
import { TamaraService } from '../services/tamara.service';

@Controller('tamara')
export class TamaraController {
  constructor(private readonly tamaraService: TamaraService) {}

  @Post('checkout-session')
  async createCheckoutSession(
    @Body() createCheckoutSessionDto: CreateCheckoutSessionDto,
  ) {
    return await this.tamaraService.createCheckoutSession(
      createCheckoutSessionDto,
    );
  }
}
