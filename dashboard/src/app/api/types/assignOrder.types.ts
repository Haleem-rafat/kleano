import { IAddOns } from './addOns';
import { IBikers } from './bikers.types';
import { IwshaingServicesList } from './wshaingServices.types';

export interface IAssignedOrdersParams {
  page?: number;
  perPage?: number;
}

export interface IAssignedOrdersList {
  success: boolean;
  pagination: {
    page: number;
    perPage: number;
    totalItems: number;
    totalPages: number;
  };
  data: {
    isScheduled: boolean;
    _id: string;
    user: {
      _id: string;
      userName: string;
      phone: string;
      imageLink: string;
    };
    washingServices: IwshaingServicesList[];
    addOns: IAddOns[];
    vehicle: {
      _id: string;
      type: string;
      brand: string;
      model: string;
      plateNumber: string;
      color: string;
      imageLink: string;
      imagePath: string;
    };
    location: {
      _id: string;
      latitude: number;
      longitude: number;
      streetName: string;
      subAdministrativeArea: string;
      city: string | null;
      isSaved: boolean;
    };
    isAssigned: boolean;
    totalDuration: number;
    status: string;
    type: string;
    paymentType: string;
    totalPrice: number;
    discount: number;
    totalPay: number;
    isPointsApplied: boolean;
    createdAt: string;
    updatedAt: string;
    __v: number;
    promoCode: {
      _id: string;
      code: string;
    };
    assignedBy: string;
    biker: IBikers;
  }[];
}
