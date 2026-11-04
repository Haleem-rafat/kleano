'use client';

import { useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import type { LatLng } from '@/lib/maps';
import type { Order, OrderStatus } from './types';

/**
 * Live wash updates over Socket.IO. The backend reads the token from the socket's Authorization
 * header (auth.service.ts authenticateSocketUser), and a browser can only set that header on the
 * polling transport. So the page polls this site's own /api/live/socket.io, which adds the header
 * from the httpOnly cookie; the token never reaches page JavaScript. See README.
 */

type StatusEvent = { _id?: string; status?: OrderStatus; time?: string; duration?: number; biker?: Order['biker'] };

const EVENTS = ['order:accepted', 'order:on-the-way', 'order:arrived', 'order:on-washing', 'order:completed'] as const;

export type LiveState = {
  connected: boolean;
  biker: LatLng | null;
  /** When each stage happened during this visit, by status. */
  times: Partial<Record<OrderStatus, string>>;
};

export function useLiveOrder(orderId: string, enabled: boolean): LiveState {
  const qc = useQueryClient();
  const [connected, setConnected] = useState(false);
  const [biker, setBiker] = useState<LatLng | null>(null);
  const [times, setTimes] = useState<LiveState['times']>({});

  useEffect(() => {
    if (!enabled) return;
    let closed = false;
    let teardown: (() => void) | undefined;

    void import('socket.io-client').then(({ io }) => {
      if (closed) return;
      const socket = io({
        path: '/api/live/socket.io',
        addTrailingSlash: false,
        transports: ['polling'],
        upgrade: false,
        withCredentials: true,
      });
      socket.on('connect', () => setConnected(true));
      socket.on('disconnect', () => setConnected(false));
      socket.on('connect_error', () => setConnected(false));

      const onStatus = (event: StatusEvent) => {
        if (event?._id !== orderId || !event.status) return;
        const status = event.status;
        if (event.time) setTimes((old) => ({ ...old, [status]: event.time }));
        qc.setQueryData<Order>(['order', orderId], (old) => (old ? { ...old, status, biker: event.biker ?? old.biker } : old));
        void qc.invalidateQueries({ queryKey: ['orders'] });
        // Completed: fetch the wash photos and the final totals.
        if (status === 'COMPLETED') void qc.invalidateQueries({ queryKey: ['order', orderId] });
      };
      EVENTS.forEach((name) => socket.on(name, onStatus));
      // Only sent to the customer whose biker is on the way (biker.gateway.ts).
      socket.on('biker:move', (body: { order?: string; latitude?: number | string; longitude?: number | string }) => {
        if (body?.order && body.order !== orderId) return;
        const lat = Number(body?.latitude);
        const lng = Number(body?.longitude);
        if (Number.isFinite(lat) && Number.isFinite(lng)) setBiker({ lat, lng });
      });

      teardown = () => {
        socket.removeAllListeners();
        socket.close();
      };
    });

    return () => {
      closed = true;
      teardown?.();
    };
  }, [enabled, orderId, qc]);

  return { connected, biker, times };
}
