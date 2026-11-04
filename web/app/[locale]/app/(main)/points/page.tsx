import { notFound } from 'next/navigation';
import { CustomerPoints } from '@/components/app/customer/rewards';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function PointsPage({ params }: PageProps<'/[locale]/app/points'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerPoints t={getAppDictionary(locale)} locale={locale} />;
}
