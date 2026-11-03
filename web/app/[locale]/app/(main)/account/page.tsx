import { notFound } from 'next/navigation';
import { CustomerAccount } from '@/components/app/customer/account';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function AccountPage({ params }: PageProps<'/[locale]/app/account'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerAccount t={getAppDictionary(locale)} locale={locale} />;
}
