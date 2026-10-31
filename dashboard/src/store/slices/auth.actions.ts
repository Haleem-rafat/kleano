import store from '../store';
import { logoutAction } from './auth.slice';

export const logout = (): void => {
  store.dispatch(logoutAction());
};
