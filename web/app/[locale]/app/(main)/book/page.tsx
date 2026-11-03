import { notFound } from 'next/navigation';
import { Suspense } from 'react';
import { Loading } from '@/components/app/bits';
import { BookingFlow } from '@/components/app/customer/booking-flow';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

/** Book a wash: service, car and place, date and time, review and pay (wallet). */
export default async function BookPage({ params }: PageProps<'/[locale]/app/book'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getAppDictionary(locale);
  return (
    <Suspense fallback={<Loading label={t.common.loading} />}>
      <BookingFlow t={t} locale={locale} />
    </Suspense>
  );
}
