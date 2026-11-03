import { notFound } from 'next/navigation';
import { PageTitle } from '@/components/app/bits';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

/** Booking flow (service, add-ons, car, place, time, payment) is the next step. */
export default async function BookPage({ params }: PageProps<'/[locale]/app/book'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getAppDictionary(locale);
  return <PageTitle title={t.home.bookNow} subtitle={t.soon} />;
}
