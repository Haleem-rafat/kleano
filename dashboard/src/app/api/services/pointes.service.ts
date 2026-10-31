import i18n from '@app/locales/i18n';
import { EAPI } from '@constants/endpoints';
import { EFormFieldType } from '@constants/enums';
import api from '..';
import { IFormField } from '../api-types';

class pointesService {
  public async getAllpoints() {
    const { data } = await api.get(EAPI.POINTS_LIST);
    return data;
  }
  public async updatePoints(body) {
    const { data } = await api.put(EAPI.POINTS, body);
    return data;
  }

  /* API FIELDS */
  public pointsFormFields: IFormField[] = [
    {
      name: 'totalPayPercentage',
      title: i18n.t('totalPayPercentage'),
      placeholder: i18n.t('totalPayPercentage'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'exchangePercentage',
      title: i18n.t('exchangePercentage'),
      placeholder: i18n.t('exchangePercentage'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'redeemLimit',
      title: i18n.t('redeemLimit'),
      placeholder: i18n.t('redeemLimit'),
      type: EFormFieldType.NUMBER,
    },
  ];
}
export default Object.freeze(new pointesService());
