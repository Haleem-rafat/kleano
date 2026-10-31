export interface IAdmin {
  _id: string;
  userName: string;
  phone: string;
  isSuperAdmin: boolean;
  status: 'SUSPENDED' | 'ACTIVE';
  isDeleted: boolean;
  suspendReason: string;
  nationalId: string;
  city: City[];
  createdAt: Date;
  updatedAt: Date;

  lang: 'ar' | 'en';
}

export interface City {
  name: Name;
  _id: string;
}
export interface IAdminsList {
  data: IAdmin[];
  page: number;
  perPage: number;
  success: boolean;
  totalItems: number;
  totalPages: number;
}
export interface IAdminParams {
  status?: 'SUSPENDED' | 'ACTIVE' | undefined;
  page: number;
  perPage: number;
  search: string
}

export interface Name {
  ar: string;
  en: string;
}
