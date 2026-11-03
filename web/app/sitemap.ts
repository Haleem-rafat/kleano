import type { MetadataRoute } from 'next';
import { locales } from '@/lib/i18n';
import { siteUrl } from '@/lib/site';

export default function sitemap(): MetadataRoute.Sitemap {
  return locales.map((locale) => ({
    url: `${siteUrl}/${locale}`,
    changeFrequency: 'monthly',
    priority: 1,
    alternates: { languages: { ar: `${siteUrl}/ar`, en: `${siteUrl}/en` } },
  }));
}
