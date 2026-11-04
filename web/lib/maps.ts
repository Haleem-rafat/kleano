'use client';

/* The Google Maps script, loaded only by screens that show a map. Same reverse lookup as the app's
 * geocoding_helper.dart: street and area in the page's language, the country always in English,
 * because the backend only recognises English country names ("Saudi Arabia"). */

export const mapsKey = process.env.NEXT_PUBLIC_GOOGLE_MAPS_KEY ?? '';

/* Riyadh, the app's fallback in set_booking_location_screen.dart. */
export const defaultCenter = { lat: 24.7136, lng: 46.6753 };

export type LatLng = { lat: number; lng: number };

/* Only what these screens use, so the full @types package isn't needed. */
export type GoogleMaps = {
  Map: new (el: HTMLElement, options: Record<string, unknown>) => GoogleMap;
  Marker: new (options: Record<string, unknown>) => GoogleMarker;
  Geocoder: new () => { geocode: (request: Record<string, unknown>) => Promise<{ results: GeocodeResult[] }> };
};
export type GoogleMap = {
  addListener: (name: string, fn: (e: { latLng?: { lat: () => number; lng: () => number } }) => void) => void;
  panTo: (position: LatLng) => void;
  setZoom: (zoom: number) => void;
  fitBounds: (bounds: { north: number; south: number; east: number; west: number }, padding?: number) => void;
};
export type GoogleMarker = { setPosition: (position: LatLng) => void; setMap: (map: GoogleMap | null) => void };
export type GeocodeResult = {
  formatted_address?: string;
  geometry?: { location?: { lat: () => number; lng: () => number } };
  address_components?: { long_name: string; short_name: string; types: string[] }[];
};

declare global {
  interface Window {
    google?: { maps: GoogleMaps };
    __kleanoMapsReady?: () => void;
  }
}

let loading: Promise<GoogleMaps> | null = null;

export function loadMaps(language: string): Promise<GoogleMaps> {
  if (window.google?.maps) return Promise.resolve(window.google.maps);
  loading ??= new Promise<GoogleMaps>((resolve, reject) => {
    window.__kleanoMapsReady = () => resolve(window.google!.maps);
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(mapsKey)}&v=weekly&loading=async&language=${language}&callback=__kleanoMapsReady`;
    script.async = true;
    script.onerror = () => {
      loading = null;
      reject(new Error('maps'));
    };
    document.head.appendChild(script);
  });
  return loading;
}

const part = (r: GeocodeResult | undefined, ...types: string[]) =>
  r?.address_components?.find((c) => types.some((t) => c.types.includes(t)))?.long_name ?? '';

export type Address = { streetName: string; subAdministrativeArea: string; country: string };

/* The three fields POST /locations/saved-locations and create-order need. */
export async function reverseGeocode(maps: GoogleMaps, position: LatLng, language: string): Promise<Address | null> {
  const geocoder = new maps.Geocoder();
  const local = await geocoder.geocode({ location: position, language });
  const first = local.results[0];
  if (!first) return null;
  let country = part(first, 'country');
  if (language !== 'en' || /[^\u0000-\u007f]/.test(country)) {
    const english = await geocoder.geocode({ location: position, language: 'en' });
    country = part(english.results[0], 'country') || country;
  }
  const street = [part(first, 'street_number'), part(first, 'route')].filter(Boolean).join(' ');
  return {
    streetName: street || first.formatted_address || part(first, 'sublocality', 'neighborhood', 'locality'),
    subAdministrativeArea: part(first, 'administrative_area_level_2', 'locality', 'administrative_area_level_1'),
    country,
  };
}

export async function searchAddress(maps: GoogleMaps, query: string, language: string): Promise<LatLng | null> {
  const { results } = await new maps.Geocoder().geocode({ address: query, language });
  const location = results[0]?.geometry?.location;
  return location ? { lat: location.lat(), lng: location.lng() } : null;
}

/* The browser's location, or null when refused or unavailable. */
export function currentPosition(): Promise<LatLng | null> {
  return new Promise((resolve) => {
    if (!navigator.geolocation) return resolve(null);
    navigator.geolocation.getCurrentPosition(
      (p) => resolve({ lat: p.coords.latitude, lng: p.coords.longitude }),
      () => resolve(null),
      { timeout: 10_000 },
    );
  });
}
