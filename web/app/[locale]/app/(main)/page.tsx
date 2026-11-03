import { notFound } from 'next/navigation';
import { CustomerHome } from '@/components/app/customer/home';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function CustomerHomePage({ params }: PageProps<'/[locale]/app'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerHome t={getAppDictionary(locale)} locale={locale} />;
}
