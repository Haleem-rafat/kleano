import { AppleIcon, PlayIcon } from '@/components/icons';
import { BookButton } from '@/components/landing/book-button';
import { Display, ScrollIn } from '@/components/landing/shared';
import { BackgroundBeams } from '@/components/ui/background-beams';
import type { Dictionary } from '@/lib/content';
import { storeLinks } from '@/lib/site';

export function Cta({ t, book, locale }: { t: Dictionary['cta']; book: string; locale: string }) {
  return (
    <section id="get" className="relative isolate scroll-mt-24 overflow-hidden border-t py-24 md:py-36">
      <BackgroundBeams />
      <ScrollIn className="relative mx-auto grid max-w-3xl justify-items-center gap-6 px-4 text-center">
        <Display>{t.title}</Display>
        <p className="max-w-xl text-lg text-pretty text-muted-foreground">{t.body}</p>
        <BookButton locale={locale} label={book} />
        <div className="flex flex-wrap justify-center gap-3 pt-2">
          {[
            { href: storeLinks.appStore, Icon: AppleIcon, small: t.appStoreSmall, name: 'App Store' },
            { href: storeLinks.googlePlay, Icon: PlayIcon, small: t.playSmall, name: 'Google Play' },
          ].map(({ href, Icon, small, name }) => (
            <a key={name} href={href || '#get'} className="inline-flex h-14 items-center gap-2.5 rounded-2xl bg-foreground px-5 text-start text-background transition-opacity hover:opacity-90">
              <Icon className="size-6.5" />
              <span>
                <small className="block text-[11px] leading-tight opacity-75">{small}</small>
                <b className="block font-heading text-[17px] leading-tight font-semibold">{name}</b>
              </span>
            </a>
          ))}
        </div>
      </ScrollIn>
    </section>
  );
}
