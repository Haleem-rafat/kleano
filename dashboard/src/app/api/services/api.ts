import { ELocalStorageKeys } from '@constants/keys';
import axios, { AxiosError, AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { ROUTES } from '@constants/routes';
import router from '@app/router';
import authService from './auth.service';

interface AxiosRequestConfigWithRetry extends AxiosRequestConfig {
  _retry?: number;
}

const getLocalAccessToken = (): string | null =>
  localStorage.getItem(ELocalStorageKeys.ACCESS_TOKEN);

const instance: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE,
  headers: {
    Authorization: `Bearer ${getLocalAccessToken()}`,
    // 'x-api-version': '1',
    // 'Content-Type': 'application/json',
  },
});

instance.interceptors.request.use(
  async (config) => {
    const token = await authService.getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    } else router.navigate(ROUTES.LOG_IN);

    return config;
  },
  (error) => {
    authService.logout();
    throw error;
  }
);

const responseInterceptor = instance.interceptors.response.use(
  (res: AxiosResponse) => res,

  async (error: AxiosError) => {
    const originalConfig = error.config as AxiosRequestConfigWithRetry | undefined;

    if (error.response && error.response.status === 403) {
      // Handle 403 error, for example, navigate to a Forbidden component or route this will remove when backend handle the request status to be 401
      if ((error.response.data as { message: { en: string } }).message.en === 'Not Authenticated') {
        authService.logout();
      } else {
        router.navigate(ROUTES.FORBIDDEN);
      }
      return Promise.reject(error);
    }

    if (
      error.response &&
      (error.response.status === 401 || error.response.status === 403) &&
      originalConfig &&
      (originalConfig?._retry ?? 0) < 3
    ) {
      originalConfig._retry = (originalConfig._retry ?? 0) + 1;
      if (error.response.status === 401) authService.logout();

      try {
        const newToken = await authService.refreshToken();

        // Add the new token to the Authorization header
        instance.defaults.headers.common['Authorization'] = `Bearer ${newToken}`;
        axios.interceptors.response.eject(responseInterceptor);

        if (newToken) return instance(originalConfig);
        else throw router.navigate(ROUTES.LOG_IN);
      } catch (_err) {
        return Promise.reject(_err);
      }
    }

    throw error;
  }
);

export default instance;
