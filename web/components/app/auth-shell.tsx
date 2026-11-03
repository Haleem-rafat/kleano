import Link from 'next/link';
import type { ReactNode } from 'react';
import { Logo } from '@/components/logo';
import { ThemeToggle } from '@/components/theme';
import { BackgroundBeams } from '@/components/ui/background-beams';

/** Log in page: Aceternity Background Beams behind an Aceternity sign-up-form style card. */
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
    <div className="relative flex min-h-dvh flex-col overflow-hidden bg-background antialiased">
      <BackgroundBeams />
      <header className="relative z-10 mx-auto flex w-full max-w-5xl items-center justify-between px-4 pt-[calc(16px+env(safe-area-inset-top))] md:px-8">
        <Link href={homeHref} aria-label={homeLabel} className="text-primary">
          <Logo className="h-10 w-auto" />
        </Link>
        <ThemeToggle label={themeLabel} />
      </header>
      <main className="relative z-10 flex flex-1 items-center justify-center px-4 py-10">
        <div className="shadow-input w-full max-w-md rounded-2xl bg-card p-6 md:p-8">
          <h1 className="text-2xl font-bold text-foreground">{title}</h1>
          <div className="mt-2 max-w-sm text-sm text-muted-foreground">{subtitle}</div>
          <div className="my-8 h-px w-full bg-gradient-to-r from-transparent via-border to-transparent" />
          {children}
        </div>
      </main>
    </div>
  );
}
