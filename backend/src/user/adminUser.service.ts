import { Injectable } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PaginationService } from 'src/common/services/pagination/pagination.service';
import { AdminUserRepository } from './adminUser.repository';
import { ListAllUsers } from './dto/list-users.dto';

@Injectable()
export class AdminUserService {
  constructor(
    private adminUserRepository: AdminUserRepository,
    private paginationService: PaginationService,
    private eventEmitter: EventEmitter2,
  ) {}

  async listAllUsers(query: ListAllUsers) {
    const { page, perPage } = query;
    const { skip, limit } = this.paginationService.getSkipAndLimit(
      Number(page),
      Number(perPage),
    );
    const { data, count } = await this.adminUserRepository.listAllUsers(
      query,
      skip,
      limit,
    );

    return this.paginationService.paginate(data, count, page, perPage);
  }

  async getUserById(userId: string) {
    const user = await this.adminUserRepository.getUserById(userId);

    return user;
  }

  async suspendUser(userId: string) {
    const suspendedUser = await this.adminUserRepository.suspendUser(userId);

    return suspendedUser;
  }

  async unsuspendUser(userId: string) {
    const user = await this.adminUserRepository.unsuspendUser(userId);

    return user;
  }

  async addBalanceToUserWallet(
    adminId: string,
    userId: string,
    amount: number,
    notes?: string,
  ) {
    const user = await this.adminUserRepository.addBalanceToUserWallet(
      userId,
      amount,
    );

    this.eventEmitter.emit('admin.wallet.topup', {
      adminId,
      userId,
      amount,
      notes,
    });

    return user;
  }
}
