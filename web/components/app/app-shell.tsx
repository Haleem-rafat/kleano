'use client';

import { Bike, CalendarDays, Car, ClipboardList, Home, LogOut, User, Wallet, type LucideIcon } from 'lucide-react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState, type ReactNode } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { authApi } from '@/lib/kleano/client';
import { cn } from '@/lib/utils';

type Item = { href: string; label: string; icon: LucideIcon };

export function navFor(role: 'customer' | 'biker', locale: Locale, t: AppDictionary): Item[] {
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
 * Signed-in frame for both web apps. Phones get a bottom tab bar (the navigation layer, the
 * only glass in the design system); wider screens get a side bar. Content stays solid.
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
  const isActive = (href: string) => (href === home ? pathname === href : pathname.startsWith(href));

  const logout = async () => {
    setLeaving(true);
    try {
      await authApi.logout();
    } finally {
      router.replace(`/${locale}/${role === 'customer' ? 'app' : 'biker'}/login`);
      router.refresh();
    }
  };

  return (
    <div className="min-h-dvh bg-background md:grid md:grid-cols-[248px_1fr]">
      <aside className="sticky top-0 hidden h-dvh flex-col gap-2 border-e bg-card px-3 py-5 md:flex">
        <Link href={home} className="mb-6 px-3 text-primary" aria-label={t.brand}>
          <Logo className="h-9 w-auto" />
        </Link>
        <nav className="grid gap-1" aria-label={t.nav.menu}>
          {items.map(({ href, label, icon: Icon }) => (
            <Link
              key={href}
              href={href}
              aria-current={isActive(href) ? 'page' : undefined}
              className={cn(
                'flex h-11 items-center gap-3 rounded-full px-4 text-[15px] font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground',
                isActive(href) && 'bg-secondary text-secondary-foreground hover:bg-secondary hover:text-secondary-foreground',
              )}
            >
              <Icon className="size-5" aria-hidden="true" />
              {label}
            </Link>
          ))}
        </nav>
        <div className="mt-auto flex items-center gap-2 px-1">
          <ThemeToggle label={themeLabel} />
          <Button variant="ghost" className="h-10 flex-1 justify-start gap-2 px-3 text-muted-foreground" onClick={logout} disabled={leaving}>
            <LogOut className="size-4.5 rtl:-scale-x-100" />
            {t.nav.logout}
          </Button>
        </div>
      </aside>

      <div className="min-w-0 pb-[calc(76px+env(safe-area-inset-bottom))] md:pb-0">
        <header className="sticky top-0 z-30 flex h-14 items-center justify-between border-b bg-background/90 px-4 pt-[env(safe-area-inset-top)] backdrop-blur-md md:hidden">
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
        <main className="mx-auto w-full max-w-4xl px-4 py-6 md:px-8 md:py-10">{children}</main>
      </div>

      <nav
        aria-label={t.nav.menu}
        className="fixed inset-x-3 bottom-[calc(10px+env(safe-area-inset-bottom))] z-40 grid grid-cols-4 rounded-full border bg-card/80 p-1.5 shadow-lg backdrop-blur-xl md:hidden"
      >
        {items.map(({ href, label, icon: Icon }) => (
          <Link
            key={href}
            href={href}
            aria-current={isActive(href) ? 'page' : undefined}
            className={cn(
              'grid h-14 place-items-center content-center gap-0.5 rounded-full text-[11px] font-medium text-muted-foreground',
              isActive(href) && 'bg-secondary text-primary',
            )}
          >
            <Icon className="size-5.5" aria-hidden="true" />
            {label}
          </Link>
        ))}
      </nav>
    </div>
  );
}
