import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import store from '@/store/store';
export { default as useMediaQuery } from './useMediaQuery';

export type AppDispatch = typeof store.dispatch;
export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
