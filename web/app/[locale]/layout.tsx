import type { Metadata, Viewport } from 'next';
import { Alexandria, Inter, Noto_Sans_Arabic } from 'next/font/google';
import { notFound } from 'next/navigation';
import type { ReactNode } from 'react';
import { ThemeProvider } from '@/components/theme';
import { getDictionary } from '@/lib/content';
import { dirOf, isLocale, locales } from '@/lib/i18n';
import { siteUrl } from '@/lib/site';
import '../globals.css';

// One headline family for both languages, and an easy-reading text face for each.
const alexandria = Alexandria({ subsets: ['arabic', 'latin'], variable: '--font-alexandria', display: 'swap' });
const inter = Inter({ subsets: ['latin'], variable: '--font-inter', display: 'swap' });
const notoArabic = Noto_Sans_Arabic({ subsets: ['arabic'], variable: '--font-noto-arabic', display: 'swap' });

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
    <html lang={locale} dir={dirOf(locale)} className={`${alexandria.variable} ${inter.variable} ${notoArabic.variable}`} data-scroll-behavior="smooth" suppressHydrationWarning>
      <body>
        <ThemeProvider>{children as ReactNode}</ThemeProvider>
      </body>
    </html>
  );
}
