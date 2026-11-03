import { notFound } from 'next/navigation';
import { AppProviders } from '@/components/app/providers';
import { isLocale } from '@/lib/i18n';

/** Customer web app: data cache and toasts for every /[locale]/app page. */
export default async function CustomerAppLayout({ children, params }: LayoutProps<'/[locale]/app'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <AppProviders rtl={locale === 'ar'}>{children}</AppProviders>;
}
