import { notFound } from 'next/navigation';
import { CustomerPromos } from '@/components/app/customer/rewards';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function PromosPage({ params }: PageProps<'/[locale]/app/promos'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerPromos t={getAppDictionary(locale)} locale={locale} />;
}
