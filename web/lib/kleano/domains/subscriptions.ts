'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { kleano } from '../client';
import { where } from './catalog';
import type { Location, Plan, Subscription, Wrapped } from '../types';

/** Same endpoints as PlansAndSubscriptionRepo in the app. */

export const subscriptionsApi = {
  plans: (l: Location) => kleano<Wrapped<Plan[]>>(`/plans/user/all?${where(l)}`).then((r) => r.data ?? []),
  /** Replies { data: {} } without a subscription. */
  mine: () => kleano<Wrapped<Subscription>>('/subscriptions/user').then((r) => (r.data?._id ? r.data : null)),
  /** message is empty when the plan works at this place. */
  atLocation: (l: Location) => kleano<Wrapped<Subscription> & { message?: string }>(`/subscriptions/user/location?${where(l)}`).then((r) => ({ subscription: r.data, message: r.message ?? '' })),
  create: (plan: string) => kleano<Wrapped<Subscription>>('/subscriptions', { json: { plan, paymentType: 'WALLET' } }).then((r) => r.data),
  pay: (subscription: string) => kleano('/subscriptions/user/pay-subscription', { method: 'PATCH', json: { subscription } }),
};

export const usePlans = (location: Location | undefined) =>
  useQuery({ queryKey: ['plans', location?._id], enabled: Boolean(location), retry: false, queryFn: () => subscriptionsApi.plans(location!) });

export const useMySubscription = () => useQuery({ queryKey: ['subscription'], queryFn: subscriptionsApi.mine });

export const useSubscriptionAt = (location: Location | undefined, enabled: boolean) =>
  useQuery({ queryKey: ['subscription-at', location?._id], enabled: Boolean(location) && enabled, retry: false, queryFn: () => subscriptionsApi.atLocation(location!) });

/** Same two calls as the app: POST /subscriptions, then PATCH pay-subscription. Wallet only on the web. */
export const useSubscribe = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (planId: string) => {
      const created = await subscriptionsApi.create(planId);
      await subscriptionsApi.pay(created._id);
    },
    onSuccess: () =>
      Promise.all([qc.invalidateQueries({ queryKey: ['subscription'] }), qc.invalidateQueries({ queryKey: ['profile'] }), qc.invalidateQueries({ queryKey: ['plans'] })]),
  });
};
