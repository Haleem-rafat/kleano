import { EAPI } from '@constants/endpoints';
import api from './api';

class UsersService {
  // static service Service API
  public async getUsersList() {
    const { data } = await api.get(EAPI.USERS);
    return data;
  }

  public async paginatedUsers(params: {
    page: number;
    search?: string;
    perPage?: number;
    status?: 'SUSPENDED' | 'ACTIVE';
  }) {
    const { data } = await api.get(EAPI.SUSPEND_USER, { params });
    return data;
  }

  public async getUsersDetails(userId: string) {
    const { data } = await api.get(`${EAPI.USERS}/${userId}`);
    return data;
  }

  public async getUsersExportExcel() {
    const { data } = await api.get(EAPI.USERS_EXPORT_EXCEL, { responseType: 'blob' });
    return data;
  }
  public async toggleUserStatus(userId: string, status: 'suspend' | 'unsuspend') {
    const { data } = await api.post(`${EAPI.SUSPEND_USER}/${userId}/${status}`);
    return data;
  }
  public async addUserBalance(userId: string, payload: { amount: number; notes?: string }) {
    const { data } = await api.post(EAPI.USERS_ADD_BALANCE.replace(':userId', userId), payload);
    return data;
  }
}
export default Object.freeze(new UsersService());
