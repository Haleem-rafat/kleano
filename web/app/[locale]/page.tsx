import { notFound } from 'next/navigation';
import { Bikers } from '@/components/landing/bikers';
import { Cta } from '@/components/landing/cta';
import { Faq } from '@/components/landing/faq';
import { Footer } from '@/components/landing/footer';
import { Hero } from '@/components/landing/hero';
import { HowItWorks } from '@/components/landing/how-it-works';
import { Logos } from '@/components/landing/logos';
import { LandingNavbar } from '@/components/landing/navbar';
import { Plans } from '@/components/landing/plans';
import { Services } from '@/components/landing/services';
import { Tracking } from '@/components/landing/tracking';
import { getDictionary } from '@/lib/content';
import { isLocale } from '@/lib/i18n';
import { siteUrl } from '@/lib/site';

/** The landing page. Each section is its own component, so reordering means editing this list only. */
export default async function LandingPage({ params }: PageProps<'/[locale]'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getDictionary(locale);

  // Structured data with facts only: no address or rating until real ones exist.
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'MobileApplication',
    name: t.brand,
    description: t.meta.description,
    url: `${siteUrl}/${locale}`,
    applicationCategory: 'LifestyleApplication',
    operatingSystem: 'iOS, Android',
  };

  return (
    <div className="relative">
      <div aria-hidden="true" className="lp-grain pointer-events-none fixed inset-0 z-50" />
      {/* Thin column guides behind the page. */}
      <div aria-hidden="true" className="pointer-events-none absolute inset-0 -z-30 mx-auto hidden max-w-6xl grid-cols-4 border-x md:grid">
        <span className="border-e" />
        <span className="border-e" />
        <span className="border-e" />
      </div>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, '\\u003c') }} />
      <LandingNavbar t={t} locale={locale} />
      <main>
        <Hero t={t} locale={locale} />
        <Logos t={t.logos} />
        <Services t={t.services} />
        <HowItWorks t={t.how} screens={t.screens} />
        <Tracking t={t.tracking} screens={t.screens} />
        <Bikers t={t.bikers} screens={t.screens} locale={locale} />
        <Plans t={t.plans} locale={locale} />
        <Faq t={t.faq} />
        <Cta t={t.cta} book={t.nav.book} locale={locale} />
      </main>
      <Footer t={t} locale={locale} />
    </div>
  );
}
