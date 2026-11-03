import { notFound } from 'next/navigation';
import { CustomerBookings } from '@/components/app/customer/bookings';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function BookingsPage({ params }: PageProps<'/[locale]/app/bookings'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerBookings t={getAppDictionary(locale)} locale={locale} />;
}
