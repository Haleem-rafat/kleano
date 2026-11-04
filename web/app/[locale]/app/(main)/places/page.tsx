import { notFound } from 'next/navigation';
import { CustomerPlaces } from '@/components/app/customer/places';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function PlacesPage({ params }: PageProps<'/[locale]/app/places'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerPlaces t={getAppDictionary(locale)} locale={locale} />;
}
