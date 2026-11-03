import { notFound, redirect } from 'next/navigation';
import { AppShell } from '@/components/app/app-shell';
import { getAppDictionary } from '@/lib/app-dictionary';
import { getDictionary } from '@/lib/dictionaries';
import { isLocale } from '@/lib/i18n';
import { getSession } from '@/lib/kleano/session';

/** Signed-in customer pages. Anyone else goes to the customer log in. */
export default async function CustomerMainLayout({ children, params }: LayoutProps<'/[locale]/app'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  if (!(await getSession('customer'))) redirect(`/${locale}/app/login`);
  return (
    <AppShell role="customer" locale={locale} t={getAppDictionary(locale)} themeLabel={getDictionary(locale).theme}>
      {children}
    </AppShell>
  );
}
