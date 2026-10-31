import { EAPI } from '@constants/endpoints';
import api from '..';

class settingsService {
  public async getProfile() {
    const { data } = await api.get(EAPI.ADMIN_PROFILE);
    return data;
  }
  public async resetMpassword(body) {
    const { data } = await api.patch(EAPI.UPDATE_MY_PASSWORD, body);
    return data;
  }

  public async updateAdminPassword(body, id) {
    const { data } = await api.patch(EAPI.UPDATE_ADMIN_PASSWORD.replace(':id', id), body);
    return data;
  }

  public async updateBikerPassword(body, id) {
    const { data } = await api.patch(EAPI.UPDATE_BIKER_PASSWORD.replace(':id', id), body);
    return data;
  }
}

export default Object.freeze(new settingsService());
