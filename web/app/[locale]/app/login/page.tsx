import { notFound, redirect } from 'next/navigation';
import { CustomerLogin } from '@/components/app/customer-login';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/content';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

export default async function CustomerLoginPage({ params }: PageProps<'/[locale]/app/login'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if (await getSession('customer')) redirect(`/${locale}/app`);
  return <CustomerLogin t={getAppDictionary(locale)} locale={locale} themeLabel={getDictionary(locale).theme} />;
}
