'use client';

import { Globe } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { BookButton } from '@/components/landing/book-button';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { MobileNav, MobileNavHeader, MobileNavMenu, MobileNavToggle, NavBody, NavItems, Navbar } from '@/components/ui/resizable-navbar';
import type { Dictionary } from '@/lib/content';
import type { Locale } from '@/lib/i18n';

const sections = ['services', 'how', 'tracking', 'bikers', 'plans', 'faq'] as const;

/** Aceternity Resizable Navbar: full width at the top, a glass pill on scroll, a drawer on phones. */
export function LandingNavbar({ t, locale }: { t: Dictionary; locale: Locale }) {
  const [open, setOpen] = useState(false);
  const other: Locale = locale === 'ar' ? 'en' : 'ar';
  const items = sections.map((id) => ({ name: t.nav[id], link: `#${id}` }));
  const language = (
    <Link href={`/${other}`} hrefLang={other} lang={other} aria-label={t.langSwitch} className="inline-flex h-10 items-center gap-1.5 rounded-full px-3 text-sm text-muted-foreground hover:bg-muted hover:text-foreground">
      <Globe className="size-4.5" aria-hidden="true" />
      <span className="hidden sm:inline">{t.langSwitch}</span>
    </Link>
  );
  const logo = (
    <a href="#top" aria-label={t.brand} className="shrink-0 px-2 text-primary">
      <Logo className="h-9 w-auto" />
    </a>
  );

  return (
    <Navbar>
      <NavBody>
        {logo}
        <NavItems items={items} />
        <div className="flex shrink-0 items-center gap-1.5">
          {language}
          <ThemeToggle label={t.theme} />
          <Link href={`/${locale}/app/login`} className="inline-flex h-10 items-center rounded-full px-3 text-sm font-medium whitespace-nowrap hover:bg-muted">
            {t.nav.signIn}
          </Link>
          <BookButton locale={locale} label={t.nav.book} size="sm" />
        </div>
      </NavBody>
      <MobileNav>
        <MobileNavHeader>
          {logo}
          <div className="flex items-center gap-1">
            {language}
            <ThemeToggle label={t.theme} />
            <MobileNavToggle isOpen={open} onClick={() => setOpen((v) => !v)} label={t.nav.menu} />
          </div>
        </MobileNavHeader>
        <MobileNavMenu isOpen={open}>
          <nav aria-label={t.nav.label} className="grid gap-1">
            {items.map((item) => (
              <a key={item.link} href={item.link} onClick={() => setOpen(false)} className="rounded-xl px-3 py-3 font-medium hover:bg-muted">
                {item.name}
              </a>
            ))}
          </nav>
          <div className="mt-2 grid grid-cols-2 gap-2">
            <Link href={`/${locale}/app/login`} className="grid h-12 place-items-center rounded-full bg-muted text-sm font-medium">
              {t.nav.signIn}
            </Link>
            <Link href={`/${locale}/app/book`} className="grid h-12 place-items-center rounded-full bg-primary text-sm font-semibold text-primary-foreground">
              {t.nav.book}
            </Link>
          </div>
        </MobileNavMenu>
      </MobileNav>
    </Navbar>
  );
}
