'use client';

import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from './client';
import { idOf } from './types';
import type {
  AddOn,
  Banner,
  Location,
  Order,
  OrderGroup,
  Paged,
  Plan,
  Profile,
  Slot,
  Vehicle,
  WashingService,
  Wrapped,
} from './types';

/** Data hooks for the customer web app. Same endpoints as customer-app/lib (repositories). */

export const useProfile = () =>
  useQuery({ queryKey: ['profile'], queryFn: () => kleano<Wrapped<Profile>>('/users').then((r) => r.data) });

export const useVehicles = () =>
  useQuery({ queryKey: ['vehicles'], queryFn: () => kleano<Wrapped<Vehicle[]>>('/users/vehicles').then((r) => r.data ?? []) });

export const useSavedLocations = () =>
  useQuery({
    queryKey: ['saved-locations'],
    queryFn: () => kleano<Wrapped<Location[]>>('/locations/saved-locations').then((r) => r.data ?? []),
  });

export const useBanners = () =>
  useQuery({ queryKey: ['banners'], queryFn: () => kleano<Wrapped<Banner[]>>('/banners/active-banner').then((r) => r.data ?? []) });

/** A location the backend can price: real coordinates and a country (the profile's can be 0,0). */
const usable = (l: Location | undefined): l is Location =>
  Boolean(l && l.country && (Math.abs(l.latitude) > 0.0001 || Math.abs(l.longitude) > 0.0001));

/**
 * Where services and plans are priced: the default saved place, else any saved place, else the
 * profile's location. Returns undefined until the saved places have loaded, so nothing is asked
 * for with an empty location.
 */
export function pickLocation(saved: Location[] | undefined, profile: Profile | undefined): Location | undefined {
  if (!saved) return undefined;
  return [saved.find((l) => l.isDefault), ...saved, profile?.location].find(usable);
}

const where = (l: Location) =>
  `latitude=${l.latitude.toFixed(6)}&longitude=${l.longitude.toFixed(6)}&country=${encodeURIComponent(l.country ?? '')}`;

export const useServices = (location: Location | undefined) =>
  useQuery({
    queryKey: ['services', location?._id],
    enabled: Boolean(location),
    retry: false,
    queryFn: () => kleano<Wrapped<WashingService[]>>(`/washing-services/user/all?${where(location!)}`).then((r) => r.data ?? []),
  });

export const usePlans = (location: Location | undefined) =>
  useQuery({
    queryKey: ['plans', location?._id],
    enabled: Boolean(location),
    retry: false,
    queryFn: () => kleano<Wrapped<Plan[]>>(`/plans/user/all?${where(location!)}`).then((r) => r.data ?? []),
  });

/** Bookings, 10 per page like the app (MyBookingRepo). */
export const useOrders = (group: OrderGroup) =>
  useInfiniteQuery({
    queryKey: ['orders', group],
    initialPageParam: 1,
    queryFn: ({ pageParam }) => kleano<Paged<Order>>(`/orders/user/all?status=${group}&page=${pageParam}&perPage=10`),
    getNextPageParam: (last, pages) => (pages.length < (last.totalPages ?? 0) ? pages.length + 1 : undefined),
  });

export const useOrder = (id: string) =>
  useQuery({
    queryKey: ['order', id],
    queryFn: () => kleano<Wrapped<Order>>(`/orders/user/order-details/${id}`).then((r) => r.data),
  });

export const useDeleteVehicle = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => kleano(`/vehicles/${id}`, { method: 'DELETE' }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['vehicles'] }),
  });
};

export const useAddOns = (location: Location | undefined) =>
  useQuery({
    queryKey: ['add-ons', location?._id],
    enabled: Boolean(location),
    retry: false,
    queryFn: () => kleano<Wrapped<AddOn[]>>(`/add-ons/user/all?${where(location!)}`).then((r) => r.data ?? []),
  });

const DAYS = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];

/** Free times for one day at a saved place (GET /user/biker-schedules), as in BookingOrderRepo. */
export const useSlots = (location: Location | undefined, dateYmd: string | undefined) =>
  useQuery({
    queryKey: ['slots', location?._id, dateYmd],
    enabled: Boolean(location && dateYmd && idOf(location.city as { _id: string } | string) && idOf(location.area)),
    queryFn: () => {
      const city = idOf(location!.city as { _id: string } | string);
      const area = idOf(location!.area);
      // The backend reads days on the Saudi clock (biker-schedule/utils/saudi-assignment-day.util.ts).
      const day = DAYS[new Date(`${dateYmd}T12:00:00+03:00`).getUTCDay()];
      return kleano<Wrapped<Slot[]>>(`/user/biker-schedules?city=${city}&area=${area}&day=${day}&date=${dateYmd}`).then((r) => r.data ?? []);
    },
  });

export type PromoResult = { totalPayAfterDiscount: number; discountAmount: number };

export const checkPromo = (code: string, totalPrice: number) =>
  kleano<Wrapped<PromoResult>>(`/orders/user/promo-code-discount?promoCode=${encodeURIComponent(code)}&totalPrice=${totalPrice}`).then((r) => r.data);

export type NewOrder = {
  washingServices: string[];
  addOns?: string[];
  vehicle: string;
  location: { latitude: string; longitude: string; streetName: string; subAdministrativeArea?: string; country: string };
  startTime: string;
  bookingDate: string;
  timeSlot: string;
  type: 'SERVICE_BOOKING';
  totalPrice: number;
  paymentType: 'WALLET';
  code?: string;
  isCarFreshened: boolean;
};

/** Same two calls as the app: POST /orders/user/create-order, then PATCH /orders/user/pay-order. */
export const createOrder = (order: NewOrder) =>
  kleano<Wrapped<{ _id: string }>>('/orders/user/create-order', { json: order }).then((r) => r.data);

export const payOrder = (orderId: string) => kleano('/orders/user/pay-order', { method: 'PATCH', json: { order: orderId } });
