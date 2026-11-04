import type { Locale } from '@/lib/i18n';
import { kleano } from './client';
import type { Location, Wrapped } from './types';

/**
 * Where someone lands after logging in or signing up, as in the app's AddressCheckScreen: Home
 * with a saved place, the map to add a first one. A failed check goes Home, never to the map:
 * it must not look like "no address" for an existing customer.
 */
export async function firstScreenAfterAuth(locale: Locale): Promise<string> {
  const base = `/${locale}/app`;
  try {
    const saved = await kleano<Wrapped<Location[]>>('/locations/saved-locations');
    return saved.data?.length ? base : `${base}/places/new?first=1`;
  } catch {
    return base;
  }
}
