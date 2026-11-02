import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { Account } from 'src/common/decorators/user.decorator';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { UserAuthorizedGuard } from '../../user/guard/userAuthorized.guard';
import { SaveLocationDTO } from '../dtos';
import { LocationsService } from '../services/locations.service';

@Controller('locations')
export class LocationsController {
  constructor(private locationsService: LocationsService) {}

  @Post('saved-locations')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async saveLocationController(
    @Body() saveLocationDTO: SaveLocationDTO,
    @Account() account: any,
  ) {
    // TODO

    const location = {
      latitude: Number(saveLocationDTO.latitude),
      longitude: Number(saveLocationDTO.longitude),
      streetName: saveLocationDTO.streetName,
      subAdministrativeArea: saveLocationDTO.subAdministrativeArea,
      country: saveLocationDTO.country,
    };

    return {
      success: true,
      data: await this.locationsService.saveNewLocation(
        account.id,
        location,
        saveLocationDTO.savedName,
      ),
    };
  }

  @Get('saved-locations')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async getSavedLocationsControllers(@Account() account: any) {
    return {
      success: true,
      data: await this.locationsService.getSavedLocations(account.id),
    };
  }

  @Patch('saved-locations/clear/all')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async unSaveLocationsController(@Account() account: any) {
    await this.locationsService.unSaveAllLocations(account.id);
    return {
      success: true,
    };
  }

  @Patch('saved-locations/clear/:locationId')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async unSaveLocationController(@Param('locationId') locationId: string) {
    await this.locationsService.unSaveLocation(locationId);
    return {
      success: true,
    };
  }

  @Patch('saved-locations/:locationId/default')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async markAsDefaultController(
    @Param('locationId') locationId: string,
    @Account() account: any,
  ) {
    await this.locationsService.markAsDefault(account.id, locationId);
    return {
      success: true,
    };
  }

  @Get('recent-locations')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async save(@Account() account: any) {
    return {
      success: true,
      data: await this.locationsService.getRecentLocations(account.id),
    };
  }

  @Patch('recent-locations/:locationId/save')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  async saveLocationFromRecentController(
    @Param('locationId') locationId: string,
    @Body('savedName') savedName: string,
  ) {
    return {
      success: true,
      data: await this.locationsService.saveCurrentLocation(
        locationId,
        savedName,
      ),
    };
  }
}
