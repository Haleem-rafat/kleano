import { EAPI } from '@constants/endpoints';
import { ELocalStorageKeys } from '@constants/keys';
import axios from 'axios';
import jwt_decode from 'jwt-decode';
import * as Yup from 'yup';

import { ILoginData } from '@servicesTypes/auth.types';
import { IFormField } from '../api-types';

let accessToken = localStorage.getItem(ELocalStorageKeys.ACCESS_TOKEN) ?? '';
let refreshToken = localStorage.getItem(ELocalStorageKeys.REFRESH_TOKEN) ?? '';

type TTokensObject = {
  newAccessToken: string;
  newRefreshToken: string;
};
class AuthService {
  private _guestAxios = axios.create({
    baseURL: import.meta.env.VITE_API_BASE,
  });
  private _decodeToken(token: string): ILoginData | null {
    try {
      const decoded = jwt_decode<ILoginData>(token);
      return decoded;
    } catch (e) {
      return null;
    }
  }

  /** SETTERS */
  async setToken({ newAccessToken, newRefreshToken }: TTokensObject) {
    if (!newAccessToken) localStorage.removeItem(ELocalStorageKeys.ACCESS_TOKEN);
    if (!newRefreshToken) localStorage.removeItem(ELocalStorageKeys.REFRESH_TOKEN);

    accessToken = newAccessToken;
    refreshToken = newRefreshToken;

    localStorage.setItem(ELocalStorageKeys.ACCESS_TOKEN, newAccessToken);
    localStorage.setItem(ELocalStorageKeys.REFRESH_TOKEN, newRefreshToken);
  }

  /** GETTERS */
  async getDecodedToken(): Promise<ILoginData | null> {
    const token = await this.getToken();
    if (!token) return null;
    return this._decodeToken(token);
  }

  async getToken(): Promise<string | null> {
    if (!this.hasExpired()) return accessToken; // will return null if not existed
    return await this.refreshToken();
  }

  async isLoggedIn(): Promise<boolean> {
    const token = await this.getToken();
    return !!token;
  }

  hasExpired(): boolean {
    if (!accessToken) return false;
    const decodedToken = jwt_decode<ILoginData>(accessToken);

    if (!decodedToken?.exp) return true;

    return decodedToken.exp * 1000 <= Date.now();
  }

  /* API ENDPOINTS */
  public async login(obj: { email: string; password: string }): Promise<ILoginData> {
    const { data } = await this._guestAxios.post(EAPI.LOGIN, obj);
    const loginData = data?.data as ILoginData;

    this.setToken({
      newAccessToken: loginData.access_token,
      newRefreshToken: loginData.refresh_token,
    });

    return loginData;
  }

  /* METHODS */
  public logout(): void {
    this.setToken({ newAccessToken: '', newRefreshToken: '' });
    localStorage.removeItem(ELocalStorageKeys.USER);
    localStorage.removeItem(ELocalStorageKeys.PERMISSIONS);
  }

  async refreshToken(): Promise<string | null> {
    if (!this.hasExpired()) return refreshToken;

    try {
      const loginData = await this._guestAxios
        .post(EAPI.REFRESH_TOKEN, {
          refresh_token: refreshToken,
        })
        .then(({ data }) => data?.data as ILoginData);

      this.setToken({
        newAccessToken: loginData.access_token,
        newRefreshToken: loginData.refresh_token,
      });

      return loginData.access_token;
    } catch (e) {
      this.logout();
      return null;
    }
  }

  /* API SCHEMAS */
  public loginSchema = Yup.object().shape({
    userName: Yup.string().trim().required('userName cannot be empty'),
    password: Yup.string().trim().required('Password is required'),
  });

  /* API FIELDS */
  public loginFormFields: IFormField[] = [
    {
      name: 'userName',
      title: 'Enter User Name',
      placeholder: 'Enter User Name',
    },
    {
      name: 'password',
      title: 'Password',
      placeholder: 'Enter your password',
      type: 'password',
    },
  ];
}

export default Object.freeze(new AuthService());
