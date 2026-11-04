import { notFound } from 'next/navigation';
import { BikerHome } from '@/components/app/biker/home';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function Page({ params }: PageProps<'/[locale]/biker'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <BikerHome t={getAppDictionary(locale)} locale={locale} />;
}
