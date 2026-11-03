'use client';

import { Globe } from 'lucide-react';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Button } from '@/components/ui/button';
import type { Dictionary } from '@/lib/dictionaries';
import type { Locale } from '@/lib/i18n';
import { cn } from '@/lib/utils';

/** Past this, the bar gathers into a pill. Not 0, so an iOS rubber-band cannot flicker it. */
const CONTRACT_AT = 24;

/** One passive scroll listener, work deferred to a frame; nothing measures layout. */
function useContracted() {
  const [contracted, setContracted] = useState(false);
  useEffect(() => {
    let queued = false;
    const update = () => {
      queued = false;
      setContracted(window.scrollY > CONTRACT_AT);
    };
    const onScroll = () => {
      if (queued) return;
      queued = true;
      requestAnimationFrame(update);
    };
    update();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);
  return contracted;
}

/**
 * Landing header, after Framecast's: a transparent full-width bar at the top of the page that
 * gathers into a centred floating pill once content runs under it. It never hides, so the
 * "Book a wash" button is always one tap away. Section links live in the dock below.
 */
export function SiteHeader({ t, locale }: { t: Dictionary; locale: Locale }) {
  const contracted = useContracted();
  const other: Locale = locale === 'ar' ? 'en' : 'ar';
  const brand = locale === 'ar' ? 'كلينو' : 'Kleano';

  return (
    <header className="fixed inset-x-0 top-0 z-40 px-3 pt-[calc(10px+env(safe-area-inset-top))]">
      <div
        className={cn(
          'mx-auto flex h-14 items-center gap-3 transition-all duration-300 ease-out',
          contracted ? 'max-w-3xl rounded-full border bg-card/85 px-3 shadow-input backdrop-blur-xl' : 'max-w-6xl px-2 md:px-5',
        )}
      >
        <a href="#top" aria-label={brand} className="ps-2 text-primary">
          <Logo className="h-9 w-auto" />
        </a>
        <div className="ms-auto flex items-center gap-2">
          <Button asChild variant="ghost" size="chip" className="hidden sm:inline-flex">
            <Link href={`/${other}`} hrefLang={other} lang={other}>
              <Globe />
              {t.langSwitch}
            </Link>
          </Button>
          <Button asChild variant="ghost" size="chip" className="sm:hidden" aria-label={t.langSwitch}>
            <Link href={`/${other}`} hrefLang={other} lang={other}>
              <Globe />
            </Link>
          </Button>
          <ThemeToggle label={t.theme} />
          <Button asChild className="h-10 px-4 text-sm font-semibold">
            <Link href={`/${locale}/app/book`}>{t.hero.ctaBook}</Link>
          </Button>
        </div>
      </div>
    </header>
  );
}
