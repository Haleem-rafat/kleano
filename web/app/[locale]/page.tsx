import { ArrowRight, Bike, Camera, Check, Clock, CreditCard, Droplets, HeartHandshake, MapPin, Phone, ReceiptText, Wallet, type LucideIcon } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import type { ReactNode } from 'react';
import { AppleIcon, PlayIcon } from '@/components/icons';
import { Logo } from '@/components/logo';
import { LandingDock, LandingDockSpacer } from '@/components/site/landing-dock';
import { SiteHeader } from '@/components/site/site-header';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Spotlight } from '@/components/ui/spotlight-new';
import { Tabs } from '@/components/ui/tabs';
import { getDictionary, type Dictionary } from '@/lib/dictionaries';
import { isLocale, type Locale } from '@/lib/i18n';
import { storeLinks } from '@/lib/site';
import biker from '@/public/images/biker.jpg';
import inside from '@/public/images/inside.jpg';
import outside from '@/public/images/outside.jpg';
import washing from '@/public/images/washing.jpg';

/*
 * Landing page structure, learned from Framecast's landing v2 (four-block structure):
 *   1. Hook        the reader's problem, then a call to action with four parts
 *   2. Value       three outcomes, not a feature list
 *   3. Credibility checkable facts only; no invented reviews, logos or numbers
 *   4. Details     how it works, services, tracking, customers and bikers
 *   then FAQ and a closing call to action that repeats the same four parts.
 */

const eyebrow = 'text-[13px] font-semibold tracking-[0.08em] text-primary uppercase rtl:text-sm rtl:tracking-normal';
const h2 = 'text-[clamp(28px,3.8vw,42px)] leading-[1.12] font-semibold tracking-tight text-balance rtl:leading-[1.3] rtl:tracking-normal';

function SectionHead({ kicker, title, lead, center }: { kicker?: string; title: string; lead?: string; center?: boolean }) {
  return (
    <div className={center ? 'mx-auto mb-12 grid max-w-2xl gap-3 text-center' : 'mb-10 grid max-w-2xl gap-3'}>
      {kicker ? <span className={eyebrow}>{kicker}</span> : null}
      <h2 className={h2}>{title}</h2>
      {lead ? <p className="text-lg text-pretty text-muted-foreground">{lead}</p> : null}
    </div>
  );
}

function Section({ id, children, className }: { id?: string; children: ReactNode; className?: string }) {
  return (
    <section id={id} className={`scroll-mt-24 py-16 md:py-24 ${className ?? ''}`}>
      <div className="mx-auto max-w-6xl px-4 md:px-8">{children}</div>
    </section>
  );
}

/** The call to action with all four parts: the action, how long, the price, what happens next. */
function BookCta({ t, locale, center }: { t: Dictionary; locale: Locale; center?: boolean }) {
  return (
    <div className={center ? 'grid justify-items-center gap-4' : 'grid gap-4'}>
      <div className="flex flex-wrap gap-3">
        <Button asChild size="xl">
          <Link href={`/${locale}/app/book`}>
            {t.hero.ctaBook}
            <ArrowRight className="rtl:-scale-x-100" />
          </Link>
        </Button>
        <Button asChild size="xl" variant="secondary">
          <a href="#get">{t.hero.ctaApp}</a>
        </Button>
      </div>
      <ul className={`flex flex-wrap gap-x-4 gap-y-1.5 text-sm text-muted-foreground ${center ? 'justify-center' : ''}`}>
        {t.hero.ctaFacts.map((fact, i) => {
          const Icon = [Clock, ReceiptText, Bike][i];
          return (
            <li key={fact} className="inline-flex items-center gap-1.5">
              <Icon className="size-4 text-primary" aria-hidden="true" />
              {fact}
            </li>
          );
        })}
      </ul>
    </div>
  );
}

export default async function LandingPage({ params }: PageProps<'/[locale]'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getDictionary(locale);
  const brand = locale === 'ar' ? 'كلينو' : 'Kleano';
  const trackIcons: LucideIcon[] = [Check, Bike, Droplets, Camera];
  const payIcons = [Wallet, CreditCard, AppleIcon];
  const outcomeIcons: LucideIcon[] = [Clock, HeartHandshake, Wallet];
  const factIcons: LucideIcon[] = [Camera, Phone, ReceiptText];

  return (
    <>
      <SiteHeader t={t} locale={locale} />

      <main id="top">
        {/* 1. Hook. The header floats over the page, so the hero pads for it. */}
        <div className="relative isolate overflow-hidden pt-20">
          {/* Always-painted ground: a soft purple wash and a pool of light behind the headline. */}
          <div aria-hidden="true" className="pointer-events-none absolute inset-0 -z-20">
            <div className="absolute inset-0 bg-gradient-to-b from-primary/10 via-primary/5 to-transparent" />
            <div className="absolute inset-0 bg-[radial-gradient(55%_45%_at_25%_30%,var(--primary)_0%,transparent_70%)] opacity-[0.08] dark:opacity-[0.16] rtl:bg-[radial-gradient(55%_45%_at_75%_30%,var(--primary)_0%,transparent_70%)]" />
          </div>
          <Spotlight />
          <div className="relative mx-auto grid max-w-6xl items-center gap-12 px-4 pt-10 pb-16 md:px-8 lg:grid-cols-[1.1fr_0.9fr] lg:gap-14 lg:pt-16 lg:pb-24">
            <div className="grid min-w-0 gap-6">
              <Badge variant="outline" className="h-7 w-fit gap-2 bg-card px-3 text-xs">
                <span className="relative flex size-2">
                  <span className="absolute inline-flex size-full animate-ping rounded-full bg-success opacity-60 motion-reduce:animate-none" />
                  <span className="relative inline-flex size-2 rounded-full bg-success" />
                </span>
                {t.hero.eyebrow}
              </Badge>
              <h1 className="text-[clamp(36px,5.4vw,64px)] leading-[1.06] font-bold tracking-[-0.025em] text-balance rtl:leading-[1.3] rtl:tracking-normal">
                {t.hero.title}
              </h1>
              <p className="max-w-[34em] text-[clamp(17px,1.8vw,20px)] text-pretty text-muted-foreground">{t.hero.lead}</p>
              <BookCta t={t} locale={locale} />
            </div>

            <div className="relative min-w-0">
              <div className="relative overflow-hidden rounded-sheet">
                <Image
                  src={washing}
                  alt={t.hero.photoAlt}
                  priority
                  placeholder="blur"
                  sizes="(max-width: 1024px) 100vw, 480px"
                  className="aspect-[4/5] w-full object-cover object-[60%_30%] sm:aspect-square lg:aspect-[4/5]"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent" />
              </div>
              {/* The app's live wash status, as a card over the photo. */}
              <div className="absolute start-4 -bottom-6 w-[min(320px,86%)] rounded-card bg-card p-4 shadow-input sm:start-8 lg:-start-8">
                <div className="flex items-center justify-between gap-3">
                  <b className="font-heading text-[15px] font-semibold">{t.status.island.title}</b>
                  <span className="text-xs text-muted-foreground tabular-nums">{t.status.island.stage}</span>
                </div>
                <ol className="mt-3 grid grid-cols-4 gap-1.5">
                  {t.tracking.steps.map((step, i) => (
                    <li key={step.title} className={i === 2 ? 'grid gap-1.5 text-center text-xs font-semibold' : 'grid gap-1.5 text-center text-xs text-muted-foreground'}>
                      <span className={i <= 2 ? 'h-1 rounded-full bg-primary' : 'h-1 rounded-full bg-border'} />
                      {step.title}
                    </li>
                  ))}
                </ol>
              </div>
            </div>
          </div>
        </div>

        {/* 2. Value: three outcomes, right after the hook. */}
        <Section>
          <SectionHead title={t.value.lead} lead={t.value.intro} center />
          <ul className="grid gap-5 sm:grid-cols-3">
            {t.value.outcomes.map((o, i) => {
              const Icon = outcomeIcons[i];
              return (
                <li key={o.name} className="grid content-start gap-3 rounded-card border bg-card/70 p-6 backdrop-blur-sm">
                  <span className="grid size-11 place-items-center rounded-full bg-secondary text-primary">
                    <Icon className="size-5" aria-hidden="true" />
                  </span>
                  <h3 className="text-lg font-semibold">{o.name}</h3>
                  <p className="text-pretty text-muted-foreground">{o.detail}</p>
                </li>
              );
            })}
          </ul>
        </Section>

        {/* 3. Credibility: only what the app really does. */}
        <Section className="bg-card/50">
          <SectionHead title={t.credibility.heading} center />
          <dl className="grid gap-10 sm:grid-cols-3">
            {t.credibility.facts.map((f, i) => {
              const Icon = factIcons[i];
              return (
                <div key={f.claim} className="grid content-start justify-items-center gap-2 text-center">
                  <Icon className="mb-1 size-7 text-primary" aria-hidden="true" />
                  <dt className="text-lg font-semibold text-balance">{f.claim}</dt>
                  <dd className="max-w-xs text-pretty text-muted-foreground">{f.detail}</dd>
                </div>
              );
            })}
          </dl>
          {t.credibility.operatorNote ? <p className="mx-auto mt-10 max-w-2xl text-center text-muted-foreground">{t.credibility.operatorNote}</p> : null}
        </Section>

        {/* 4. Details. */}
        <Section id="how">
          <SectionHead kicker={t.how.eyebrow} title={t.how.title} />
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
          <SectionHead kicker={t.services.eyebrow} title={t.services.title} />
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
              <SectionHead kicker={t.tracking.eyebrow} title={t.tracking.title} lead={t.tracking.lead} />
              <ol className="grid">
                {t.tracking.steps.map((step, i) => {
                  const Icon = trackIcons[i];
                  return (
                    <li key={step.title} className="relative grid grid-cols-[40px_1fr] gap-4 pb-6 last:pb-0">
                      {i < t.tracking.steps.length - 1 ? <span className="absolute start-[19px] top-10 bottom-1 w-0.5 bg-border" aria-hidden="true" /> : null}
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
                  <Image src={photo.img} alt={photo.alt} placeholder="blur" sizes="(max-width: 1024px) 50vw, 270px" className="aspect-[3/4] w-full rounded-card object-cover" />
                  <figcaption className="text-center text-sm text-muted-foreground">{photo.caption}</figcaption>
                </figure>
              ))}
            </div>
          </div>
        </Section>

        {/* Customers and bikers, switched with Aceternity's stacked tabs. */}
        <Section id="bikers">
          <div className="relative flex h-[50rem] flex-col items-start [perspective:1000px] sm:h-[44rem] md:h-[30rem]">
            <Tabs
              containerClassName="w-fit rounded-full bg-muted p-1"
              contentClassName="mt-6"
              tabs={[
                {
                  value: 'customers',
                  title: t.bikers.tabCustomers,
                  content: (
                    <div className="grid h-full gap-5 rounded-sheet bg-background md:grid-cols-[1.2fr_0.8fr]">
                      <Card className="rounded-card border-0 bg-primary py-8 text-primary-foreground shadow-none">
                        <CardContent className="grid gap-4 px-8">
                          <span className="text-[13px] font-semibold tracking-[0.08em] uppercase opacity-80 rtl:text-sm rtl:tracking-normal">{t.plans.eyebrow}</span>
                          <h2 className={h2}>{t.plans.title}</h2>
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
                  value: 'bikers',
                  title: t.bikers.tabBikers,
                  content: (
                    <div className="grid h-full items-center gap-8 overflow-hidden rounded-sheet bg-card shadow-input md:grid-cols-[0.9fr_1.1fr]">
                      <div className="relative min-h-72 self-stretch">
                        <Image src={biker} alt={t.bikers.photoAlt} fill placeholder="blur" sizes="(max-width: 768px) 100vw, 480px" className="object-cover object-[60%_40%]" />
                      </div>
                      <div className="grid content-center gap-5 px-6 pb-8 md:py-10 md:ps-0 md:pe-10">
                        <span className={eyebrow}>{t.bikers.eyebrow}</span>
                        <h2 className={h2}>{t.bikers.title}</h2>
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
                            <Link href={`/${locale}/biker/login`}>
                              {t.bikers.cta}
                              <ArrowRight className="rtl:-scale-x-100" />
                            </Link>
                          </Button>
                        </div>
                      </div>
                    </div>
                  ),
                },
              ]}
            />
          </div>
        </Section>

        {/* FAQ: only answers the app can back up. */}
        <Section id="faq">
          <SectionHead title={t.faq.title} center />
          <Accordion type="single" collapsible className="mx-auto w-full max-w-3xl">
            {t.faq.items.map((item) => (
              <AccordionItem key={item.q} value={item.q}>
                <AccordionTrigger className="text-start text-base font-semibold">{item.q}</AccordionTrigger>
                <AccordionContent className="text-base text-pretty text-muted-foreground">{item.a}</AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </Section>

        {/* Closing call to action: the same four parts as the hero, for whoever needed longer to decide. */}
        <section className="relative isolate overflow-hidden py-20 md:py-28">
          <Spotlight />
          <div className="mx-auto grid max-w-3xl justify-items-center gap-5 px-4 text-center">
            <MapPin className="size-8 text-primary" aria-hidden="true" />
            <h2 className={h2}>{t.cta.title}</h2>
            <p className="text-lg text-pretty text-muted-foreground">{t.cta.body}</p>
            <BookCta t={t} locale={locale} center />
          </div>
        </section>

        <Section id="get">
          <div className="grid justify-items-center gap-6 rounded-sheet bg-secondary px-5 py-12 text-center text-secondary-foreground md:px-10 md:py-16">
            <h2 className={h2}>{t.get.title}</h2>
            <p className="max-w-[34em]">{t.get.body}</p>
            <div className="flex flex-wrap justify-center gap-3">
              {[
                { href: storeLinks.appStore, Icon: AppleIcon, small: t.get.appStoreSmall, name: 'App Store' },
                { href: storeLinks.googlePlay, Icon: PlayIcon, small: t.get.playSmall, name: 'Google Play' },
              ].map(({ href, Icon, small, name }) => (
                <a key={name} href={href || '#get'} className="inline-flex h-14 items-center gap-2.5 rounded-2xl bg-foreground px-5 text-start text-background transition-opacity hover:opacity-90">
                  <Icon className="size-6.5" />
                  <span>
                    <small className="block text-[11px] leading-tight opacity-75">{small}</small>
                    <b className="block font-heading text-[17px] leading-tight font-semibold">{name}</b>
                  </span>
                </a>
              ))}
              <Link href={`/${locale}/app/book`} className="inline-flex h-14 items-center gap-2.5 rounded-2xl border border-foreground/20 px-5 text-start transition hover:border-primary">
                <MapPin className="size-6" aria-hidden="true" />
                <span>
                  <small className="block text-[11px] leading-tight opacity-75">{t.hero.ctaBook}</small>
                  <b className="block font-heading text-[17px] leading-tight font-semibold">{t.get.web}</b>
                </span>
              </Link>
            </div>
          </div>
        </Section>
      </main>

      <footer className="mx-auto max-w-6xl px-4 pt-6 md:px-8">
        <div className="flex flex-wrap items-center justify-between gap-4 border-t pt-6 text-sm text-muted-foreground">
          <a href="#top" aria-label={brand} className="text-primary">
            <Logo className="h-7 w-auto" />
          </a>
          <span>{t.footer}</span>
        </div>
        <LandingDockSpacer />
      </footer>

      <LandingDock t={t} />
    </>
  );
}
