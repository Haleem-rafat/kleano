import { EAPI } from '@constants/endpoints';
import { IRootOrder } from '@servicesTypes/order.types';
import api from '..';

class OrdersService {
  public async getAllOrders(params): Promise<IRootOrder> {
    const { data } = await api.get(EAPI.ORDERS_LIST, { params });
    return data;
  }

  public async getOrdersDetails(orderId): Promise<IRootOrder> {
    const { data } = await api.get(`${EAPI.ORDER_DETAILS}/${orderId}`);
    return data;
  }

  public async assignBikerOrder(orderId, body): Promise<IRootOrder> {
    const { data } = await api.patch(`${EAPI.ORDER}/${orderId}/assign-biker`, body);
    return data;
  }

  public async getOrderExportExcel() {
    const { data } = await api.get(EAPI.ORDER_EXPORT_EXCEL, { responseType: 'blob' });
    return data;
  }

  public async cancelOrderByAdmin(body: {
    totalAmount: number;
    order: string;
    cancellationReason: string;
  }): Promise<IRootOrder> {
    const { data } = await api.patch(`${EAPI.ORDER_CANCEL_BY_ADMIN}`, body);

    return data;
  }
}

export default Object.freeze(new OrdersService());
