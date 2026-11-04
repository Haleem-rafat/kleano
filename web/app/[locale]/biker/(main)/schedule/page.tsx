import { notFound } from 'next/navigation';
import { BikerSchedule } from '@/components/app/biker/schedule';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerSchedule t={getAppDictionary(locale)} locale={locale} />;
}
