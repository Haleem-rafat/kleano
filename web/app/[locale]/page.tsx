import {
  ArrowRight,
  Bike,
  Camera,
  Check,
  CreditCard,
  Droplets,
  MapPin,
  MonitorSmartphone,
  Wallet,
  type LucideIcon,
} from 'lucide-react';
import Image from 'next/image';
import { notFound } from 'next/navigation';
import type { ReactNode } from 'react';
import { AppleIcon, PlayIcon } from '@/components/icons';
import { Logo } from '@/components/logo';
import { AppPhone } from '@/components/site/app-phone';
import { SiteHeader } from '@/components/site/site-header';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { DirectionAwareTabs } from '@/components/ui/direction-aware-tabs';
import { HaloBadge } from '@/components/ui/halo-badge';
import { getDictionary } from '@/lib/dictionaries';
import { isLocale } from '@/lib/i18n';
import { storeLinks } from '@/lib/site';
import biker from '@/public/images/biker.jpg';
import inside from '@/public/images/inside.jpg';
import outside from '@/public/images/outside.jpg';
import bikerScreen from '@/public/images/screens/biker-app.jpg';
import customerScreen from '@/public/images/screens/customer-app.jpg';
import washing from '@/public/images/washing.jpg';

function SectionHead({ eyebrow, title, lead }: { eyebrow: string; title: string; lead?: string }) {
  return (
    <div className="mb-10 grid max-w-2xl gap-3">
      <span className="text-[13px] font-semibold tracking-[0.08em] text-primary uppercase rtl:text-sm rtl:tracking-normal">
        {eyebrow}
      </span>
      <h2 className="text-[clamp(28px,3.8vw,42px)] leading-[1.12] font-semibold tracking-tight rtl:leading-[1.3] rtl:tracking-normal">
        {title}
      </h2>
      {lead ? <p className="text-muted-foreground">{lead}</p> : null}
    </div>
  );
}

function Section({ id, children }: { id: string; children: ReactNode }) {
  return (
    <section id={id} className="scroll-mt-20 py-16 md:py-20">
      <div className="mx-auto max-w-6xl px-4 md:px-8">{children}</div>
    </section>
  );
}

export default async function LandingPage({ params }: PageProps<'/[locale]'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getDictionary(locale);
  const brand = locale === 'ar' ? 'كلينو' : 'Kleano';

  const trustIcons: LucideIcon[] = [MapPin, Camera, Wallet];
  const trackIcons: LucideIcon[] = [Check, Bike, Droplets, Camera];
  const payIcons = [Wallet, CreditCard, AppleIcon];

  return (
    <>
      <SiteHeader t={t} locale={locale} />

      <main id="top">
        {/* Hero: the promise on one side, the app's live wash status on the other. */}
        <div className="mx-auto grid max-w-6xl items-center gap-12 px-4 pt-10 pb-16 md:px-8 lg:grid-cols-[1.05fr_0.95fr] lg:gap-14 lg:pt-16 lg:pb-24">
          <div className="grid min-w-0 gap-6">
            <HaloBadge live variant="default" className="text-xs">
              {t.hero.eyebrow}
            </HaloBadge>
            <h1 className="text-[clamp(40px,6.4vw,72px)] leading-[1.04] font-bold tracking-[-0.025em] rtl:leading-[1.25] rtl:tracking-normal">
              {t.hero.title}
            </h1>
            <p className="max-w-[30em] text-[clamp(18px,1.9vw,21px)] text-muted-foreground">{t.hero.lead}</p>
            <div className="flex flex-wrap gap-3 pt-1">
              <Button asChild size="xl">
                <a href="#get">
                  {t.hero.ctaApp}
                  <ArrowRight className="rtl:-scale-x-100" />
                </a>
              </Button>
              <Button asChild size="xl" variant="secondary">
                <a href="#get">
                  <MonitorSmartphone />
                  {t.hero.ctaWeb}
                  <Badge variant="outline" className="bg-card">
                    {t.hero.soon}
                  </Badge>
                </a>
              </Button>
            </div>
            <ul className="flex flex-wrap gap-x-5 gap-y-2 text-sm text-muted-foreground">
              {t.hero.trust.map((label, i) => {
                const Icon = trustIcons[i];
                return (
                  <li key={label} className="inline-flex items-center gap-1.5">
                    <Icon className="size-4 text-primary" aria-hidden="true" />
                    {label}
                  </li>
                );
              })}
            </ul>
          </div>

          <div className="relative min-w-0">
            <div className="relative overflow-hidden rounded-sheet">
              <Image
                src={washing}
                alt={t.hero.photoAlt}
                priority
                placeholder="blur"
                sizes="(max-width: 1024px) 100vw, 520px"
                className="aspect-[4/5] w-full object-cover object-[60%_30%] sm:aspect-[5/5] lg:aspect-[4/5]"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent" />
            </div>
            <div className="absolute -bottom-8 start-4 sm:start-8 lg:-start-10">
              <AppPhone
                screen={customerScreen}
                alt={t.status.screenAlt}
                scale={0.62}
                priority
                island={{ title: t.status.island.title, stage: t.status.island.stage, progress: 66 }}
              />
              <p className="mt-2 text-center text-xs text-muted-foreground">
                {t.status.tapHint}
              </p>
            </div>
          </div>
        </div>

        <Section id="how">
          <SectionHead eyebrow={t.how.eyebrow} title={t.how.title} />
          <ol className="grid gap-5 md:grid-cols-3">
            {t.how.steps.map((step, i) => (
              <li key={step.title}>
                <Card className="h-full rounded-card border-0 py-7 shadow-none">
                  <CardContent className="grid gap-2.5 px-6">
                    <span className="mb-2 grid size-9 place-items-center rounded-full bg-secondary font-heading font-semibold text-secondary-foreground">
                      {(i + 1).toLocaleString(locale === 'ar' ? 'ar-EG' : 'en')}
                    </span>
                    <h3 className="text-xl font-semibold">{step.title}</h3>
                    <p className="text-muted-foreground">{step.body}</p>
                  </CardContent>
                </Card>
              </li>
            ))}
          </ol>
        </Section>

        <Section id="services">
          <SectionHead eyebrow={t.services.eyebrow} title={t.services.title} />
          <div className="grid gap-5 md:grid-cols-3">
            {[
              { img: outside, ...t.services.outside },
              { img: inside, ...t.services.inside },
            ].map((svc) => (
              <article key={svc.title} className="group relative isolate flex min-h-96 items-end overflow-hidden rounded-card text-white">
                <Image
                  src={svc.img}
                  alt={svc.alt}
                  fill
                  placeholder="blur"
                  sizes="(max-width: 768px) 100vw, 360px"
                  className="-z-20 object-cover transition-transform duration-500 group-hover:scale-105 motion-reduce:transition-none"
                />
                <div className="absolute inset-0 -z-10 bg-gradient-to-t from-black/85 via-black/20 to-transparent" />
                <div className="grid gap-1.5 p-6">
                  <h3 className="text-xl font-semibold">{svc.title}</h3>
                  <p className="text-base text-white/80">{svc.body}</p>
                </div>
              </article>
            ))}
            <Card className="min-h-96 rounded-card border-0 bg-secondary py-6 text-secondary-foreground shadow-none">
              <CardContent className="flex h-full flex-col justify-between gap-6 px-6">
                <div className="grid gap-1.5">
                  <h3 className="text-xl font-semibold">{t.services.extras.title}</h3>
                  <p className="opacity-85">{t.services.extras.body}</p>
                </div>
                <div className="flex flex-wrap gap-2">
                  {t.services.addons.map((addon) => (
                    <Badge key={addon} variant="outline" className="h-auto border-0 bg-card px-3.5 py-2 text-sm text-foreground">
                      {addon}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </Section>

        <Section id="tracking">
          <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-14">
            <div>
              <SectionHead eyebrow={t.tracking.eyebrow} title={t.tracking.title} lead={t.tracking.lead} />
              <ol className="grid">
                {t.tracking.steps.map((step, i) => {
                  const Icon = trackIcons[i];
                  return (
                    <li key={step.title} className="relative grid grid-cols-[40px_1fr] gap-4 pb-6 last:pb-0">
                      {i < t.tracking.steps.length - 1 ? (
                        <span className="absolute start-[19px] top-10 bottom-1 w-0.5 bg-border" aria-hidden="true" />
                      ) : null}
                      <span className="grid size-10 place-items-center rounded-full bg-secondary text-secondary-foreground">
                        <Icon className="size-5" aria-hidden="true" />
                      </span>
                      <div className="pt-1.5">
                        <b className="block font-heading text-[17px] font-semibold">{step.title}</b>
                        <span className="text-[15px] text-muted-foreground">{step.body}</span>
                      </div>
                    </li>
                  );
                })}
              </ol>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {[
                { img: outside, alt: t.services.outside.alt, caption: t.tracking.photos[0] },
                { img: inside, alt: t.services.inside.alt, caption: t.tracking.photos[1] },
              ].map((photo) => (
                <figure key={photo.caption} className="grid min-w-0 gap-2">
                  <Image
                    src={photo.img}
                    alt={photo.alt}
                    placeholder="blur"
                    sizes="(max-width: 1024px) 50vw, 270px"
                    className="aspect-[3/4] w-full rounded-card object-cover"
                  />
                  <figcaption className="text-center text-sm text-muted-foreground">{photo.caption}</figcaption>
                </figure>
              ))}
            </div>
          </div>
        </Section>

        {/* One place for both apps: customers and bikers, switched with Cult UI's direction-aware tabs. */}
        <Section id="bikers">
          <DirectionAwareTabs
            rtl={locale === 'ar'}
            className="mb-8"
            tabs={[
              {
                id: 0,
                label: t.bikers.tabCustomers,
                content: (
                  <div className="grid gap-5 pt-2 md:grid-cols-[1.2fr_0.8fr]">
                    <Card className="rounded-card border-0 bg-primary py-8 text-primary-foreground shadow-none">
                      <CardContent className="grid gap-4 px-8">
                        <span className="text-[13px] font-semibold tracking-[0.08em] uppercase opacity-80 rtl:text-sm rtl:tracking-normal">
                          {t.plans.eyebrow}
                        </span>
                        <h2 className="text-[clamp(28px,3.8vw,42px)] leading-[1.12] font-semibold rtl:leading-[1.3]">{t.plans.title}</h2>
                        <p className="opacity-90">{t.plans.body}</p>
                      </CardContent>
                    </Card>
                    <Card className="rounded-card border-0 py-8 shadow-none">
                      <CardContent className="grid gap-4 px-8">
                        <h3 className="text-xl font-semibold">{t.plans.payTitle}</h3>
                        <ul className="grid gap-2.5">
                          {t.plans.pay.map((method, i) => {
                            const Icon = payIcons[i];
                            return (
                              <li key={method} className="flex items-center gap-3 rounded-lg bg-background px-4 py-3.5 font-medium">
                                <Icon className="size-5.5 text-primary" aria-hidden="true" />
                                {method}
                              </li>
                            );
                          })}
                        </ul>
                      </CardContent>
                    </Card>
                  </div>
                ),
              },
              {
                id: 1,
                label: t.bikers.tabBikers,
                content: (
                  <div className="grid items-center gap-8 overflow-hidden rounded-sheet bg-card pt-2 md:grid-cols-[0.9fr_1.1fr]">
                    <div className="relative min-h-80 self-stretch">
                      <Image src={biker} alt={t.bikers.photoAlt} fill placeholder="blur" sizes="(max-width: 768px) 100vw, 480px" className="object-cover object-[60%_40%]" />
                      <div className="absolute inset-0 grid place-items-center bg-black/25">
                        <AppPhone screen={bikerScreen} alt={t.bikers.screenAlt} scale={0.55} />
                      </div>
                    </div>
                    <div className="grid content-center gap-5 px-6 pb-8 md:py-10 md:pe-10 md:ps-0">
                      <span className="text-[13px] font-semibold tracking-[0.08em] text-primary uppercase rtl:text-sm rtl:tracking-normal">
                        {t.bikers.eyebrow}
                      </span>
                      <h2 className="text-[clamp(28px,3.8vw,42px)] leading-[1.12] font-semibold rtl:leading-[1.3]">{t.bikers.title}</h2>
                      <ul className="grid gap-2.5">
                        {t.bikers.points.map((point) => (
                          <li key={point} className="flex items-start gap-2.5">
                            <Check className="mt-1 size-5 shrink-0 text-primary" aria-hidden="true" />
                            {point}
                          </li>
                        ))}
                      </ul>
                      <div>
                        <Button asChild size="xl" variant="secondary">
                          <a href="#get">
                            {t.bikers.cta}
                            <ArrowRight className="rtl:-scale-x-100" />
                          </a>
                        </Button>
                      </div>
                    </div>
                  </div>
                ),
              },
            ]}
          />
        </Section>

        <Section id="get">
          <div className="grid justify-items-center gap-6 rounded-sheet bg-secondary px-5 py-12 text-center text-secondary-foreground md:px-10 md:py-16">
            <h2 className="text-[clamp(28px,3.8vw,42px)] leading-[1.12] font-semibold rtl:leading-[1.3]">{t.get.title}</h2>
            <p className="max-w-[34em]">{t.get.body}</p>
            <div className="flex flex-wrap justify-center gap-3">
              {[
                { href: storeLinks.appStore, Icon: AppleIcon, small: t.get.appStoreSmall, name: 'App Store' },
                { href: storeLinks.googlePlay, Icon: PlayIcon, small: t.get.playSmall, name: 'Google Play' },
              ].map(({ href, Icon, small, name }) => (
                <a
                  key={name}
                  href={href || '#get'}
                  className="inline-flex h-14 items-center gap-2.5 rounded-2xl bg-foreground px-5 text-start text-background transition-opacity hover:opacity-90"
                >
                  <Icon className="size-6.5" />
                  <span>
                    <small className="block text-[11px] leading-tight opacity-75">{small}</small>
                    <b className="block font-heading text-[17px] leading-tight font-semibold">{name}</b>
                  </span>
                </a>
              ))}
              <span aria-disabled="true" className="inline-flex h-14 items-center gap-2.5 rounded-2xl border border-foreground/20 px-5 text-start">
                <MonitorSmartphone className="size-6" aria-hidden="true" />
                <span>
                  <small className="block text-[11px] leading-tight opacity-75">{t.hero.soon}</small>
                  <b className="block font-heading text-[17px] leading-tight font-semibold">{t.get.web}</b>
                </span>
              </span>
            </div>
          </div>
        </Section>
      </main>

      <footer className="mx-auto max-w-6xl px-4 pt-6 pb-12 md:px-8">
        <div className="flex flex-wrap items-center justify-between gap-4 border-t pt-6 text-sm text-muted-foreground">
          <a href="#top" aria-label={brand} className="text-primary">
            <Logo className="h-7 w-auto" />
          </a>
          <span>{t.footer}</span>
        </div>
      </footer>
    </>
  );
}
