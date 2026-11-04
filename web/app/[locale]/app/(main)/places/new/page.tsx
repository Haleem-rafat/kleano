import { notFound } from 'next/navigation';
import { Suspense } from 'react';
import { CustomerPlaceNew } from '@/components/app/customer/place-new';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function NewPlacePage({ params }: PageProps<'/[locale]/app/places/new'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return (
    <Suspense>
      <CustomerPlaceNew t={getAppDictionary(locale)} locale={locale} />
    </Suspense>
  );
}
