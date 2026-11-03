'use client';

import { Globe, Menu } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '@/components/ui/sheet';
import type { Dictionary } from '@/lib/dictionaries';
import type { Locale } from '@/lib/i18n';

const sections = ['how', 'services', 'tracking', 'bikers'] as const;

export function SiteHeader({ t, locale }: { t: Dictionary; locale: Locale }) {
  const [open, setOpen] = useState(false);
  const other: Locale = locale === 'ar' ? 'en' : 'ar';
  const brand = locale === 'ar' ? 'كلينو' : 'Kleano';

  return (
    <header className="sticky top-0 z-40 border-b bg-background/90 pt-[env(safe-area-inset-top)] backdrop-blur-md">
      <div className="mx-auto flex h-17 max-w-6xl items-center gap-5 px-4 md:px-8">
        <a href="#top" aria-label={brand} className="text-primary">
          <Logo className="h-9 w-auto" />
        </a>

        <nav aria-label={t.nav.sections} className="ms-auto hidden items-center gap-6 lg:flex">
          {sections.map((id) => (
            <a key={id} href={`#${id}`} className="text-[15px] text-muted-foreground transition-colors hover:text-foreground">
              {t.nav[id]}
            </a>
          ))}
        </nav>

        <div className="ms-auto flex items-center gap-2 lg:ms-0">
          <Button asChild variant="outline" size="chip">
            <Link href={`/${other}`} hrefLang={other} lang={other}>
              <Globe />
              {t.langSwitch}
            </Link>
          </Button>
          <ThemeToggle label={t.theme} />

          <Sheet open={open} onOpenChange={setOpen}>
            <SheetTrigger asChild>
              <Button variant="outline" size="chip" className="lg:hidden" aria-label={t.nav.menu}>
                <Menu />
              </Button>
            </SheetTrigger>
            <SheetContent side={locale === 'ar' ? 'left' : 'right'} className="w-72">
              <SheetHeader>
                <SheetTitle className="text-primary">
                  <Logo className="h-8 w-auto" />
                  <span className="sr-only">{brand}</span>
                </SheetTitle>
              </SheetHeader>
              <nav aria-label={t.nav.sections} className="grid gap-1 px-4">
                {sections.map((id) => (
                  <a
                    key={id}
                    href={`#${id}`}
                    onClick={() => setOpen(false)}
                    className="rounded-lg px-3 py-3 text-base font-medium hover:bg-muted"
                  >
                    {t.nav[id]}
                  </a>
                ))}
              </nav>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </header>
  );
}
