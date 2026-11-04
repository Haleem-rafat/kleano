import { notFound } from 'next/navigation';
import { CustomerNotifications } from '@/components/app/customer/notifications';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function NotificationsPage({ params }: PageProps<'/[locale]/app/notifications'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerNotifications t={getAppDictionary(locale)} locale={locale} />;
}
