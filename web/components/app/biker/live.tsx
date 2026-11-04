'use client';

import type { AppDictionary } from '@/lib/app-dictionary';
import { useBikerSocket } from '@/lib/kleano/biker-live';
import { useBikerProfile } from '@/lib/kleano/domains/biker';

/** Keeps the socket open on every biker page while the biker is online. Draws nothing. */
export function BikerLive({ t }: { t: AppDictionary }) {
  const profile = useBikerProfile();
  useBikerSocket(profile.data?.status === 'ONLINE', t.b.newOrder);
  return null;
}
