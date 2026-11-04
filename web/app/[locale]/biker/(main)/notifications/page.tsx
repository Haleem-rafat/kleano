import { notFound } from 'next/navigation';
import { BikerNotifications } from '@/components/app/biker/notifications';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerNotifications t={getAppDictionary(locale)} locale={locale} />;
}
