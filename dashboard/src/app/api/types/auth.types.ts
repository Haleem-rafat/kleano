export interface ILoginData {
  lang: string;
  _id: string;
  userName: string;
  isSuperAdmin: boolean;
  status: string;
  isDeleted: boolean;
  suspendReason: string;
  city: any[];
  createdAt: string;
  updatedAt: string;
  __v: number;
  access_token: string;
  refresh_token: string;
  iat: number;
  exp: number;
}

export interface LocalizedMessage {
  en: string;
  ar: string;
}
