'use client';

import {
  Bell,
  Bike,
  CalendarDays,
  Car,
  ClipboardList,
  Coins,
  CreditCard,
  Home,
  Languages,
  LogOut,
  MapPin,
  Plus,
  Search,
  TicketPercent,
  User,
  Wallet,
  type LucideIcon,
} from 'lucide-react';
import dynamic from 'next/dynamic';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState, type ReactNode } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Button } from '@/components/ui/button';
import { LiquidGlass } from '@/components/ui/liquid-glass';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { authApi } from '@/lib/kleano/client';
import { accountApi } from '@/lib/kleano/domains/account';
import { cn } from '@/lib/utils';

// Only downloaded the first time someone opens it.
const CommandPalette = dynamic(() => import('@/components/app/command-palette').then((m) => m.CommandPalette), { ssr: false });

export type NavItem = { href: string; label: string; icon: LucideIcon };

/** Every customer screen: the sidebar and the palette show all of them, the phone dock the main four. */
export function customerNav(locale: Locale, t: AppDictionary): NavItem[] {
  const base = `/${locale}/app`;
  return [
    { href: base, label: t.nav.home, icon: Home },
    { href: `${base}/bookings`, label: t.nav.bookings, icon: ClipboardList },
    { href: `${base}/cars`, label: t.nav.vehicles, icon: Car },
    { href: `${base}/places`, label: t.places.title, icon: MapPin },
    { href: `${base}/plans`, label: t.nav.plans, icon: CreditCard },
    { href: `${base}/wallet`, label: t.nav.wallet, icon: Wallet },
    { href: `${base}/points`, label: t.nav.points, icon: Coins },
    { href: `${base}/promos`, label: t.nav.promos, icon: TicketPercent },
    { href: `${base}/notifications`, label: t.nav.notifications, icon: Bell },
    { href: `${base}/account`, label: t.nav.profile, icon: User },
  ];
}

function navFor(role: 'customer' | 'biker', locale: Locale, t: AppDictionary): NavItem[] {
  if (role === 'customer') return customerNav(locale, t);
  const base = `/${locale}/biker`;
  return [
    { href: base, label: t.nav.orders, icon: Bike },
    { href: `${base}/schedule`, label: t.nav.schedule, icon: CalendarDays },
    { href: `${base}/earnings`, label: t.nav.earnings, icon: Wallet },
    { href: `${base}/account`, label: t.nav.profile, icon: User },
  ];
}

/**
 * Signed-in frame for both web apps.
 * Desktop: sidebar and top bar. Tablet: icon rail and top bar. Phone: slim top bar and a floating
 * dock. The dock is the glass layer; everything inside <main> is on solid surfaces.
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
  const [palette, setPalette] = useState(false);
  const [paletteLoaded, setPaletteLoaded] = useState(false);
  const items = navFor(role, locale, t);
  const home = items[0].href;
  const customer = role === 'customer';
  const bookHref = customer ? `/${locale}/app/book` : null;
  const isActive = (href: string) => (href === home ? pathname === href : pathname.startsWith(href));
  const dockItems = customer ? items.filter((i) => [t.nav.home, t.nav.bookings, t.nav.vehicles, t.nav.profile].includes(i.label)) : items;

  const openPalette = () => {
    setPaletteLoaded(true);
    setPalette(true);
  };

  useEffect(() => {
    if (!customer) return;
    const onKey = (e: KeyboardEvent) => {
      const target = e.target as HTMLElement | null;
      const typing = target?.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(target?.tagName ?? '');
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        setPaletteLoaded(true);
        setPalette((open) => !open);
      } else if (e.key === '/' && !typing) {
        e.preventDefault();
        setPaletteLoaded(true);
        setPalette(true);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [customer]);

  const logout = async () => {
    setLeaving(true);
    try {
      await authApi.logout(role);
    } finally {
      router.replace(`/${locale}/${customer ? 'app' : 'biker'}/login`);
      router.refresh();
    }
  };

  const other: Locale = locale === 'ar' ? 'en' : 'ar';
  const switchLanguage = () => {
    // The backend sends notifications in this language too (ProfileRepo.updateUserLanguage).
    if (customer) void accountApi.language(other).catch(() => undefined);
    router.push(`/${other}${pathname.slice(3)}`);
  };

  return (
    <div className="flex min-h-dvh w-full bg-background">
      {/* Tablet: icons only. Desktop: icons and words. */}
      <aside className="sticky top-0 hidden h-dvh w-[76px] shrink-0 flex-col justify-between gap-6 border-e bg-card px-3 py-5 md:flex lg:w-[264px] lg:px-4">
        <div className="flex min-h-0 flex-col gap-6">
          <Link href={home} aria-label={t.brand} className="grid place-items-center text-primary lg:justify-items-start lg:px-2">
            <Logo className="h-9 w-auto lg:h-10" />
          </Link>
          {bookHref ? (
            <Button asChild size="xl" className="size-13 px-0 lg:w-full lg:px-6">
              <Link href={bookHref} aria-label={t.home.bookNow}>
                <Plus />
                <span className="hidden lg:inline">{t.home.bookNow}</span>
              </Link>
            </Button>
          ) : null}
          <nav aria-label={t.nav.menu} className="-mx-1 grid min-h-0 gap-1 overflow-y-auto px-1">
            {items.map(({ href, label, icon: Icon }) => (
              <Link
                key={href}
                href={href}
                title={label}
                aria-label={label}
                aria-current={isActive(href) ? 'page' : undefined}
                className={cn(
                  'flex h-11 shrink-0 items-center justify-center gap-3 rounded-xl text-[15px] font-medium text-muted-foreground transition hover:bg-muted hover:text-foreground lg:justify-start lg:px-3',
                  isActive(href) && 'bg-secondary text-secondary-foreground hover:bg-secondary hover:text-secondary-foreground',
                )}
              >
                <Icon className="size-5 shrink-0" aria-hidden="true" />
                <span className="hidden truncate lg:inline">{label}</span>
              </Link>
            ))}
          </nav>
        </div>
        <Button variant="ghost" className="h-11 w-full justify-center gap-2 border-t pt-0 text-muted-foreground lg:justify-start lg:px-3" onClick={logout} disabled={leaving} aria-label={t.nav.logout} title={t.nav.logout}>
          <LogOut className="size-4.5 rtl:-scale-x-100" />
          <span className="hidden lg:inline">{t.nav.logout}</span>
        </Button>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex min-h-14 items-center justify-between gap-2 border-b bg-background/90 px-4 pt-[env(safe-area-inset-top)] backdrop-blur-xl md:h-16 md:px-8">
          <Link href={home} className="text-primary md:hidden" aria-label={t.brand}>
            <Logo className="h-8 w-auto" />
          </Link>
          {customer ? (
            <button
              type="button"
              onClick={openPalette}
              className="hidden h-10 w-full max-w-sm items-center gap-2 rounded-full border bg-card px-4 text-sm text-foreground/80 transition hover:bg-muted md:flex"
            >
              <Search className="size-4 shrink-0" aria-hidden="true" />
              <span className="flex-1 truncate text-start">{t.palette.placeholder}</span>
              <kbd className="rounded-md border bg-muted px-1.5 text-xs" dir="ltr">
                ⌘K
              </kbd>
            </button>
          ) : (
            <span className="hidden md:block" />
          )}
          <div className="flex items-center gap-2">
            {customer ? (
              <Button asChild variant="outline" size="chip" className="px-3">
                <Link href={`/${locale}/app/notifications`} aria-label={t.nav.notifications}>
                  <Bell />
                </Link>
              </Button>
            ) : null}
            <Button variant="outline" size="chip" className="px-3" onClick={switchLanguage} aria-label={t.welcome.language} title={t.welcome.language}>
              <Languages />
            </Button>
            <ThemeToggle label={themeLabel} />
            {customer ? null : (
              <Button variant="outline" size="chip" className="md:hidden" onClick={logout} disabled={leaving} aria-label={t.nav.logout}>
                <LogOut className="rtl:-scale-x-100" />
              </Button>
            )}
          </div>
        </header>

        <main className="flex-1 pb-[calc(104px+env(safe-area-inset-bottom))] md:pb-0">
          <div className="mx-auto w-full max-w-6xl px-4 py-6 md:px-8 md:py-8 2xl:max-w-7xl">{children}</div>
        </main>
      </div>

      <LiquidGlass
        radius={40}
        role="navigation"
        aria-label={t.nav.menu}
        className="fixed inset-x-3 bottom-[calc(12px+env(safe-area-inset-bottom))] z-40 shadow-input md:hidden"
        contentClassName="flex items-center gap-1 p-1.5"
      >
        {dockItems.map(({ href, label, icon: Icon }, i) => (
          <div key={href} className="contents">
            {bookHref && i === 2 ? (
              <Link href={bookHref} aria-label={t.home.bookNow} className="grid size-14 shrink-0 place-items-center rounded-full bg-primary text-primary-foreground shadow-lg">
                <Plus className="size-6" aria-hidden="true" />
              </Link>
            ) : null}
            <Link
              href={href}
              aria-current={isActive(href) ? 'page' : undefined}
              className={cn(
                // Foreground, not muted: this text must stay above 4.5:1 on glass over any content.
                'grid h-14 min-w-0 flex-1 place-items-center content-center gap-0.5 rounded-full text-[11px] leading-tight font-medium text-foreground',
                isActive(href) && 'bg-secondary text-secondary-foreground',
              )}
            >
              <Icon className="size-5.5" aria-hidden="true" />
              <span className="max-w-full truncate px-1">{label}</span>
            </Link>
          </div>
        ))}
      </LiquidGlass>

      {paletteLoaded && customer ? <CommandPalette open={palette} onOpenChange={setPalette} locale={locale} t={t} /> : null}
    </div>
  );
}
