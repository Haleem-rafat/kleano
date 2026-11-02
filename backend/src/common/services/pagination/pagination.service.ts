import { Injectable } from '@nestjs/common';

@Injectable()
export class PaginationService {
  constructor() {
    /* TODO document why this constructor is empty */
  }

  getSkipAndLimit(page: number, perPage: number) {
    const skip = (page - 1) * perPage;
    const limit = perPage;
    return { skip: Number(skip), limit: Number(limit) };
  }

  paginate(dataList: any[], count: number, page: number, perPage: number) {
    const paginationData = {
      page: Number(page),
      perPage: Number(perPage),
      totalItems: count,
      totalPages: Math.ceil(count / Number(perPage)),
    };

    return { dataList, paginationData };
  }
}
