import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { ForbiddenResponse } from '../../common/errors/ForbiddenResponse';
import { BikersService } from '../services/bikers.service';

@Injectable()
export class BikerProfileOwnerGuard implements CanActivate {
  constructor(private bikersService: BikersService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Get Request Object
    const request = context.switchToHttp().getRequest();

    const bikerId: string = request.account.id;

    // Check if BIKER is ProfileOwner
    const biker = await this.bikersService.getByIdOr404(bikerId);
    if (biker._id.toString() === bikerId.toString()) return true;

    throw new ForbiddenResponse({
      ar: 'غير مصرح لك ',
      en: 'You have no privileges to perform an this action',
    });
  }
}
