export interface IPromoCodeParams {
  status?: string;
  fromDate?: string;
  toDate?: string;
  page?: string;
  perPage?: string;
  segment?: string;
  city?: string;
  targetAudience?: string;
  isGraphView: boolean;
  business?: string;
  totalItems: number;
}

export interface IPromoCodeList {
  data: {
    dataList: {
      _id: string;
      code: string;
      numberOfUses: number;
      business?: string;
      discountPercentage: number;
      status: 'ACTIVE' | 'EXPIRED';
      targetAudience: 'allUsers' | 'segment' | 'newComers' | 'aggregator';
      createdAt: Date;
      expiryDate: Date;
      appliedCount: number;
    }[];
    paginationData: {
      page: number;
      perPage: number;
      totalItems: number;
      totalPages: number;
    };
  };
}
