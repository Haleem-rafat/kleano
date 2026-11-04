import { notFound } from 'next/navigation';
import { BikerAccount } from '@/components/app/biker/account';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerAccount t={getAppDictionary(locale)} locale={locale} />;
}
