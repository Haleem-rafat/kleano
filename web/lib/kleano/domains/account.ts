'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from '../client';
import type { PointsInfo, Profile, Wrapped } from '../types';

/** Same endpoints as ProfileRepo and PointRepo in the app. */

export type ProfileInput = { userName: string; email?: string; gender?: string; dob?: string; image?: Blob | null };

function toForm({ image, ...fields }: ProfileInput) {
  const form = new FormData();
  Object.entries(fields).forEach(([k, v]) => {
    if (v) form.append(k, v);
  });
  if (image) form.append('image', image, 'profile.jpg');
  return form;
}

export const accountApi = {
  profile: () => kleano<Wrapped<Profile>>('/users').then((r) => r.data),
  update: (input: ProfileInput) => kleano<Wrapped<Profile>>('/users', { method: 'PUT', form: toForm(input) }).then((r) => r.data),
  /** The backend changes the number straight away, with no code to the new phone: see MISSING_API.md. */
  changePhone: (phone: string) => kleano('/users/phone-number', { method: 'PATCH', json: { phone } }),
  language: (language: 'ar' | 'en') => kleano('/users/user-language', { method: 'PATCH', json: { language } }),
  notifications: (allow: 'on' | 'off') => kleano('/users/notification-permission', { method: 'PATCH', json: { allow } }),
  remove: () => kleano('/users', { method: 'DELETE' }),
  points: () => kleano<Wrapped<PointsInfo>>('/users/points-system').then((r) => r.data),
};

export const useProfile = () => useQuery({ queryKey: ['profile'], queryFn: accountApi.profile });
export const usePoints = () => useQuery({ queryKey: ['points'], queryFn: accountApi.points });

export const useUpdateProfile = () => {
  const qc = useQueryClient();
  return useMutation({ mutationFn: accountApi.update, onSuccess: () => qc.invalidateQueries({ queryKey: ['profile'] }) });
};

export const useChangePhone = () => {
  const qc = useQueryClient();
  return useMutation({ mutationFn: accountApi.changePhone, onSuccess: () => qc.invalidateQueries({ queryKey: ['profile'] }) });
};

export const useDeleteAccount = () => useMutation({ mutationFn: accountApi.remove });

/** Optimistic toggle with rollback. */
export const useNotificationPermission = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (on: boolean) => accountApi.notifications(on ? 'on' : 'off'),
    onMutate: async (on: boolean) => {
      await qc.cancelQueries({ queryKey: ['profile'] });
      const before = qc.getQueryData<Profile>(['profile']);
      qc.setQueryData<Profile>(['profile'], (p) => (p ? { ...p, isAllowNotification: on } : p));
      return { before };
    },
    onError: (_e, _on, context) => qc.setQueryData(['profile'], context?.before),
    onSettled: () => qc.invalidateQueries({ queryKey: ['profile'] }),
  });
};
