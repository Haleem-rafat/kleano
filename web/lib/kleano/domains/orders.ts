'use client';

import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from '../client';
import type { Order, OrderGroup, Paged, Wrapped } from '../types';

/** Same endpoints as BookingOrderRepo, MyBookingRepo, PromoCodesRepo and PointRepo in the app. */

export type PromoResult = { totalPayAfterDiscount: number; discountAmount: number };

export type NewOrder = {
  washingServices?: string[];
  addOns?: string[];
  vehicle: string;
  location: { latitude: string; longitude: string; streetName: string; subAdministrativeArea?: string; country: string };
  description?: string;
  startTime: string;
  bookingDate: string;
  timeSlot: string;
  type: 'SERVICE_BOOKING' | 'SUBSCRIPTION_BOOKING';
  subscription?: string;
  totalPrice: number;
  /** The web only ever pays from the wallet, or on the plan when nothing is owed. */
  paymentType: 'WALLET' | 'SUBSCRIBED';
  code?: string;
  isCarFreshened: boolean;
  appliedPoints?: number;
};

export const ordersApi = {
  page: (group: OrderGroup, page: number) => kleano<Paged<Order>>(`/orders/user/all?status=${group}&page=${page}&perPage=10`),
  details: (id: string) => kleano<Wrapped<Order>>(`/orders/user/order-details/${id}`).then((r) => r.data),
  /** The backend replies { data: { createdOrder, redeemLimit } } (userOrders.service.ts). */
  create: (order: NewOrder) => kleano<Wrapped<{ createdOrder: Order; redeemLimit?: number }>>('/orders/user/create-order', { json: order }).then((r) => r.data.createdOrder),
  /** Wallet payment needs only the order id. The web never sends paymentDetails. */
  pay: (orderId: string) => kleano('/orders/user/pay-order', { method: 'PATCH', json: { order: orderId } }),
  cancel: (orderId: string) => kleano('/orders/user/cancel-order', { method: 'PATCH', json: { order: orderId } }),
  rate: (orderId: string, starsNum: number) => kleano('/orders/user/rate-order', { method: 'PATCH', json: { order: orderId, starsNum } }),
  promoDiscount: (code: string, totalPrice: number) =>
    kleano<Wrapped<PromoResult>>(`/orders/user/promo-code-discount?promoCode=${encodeURIComponent(code)}&totalPrice=${totalPrice}`).then((r) => r.data),
  applyPromo: (orderId: string, code: string) => kleano('/orders/user/apply-promo-code', { method: 'PATCH', json: { order: orderId, code } }),
  applyPoints: (orderId: string) => kleano('/orders/user/apply-points', { method: 'PATCH', json: { order: orderId } }),
  pointsDiscount: (points: number) =>
    kleano<Wrapped<{ discountAmount: number; redeemLimit?: number; exchangePercentage?: number }>>('/points/calculate-discount', { json: { points } }).then((r) => r.data),
};

/** Bookings, 10 per page like the app (MyBookingRepo). */
export const useOrders = (group: OrderGroup) =>
  useInfiniteQuery({
    queryKey: ['orders', group],
    initialPageParam: 1,
    queryFn: ({ pageParam }) => ordersApi.page(group, pageParam),
    getNextPageParam: (last, pages) => (pages.length < (last.totalPages ?? 0) ? pages.length + 1 : undefined),
  });

export const useOrder = (id: string) => useQuery({ queryKey: ['order', id], queryFn: () => ordersApi.details(id) });

/** Any change to an order also changes the lists, the wallet and the points. */
function useOrderChange<V>(id: string, mutationFn: (v: V) => Promise<unknown>) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn,
    onSuccess: () =>
      Promise.all([
        qc.invalidateQueries({ queryKey: ['order', id] }),
        qc.invalidateQueries({ queryKey: ['orders'] }),
        qc.invalidateQueries({ queryKey: ['profile'] }),
      ]),
  });
}

export const useCancelOrder = (id: string) => useOrderChange<void>(id, () => ordersApi.cancel(id));
export const useRateOrder = (id: string) => useOrderChange<number>(id, (stars) => ordersApi.rate(id, stars));
export const useApplyPromo = (id: string) => useOrderChange<string>(id, (code) => ordersApi.applyPromo(id, code));
export const useApplyPoints = (id: string) => useOrderChange<void>(id, () => ordersApi.applyPoints(id));
export const usePayOrder = (id: string) => useOrderChange<void>(id, () => ordersApi.pay(id));
