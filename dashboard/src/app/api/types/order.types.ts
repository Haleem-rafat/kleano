export interface IRootOrder {
  success: boolean;
  pagination: Pagination;
  data: IOrderList[] | IOrderList;
}

export interface IRootTransactionsList {
  success: boolean;
  pagination: Pagination;
  data: IOrderList[] | IOrderList;
}

export interface ITransactionsList {
  _id: string;
  order: IOrderList[] | IOrderList;
  createdAt: string;
  updatedAt: string;
}


export interface Pagination {
  page: number;
  perPage: number;
  totalItems: number;
  totalPages: number;
}

export interface IOrderList {
  _id: string;
  user: User;
  washingServices: WashingService[];
  addOns: AddOn[];
  vehicle: Vehicle;
  location: Location;
  isAssigned: boolean;
  startTime: string;
  totalDuration: number;
  status: string;
  type: string;
  paymentType: string;
  totalPrice: number;
  discount: number;
  isPointsApplied: boolean;
  pointsDiscount: number;
  carAfterWashLink?: string;
  carBeforeWashLink?: string;
  totalPay: number;
  createdAt: string
  ratingOfUser: number,
  ratingOfBiker: number,
  bikerCommission?: number;
  updatedAt: string;
  __v: number;
  biker: Biker;
  OnTheWayAt?: string;
  assignedBy?: string;
  description?: string;
  onWashingAt?: string;
  userOrdersCount: number;
  endTime?: string;
  promoCode?: {
    code: string,
    _id: string
  };
  googleMapsLink: string;
  subscription?: {
    _id: string;
    plan: {
      _id: string;
      type: {
        en: string;
        ar: string;
      };
      color: string;
      price: number;
      washingServices: WashingService[];
    };
    remainingWashes: number;
    washesCount: number;
  };
}

export interface User {
  _id: string;
  userName: string;
  phone: string;
  imageLink: string;
}

export interface WashingService {
  _id: string;
  name: string;
  description: string[];
  duration: number;
  price: number;
  icon: Icon;
}

export interface Icon {
  _id: string;
  iconPath: string;
  iconLink: string;
}

export interface AddOn {
  _id: string;
  name: string;
  price: number;
  icon: Icon2;
}

export interface Icon2 {
  _id: string;
  iconPath: string;
  iconLink: string;
}

export interface Vehicle {
  _id: string;
  type: string;
  brand: string;
  model: string;
  plateNumber: string;
  color: string;
  imageLink?: string;
  imagePath?: string;
}

export interface Location {
  _id: string;
  latitude: number;
  longitude: number;
  streetName: string;
  subAdministrativeArea: string;
  city: any;
  area: {
    _id: string;
    name: {
      en: string;
      ar: string;
    };
  };
  isSaved: boolean;
}

export interface Biker {
  _id: string;
  userName: string;
  phone: string;
  imageLink: string;
  imagePath: string;
  rating: number;
  latitude?: number;
  longitude?: number;
}
