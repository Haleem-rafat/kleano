import { notFound, redirect } from 'next/navigation';
import { BikerLogin } from '@/components/app/biker-login';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/dictionaries';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

export default async function BikerLoginPage({ params }: PageProps<'/[locale]/biker/login'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if (await getSession('biker')) redirect(`/${locale}/biker`);
  return <BikerLogin t={getAppDictionary(locale)} locale={locale} themeLabel={getDictionary(locale).theme} />;
}
