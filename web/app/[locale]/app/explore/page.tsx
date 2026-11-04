import { notFound } from 'next/navigation';
import { CustomerExplore } from '@/components/app/customer/explore';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/content';
import { isLocale } from '@/lib/i18n';

export default async function ExplorePage({ params }: PageProps<'/[locale]/app/explore'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerExplore t={getAppDictionary(locale)} locale={locale} themeLabel={getDictionary(locale).theme} />;
}
