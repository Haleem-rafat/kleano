import { Inject, Injectable, forwardRef } from '@nestjs/common';
import * as ExcelJS from 'exceljs';
import { parse } from 'json2csv';
import { AdminService } from 'src/admin/admin.service';
import { Admin, Roles } from 'src/admin/schemas/admin.schema';
import { PaginationService } from 'src/common/services/pagination/pagination.service';
import { NotificationsService } from 'src/notifications/services/notifications.service';
import { UserService } from 'src/user/user.service';
import { BikersService } from '../../bikers/services/bikers.service';
import { PaymentsRepository } from '../repositories/payments.repository';
import { GetPaymentsByAdminDTO } from '../dtos';

@Injectable()
export class AdminsPaymentsService {
  constructor(
    private paymentsRepository: PaymentsRepository,
    private adminService: AdminService,
    private paginationService: PaginationService,
    @Inject(forwardRef(() => NotificationsService))
    private notificationService: NotificationsService,
    private bikerService: BikersService,
    private userService: UserService,
  ) {}

  /**
   * return -all payments (within cities if sub) /  all if super
   *        - and filter creteria
   */
  async getPaymentsByAdmin(
    adminId: string,
    role: string,
    getPaymentsByAdminQuery: GetPaymentsByAdminDTO,
  ) {
    const { page = 1, perPage = 10, status, search } = getPaymentsByAdminQuery;
    const { limit, skip } = this.paginationService.getSkipAndLimit(
      Number(page),
      Number(perPage),
    );
    let admin: Admin;
    if (role === Roles.SubAdmin)
      admin = await this.adminService.getById(adminId);
    const { payments, count } = await this.paymentsRepository.findAllByAdmin(
      skip,
      limit,
      role,
      status,
      role === Roles.SubAdmin ? admin.city : [],
      search,
    );
    return this.paginationService.paginate(
      payments,
      count,
      Number(page),
      Number(perPage),
    );
  }

  async getPaymentById(paymentId: string) {
    return await this.paymentsRepository.findPaymentWithCityByIdPopulatedOr404(
      paymentId,
    );
  }

  async findAllUsersWithPaymentsAggregator(
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    return await this.paymentsRepository.findAllUsersWithPaymentsAggregator(
      expressionLeftSide,
      operator,
      expressionRightSide,
    );
  }
}
