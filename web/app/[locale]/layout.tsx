import type { Metadata, Viewport } from 'next';
import { IBM_Plex_Sans_Arabic, Readex_Pro } from 'next/font/google';
import { notFound } from 'next/navigation';
import type { ReactNode } from 'react';
import { ThemeProvider } from '@/components/theme';
import { getDictionary } from '@/lib/dictionaries';
import { dirOf, isLocale, locales } from '@/lib/i18n';
import { siteUrl } from '@/lib/site';
import '../globals.css';

const readex = Readex_Pro({
  subsets: ['arabic', 'latin'],
  weight: ['500', '600', '700'],
  variable: '--font-readex',
  display: 'swap',
});

const plex = IBM_Plex_Sans_Arabic({
  subsets: ['arabic', 'latin'],
  weight: ['400', '500', '600'],
  variable: '--font-plex',
  display: 'swap',
});

export function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export const viewport: Viewport = {
  viewportFit: 'cover',
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#f4f2f6' },
    { media: '(prefers-color-scheme: dark)', color: '#0b0a0c' },
  ],
};

export async function generateMetadata({ params }: LayoutProps<'/[locale]'>): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) return {};
  const t = getDictionary(locale);
  return {
    metadataBase: new URL(siteUrl),
    title: t.meta.title,
    description: t.meta.description,
    alternates: {
      canonical: `/${locale}`,
      languages: { ar: '/ar', en: '/en', 'x-default': '/ar' },
    },
    openGraph: {
      type: 'website',
      siteName: locale === 'ar' ? 'كلينو' : 'Kleano',
      title: t.meta.title,
      description: t.meta.description,
      locale: locale === 'ar' ? 'ar_EG' : 'en_US',
      images: [{ url: '/images/washing.jpg', width: 692, height: 1500 }],
    },
  };
}

export default async function LocaleLayout({ children, params }: LayoutProps<'/[locale]'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();

  return (
    <html lang={locale} dir={dirOf(locale)} className={`${readex.variable} ${plex.variable}`} suppressHydrationWarning>
      <body>
        <ThemeProvider>{children as ReactNode}</ThemeProvider>
      </body>
    </html>
  );
}
