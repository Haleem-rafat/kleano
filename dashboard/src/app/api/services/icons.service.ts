import { EAPI } from '@constants/endpoints';
import { IAssignedOrdersList } from '@servicesTypes/assignOrder.types';

import { IIcons } from '@servicesTypes/static.types';
import api from '..';

class IconsService {
  public async getIcons() {
    const { data } = await api.get(EAPI.ICONS);
    return data;
  }

  public async addNewIcons(body): Promise<IAssignedOrdersList> {
    const { data } = await api.post(EAPI.ICONS, body);
    return data;
  }

  public async deleteIcons(id: string): Promise<IAssignedOrdersList> {
    const { data } = await api.delete(`${EAPI.ICONS}/${id}`);
    return data;
  }
}

export default Object.freeze(new IconsService());
