export const locales = ['ar', 'en'] as const;
export type Locale = (typeof locales)[number];

/** Egypt is the main market, so Arabic is the default. */
export const defaultLocale: Locale = 'ar';

export function isLocale(value: string): value is Locale {
  return (locales as readonly string[]).includes(value);
}

export function dirOf(locale: Locale): 'rtl' | 'ltr' {
  return locale === 'ar' ? 'rtl' : 'ltr';
}

/** Picks a locale from an Accept-Language header, falling back to Arabic. */
export function localeFromHeader(header: string | null): Locale {
  if (!header) return defaultLocale;
  for (const part of header.split(',')) {
    const code = part.split(';')[0].trim().slice(0, 2).toLowerCase();
    if (isLocale(code)) return code;
  }
  return defaultLocale;
}
