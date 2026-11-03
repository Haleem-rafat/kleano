import Link from 'next/link';
import { Logo } from '@/components/logo';
import { Label } from '@/components/landing/shared';
import { TextHoverEffect } from '@/components/ui/text-hover-effect';
import type { Dictionary } from '@/lib/content';

export function Footer({ t, locale }: { t: Dictionary; locale: string }) {
  const sections = ['services', 'how', 'tracking', 'plans', 'faq'] as const;
  return (
    <footer className="border-t">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 pt-14 md:grid-cols-[1.4fr_1fr_1fr] md:px-8">
        <div className="grid content-start gap-3">
          <Logo className="h-10 w-auto text-primary" />
          <p className="text-muted-foreground">{t.footer.tagline}</p>
        </div>
        <nav aria-label={t.footer.product} className="grid content-start gap-2.5">
          <Label>{t.footer.product}</Label>
          {sections.map((id) => (
            <a key={id} href={`#${id}`} className="w-fit text-muted-foreground hover:text-foreground">
              {t.nav[id]}
            </a>
          ))}
        </nav>
        <nav aria-label={t.footer.accounts} className="grid content-start gap-2.5">
          <Label>{t.footer.accounts}</Label>
          <Link href={`/${locale}/app/login`} className="w-fit text-muted-foreground hover:text-foreground">
            {t.footer.customer}
          </Link>
          <Link href={`/${locale}/biker/login`} className="w-fit text-muted-foreground hover:text-foreground">
            {t.footer.biker}
          </Link>
        </nav>
      </div>
      <div className="mx-auto max-w-6xl px-4 pt-6 md:px-8" dir="ltr">
        <TextHoverEffect text="KLEANO" />
      </div>
      <p className="px-4 pb-8 text-center text-xs text-muted-foreground">
        © {new Date().getFullYear()} {t.footer.rights}
      </p>
    </footer>
  );
}
