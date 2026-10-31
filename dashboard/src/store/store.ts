import { configureStore } from '@reduxjs/toolkit';
import authReducer from '@store/slices/auth.slice';
import hasDataReducer from '@store/slices/hasData.slice';

const store = configureStore({
  reducer: {
    auth: authReducer,
    hasData: hasDataReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
