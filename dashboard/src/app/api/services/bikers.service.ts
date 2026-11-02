import { v } from '@app/utils/validation';
import { EAPI } from '@constants/endpoints';
import * as Yup from 'yup';
import { IBikerParams, IBikers } from '@servicesTypes/bikers.types';
import { EFormFieldType } from '@constants/enums';
import i18n from '@app/locales/i18n';
import api from '..';
import { IFormField } from '../api-types';

class bikersService {
  public async createBiker(body) {
    const { data } = await api.post(EAPI.BIKERS, body);
    return data;
  }
  public async editBiker(bikerId, body) {
    const { data } = await api.put(`${EAPI.BIKERS}/${bikerId}`, body);
    return data;
  }

  public async getAllBikers(params?: IBikerParams): Promise<{ data: IBikers[]; success: boolean }> {
    const { data } = await api.get(EAPI.BIKERS_LIST, { params });
    return data;
  }

  // get bikers by area id
  public async getBikersByAreaId(areaId: string): Promise<{ data: IBikers[]; success: boolean }> {
    const { data } = await api.get(`${EAPI.BIKERS_BY_AREA_ID.replace(':areaId', areaId)}`);
    return data;
  }

  public async getBikerById(bikerId: string) {
    const { data } = await api.get(`${EAPI.BIKERS}/${bikerId}`);
    return data;
  }

  public async suspendBiker(bikerId: string) {
    const { data } = await api.patch(`${EAPI.BIKERS}/${bikerId}/suspend`);
    return data;
  }

  public async restoreBiker(bikerId: string) {
    const { data } = await api.patch(`${EAPI.BIKERS}/${bikerId}/restore`);
    return data;
  }
  public async getBikersExportExcel() {
    const { data } = await api.get(EAPI.BIKER_EXCEL, { responseType: 'blob' });
    return data;
  }
  // admin/biker-schedules
  public async getBikerSchedules(bikerId: string) {
    const { data } = await api.get(`${EAPI.BIKER_SCHEDULES}/${bikerId}`);
    return data;
  }
  // admin/biker-schedules POST
  public async createBikerSchedule(body: any) {
    const { data } = await api.post(`${EAPI.BIKER_SCHEDULES}`, body);
    return data;
  }
  // admin/biker-schedules GET
  public async getBikerSchedule(bikerId: string) {
    const { data } = await api.get(`${EAPI.BIKER_SCHEDULE_DATA}/${bikerId}`);
    return data;
  }
  // admin/biker-schedules PATCH
  public async updateBikerSchedule(bikerId: string, body: any) {
    const { data } = await api.patch(`${EAPI.BIKER_SCHEDULE_DATA}/${bikerId}`, body);
    return data;
  }
  // admin/biker-schedules DELETE
  public async deleteBikerSchedule(bikerId: string) {
    const { data } = await api.delete(`${EAPI.BIKER_SCHEDULE_DATA}/${bikerId}`);
    return data;
  }
  // get biker total commission
  public async getBikerTotalCommission(bikerId: string) {
    const { data } = await api.get(`${EAPI.BIKER_TOTAL_COMMISSION.replace(':bikerId', bikerId)}`);
    return data;
  }

  public async getAreaId(latitude: number, longitude: number) {
    const { data } = await api.get(`${EAPI.MAP_AREAS}?latitude=${latitude}&longitude=${longitude}`);
    return data;
  }

  /* API SCHEMAS */

  baseBikerSchema = {
    image: Yup.mixed(),
    userName: v.text(60),
    phone: v.phone(),
    nationalId: v.digits(),
    commissionType: v.choice(),
    commission: Yup.number()
      .transform((val, orig) => (orig === '' ? undefined : val))
      .typeError('validation.number')
      .required('validation.required')
      .when('commissionType', {
        is: 'PERCENTAGE',
        then: (schema) => schema.min(0, 'validation.min0').max(100, 'validation.percent'),
        otherwise: (schema) => schema.min(0, 'validation.min0'),
      }),
    ordersBeforeCommission: v.count(),
    minimumCommission: v.optionalNumber(),
    weekendCommission: v.optionalNumber(),
  };

  public addBikerSchema = Yup.object({
    ...this.baseBikerSchema,
    password: v.password(),
  });

  public editBikerSchema = Yup.object(this.baseBikerSchema);

  /* API FIELDS */
  baseBikerFormFields: IFormField[] = [
    {
      name: 'image',
      title: i18n.t('uploadBikerImage'),
      placeholder: i18n.t('uploadBikerImage'),
      type: EFormFieldType.IMG_UPLOAD,
    },
    {
      name: 'userName',
      title: i18n.t('bikerName'),
      placeholder: i18n.t('bikerName'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'nationalId',
      title: i18n.t('nationalId'),
      placeholder: i18n.t('nationalId'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'phone',
      title: i18n.t('phone'),
      placeholder: i18n.t('phone'),
      type: EFormFieldType.PHONE_NUMBER,
    },
    {
      name: 'commissionType',
      title: i18n.t('commissionType'),
      placeholder: i18n.t('Select commission type'),
      type: EFormFieldType.SELECT,
      options: [
        { label: i18n.t('PERCENTAGE'), value: 'PERCENTAGE' },
        { label: i18n.t('FIXED'), value: 'FIXED' },
      ],
    },
    {
      name: 'commission',
      title: i18n.t('commission'),
      placeholder: i18n.t('Enter commission'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'ordersBeforeCommission',
      title: i18n.t('ordersBeforeCommission'),
      placeholder: i18n.t('Enter orders before commission'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'minimumCommission',
      title: i18n.t('Minimum Commission'),
      placeholder: i18n.t('Enter minimum commission'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'weekendCommission',
      title: i18n.t('weekendCommission'),
      placeholder: i18n.t('Enter weekend commission'),
      type: EFormFieldType.NUMBER,
    },
  ];

  // Add the password field only for the add form
  addBikerFormFields: IFormField[] = [
    ...this.baseBikerFormFields,
    {
      name: 'password',
      title: i18n.t('password'),
      placeholder: i18n.t('password'),
      type: EFormFieldType.TEXT,
    },
  ];

  // For edit form, simply use the base fields without the password
  editBikerFormFields: IFormField[] = [...this.baseBikerFormFields];
}
export default Object.freeze(new bikersService());
