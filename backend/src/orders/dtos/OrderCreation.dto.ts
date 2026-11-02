import {
  IsArray,
  IsBoolean,
  IsIn,
  IsMongoId,
  IsNotEmpty,
  IsNotEmptyObject,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
} from 'class-validator';
import { AddOns } from '../../add-ons/schemas/add-ons.schema';
import { Subscription } from '../../subscriptions/schemas/subscriptions.schema';
import { Vehicle } from '../../vehicles/schemas/vehicles.schema';
import { WashingService } from '../../washing-services/schemas/washing-services.schema';
import { PaymentTypes, UserOS } from '../schemas/orders.schema';

class LocationDTO {
  @Matches(/(-\d+\.\d\d\d\d\d+|\d+.\d\d\d\d\d+)/i, {
    message: 'Latitude must be in the format X.dddddd+',
  })
  latitude: string;

  @Matches(/(-\d+\.\d\d\d\d\d+|\d+.\d\d\d\d\d+)/i, {
    message: 'Longitude must be in the format X.dddddd+',
  })
  longitude: string;

  @IsNotEmpty()
  @IsString()
  streetName: string;

  @IsOptional()
  @IsString()
  subAdministrativeArea: string;

  @IsNotEmpty()
  @IsString()
  country: string;
}

export class OrderCreationDTO {
  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  washingServices?: WashingService[];

  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  addOns?: AddOns[];

  @IsNotEmpty()
  @IsMongoId()
  vehicle: Vehicle;

  @IsNotEmptyObject()
  location: LocationDTO;

  @IsOptional()
  @IsString()
  description: string;

  @IsString()
  startTime: string;

  // required explicit time slot 'HH:MM' matching biker shift timeSlot
  @IsString()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/, {
    message: 'timeSlot must be in the format HH:MM (e.g., 09:30, 14:45)',
  })
  timeSlot: string;

  @IsString()
  bookingDate: string;

  @IsNotEmpty()
  @IsString()
  type: string;

  @IsNumber()
  totalPrice: number;

  @IsOptional()
  @IsMongoId()
  subscription?: Subscription;

  @IsOptional()
  @IsString()
  @IsIn([
    PaymentTypes.CREDIT,
    PaymentTypes.WALLET,
    PaymentTypes.SUBSCRIBED,
    PaymentTypes.APPLE_PAY,
    PaymentTypes.TAMARA,
    PaymentTypes.TABBY,
  ])
  paymentType?: string;

  @IsOptional()
  @IsString()
  code?: string;

  @IsOptional()
  @IsString()
  userOS?: UserOS;

  @IsOptional()
  @IsBoolean()
  isCarFreshened?: boolean;

  @IsOptional()
  @IsNumber()
  appliedPoints?: number;
}
