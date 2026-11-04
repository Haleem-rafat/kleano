import { notFound } from 'next/navigation';
import { CustomerPlans } from '@/components/app/customer/plans';
import { getAppDictionary } from '@/lib/app-dictionary';
import { isLocale } from '@/lib/i18n';

export default async function PlansPage({ params }: PageProps<'/[locale]/app/plans'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  return <CustomerPlans t={getAppDictionary(locale)} locale={locale} />;
}
