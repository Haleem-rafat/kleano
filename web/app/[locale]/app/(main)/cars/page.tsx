import { notFound } from 'next/navigation';
import { CustomerCars } from '@/components/app/customer/cars';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function CarsPage({ params }: PageProps<'/[locale]/app/cars'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerCars t={getAppDictionary(locale)} locale={locale} />;
}
