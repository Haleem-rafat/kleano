'use client';

import { ArrowRight } from 'lucide-react';
import { AnimatePresence, motion } from 'motion/react';
import Image from 'next/image';
import Link from 'next/link';
import { useState } from 'react';
import { Logo } from '@/components/logo';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';

const photos = ['/images/onboarding/order.jpg', '/images/onboarding/collect.jpg', '/images/onboarding/ready.jpg'];
const lastPhoto = '/images/onboarding/start.jpg';

/** The app's photos and words. Remembers it was seen, as the app's FirstTime flag does. */
function remember() {
  document.cookie = 'kleano_welcomed=1; path=/; max-age=31536000; samesite=lax';
}

/** First run, as in the app's OnboardScreen and ChooseRegisterView: three slides, then the choice. */
export function CustomerWelcome({ t, locale }: { t: AppDictionary; locale: Locale }) {
  const [index, setIndex] = useState(0);
  const slides = t.welcome.slides;
  const choosing = index >= slides.length;
  const base = `/${locale}/app`;
  const other = locale === 'ar' ? 'en' : 'ar';

  return (
    <div className="grid min-h-dvh bg-background lg:grid-cols-2">
      {/* Photo: full screen on phones with the words over it, one half on desktop. */}
      <div className="relative min-h-dvh overflow-hidden bg-black lg:order-2 lg:min-h-0">
        <AnimatePresence initial={false}>
          <motion.div key={index} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.35 }} className="absolute inset-0">
            <Image src={choosing ? lastPhoto : photos[index]} alt="" fill priority sizes="(min-width: 1024px) 50vw, 100vw" className="object-cover" />
          </motion.div>
        </AnimatePresence>
        <div className="absolute inset-0 bg-black/40 lg:bg-transparent" aria-hidden="true" />
      </div>

      <div className="absolute inset-0 flex min-h-dvh flex-col px-6 pt-[calc(24px+env(safe-area-inset-top))] pb-[calc(24px+env(safe-area-inset-bottom))] text-white lg:relative lg:inset-auto lg:px-16 lg:text-foreground">
        <div className="flex items-center justify-between gap-3">
          <Link href={`/${locale}`} aria-label={t.backToSite} className="lg:text-primary">
            <Logo className="h-10 w-auto" />
          </Link>
          <div className="flex items-center gap-2">
            <Button asChild variant="ghost" size="chip" className="text-inherit hover:bg-white/15 hover:text-white lg:hover:bg-muted lg:hover:text-foreground">
              <Link href={`/${other}/app/welcome`} hrefLang={other}>
                {t.welcome.language}
              </Link>
            </Button>
            {!choosing ? (
              <Button variant="ghost" size="chip" className="text-inherit hover:bg-white/15 hover:text-white lg:hover:bg-muted lg:hover:text-foreground" onClick={() => setIndex(slides.length)}>
                {t.welcome.skip}
              </Button>
            ) : null}
          </div>
        </div>

        <div className="mx-auto mt-auto flex w-full max-w-md flex-col gap-6 lg:my-auto">
          {!choosing ? (
            <>
              <div className="grid gap-2">
                <h1 className="text-4xl font-bold md:text-5xl">{slides[index].title}</h1>
                <p className="text-lg opacity-90">{slides[index].body}</p>
              </div>
              <div className="flex gap-2" aria-hidden="true">
                {slides.map((_, i) => (
                  <span key={i} className={`h-2 rounded-full bg-current transition-all ${i === index ? 'w-6 opacity-100' : 'w-2 opacity-40'}`} />
                ))}
              </div>
              <Button size="xl" className="w-full bg-white text-black hover:bg-white/90 lg:bg-primary lg:text-primary-foreground lg:hover:bg-primary/80" onClick={() => setIndex(index + 1)}>
                {index === slides.length - 1 ? t.welcome.getStarted : t.welcome.next}
                <ArrowRight className="rtl:-scale-x-100" aria-hidden="true" />
              </Button>
            </>
          ) : (
            <div className="grid gap-3">
              <Button asChild size="xl" className="w-full bg-white text-black hover:bg-white/90 lg:bg-primary lg:text-primary-foreground lg:hover:bg-primary/80">
                <Link href={`${base}/signup`} onClick={remember}>
                  {t.welcome.signUp}
                </Link>
              </Button>
              <Button asChild size="xl" variant="outline" className="w-full border-white/70 bg-transparent text-white hover:bg-white/15 hover:text-white dark:bg-transparent lg:border-border lg:text-foreground lg:hover:bg-muted lg:hover:text-foreground">
                <Link href={`${base}/login`} onClick={remember}>
                  {t.welcome.login}
                </Link>
              </Button>
              <Button asChild size="xl" variant="ghost" className="w-full text-inherit hover:bg-white/15 hover:text-white lg:hover:bg-muted lg:hover:text-foreground">
                <Link href={`${base}/explore`} onClick={remember}>
                  {t.welcome.guest}
                </Link>
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
