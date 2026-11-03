/** Public address of the site. Set NEXT_PUBLIC_SITE_URL once the domain is chosen. */
export const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:4100';

/**
 * Store links. Empty until the owner provides the real App Store and Google Play pages;
 * the buttons then scroll to the download section instead of going nowhere.
 */
export const storeLinks = {
  appStore: process.env.NEXT_PUBLIC_APP_STORE_URL ?? '',
  googlePlay: process.env.NEXT_PUBLIC_GOOGLE_PLAY_URL ?? '',
};
