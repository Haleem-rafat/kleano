export interface IwshaingServicesList {
  _id: string;
  name: string;
  description: string[];
  duration: number;
  durationUnit: string;
  price: number;
  pointsToPay: number;
  icon: Icon;
  createdAt: string;
  type: 'main' | 'extra';
  updatedAt: string;
  __v: number;
  cities: City[];
}

export interface Icon {
  _id: string;
  iconPath: string;
  iconLink: string;
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
