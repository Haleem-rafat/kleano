import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { UserService } from '../user.service';
import { ForbiddenResponse } from '../../common/errors/ForbiddenResponse';

@Injectable()
export class UserAuthorizedGuard implements CanActivate {
  constructor(private userService: UserService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    const userId: string = request.account.id || request.params.userId;
    const user = await this.userService.getUserById(userId);
    if (user) return true;

    throw new ForbiddenResponse({
      ar: 'غير مصرح لك ',
      en: 'You have no privileges to perform an this action',
    });
  }
}
