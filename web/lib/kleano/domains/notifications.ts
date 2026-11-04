'use client';

import { useInfiniteQuery, useMutation, useQueryClient, type InfiniteData } from '@tanstack/react-query';
import { kleano } from '../client';
import type { KleanoNotification, Paged } from '../types';

/** Same endpoints as NotificationsRepo in the app, 10 per page. */

export const notificationsApi = {
  page: (page: number) => kleano<Paged<KleanoNotification>>(`/notifications?page=${page}&perPage=10`),
  read: (id: string) => kleano(`/notifications/${id}/set-read`, { method: 'PATCH' }),
};

const KEY = ['notifications'];
type Pages = InfiniteData<Paged<KleanoNotification>>;

export const useNotifications = () =>
  useInfiniteQuery({
    queryKey: KEY,
    initialPageParam: 1,
    queryFn: ({ pageParam }) => notificationsApi.page(pageParam),
    getNextPageParam: (last, pages) => (pages.length < (last.totalPages ?? 0) ? pages.length + 1 : undefined),
  });

/** Optimistic: reads at once, unread again if the backend refuses. */
export const useReadNotification = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: notificationsApi.read,
    onMutate: async (id: string) => {
      await qc.cancelQueries({ queryKey: KEY });
      const before = qc.getQueryData<Pages>(KEY);
      qc.setQueryData<Pages>(KEY, (data) =>
        data ? { ...data, pages: data.pages.map((p) => ({ ...p, data: p.data.map((n) => (n._id === id ? { ...n, isRead: true } : n)) })) } : data,
      );
      return { before };
    },
    onError: (_e, _id, context) => qc.setQueryData(KEY, context?.before),
  });
};
