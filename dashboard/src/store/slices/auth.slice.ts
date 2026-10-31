import { getLocalStorageItem } from '@app/utils/local-storage';
import { ELocalStorageKeys } from '@constants/keys';
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import authService from '@services/auth.service';
import { RootState } from '@store/store';

// Define initial values
const initialUser = {
  lang: '',
  _id: '',
  userName: '',
  isSuperAdmin: '',
  status: '',
  isDeleted: '',
  suspendReason: '',
  city: [],
  createdAt: '',
  updatedAt: '',
  __v: 0,
  access_token: '',
  refresh_token: '',
};

// Load initial values from local storage
const user = getLocalStorageItem(ELocalStorageKeys.USER);

const initialState: any = user
  ? {
      ...initialUser,
      ...user,
    }
  : initialUser;

const authSlice = createSlice({
  initialState,
  name: 'auth',
  reducers: {
    login(state, action: PayloadAction<any>) {
      localStorage.setItem(ELocalStorageKeys.USER, JSON.stringify(action.payload));
      return { ...state, ...action.payload };
    },

    logout(state) {
      authService.logout();
      state = { ...initialUser };
      return state;
    },
  },
});

// Selectors
export const selectAuth = (state: RootState) => state.auth;

// Actions
export const { logout: logoutAction, login: loginAction } = authSlice.actions;

export default authSlice.reducer;
