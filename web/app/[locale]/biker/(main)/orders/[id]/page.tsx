import { notFound } from 'next/navigation';
import { BikerOrderDetails } from '@/components/app/biker/order-details';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: { params: Promise<{ locale: string; id: string }> }) {
  const { locale, id } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerOrderDetails id={id} t={getAppDictionary(locale)} locale={locale} />;
}
