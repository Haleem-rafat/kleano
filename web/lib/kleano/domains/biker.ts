'use client';

import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from '../client';
import type { LocalizedText, Order, Paged, Wrapped } from '../types';

/** Same endpoints as HomeRepo, OrderRepo, ProfileRepo and AuthRepo in the biker app. */

export type BikerOrder = Order & { user?: { _id?: string; userName?: string; phone?: string; imageLink?: string }; ratingOfUser?: number };
export type BikerProfile = {
  _id: string;
  userName?: string;
  phone?: string;
  status?: 'ACTIVE' | 'ONLINE' | 'OFFLINE' | 'SUSPENDED';
  imageLink?: string;
  rating?: number;
  totalWashes?: number;
  nationalId?: string;
  city?: { name?: LocalizedText } | string;
};
export type CommissionPeriod = { totalCommission?: number; ordersCount?: number };
export type Commission = { today?: CommissionPeriod; allTime?: CommissionPeriod; allWeekends?: CommissionPeriod };
export type Shift = { timeSlot?: string; day?: string; city?: { name?: LocalizedText }; area?: { name?: LocalizedText }; priorityLevel?: number };
export type BikerSchedule = { shifts?: Shift[]; weekends?: string[] };
export type BikerList = 'ACTIVE' | 'COMPLETED';
export type Position = { latitude: string; longitude: string; streetName: string };

const withPhoto = (order: string, photo?: Blob | null) => {
  if (!photo) return { json: { order } };
  const form = new FormData();
  form.append('order', order);
  form.append('image', photo, 'wash.jpg');
  return { form };
};

export const bikerApi = {
  profile: () => kleano<Wrapped<BikerProfile>>('/bikers').then((r) => r.data),
  setStatus: (status: 'ONLINE' | 'OFFLINE') => kleano('/bikers/update-status', { method: 'PATCH', json: { status } }),
  update: (userName: string, image?: Blob | null) => {
    const form = new FormData();
    form.append('userName', userName);
    if (image) form.append('image', image, 'profile.jpg');
    return kleano('/bikers/update-info', { method: 'PUT', form });
  },
  password: (oldPassword: string, newPassword: string) => kleano('/bikers/update-credentials', { method: 'PATCH', json: { oldPassword, newPassword } }),
  language: (language: 'ar' | 'en') => kleano('/bikers/update-language', { method: 'PATCH', json: { language } }),
  orders: (status: BikerList, page: number) => kleano<Paged<BikerOrder>>(`/orders/biker?status=${status}&page=${page}&perPage=10`),
  order: (id: string) => kleano<Wrapped<BikerOrder>>(`/orders/user/order-details/${id}`).then((r) => r.data),
  accept: (order: string, at: Position) => kleano('/orders/biker/accept-order', { method: 'PATCH', json: { order, ...at } }),
  onTheWay: (order: string) => kleano('/orders/biker/on-the-way', { method: 'PATCH', json: { order } }),
  arrived: (order: string) => kleano('/orders/biker/arrived', { method: 'PATCH', json: { order } }),
  washing: (order: string, photo?: Blob | null) => kleano('/orders/biker/on-washing', { method: 'PATCH', ...withPhoto(order, photo) }),
  complete: (order: string, photo?: Blob | null) => kleano('/orders/biker/completed', { method: 'PATCH', ...withPhoto(order, photo) }),
  rate: (order: string, starsNum: number) => kleano('/orders/biker/rate-order', { method: 'PATCH', json: { order, starsNum } }),
  totalWashes: () => kleano<Wrapped<number>>('/orders/biker/total-orders?status=COMPLETED').then((r) => r.data ?? 0),
  commission: () => kleano<Wrapped<Commission>>('/orders/biker/total-commission').then((r) => r.data),
  schedule: () => kleano<Wrapped<BikerSchedule>>('/biker/schedule').then((r) => r.data),
};

export const useBikerProfile = () => useQuery({ queryKey: ['biker-profile'], queryFn: bikerApi.profile });
export const useCommission = () => useQuery({ queryKey: ['biker-commission'], queryFn: bikerApi.commission });
export const useTotalWashes = () => useQuery({ queryKey: ['biker-washes'], queryFn: bikerApi.totalWashes });
export const useSchedule = () => useQuery({ queryKey: ['biker-schedule'], queryFn: bikerApi.schedule });
export const useBikerOrder = (id: string) => useQuery({ queryKey: ['biker-order', id], queryFn: () => bikerApi.order(id) });

export const useBikerOrders = (list: BikerList, enabled = true) =>
  useInfiniteQuery({
    queryKey: ['biker-orders', list],
    initialPageParam: 1,
    enabled,
    queryFn: ({ pageParam }) => bikerApi.orders(list, pageParam),
    getNextPageParam: (last, pages) => (pages.length < (last.totalPages ?? 0) ? pages.length + 1 : undefined),
  });

/** The switch moves only once the backend agrees, as in the app. */
export const useSetBikerStatus = () => {
  const qc = useQueryClient();
  return useMutation({ mutationFn: bikerApi.setStatus, onSuccess: () => qc.invalidateQueries({ queryKey: ['biker-profile'] }) });
};

export const useUpdateBiker = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ userName, image }: { userName: string; image?: Blob | null }) => bikerApi.update(userName, image),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['biker-profile'] }),
  });
};

/** Any step of a job changes the job, the lists and the earnings. */
export function useJobAction<V>(id: string, mutationFn: (v: V) => Promise<unknown>) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn,
    onSettled: () =>
      Promise.all(['biker-orders', 'biker-commission', 'biker-washes'].map((k) => qc.invalidateQueries({ queryKey: [k] })).concat(qc.invalidateQueries({ queryKey: ['biker-order', id] }))),
  });
}

/** Where the biker is now. The backend wants at least five decimals and a street name on accept. */
export function currentPosition(streetName: string): Promise<Position> {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) return reject(new Error('no-geolocation'));
    navigator.geolocation.getCurrentPosition(
      (p) => resolve({ latitude: p.coords.latitude.toFixed(6), longitude: p.coords.longitude.toFixed(6), streetName }),
      reject,
      { enableHighAccuracy: true, timeout: 15000, maximumAge: 30000 },
    );
  });
}
