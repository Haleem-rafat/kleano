import { EAPI } from '@constants/endpoints';
import api from './api';

class StaticService {
  // static service Service API
  public async getCitiesOptions() {
    const { data } = await api.get(EAPI.CITIES);
    return data;
  }

  public async getAreasOptions(citieId) {
    const { data } = await api.get(`${EAPI.AREAS}/${citieId}`);
    return data;
  }

  public async getUsersOptions() {
    const { data } = await api.get(EAPI.USERS);
    return data;
  }

  public async getRevenueMonth() {
    const { data } = await api.get(EAPI.REVENUE_PER_MONTH);
    return data;
  }

  public async getRevenueWeek() {
    const { data } = await api.get(EAPI.REVENUE_PER_WEEK);
    return data;
  }
  // get all promo code un paginated
  public async getAllPromoCode() {
    const { data } = await api.get(EAPI.PROMO_CODE_ALL);
    return data;
  }
  // get all plans un paginated
  public async getAllPlans() {
    const { data } = await api.get(EAPI.PLANS_ALL);
    return data;
  }
}
export default Object.freeze(new StaticService());
