import { EAPI } from '@constants/endpoints';
import i18n from '@app/locales/i18n';
import { EFormFieldType } from '@constants/enums';
import * as Yup from 'yup';
import { IFormField } from '../api-types';
import api from './api';

class addOnsService {
  public async getAllAddOnsList() {
    const { data } = await api.get(EAPI.ADD_ONS_LIST);
    return data;
  }

  public async getAddOnsDetails(addOnsId) {
    const { data } = await api.get(`${EAPI.ADD_ONS_DETAILS}/${addOnsId}`);
    return data;
  }
  public async creatAddOns(body) {
    const { data } = await api.post(EAPI.ADD_ONS, body);
    return data;
  }
  public async editAddOns(addOnsId, body) {
    const { data } = await api.put(`${EAPI.ADD_ONS}/${addOnsId}`, body);
    return data;
  }

  public async addCityPlan(body) {
    const { data } = await api.post(EAPI.ADD_ONS_CITY, body);
    return data;
  }

  public async activeCityPlan(body) {
    const { data } = await api.put(EAPI.ADD_ONS_CITY_ACTIVATE, body);
    return data;
  }
  public async archiveCityPlan(body) {
    const { data } = await api.put(EAPI.ADD_ONS_CITY_ARCHIVE, body);
    return data;
  }
  /* API SCHEMAS */

  baseAddOnsSchema = {
    name: Yup.object().shape({
      en: Yup.string().required('Required').trim(),
      ar: Yup.string().required('Required').trim(),
    }).required('Required'),
    price: Yup.string().required('Required').trim(),
    icon: Yup.mixed().required('Required'),
    stock: Yup.number().required('Required'),
  };

  public editAddOnsSchemas = Yup.object(this.baseAddOnsSchema);
  public addAddOnsSchemas = Yup.object({ ...this.baseAddOnsSchema, cities: Yup.array().min(1, 'at least one').required('required') });


  /* API FIELDS */
  baseAddOnsFormFields: IFormField[] = [
    {
      name: 'name',
      title: i18n.t('addOnsName'),
      placeholder: i18n.t('addOnsName'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'price',
      title: i18n.t('price'),
      placeholder: i18n.t('price'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'icon',
      title: i18n.t('icon'),
      placeholder: i18n.t('icon'),
      type: EFormFieldType.SELECT,
    },
    {
      name: 'stock',
      title: i18n.t('stock'),
      placeholder: i18n.t('stock'),
      type: EFormFieldType.NUMBER,
    },
  ];

  public editAddOnsFormFields: IFormField[] = [...this.baseAddOnsFormFields];

  public addAddOnsFormFields: IFormField[] = [
    ...this.baseAddOnsFormFields,
    {
      name: 'cities',
      title: i18n.t('city'),
      placeholder: i18n.t('city'),
      type: EFormFieldType.MULTI_SELECT,
    },
  ];
}
export default Object.freeze(new addOnsService());
