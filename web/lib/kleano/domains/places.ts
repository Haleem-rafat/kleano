'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from '../client';
import type { Location, Wrapped } from '../types';

/**
 * Same endpoints as HomeRepo in customer-app/lib/repository/home_repo.dart. The app sends no city
 * or area: the backend picks the nearest ones from the coordinates, so the web does the same.
 */

export type NewPlace = {
  /** At least 5 decimals: backend/src/locations/dtos/saveLocation.dto.ts. */
  latitude: string;
  longitude: string;
  streetName: string;
  subAdministrativeArea: string;
  country: string;
  savedName: string;
};

export const placesApi = {
  list: () => kleano<Wrapped<Location[]>>('/locations/saved-locations').then((r) => r.data ?? []),
  save: (place: NewPlace) => kleano<Wrapped<Location>>('/locations/saved-locations', { json: place }).then((r) => r.data),
  setDefault: (id: string) => kleano(`/locations/saved-locations/${id}/default`, { method: 'PATCH' }),
  remove: (id: string) => kleano(`/locations/saved-locations/clear/${id}`, { method: 'PATCH' }),
  clearAll: () => kleano('/locations/saved-locations/clear/all', { method: 'PATCH' }),
};

const KEY = ['saved-locations'];

export const useSavedLocations = () => useQuery({ queryKey: KEY, queryFn: placesApi.list });

export const useSavePlace = () => {
  const qc = useQueryClient();
  return useMutation({ mutationFn: placesApi.save, onSuccess: () => qc.invalidateQueries({ queryKey: KEY }) });
};

/** Optimistic list change with rollback, for the quick actions on a saved place. */
function useOptimisticPlaces<V>(mutationFn: (v: V) => Promise<unknown>, change: (list: Location[], v: V) => Location[]) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn,
    onMutate: async (v: V) => {
      await qc.cancelQueries({ queryKey: KEY });
      const before = qc.getQueryData<Location[]>(KEY);
      qc.setQueryData<Location[]>(KEY, (list) => (list ? change(list, v) : list));
      return { before };
    },
    onError: (_e, _v, context) => qc.setQueryData(KEY, context?.before),
    onSettled: () => qc.invalidateQueries({ queryKey: KEY }),
  });
}

export const useSetDefaultPlace = () => useOptimisticPlaces(placesApi.setDefault, (list, id: string) => list.map((l) => ({ ...l, isDefault: l._id === id })));
export const useDeletePlace = () => useOptimisticPlaces(placesApi.remove, (list, id: string) => list.filter((l) => l._id !== id));
export const useClearPlaces = () => useOptimisticPlaces<void>(() => placesApi.clearAll(), () => []);
