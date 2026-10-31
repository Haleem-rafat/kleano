import { EAPI } from '@constants/endpoints';
import { IRootTransactionsList } from '@servicesTypes/order.types';
import api from '..';

class TransactionsService {

  public async getAllTransactions(params): Promise<IRootTransactionsList> {
    const { data } = await api.get(EAPI.TRANSACTIONS_LIST, { params });
    return data;
  }

  public async getTransactionDetails(transactionId): Promise<IRootTransactionsList> {
    const { data } = await api.get(`${EAPI.TRANSACTIONS_DETAILS}/${transactionId}`);
    return data;
  }
}

export default Object.freeze(new TransactionsService());
