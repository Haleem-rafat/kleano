'use client';

import { useQuery } from '@tanstack/react-query';
import { kleano } from '../client';
import type { ContactInfo, PromoCode, Wrapped } from '../types';

/** Same endpoints as AboutUsRepo and PromoCodesRepo in the app. */

export const useContactInfo = () =>
  useQuery({ queryKey: ['contact-info'], staleTime: 300_000, queryFn: () => kleano<Wrapped<ContactInfo>>('/contact-info').then((r) => r.data) });

export type PromoStatus = 'ACTIVE' | 'USED' | 'EXPIRED';

export const usePromoCodes = (status: PromoStatus) =>
  useQuery({ queryKey: ['promo-codes', status], queryFn: () => kleano<Wrapped<PromoCode[]>>(`/promo-codes/user?status=${status}`).then((r) => r.data ?? []) });
