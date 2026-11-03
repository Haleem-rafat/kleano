import { notFound } from 'next/navigation';
import { BookingDetails } from '@/components/app/customer/booking-details';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function BookingDetailsPage({ params }: PageProps<'/[locale]/app/bookings/[id]'>) {
  const { locale, id } = await params;
  if (!isLocale(locale) || !/^[a-f0-9]{24}$/i.test(id)) notFound();
  return <BookingDetails id={id} t={getAppDictionary(locale)} locale={locale} />;
}
