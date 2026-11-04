'use client';

import { useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import type { Socket } from 'socket.io-client';
import { toast } from 'sonner';

/** One socket per biker page, through this site's door (see app/api/live/socket.io). */
let live: Socket | null = null;

/** While online: new jobs arrive with a sound and refresh the list, like SocketService in the app. */
export function useBikerSocket(online: boolean, newOrderText: string) {
  const qc = useQueryClient();
  useEffect(() => {
    if (!online) return;
    let closed = false;
    let socket: Socket | null = null;
    void import('socket.io-client').then(({ io }) => {
      if (closed) return;
      socket = io({ path: '/api/live/socket.io', addTrailingSlash: false, transports: ['polling'], upgrade: false, withCredentials: true, query: { role: 'biker' } });
      live = socket;
      socket.on('order:published', () => {
        toast.info(newOrderText);
        // Browsers may block sound until the page has been touched; the message still shows.
        void new Audio('/sounds/new-order.wav').play().catch(() => undefined);
        void qc.invalidateQueries({ queryKey: ['biker-orders'] });
      });
    });
    return () => {
      closed = true;
      socket?.close();
      live = null;
    };
  }, [online, newOrderText, qc]);
}

/** On the way to a job: the customer sees the biker move. Sent at most every 10 seconds. */
export function useShareLocation(order: string, active: boolean) {
  useEffect(() => {
    if (!active || !navigator.geolocation) return;
    let last = 0;
    const watch = navigator.geolocation.watchPosition(
      (p) => {
        const now = Date.now();
        if (now - last < 10000) return;
        last = now;
        live?.emit('biker:location-changes', { order, latitude: p.coords.latitude, longitude: p.coords.longitude });
      },
      () => undefined,
      { enableHighAccuracy: true, maximumAge: 5000 },
    );
    return () => navigator.geolocation.clearWatch(watch);
  }, [order, active]);
}
