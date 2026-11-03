'use client';

import { Bike, CalendarDays, Car, ClipboardList, Home, LogOut, User, Wallet, type LucideIcon } from 'lucide-react';
import { motion } from 'motion/react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState, type ReactNode } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { Sidebar, SidebarBody, SidebarLink } from '@/components/ui/sidebar';
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

/** Signed-in frame for both web apps, built on Aceternity's Sidebar. */
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
  const [open, setOpen] = useState(false);
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
    <div className="flex h-dvh w-full flex-col overflow-hidden bg-background md:flex-row">
      <Sidebar open={open} setOpen={setOpen} rtl={locale === 'ar'}>
        <SidebarBody className="justify-between gap-10 border-e">
          <div className="flex flex-1 flex-col overflow-x-hidden overflow-y-auto">
            <Link href={home} aria-label={t.brand} className="flex h-10 items-center text-primary">
              {open ? <Logo className="h-9 w-auto" /> : <span className="grid size-7 place-items-center rounded-lg bg-primary font-bold text-primary-foreground">K</span>}
            </Link>
            <nav aria-label={t.nav.menu} className="mt-8 flex flex-col gap-1">
              {items.map(({ href, label, icon: Icon }) => (
                <SidebarLink
                  key={href}
                  link={{ href, label, icon: <Icon className="size-5 shrink-0" aria-hidden="true" /> }}
                  aria-current={isActive(href) ? 'page' : undefined}
                  onClick={() => setOpen(false)}
                  className={cn(
                    'rounded-lg px-2 text-muted-foreground hover:text-foreground',
                    isActive(href) && 'bg-secondary text-secondary-foreground hover:text-secondary-foreground',
                  )}
                />
              ))}
            </nav>
          </div>
          <div className="flex flex-col gap-2">
            <div className="flex items-center gap-2">
              <ThemeToggle label={themeLabel} />
            </div>
            <button
              type="button"
              onClick={logout}
              disabled={leaving}
              className="group/sidebar flex items-center gap-2 rounded-lg px-2 py-2 text-muted-foreground hover:text-foreground disabled:opacity-50"
            >
              <LogOut className="size-5 shrink-0 rtl:-scale-x-100" aria-hidden="true" />
              <motion.span
                animate={{ display: open ? 'inline-block' : 'none', opacity: open ? 1 : 0 }}
                className="text-sm font-medium whitespace-pre md:inline-block"
              >
                {t.nav.logout}
              </motion.span>
              <span className="text-sm font-medium md:hidden">{t.nav.logout}</span>
            </button>
          </div>
        </SidebarBody>
      </Sidebar>
      <main className="flex-1 overflow-y-auto">
        <div className="mx-auto w-full max-w-4xl px-4 py-6 md:px-10 md:py-10">{children}</div>
      </main>
    </div>
  );
}
