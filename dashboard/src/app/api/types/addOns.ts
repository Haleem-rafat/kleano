export interface IRootAddOns {
  success: boolean;
  data: IAddOns[] | IAddOns;
}

export interface IAddOns {
  _id: string;
  name: string;
  price: number;
  icon: Icon;
  stock: number;
  createdAt: string;
  updatedAt: string;
  __v: number;
  cities: any[];
}

export interface Icon {
  _id: string;
  iconPath: string;
  iconLink: string;
}
