'use client';

import { useQuery } from '@tanstack/react-query';
import { kleano } from '../client';
import { idOf } from '../types';
import type { AddOn, Banner, Location, Profile, Slot, WashingService, Wrapped } from '../types';

/** Services, extras, banners and free times. Same endpoints as HomeRepo and BookingOrderRepo. */

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

export const where = (l: Location) =>
  `latitude=${l.latitude.toFixed(6)}&longitude=${l.longitude.toFixed(6)}&country=${encodeURIComponent(l.country ?? '')}`;

export const useBanners = () =>
  useQuery({ queryKey: ['banners'], queryFn: () => kleano<Wrapped<Banner[]>>('/banners/active-banner').then((r) => r.data ?? []) });

export const useServices = (location: Location | undefined) =>
  useQuery({
    queryKey: ['services', location?._id],
    enabled: Boolean(location),
    retry: false,
    queryFn: () => kleano<Wrapped<WashingService[]>>(`/washing-services/user/all?${where(location!)}`).then((r) => r.data ?? []),
  });

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
