export interface IBikers {
  selectedPoints: any[];
  _id: string;
  userName: string;
  phone: string;
  city?: City;
  areas?: Areas[];
  nationalId: string;
  status: 'ONLINE' | 'OFFLINE' | 'SUSPENDED' | 'ACTIVE';
  imageLink: string;
  streetName?: string;
  rating?: number;
  totalDeliveries: number;
  totalTimeWorked: number;
  averageTimePerDelivery: number;
  createdBy?: CreatedBy;
  createdAt: string;
  commissionType?: 'PERCENTAGE' | 'FIXED';
  commission?: number;
  ordersBeforeCommission?: number;
  weekendCommission?: number;
  minimumCommission?: number;
}

export interface City {
  _id: string;
  name: Name;
}
export interface Areas {
  _id: string;
  name: Name;
}

export interface Name {
  ar: string;
  en: string;
}

export interface CreatedBy {
  _id: string;
  userName: string;
}

export interface IBikerParams {
  fromDate?: string;
  toDate?: string;
  search?: string;
}
