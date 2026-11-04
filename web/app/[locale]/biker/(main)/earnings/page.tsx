import { notFound } from 'next/navigation';
import { BikerEarnings } from '@/components/app/biker/earnings';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerEarnings t={getAppDictionary(locale)} />;
}
