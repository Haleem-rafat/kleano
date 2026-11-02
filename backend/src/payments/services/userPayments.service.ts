import { BadRequestException, Injectable } from '@nestjs/common';
import { UserService } from '../../user/user.service';

import { HttpService } from '@nestjs/axios';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { PaymentsRepository } from 'src/payments/repositories/payments.repository';
import { PaginationService } from '../../common/services/pagination/pagination.service';
import { GetPaymentsDTO } from '../dtos';

@Injectable()
export class UsersPaymentsService {
  constructor(
    @InjectConnection() private readonly connection: Connection,

    private paymentsRepository: PaymentsRepository,
    private userService: UserService,

    private paginationService: PaginationService,
    private readonly httpService: HttpService,
  ) {}

  async getAllUserPayments(userId: string, getPaymentsDTO: GetPaymentsDTO) {
    // Get User
    const user = await this.userService.getUserById(userId);

    const { skip, limit } = this.paginationService.getSkipAndLimit(
      Number(getPaymentsDTO.page),
      Number(getPaymentsDTO.perPage),
    );
    const { payments, count } =
      await this.paymentsRepository.findAllUserPayments(
        user,
        getPaymentsDTO.status,
        skip,
        limit,
      );

    return this.paginationService.paginate(
      payments,
      count,
      Number(getPaymentsDTO.page),
      Number(getPaymentsDTO.perPage),
    );
  }

  async getPaymentByIdPopulated(paymentId: string) {
    return await this.paymentsRepository.findPaymentByIdPopulatedOr404(
      paymentId,
    );
  }

  async getPaymentById(paymentId: string) {
    return await this.paymentsRepository.findPaymentByIdOr404(paymentId);
  }

  async getApplePaymentById(paymentId: string) {
    try {
      const response = await this.httpService.axiosRef.get(
        `https://api.moyasar.com/v1/payments/${paymentId}`,
        {
          auth: {
            username: process.env.API_SECRET_KEY,
            password: '',
          },
        },
      );

      console.log('Payment Details:', response.data);
      return response.data;
    } catch (error) {
      console.error('Payment Fetch Error:', error.response?.data || error);
      throw new BadRequestException({
        ar: 'فشل في جلب بيانات الدفع.',
        en: 'Failed to fetch payment.',
      });
    }
  }
}
