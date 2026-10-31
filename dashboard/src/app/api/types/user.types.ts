export interface IRootUser {
  _id: string;
  serialNumber: number;
  userName: string;
  phone: string;
  email: string;
  fcmTokens: string[];
  createdAt: string;
  updatedAt: string;
  __v: number;
  isDeleted: boolean;
  location: Location;
  gender: string;
  points: number;
  walletBalance: number;
  language: string;
  imageLink: string;
  imagePath: string;
  isAllowNotification: boolean;
  rating: number;
  totalAddOnsPrice: number
  addOnsCount: number
  ordersCount: number
  totalOrdersPrice: number
  isSuspended: boolean
  vehicles: Vehicle[];
  orders: Order[];
  plans: IPlan[];
}

export interface Location {
  city: string;
  country: string;
  latitude: number;
  longitude: number;
  streetName: string;
  subAdministrativeArea: string;
}

export interface Vehicle {
  _id: string;
  brand: string;
  model: string;
  plateNumber: string;
  color: string;
  imageLink: string;
  imagePath: string;
}

export interface Order {
  _id: string;
  user: string;
  washingServices: WashingService[];
  addOns: string[];
  vehicle: Vehicle;
  location: Location;
  isAssigned: boolean;
  isScheduled: boolean;
  startTime: string;
  totalDuration: number;
  status: string;
  description?: string;
  type: string;
  paymentType: string;
  totalPrice: number;
  discount: number;
  totalPay: number;
  isPointsApplied: boolean;
  createdAt: string;
  updatedAt: string;
  __v: number;
}

export interface IPlan {
  _id: string;
  plan: Plan;
}

export interface Plan {
  _id: string;
  type: string;
  color: string;
  price: number;
  duration: number;
  durationUnit: string;
  usageCount: number;
  pointsToPay: number;
  washingServices: WashingService[];
  createdAt: string;
  updatedAt: string;
  __v: number;
}

export interface WashingService {
  _id: string;
  name: string;
  duration: number;
  price: number;
  icon: string;
}
