import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Observable } from 'rxjs';
import { UnAuthorizedResponse } from '../../common/errors/UnAuthorizedResponse';

@Injectable()
export class SuperAdminGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();

    if (request.account.role != 'superAdmin')
      throw new UnAuthorizedResponse({
        ar: 'غير مصرح لك',
        en: 'Not Authorized',
      });

    return true;
  }
}
