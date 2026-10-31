import { EAPI } from '@constants/endpoints';
import * as Yup from 'yup';
import { EFormFieldType } from '@constants/enums';
import i18n from '@app/locales/i18n';
import { IFormField } from '../api-types';
import api from './api';

class WashingServices {
  // WashingServices Service API
  public async getWashingServicesList() {
    const { data } = await api.get(EAPI.WASHING_SERVICE_LIST);
    return data;
  }

  public async getWashingServicesDetails(washingServicesId) {
    const { data } = await api.get(`${EAPI.WASHING_SERVICE_DETAILS}/${washingServicesId}`);
    return data;
  }

  public async addWashingServices(body) {
    const { data } = await api.post(EAPI.WASHING_SERVICE, body);
    return data;
  }

  public async editWashingServices(washingServicesId, body) {
    const { data } = await api.put(`${EAPI.WASHING_SERVICE}/${washingServicesId}`, body);
    return data;
  }

  public async addCityWashingServices(body) {
    const { data } = await api.post(EAPI.WASHING_SERVICE_CITY, body);
    return data;
  }

  public async activeCityWashingServices(body) {
    const { data } = await api.put(EAPI.WASHING_SERVICE_CITY_ACTIVATE, body);
    return data;
  }
  public async archiveCityWashingServices(body) {
    const { data } = await api.put(EAPI.WASHING_SERVICE_CITY_ARCHIVE, body);
    return data;
  }

  /* API SCHEMAS */
  public WashingServicesFormSchema = Yup.object().shape({
    servicesName: Yup.object().shape({
      en: Yup.string().required('Required').trim(),
      ar: Yup.string().required('Required').trim(),
    }).required('Required'),
    duration: Yup.string().required('Required'),
    price: Yup.string().required('Required').trim(),
    pointsToPay: Yup.string().required('Required').trim(),
    type: Yup.object().required('Required'),
    icon: Yup.mixed().required('Required'),
    city: Yup.array().required('Required'),
    description: Yup.array()
      .of(
        Yup.object().shape({
          en: Yup.string(),
          ar: Yup.string(),
        })
      )
      .required('Required'),
  });

  /* API FIELDS */
  public WashingServicesFormFields: IFormField[] = [
    {
      name: 'servicesName',
      title: i18n.t('servesName'),
      placeholder: i18n.t('servesName'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'duration',
      title: i18n.t('durationTime'),
      placeholder: i18n.t('durationTime'),
      type: EFormFieldType.NUMBER,
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
      type: EFormFieldType.MULTI_SELECT,
    },
    {
      name: 'type',
      title: i18n.t('type'),
      placeholder: i18n.t('type'),
      type: EFormFieldType.SELECT,
    },
    {
      name: 'city',
      title: i18n.t('city'),
      placeholder: i18n.t('city'),
      type: EFormFieldType.MULTI_SELECT,
    },
    {
      name: 'description',
      title: i18n.t('description'),
      placeholder: i18n.t('description'),
      type: EFormFieldType.DESCRIPTIONS,
    },
  ];
}
export default Object.freeze(new WashingServices());
