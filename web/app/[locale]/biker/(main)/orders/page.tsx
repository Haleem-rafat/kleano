import { notFound } from 'next/navigation';
import { BikerOrders } from '@/components/app/biker/orders';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerOrders t={getAppDictionary(locale)} locale={locale} />;
}
