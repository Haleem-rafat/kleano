import { notFound } from 'next/navigation';
import { CustomerAbout } from '@/components/app/customer/about';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function AboutPage({ params }: PageProps<'/[locale]/app/about'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerAbout t={getAppDictionary(locale)} locale={locale} />;
}
