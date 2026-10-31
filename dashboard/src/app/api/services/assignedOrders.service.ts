import { EAPI } from '@constants/endpoints';
import { IAssignedOrdersList, IAssignedOrdersParams } from '@servicesTypes/assignOrder.types';

import api from '..';

class assignedOrdersServices {
  public async getAllAssingedOrders(params?: IAssignedOrdersParams): Promise<IAssignedOrdersList> {
    const { data } = await api.get(EAPI.ASSIGNED_ORDERS_lIST, { params });
    return data;
  }
}

export default Object.freeze(new assignedOrdersServices());
