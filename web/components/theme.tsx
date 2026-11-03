'use client';

import { ThemeProvider as NextThemes, useTheme } from 'next-themes';
import type { ReactNode } from 'react';
import { MoonIcon, SunIcon } from './icons';

/** Light, dark or the device setting. Sets data-theme on <html>, which globals.css reads. */
export function ThemeProvider({ children }: { children: ReactNode }) {
  return (
    <NextThemes attribute="data-theme" defaultTheme="system" enableSystem disableTransitionOnChange>
      {children}
    </NextThemes>
  );
}

/** Both icons render; CSS shows the sun in dark mode and the moon in light mode. */
export function ThemeToggle({ label }: { label: string }) {
  const { resolvedTheme, setTheme } = useTheme();
  return (
    <button
      type="button"
      className="lp-chip theme-toggle"
      aria-label={label}
      onClick={() => setTheme(resolvedTheme === 'dark' ? 'light' : 'dark')}
    >
      <SunIcon className="icon-sun" />
      <MoonIcon className="icon-moon" />
    </button>
  );
}
