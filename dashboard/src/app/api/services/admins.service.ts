import { EAPI } from '@constants/endpoints';
import i18n from '@app/locales/i18n';
import { EFormFieldType } from '@constants/enums';

import { IAdmin, IAdminParams, IAdminsList } from '@servicesTypes/admins.types';
import api from '..';
import { IFormField } from '../api-types';
class adminsServices {
  public async getAllAdmins(params?: IAdminParams): Promise<IAdminsList> {
    const { data } = await api.get(EAPI.ADMIN_LIST, {
      params,
    });
    return data;
  }
  public async getAdminDetails(adminId): Promise<{
    success: boolean;
    data: IAdmin;
  }> {
    const { data } = await api.get(`${EAPI.ADMIN_DETAILS.replace(':id', adminId)}`);
    return data;
  }

  public async editAdmin(id: string, payload: any): Promise<IAdminsList> {
    const { data } = await api.patch(EAPI.ADMIN_EDIT.replace(':id', id), payload);
    return data;
  }

  public async createAdmin(payload: any): Promise<IAdminsList> {
    const { data } = await api.post(EAPI.ADMIN_CREATE, payload);
    return data;
  }

  public async deleteAdmin(id: string): Promise<IAdminsList> {
    const { data } = await api.delete(EAPI.ADMIN_DELETE.replace(':id', id));
    return data;
  }

  public async toggleAdminStatus(
    id: string,
    status: 'suspend' | 'restore',
    reason?: string
  ): Promise<IAdminsList> {
    const { data } = await api.patch(`${EAPI.ADMIN_TOGGLE.replace(':id', id)}/${status}`, {
      reason,
    });
    return data;
  }

  baseAdminFormFields: IFormField[] = [
    {
      name: 'phone',
      title: i18n.t('phone'),
      placeholder: i18n.t('phone'),
      type: EFormFieldType.PHONE_NUMBER,
    },
    {
      name: 'nationalId',
      title: i18n.t('nationalId'),
      placeholder: i18n.t('nationalId'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'city',
      title: i18n.t('city'),
      placeholder: i18n.t('city'),
      type: EFormFieldType.MULTI_SELECT,
    },
  ];
  adminFormFields: IFormField[] = [
    {
      name: 'userName',
      title: i18n.t('name'),
      placeholder: i18n.t('name'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'password',
      title: i18n.t('password'),
      placeholder: i18n.t('password'),
      type: EFormFieldType.PASSWORD,
    },
    {
      name: 'phone',
      title: i18n.t('phone'),
      placeholder: i18n.t('phone'),
      type: EFormFieldType.PHONE_NUMBER,
    },
    {
      name: 'nationalId',
      title: i18n.t('nationalId'),
      placeholder: i18n.t('nationalId'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'city',
      title: i18n.t('city'),
      placeholder: i18n.t('city'),
      type: EFormFieldType.MULTI_SELECT,
    },
  ];
}
export default Object.freeze(new adminsServices());
