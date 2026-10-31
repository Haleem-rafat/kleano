import { EAPI } from '@constants/endpoints';
import i18n from '@app/locales/i18n';

import { EFormFieldType } from '@constants/enums';
import api from '..';
import { IFormField } from '../api-types';

class plansService {
  public async getAllPlansList() {
    const { data } = await api.get(EAPI.PLANS_LIST);
    return data;
  }
  public async getAllPlansDetails(planId) {
    const { data } = await api.get(`${EAPI.PLANS_LIST_DETAILS}/${planId}`);
    return data;
  }

  public async createPlan(body) {
    const { data } = await api.post(EAPI.PLANS, body);
    return data;
  }

  public async editPlan(planId, body) {
    const { data } = await api.put(`${EAPI.PLANS}/${planId}`, body);
    return data;
  }

  public async addCityPlan(body) {
    const { data } = await api.post(EAPI.PLANS_LIST_CITY, body);
    return data;
  }

  public async activeCityPlan(body) {
    const { data } = await api.put(EAPI.PLANS_LIST_CITY_ACTIVATE, body);
    return data;
  }
  public async archiveCityPlan(body) {
    const { data } = await api.put(EAPI.PLANS_LIST_CITY_ARCHIVE, body);
    return data;
  }

  /* API FIELDS */
  basePlansFormFields: IFormField[] = [
    {
      name: 'type',
      title: i18n.t('planType'),
      placeholder: i18n.t('planType'),
      type: EFormFieldType.TEXT,
    }, {
      name: 'description',
      title: i18n.t('description'),
      placeholder: i18n.t('description'),
      type: EFormFieldType.DESCRIPTIONS,
    },
    {
      name: 'color',
      title: i18n.t('color'),
      placeholder: i18n.t('color'),
      type: EFormFieldType.COLOR_PICKER,
    }, 
    {
      name: 'icon',
      title: i18n.t('icon'),
      placeholder: i18n.t('icon'),
      type: EFormFieldType.SELECT,
    },
    {
      name: 'price',
      title: i18n.t('price'),
      placeholder: i18n.t('price'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'duration',
      title: i18n.t('durationByMonth'),
      placeholder: i18n.t('durationByMonth'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'usageCount',
      title: i18n.t('usageCount'),
      placeholder: i18n.t('usageCount'),
      type: EFormFieldType.NUMBER,
    },
    // {
    //   name: 'pointsToPay',
    //   title: i18n.t('pointsToPay'),
    //   placeholder: i18n.t('pointsToPay'),
    //   type: EFormFieldType.NUMBER,
    // },
    {
      name: 'washingServices',
      title: i18n.t('washingServices'),
      placeholder: i18n.t('washingServices'),
      type: EFormFieldType.MULTI_SELECT,
    },
  ];

  public editPlansFormFields: IFormField[] = [...this.basePlansFormFields];

  public addPlansFormFields: IFormField[] = [
    ...this.basePlansFormFields,
    {
      name: 'cities',
      title: i18n.t('city'),
      placeholder: i18n.t('city'),
      type: EFormFieldType.MULTI_SELECT,
    },
  ];
}
export default Object.freeze(new plansService());
