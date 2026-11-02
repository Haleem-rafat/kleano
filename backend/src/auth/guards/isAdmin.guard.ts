import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Observable } from 'rxjs';
import { UnAuthorizedResponse } from '../../common/errors/UnAuthorizedResponse';
import { Roles } from 'src/admin/schemas/admin.schema';

@Injectable()
export class IsAdminGaurd implements CanActivate {
  constructor() {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();

    if (
      request.account.role != Roles.SubAdmin &&
      request.account.role != Roles.SuperAdmin
    )
      throw new UnAuthorizedResponse({
        ar: 'غير مصرح لك الدخول',
        en: 'Not Authorized Access For This Operation',
      });

    return true;
  }
}
