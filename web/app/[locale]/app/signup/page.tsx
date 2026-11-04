import { notFound, redirect } from 'next/navigation';
import { CustomerSignup } from '@/components/app/customer-signup';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/content';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

export default async function CustomerSignupPage({ params }: PageProps<'/[locale]/app/signup'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if (await getSession('customer')) redirect(`/${locale}/app`);
  return <CustomerSignup t={getAppDictionary(locale)} locale={locale} themeLabel={getDictionary(locale).theme} />;
}
