import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AdminService } from 'src/admin/admin.service';
import { AdminStatus, Roles } from 'src/admin/schemas/admin.schema';

@Injectable()
export class UserAuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private adminService: AdminService,
  ) {}

  async canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    let payload;

    try {
      const access_token = request.headers['authorization'].split(' ')[1];
      payload = this.jwtService.verify(access_token, {
        secret: process.env.ACCESS_TOKEN_SECRET,
      });
    } catch (err) {
      throw new ForbiddenException({
        success: false,
        message: {
          en: 'Not Authenticated',
          ar: 'غير مصدق للدخول',
        },
      });
    }

    request.account = {
      id: payload.id,
      role: payload.role,
      isSuspended: payload.isSuspended,
    };

    if (payload.role === Roles.SubAdmin || payload.role === Roles.SuperAdmin) {
      const admin = await this.adminService.getById(payload.id);

      if (!admin || admin.isDeleted === true) {
        throw new UnauthorizedException({
          success: false,
          message: {
            en: 'Your account has been deleted',
            ar: 'لقد تم مسح حسابك',
          },
        });
      }

      if (admin.status === AdminStatus.SUSPENDED) {
        throw new UnauthorizedException({
          success: false,
          message: {
            en: 'Your account has been suspended',
            ar: 'لقد تم ايقاف حسابك',
          },
        });
      }
    }

    if (payload.role === Roles.User) {
      if (request.account.isSuspended) {
        throw new ForbiddenException({
          success: false,
          message: {
            en: 'Your account has been suspended',
            ar: 'لقد تم ايقاف حسابك',
          },
        });
      }
    }

    if (payload.id) return true;
    return false;
  }
}
