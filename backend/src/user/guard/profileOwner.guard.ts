import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { ForbiddenResponse } from '../../common/errors/ForbiddenResponse';
import { UserService } from '../user.service';

@Injectable()
export class ProfileOwnerGuard implements CanActivate {
  constructor(private userService: UserService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Get Request Object
    const request = context.switchToHttp().getRequest();

    const userId: string = request.account.id;

    // Check if user is ProfileOwner
    const user = await this.userService.getUserByIdOr404(userId);
    if (user._id.toString() === userId.toString()) return true;

    throw new ForbiddenResponse({
      ar: 'غير مصرح لك ',
      en: 'You have no privileges to perform an this action',
    });
  }
}
