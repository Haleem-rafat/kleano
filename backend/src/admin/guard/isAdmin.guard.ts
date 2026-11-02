import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { ForbiddenResponse } from '../../common/errors/ForbiddenResponse';
import { Roles } from '../schemas/admin.schema';

@Injectable()
export class IsAdminGuard implements CanActivate {
  constructor() {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    if (
      request.account.role === Roles.SubAdmin ||
      request.account.role === Roles.SuperAdmin
    )
      return true;
    throw new ForbiddenResponse({
      ar: 'غير مصرح لك ',
      en: 'You have no privileges to perform an this action',
    });
  }
}
