import {
  Controller,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { Account } from 'src/common/decorators/user.decorator';
import { NotificationsService } from '../services/notifications.service';
import { NotifcationsPaginationsDTO } from '../dtos/notificationsPaginations.dto';

@Controller('notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @UseGuards(UserAuthGuard)
  async getNotificationsController(
    @Account() account: any,
    @Query() notifcationsPaginationsDTO: NotifcationsPaginationsDTO,
  ) {
    const paginatedNotificationsResult =
      await this.notificationsService.getAllNotificationsForReceiver(
        account.id,
        account.role,
        notifcationsPaginationsDTO,
      );
    return {
      success: true,
      totalPages:
        paginatedNotificationsResult.paginationResult.paginationData.totalPages,
      totalItems:
        paginatedNotificationsResult.paginationResult.paginationData.totalItems,
      totalUnRead: paginatedNotificationsResult.totalUnRead,
      data: paginatedNotificationsResult.paginationResult.dataList,
    };
  }

  @Patch('/:notificationId/set-read')
  @UseGuards(UserAuthGuard)
  async setNotificationRead(@Param('notificationId') notificationId: string) {
    await this.notificationsService.setNotificationIsRead(notificationId);
    return {
      success: true,
    };
  }
}
