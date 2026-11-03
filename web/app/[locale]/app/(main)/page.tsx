import { notFound } from 'next/navigation';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function CustomerHome({ params }: PageProps<'/[locale]/app'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getAppDictionary(locale);
  return (
    <div className="grid gap-2">
      <h1 className="text-[34px] font-extrabold">{t.nav.home}</h1>
      <p className="text-muted-foreground">{t.soon}</p>
    </div>
  );
}
