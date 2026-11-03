import { notFound } from 'next/navigation';
import { AppProviders } from '@/components/app/providers';
import { isLocale } from '@/lib/i18n';

/** Biker web app: data cache and toasts for every /[locale]/biker page. */
export default async function BikerAppLayout({ children, params }: LayoutProps<'/[locale]/biker'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <AppProviders rtl={locale === 'ar'}>{children}</AppProviders>;
}
