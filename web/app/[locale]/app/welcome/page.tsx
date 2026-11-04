import { notFound, redirect } from 'next/navigation';
import { CustomerWelcome } from '@/components/app/customer/welcome';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

export default async function WelcomePage({ params }: PageProps<'/[locale]/app/welcome'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if (await getSession('customer')) redirect(`/${locale}/app`);
  return <CustomerWelcome t={getAppDictionary(locale)} locale={locale} />;
}
