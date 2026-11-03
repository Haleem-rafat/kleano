'use client';

import { Bike, CalendarDays, Car, ClipboardList, Home, LogOut, Plus, User, Wallet, type LucideIcon } from 'lucide-react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState, type ReactNode } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Button } from '@/components/ui/button';
import { DesktopSidebar, Sidebar } from '@/components/ui/sidebar';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { authApi } from '@/lib/kleano/client';
import { cn } from '@/lib/utils';

type Item = { href: string; label: string; icon: LucideIcon };

function navFor(role: 'customer' | 'biker', locale: Locale, t: AppDictionary): Item[] {
  if (role === 'customer') {
    const base = `/${locale}/app`;
    return [
      { href: base, label: t.nav.home, icon: Home },
      { href: `${base}/bookings`, label: t.nav.bookings, icon: ClipboardList },
      { href: `${base}/cars`, label: t.nav.vehicles, icon: Car },
      { href: `${base}/account`, label: t.nav.profile, icon: User },
    ];
  }
  const base = `/${locale}/biker`;
  return [
    { href: base, label: t.nav.orders, icon: Bike },
    { href: `${base}/schedule`, label: t.nav.schedule, icon: CalendarDays },
    { href: `${base}/earnings`, label: t.nav.earnings, icon: Wallet },
    { href: `${base}/account`, label: t.nav.profile, icon: User },
  ];
}

/**
 * Signed-in frame for both web apps. Main screens are always one tap away:
 * an always-open Aceternity sidebar on wider screens, a bottom tab bar on phones.
 */
export function AppShell({
  role,
  locale,
  t,
  themeLabel,
  children,
}: {
  role: 'customer' | 'biker';
  locale: Locale;
  t: AppDictionary;
  themeLabel: string;
  children: ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const [leaving, setLeaving] = useState(false);
  const items = navFor(role, locale, t);
  const home = items[0].href;
  const bookHref = role === 'customer' ? `/${locale}/app/book` : null;
  const isActive = (href: string) => (href === home ? pathname === href : pathname.startsWith(href));

  const logout = async () => {
    setLeaving(true);
    try {
      await authApi.logout(role);
    } finally {
      router.replace(`/${locale}/${role === 'customer' ? 'app' : 'biker'}/login`);
      router.refresh();
    }
  };

  return (
    <div className="flex min-h-dvh w-full bg-background">
      <Sidebar animate={false} rtl={locale === 'ar'}>
        <DesktopSidebar className="sticky top-0 h-dvh justify-between gap-8 border-e px-4 py-6">
          <div className="flex flex-col gap-8">
            <Link href={home} aria-label={t.brand} className="px-2 text-primary">
              <Logo className="h-10 w-auto" />
            </Link>
            {bookHref ? (
              <Button asChild size="xl" className="w-full">
                <Link href={bookHref}>
                  <Plus />
                  {t.home.bookNow}
                </Link>
              </Button>
            ) : null}
            <nav aria-label={t.nav.menu} className="grid gap-1">
              {items.map(({ href, label, icon: Icon }) => (
                <Link
                  key={href}
                  href={href}
                  aria-current={isActive(href) ? 'page' : undefined}
                  className={cn(
                    'flex h-11 items-center gap-3 rounded-xl px-3 text-[15px] font-medium text-muted-foreground transition hover:bg-muted hover:text-foreground',
                    isActive(href) && 'bg-secondary text-secondary-foreground hover:bg-secondary hover:text-secondary-foreground',
                  )}
                >
                  <Icon className="size-5 shrink-0" aria-hidden="true" />
                  {label}
                </Link>
              ))}
            </nav>
          </div>
          <div className="flex items-center gap-2 border-t pt-4">
            <ThemeToggle label={themeLabel} />
            <Button variant="ghost" className="h-10 flex-1 justify-start gap-2 px-3 text-muted-foreground" onClick={logout} disabled={leaving}>
              <LogOut className="size-4.5 rtl:-scale-x-100" />
              {t.nav.logout}
            </Button>
          </div>
        </DesktopSidebar>
      </Sidebar>

      <div className="flex min-w-0 flex-1 flex-col">
        {/* Phones: slim top bar; the screens themselves are in the bottom tab bar. */}
        <header className="sticky top-0 z-30 flex h-14 items-center justify-between border-b bg-background/85 px-4 pt-[env(safe-area-inset-top)] backdrop-blur-xl md:hidden">
          <Link href={home} className="text-primary" aria-label={t.brand}>
            <Logo className="h-8 w-auto" />
          </Link>
          <div className="flex items-center gap-2">
            <ThemeToggle label={themeLabel} />
            <Button variant="outline" size="chip" onClick={logout} disabled={leaving} aria-label={t.nav.logout}>
              <LogOut className="rtl:-scale-x-100" />
            </Button>
          </div>
        </header>

        <main className="flex-1 pb-[calc(96px+env(safe-area-inset-bottom))] md:pb-0">
          <div className="mx-auto w-full max-w-5xl px-4 py-6 md:px-10 md:py-10">{children}</div>
        </main>
      </div>

      <nav
        aria-label={t.nav.menu}
        className="fixed inset-x-3 bottom-[calc(12px+env(safe-area-inset-bottom))] z-40 flex items-center gap-1 rounded-full border bg-card/85 p-1.5 shadow-input backdrop-blur-xl md:hidden"
      >
        {items.map(({ href, label, icon: Icon }, i) => (
          <div key={href} className="contents">
            {bookHref && i === 2 ? (
              <Link
                href={bookHref}
                aria-label={t.home.bookNow}
                className="grid size-14 shrink-0 place-items-center rounded-full bg-primary text-primary-foreground shadow-lg"
              >
                <Plus className="size-6" aria-hidden="true" />
              </Link>
            ) : null}
            <Link
              href={href}
              aria-current={isActive(href) ? 'page' : undefined}
              className={cn(
                'grid h-14 min-w-0 flex-1 place-items-center content-center gap-0.5 rounded-full text-[11px] font-medium text-muted-foreground',
                isActive(href) && 'bg-secondary text-primary',
              )}
            >
              <Icon className="size-5.5" aria-hidden="true" />
              <span className="max-w-full truncate px-1">{label}</span>
            </Link>
          </div>
        ))}
      </nav>
    </div>
  );
}
