import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import {
  AppleIcon,
  ArrowIcon,
  BikeIcon,
  CameraIcon,
  CardIcon,
  CheckIcon,
  DropIcon,
  GlobeIcon,
  PinIcon,
  PlayIcon,
  WalletIcon,
  WebIcon,
} from '@/components/icons';
import '@/components/landing/landing.css';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { getDictionary } from '@/lib/dictionaries';
import { isLocale } from '@/lib/i18n';
import { storeLinks } from '@/lib/site';
import biker from '@/public/images/biker.jpg';
import inside from '@/public/images/inside.jpg';
import outside from '@/public/images/outside.jpg';
import washing from '@/public/images/washing.jpg';

export default async function LandingPage({ params }: PageProps<'/[locale]'>) {
  const { locale } = await params;
  if (!isLocale(locale)) notFound();
  const t = getDictionary(locale);
  const other = locale === 'ar' ? 'en' : 'ar';
  const trackIcons = [CheckIcon, BikeIcon, DropIcon, CameraIcon];
  const trustIcons = [PinIcon, CameraIcon, WalletIcon];
  const payIcons = [WalletIcon, CardIcon, AppleIcon];

  return (
    <div className="lp">
      <header className="lp-header">
        <div className="lp-wrap lp-bar">
          <a className="lp-logo" href="#top" aria-label={locale === 'ar' ? 'كلينو' : 'Kleano'}>
            <Logo />
          </a>
          <nav className="lp-links" aria-label={t.nav.sections}>
            <a href="#how">{t.nav.how}</a>
            <a href="#services">{t.nav.services}</a>
            <a href="#tracking">{t.nav.tracking}</a>
            <a href="#bikers">{t.nav.bikers}</a>
          </nav>
          <div className="lp-tools">
            <Link className="lp-chip" href={`/${other}`} hrefLang={other} lang={other}>
              <GlobeIcon />
              <span>{t.langSwitch}</span>
            </Link>
            <ThemeToggle label={t.theme} />
          </div>
        </div>
      </header>

      <main id="top">
        <div className="lp-wrap lp-hero">
          <div className="lp-hero-copy">
            <span className="eyebrow">{t.hero.eyebrow}</span>
            <h1>{t.hero.title}</h1>
            <p className="lp-lead">{t.hero.lead}</p>
            <div className="lp-ctas">
              <a className="lp-btn lp-btn-primary" href="#get">
                <span>{t.hero.ctaApp}</span>
                <ArrowIcon className="flip" />
              </a>
              <a className="lp-btn lp-btn-tonal" href="#get">
                <WebIcon />
                <span>{t.hero.ctaWeb}</span>
                <span className="lp-soon">{t.hero.soon}</span>
              </a>
            </div>
            <div className="lp-trust">
              {t.hero.trust.map((label, i) => {
                const TrustIcon = trustIcons[i];
                return (
                  <span key={label}>
                    <TrustIcon />
                    <span>{label}</span>
                  </span>
                );
              })}
            </div>
          </div>

          <div className="lp-hero-media">
            <div className="lp-hero-photo">
              <Image
                src={washing}
                alt={t.hero.photoAlt}
                fill
                priority
                placeholder="blur"
                sizes="(max-width: 900px) 100vw, 520px"
              />
            </div>
            <div className="lp-status" role="img" aria-label={t.status.label}>
              <div className="lp-status-top">
                <b>{t.status.title}</b>
                <span className="lp-live">
                  <i />
                  <span>{t.status.live}</span>
                </span>
              </div>
              <ol className="lp-stages">
                {t.status.stages.map((stage, i) => (
                  <li key={stage} className={i < 2 ? 'done' : i === 2 ? 'now' : undefined}>
                    {stage}
                  </li>
                ))}
              </ol>
              <small>{t.status.note}</small>
            </div>
          </div>
        </div>

        <section id="how" className="lp-section">
          <div className="lp-wrap">
            <div className="lp-head">
              <span className="eyebrow">{t.how.eyebrow}</span>
              <h2>{t.how.title}</h2>
            </div>
            <ol className="lp-steps">
              {t.how.steps.map((step) => (
                <li key={step.title}>
                  <h3>{step.title}</h3>
                  <p>{step.body}</p>
                </li>
              ))}
            </ol>
          </div>
        </section>

        <section id="services" className="lp-section">
          <div className="lp-wrap">
            <div className="lp-head">
              <span className="eyebrow">{t.services.eyebrow}</span>
              <h2>{t.services.title}</h2>
            </div>
            <div className="lp-services">
              <article className="lp-svc">
                <Image src={outside} alt={t.services.outside.alt} fill placeholder="blur" sizes="(max-width: 900px) 100vw, 360px" />
                <div className="lp-svc-body">
                  <h3>{t.services.outside.title}</h3>
                  <p>{t.services.outside.body}</p>
                </div>
              </article>
              <article className="lp-svc">
                <Image src={inside} alt={t.services.inside.alt} fill placeholder="blur" sizes="(max-width: 900px) 100vw, 360px" />
                <div className="lp-svc-body">
                  <h3>{t.services.inside.title}</h3>
                  <p>{t.services.inside.body}</p>
                </div>
              </article>
              <article className="lp-svc extras">
                <div className="lp-svc-body">
                  <div className="grid gap-1.5">
                    <h3>{t.services.extras.title}</h3>
                    <p>{t.services.extras.body}</p>
                  </div>
                  <ul className="lp-addons">
                    {t.services.addons.map((addon) => (
                      <li key={addon}>{addon}</li>
                    ))}
                  </ul>
                </div>
              </article>
            </div>
          </div>
        </section>

        <section id="tracking" className="lp-section">
          <div className="lp-wrap lp-track">
            <div>
              <div className="lp-head">
                <span className="eyebrow">{t.tracking.eyebrow}</span>
                <h2>{t.tracking.title}</h2>
                <p className="muted">{t.tracking.lead}</p>
              </div>
              <ol className="lp-timeline">
                {t.tracking.steps.map((step, i) => {
                  const StepIcon = trackIcons[i];
                  return (
                    <li key={step.title}>
                      <span className="lp-dot">
                        <StepIcon />
                      </span>
                      <div>
                        <b>{step.title}</b>
                        <span>{step.body}</span>
                      </div>
                    </li>
                  );
                })}
              </ol>
            </div>
            <div className="lp-photos">
              {[
                { src: outside, alt: t.services.outside.alt, caption: t.tracking.photos[0] },
                { src: inside, alt: t.services.inside.alt, caption: t.tracking.photos[1] },
              ].map((photo) => (
                <figure key={photo.caption}>
                  <div className="ph">
                    <Image src={photo.src} alt={photo.alt} fill placeholder="blur" sizes="(max-width: 900px) 50vw, 270px" />
                  </div>
                  <figcaption>{photo.caption}</figcaption>
                </figure>
              ))}
            </div>
          </div>
        </section>

        <section id="plans" className="lp-section">
          <div className="lp-wrap lp-duo">
            <div className="lp-panel brand">
              <span className="eyebrow">{t.plans.eyebrow}</span>
              <h2>{t.plans.title}</h2>
              <p>{t.plans.body}</p>
            </div>
            <div className="lp-panel">
              <h3>{t.plans.payTitle}</h3>
              <ul className="lp-pay">
                {t.plans.pay.map((method, i) => {
                  const PayIcon = payIcons[i];
                  return (
                    <li key={method}>
                      <PayIcon />
                      <span>{method}</span>
                    </li>
                  );
                })}
              </ul>
            </div>
          </div>
        </section>

        <section id="bikers" className="lp-section">
          <div className="lp-wrap">
            <div className="lp-biker">
              <div className="lp-biker-photo">
                <Image src={biker} alt={t.bikers.photoAlt} fill placeholder="blur" sizes="(max-width: 820px) 100vw, 480px" />
              </div>
              <div className="lp-biker-copy">
                <span className="eyebrow">{t.bikers.eyebrow}</span>
                <h2>{t.bikers.title}</h2>
                <ul className="lp-ticks">
                  {t.bikers.points.map((point) => (
                    <li key={point}>
                      <CheckIcon />
                      <span>{point}</span>
                    </li>
                  ))}
                </ul>
                <div className="lp-ctas">
                  <a className="lp-btn lp-btn-tonal" href="#get">
                    <span>{t.bikers.cta}</span>
                    <ArrowIcon className="flip" />
                  </a>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="get" className="lp-section">
          <div className="lp-wrap">
            <div className="lp-get">
              <h2>{t.get.title}</h2>
              <p>{t.get.body}</p>
              <div className="lp-stores">
                <a className="lp-store" href={storeLinks.appStore || '#get'}>
                  <AppleIcon />
                  <span>
                    <small>{t.get.appStoreSmall}</small>
                    <b>App Store</b>
                  </span>
                </a>
                <a className="lp-store" href={storeLinks.googlePlay || '#get'}>
                  <PlayIcon />
                  <span>
                    <small>{t.get.playSmall}</small>
                    <b>Google Play</b>
                  </span>
                </a>
                <span className="lp-store" aria-disabled="true">
                  <WebIcon />
                  <span>
                    <small>{t.hero.soon}</small>
                    <b>{t.get.web}</b>
                  </span>
                </span>
              </div>
            </div>
          </div>
        </section>
      </main>

      <footer className="lp-wrap lp-footer">
        <div className="lp-foot">
          <a className="lp-logo" href="#top" aria-label={locale === 'ar' ? 'كلينو' : 'Kleano'}>
            <Logo />
          </a>
          <span>{t.footer}</span>
        </div>
      </footer>
    </div>
  );
}
