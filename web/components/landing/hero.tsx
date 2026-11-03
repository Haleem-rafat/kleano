import { BookButton } from '@/components/landing/book-button';
import { Display, Label } from '@/components/landing/shared';
import { HeroPhones } from '@/components/landing/hero-phones';
import { ContainerScroll } from '@/components/ui/container-scroll-animation';
import { FlipWords } from '@/components/ui/flip-words';
import { Spotlight } from '@/components/ui/spotlight-new';
import type { Dictionary } from '@/lib/content';
import type { Locale } from '@/lib/i18n';

/** Spotlight over a dot grid; the phone tilts flat on scroll (Aceternity Container Scroll). */
export function Hero({ t, locale }: { t: Dictionary; locale: Locale }) {
  return (
    <div id="top" className="relative isolate overflow-hidden">
      <div aria-hidden="true" className="absolute inset-0 -z-20 [background-image:radial-gradient(var(--border)_1px,transparent_1px)] [background-size:22px_22px] [mask-image:radial-gradient(70%_60%_at_50%_30%,black,transparent)]" />
      <div aria-hidden="true" className="absolute inset-0 -z-10 bg-[radial-gradient(50%_40%_at_50%_62%,var(--primary)_0%,transparent_70%)] opacity-[0.14]" />
      <Spotlight />
      <ContainerScroll
        titleComponent={
          <div className="grid justify-items-center gap-6">
            <Label className="max-w-[90%] text-balance">{t.hero.eyebrow}</Label>
            <Display as="h1">
              {t.hero.titleStart} <FlipWords words={t.hero.flip} className="text-primary" />
            </Display>
            <p className="max-w-2xl text-[clamp(17px,1.8vw,20px)] text-pretty text-muted-foreground">{t.hero.lead}</p>
            <div className="flex flex-wrap items-center justify-center gap-3 pt-1">
              <BookButton locale={locale} label={t.nav.book} />
              <a href="#how" className="inline-flex h-13 items-center rounded-full border px-7 text-base font-medium transition hover:bg-muted">
                {t.hero.how}
              </a>
            </div>
          </div>
        }
      >
        <HeroPhones screens={t.screens} />
      </ContainerScroll>
    </div>
  );
}
