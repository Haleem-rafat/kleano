import { notFound, redirect } from 'next/navigation';
import { AppShell } from '@/components/app/app-shell';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/dictionaries';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

/** Signed-in biker pages. Anyone else goes to the biker log in. */
export default async function BikerMainLayout({ children, params }: LayoutProps<'/[locale]/biker'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if ((await getSession())?.role !== 'biker') redirect(`/${locale}/biker/login`);
  return (
    <AppShell role="biker" locale={locale} t={getAppDictionary(locale)} themeLabel={getDictionary(locale).theme}>
      {children}
    </AppShell>
  );
}
