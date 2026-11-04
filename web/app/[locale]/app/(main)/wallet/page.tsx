import { notFound } from 'next/navigation';
import { CustomerWallet } from '@/components/app/customer/rewards';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function WalletPage({ params }: PageProps<'/[locale]/app/wallet'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerWallet t={getAppDictionary(locale)} locale={locale} />;
}
