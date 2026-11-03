'use client';

import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from './client';
import type {
  Banner,
  Location,
  Order,
  OrderGroup,
  Paged,
  Plan,
  Profile,
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
