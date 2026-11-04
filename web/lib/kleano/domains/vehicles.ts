'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from '../client';
import type { Vehicle, Wrapped } from '../types';

/** Same endpoints as customer-app/lib/repository/vehicles_repo.dart. */

export type CarBrand = { _id: string; brand: string };
export type VehicleInput = { brand: string; model: string; plateNumber: string; color: string; image?: Blob | null };

function toForm({ image, ...fields }: VehicleInput) {
  const form = new FormData();
  Object.entries(fields).forEach(([k, v]) => form.append(k, v));
  if (image) form.append('image', image, 'car.jpg');
  return form;
}

export const vehiclesApi = {
  list: () => kleano<Wrapped<Vehicle[]>>('/users/vehicles').then((r) => r.data ?? []),
  create: (input: VehicleInput) => kleano('/vehicles', { method: 'POST', form: toForm(input) }),
  update: (id: string, input: VehicleInput) => kleano(`/vehicles/${id}`, { method: 'PUT', form: toForm(input) }),
  remove: (id: string) => kleano(`/vehicles/${id}`, { method: 'DELETE' }),
  brands: () => kleano<Wrapped<CarBrand[]>>('/cars').then((r) => r.data ?? []),
  models: (brandId: string) => kleano<Wrapped<{ models?: string[] }>>(`/cars/${brandId}`).then((r) => r.data?.models ?? []),
};

export const useVehicles = () => useQuery({ queryKey: ['vehicles'], queryFn: vehiclesApi.list });
export const useCarBrands = (enabled = true) => useQuery({ queryKey: ['car-brands'], staleTime: Infinity, enabled, queryFn: vehiclesApi.brands });
export const useCarModels = (brandId: string | undefined) =>
  useQuery({ queryKey: ['car-models', brandId], staleTime: Infinity, enabled: Boolean(brandId), queryFn: () => vehiclesApi.models(brandId!) });

export const useSaveVehicle = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, input }: { id?: string; input: VehicleInput }) => (id ? vehiclesApi.update(id, input) : vehiclesApi.create(input)),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['vehicles'] }),
  });
};

/** Optimistic: the car leaves the list at once and comes back if the backend refuses. */
export const useDeleteVehicle = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: vehiclesApi.remove,
    onMutate: async (id: string) => {
      await qc.cancelQueries({ queryKey: ['vehicles'] });
      const before = qc.getQueryData<Vehicle[]>(['vehicles']);
      qc.setQueryData<Vehicle[]>(['vehicles'], (list) => list?.filter((v) => v._id !== id));
      return { before };
    },
    onError: (_e, _id, context) => qc.setQueryData(['vehicles'], context?.before),
    onSettled: () => qc.invalidateQueries({ queryKey: ['vehicles'] }),
  });
};
