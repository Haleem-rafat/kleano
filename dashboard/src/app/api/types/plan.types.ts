export interface IRootPlan {
  success: boolean;
  data: IPlan | IPlan[];
}

export interface IPlan {
  _id: string;
  type: string;
  color: string;
  icon: {
    _id: string,
    iconPath: string,
    iconLink: string
  };
  description: string[];
  price: number;
  duration: number;
  durationUnit: string;
  usageCount: number;
  pointsToPay: number;
  washingServices: WashingService[];
  createdAt: string;
  updatedAt: string;
  __v: number;
  cities: City[];
}

export interface WashingService {
  icon?: { iconLink: string };
  _id: string;
  name: string;
}

export interface City {
  city: City2;
  isArchived: boolean;
  createdAt: string;
  updatedAt: string;
  __v: number;
}

export interface City2 {
  _id: string;
  name: Name;
  latitude: number;
  longitude: number;
  isExist: boolean;
  __v: number;
}

export interface Name {
  ar: string;
  en: string;
}
