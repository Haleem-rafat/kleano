import Link from 'next/link';
import type { ReactNode } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';

/**
 * Web version of the apps' KAuthScaffold: brand header with the logo (the one place the
 * design system allows a purple band), then the form on a card.
 */
export function AuthShell({
  title,
  subtitle,
  homeHref,
  homeLabel,
  themeLabel,
  children,
}: {
  title: string;
  subtitle: ReactNode;
  homeHref: string;
  homeLabel: string;
  themeLabel: string;
  children: ReactNode;
}) {
  return (
    <div className="min-h-dvh bg-background">
      <div className="bg-primary pt-[env(safe-area-inset-top)] text-primary-foreground">
        <div className="mx-auto flex max-w-md items-center justify-between px-4 pt-4">
          <Link href={homeHref} aria-label={homeLabel}>
            <Logo className="h-10 w-auto" />
          </Link>
          <ThemeToggle label={themeLabel} />
        </div>
        <div className="mx-auto grid max-w-md gap-2 px-4 pt-10 pb-16">
          <h1 className="text-[34px] leading-tight font-extrabold">{title}</h1>
          <div className="text-primary-foreground/85">{subtitle}</div>
        </div>
      </div>
      <div className="mx-auto -mt-8 max-w-md px-4 pb-10">
        <div className="rounded-sheet bg-card p-6 shadow-sm">{children}</div>
      </div>
    </div>
  );
}
