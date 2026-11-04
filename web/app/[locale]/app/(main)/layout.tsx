import { cookies } from 'next/headers';
import { notFound, redirect } from 'next/navigation';
import { AppShell } from '@/components/app/app-shell';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/content';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

/** Signed-in customer pages. Anyone else goes to the welcome slides the first time, then to log in. */
export default async function CustomerMainLayout({ children, params }: LayoutProps<'/[locale]/app'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if (!(await getSession('customer'))) {
    const welcomed = (await cookies()).has('kleano_welcomed');
    redirect(`/${locale}/app/${welcomed ? 'login' : 'welcome'}`);
  }
  return (
    <AppShell role="customer" locale={locale} t={getAppDictionary(locale)} themeLabel={getDictionary(locale).theme}>
      {children}
    </AppShell>
  );
}
