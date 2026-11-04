'use client';

import { RotateCcw } from 'lucide-react';
import { AnimatePresence, motion, useMotionValue, useScroll, useTransform } from 'motion/react';
import dynamic from 'next/dynamic';
import Image from 'next/image';
import { useCallback, useEffect, useRef, useState } from 'react';
import { BookButton } from '@/components/landing/book-button';
import { Display, Label, ScrollIn } from '@/components/landing/shared';
import { WasherCursor } from '@/components/landing/washer-cursor';
import type { SprayState } from '@/components/landing/wash-scene';
import { Spotlight } from '@/components/ui/spotlight-new';
import type { Dictionary } from '@/lib/content';
import type { Locale } from '@/lib/i18n';
import { cn } from '@/lib/utils';
import washing from '@/public/images/washing.jpg';

/** three.js is large, so it downloads only when this section is about to be seen. */
const WashScene = dynamic(() => import('@/components/landing/wash-scene'), { ssr: false });

/** Reduced motion or no WebGL: the page keeps the photo and the Book button. */
function canRun3D() {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return false;
  try {
    const c = document.createElement('canvas');
    return Boolean(c.getContext('webgl2') || c.getContext('webgl'));
  } catch {
    return false;
  }
}

export function Wash3D({ t, locale }: { t: Dictionary['wash']; locale: Locale }) {
  const section = useRef<HTMLElement>(null);
  const stage = useRef<HTMLDivElement>(null);
  const spray = useRef<SprayState>({ onCar: false });
  const [load, setLoad] = useState(false);
  const [active, setActive] = useState(false);
  const [ready, setReady] = useState(false);
  const [unsupported, setUnsupported] = useState(false);
  const [clean, setClean] = useState(false);
  const [resetKey, setResetKey] = useState(0);

  const cleaned = useMotionValue(0);
  const percent = useTransform(cleaned, (v) => `${Math.round(v * 100)}%`);
  const barWidth = useTransform(cleaned, (v) => `${v * 100}%`);
  const { scrollYProgress } = useScroll({ target: stage, offset: ['start end', 'end start'] });

  useEffect(() => {
    const el = stage.current;
    if (!el) return;
    const near = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return;
        near.disconnect();
        if (canRun3D()) setLoad(true);
        else setUnsupported(true);
      },
      { rootMargin: '500px' },
    );
    // Stop drawing the 3D scene while it is off screen.
    const visible = new IntersectionObserver(([entry]) => setActive(entry.isIntersecting));
    near.observe(el);
    visible.observe(el);
    return () => {
      near.disconnect();
      visible.disconnect();
    };
  }, []);

  const onCleaned = useCallback(
    (fraction: number) => {
      cleaned.set(fraction);
      setClean(fraction >= 1);
    },
    [cleaned],
  );
  const onReady = useCallback(() => setReady(true), []);

  return (
    <section
      ref={section}
      aria-label={t.title}
      className={cn(
        'relative isolate overflow-hidden border-t py-16 md:py-24',
        // The gun replaces the pointer here only, and only for a real mouse; controls keep the hand.
        ready && '[@media(hover:hover)_and_(pointer:fine)]:cursor-none [&_a]:cursor-pointer [&_button]:cursor-pointer',
      )}
    >
      <div aria-hidden="true" className="absolute inset-0 -z-20 [background-image:radial-gradient(var(--border)_1px,transparent_1px)] [background-size:22px_22px] [mask-image:radial-gradient(70%_60%_at_50%_45%,black,transparent)]" />
      <Spotlight />

      <ScrollIn className="mx-auto grid max-w-3xl justify-items-center gap-4 px-4 text-center">
        <Label>{t.label}</Label>
        <Display>{t.title}</Display>
        {ready ? (
          <p className="text-lg text-pretty text-muted-foreground">
            <span className="[@media(pointer:coarse)]:hidden">{t.line}</span>
            <span className="hidden [@media(pointer:coarse)]:inline">{t.lineTouch}</span>
          </p>
        ) : null}
      </ScrollIn>

      <div ref={stage} role="img" aria-label={t.sceneLabel} className="relative mx-auto mt-6 h-[350px] w-full max-w-7xl sm:h-[500px] lg:h-[620px]" style={{ touchAction: 'pan-y' }}>
        {/* The photo holds the place until the scene is ready, and stays if 3D cannot run. */}
        <div className={cn('absolute inset-x-4 inset-y-2 overflow-hidden rounded-sheet transition-opacity duration-700 md:inset-x-8', ready ? 'pointer-events-none opacity-0' : 'opacity-100')}>
          <Image src={washing} alt="" fill placeholder="blur" sizes="(max-width: 1280px) 100vw, 1200px" className="object-cover object-[60%_30%]" />
        </div>
        {load ? (
          <div className={cn('absolute inset-0 transition-opacity duration-700 [mask-image:linear-gradient(black_90%,transparent)]', ready ? 'opacity-100' : 'opacity-0')} aria-hidden="true">
            <WashScene active={active} progress={scrollYProgress} spray={spray} resetKey={resetKey} onCleaned={onCleaned} onReady={onReady} />
          </div>
        ) : null}
      </div>

      <div className="mx-auto mt-2 grid min-h-28 max-w-md justify-items-center gap-4 px-4 text-center">
        {unsupported ? (
          <BookButton locale={locale} label={t.clean} />
        ) : (
          <AnimatePresence mode="wait" initial={false}>
            {clean ? (
              <motion.div key="clean" initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }} className="grid justify-items-center gap-3">
                <p className="font-display text-xl font-semibold text-balance">{t.clean}</p>
                <div className="flex flex-wrap items-center justify-center gap-2">
                  <BookButton locale={locale} label={locale === 'ar' ? 'احجز غسلة' : 'Book a wash'} />
                  <button
                    type="button"
                    onClick={() => {
                      setClean(false);
                      cleaned.set(0);
                      setResetKey((k) => k + 1);
                    }}
                    className="inline-flex h-13 items-center gap-2 rounded-full border px-5 font-medium transition hover:bg-muted"
                  >
                    <RotateCcw className="size-4" aria-hidden="true" />
                    {t.again}
                  </button>
                </div>
              </motion.div>
            ) : ready ? (
              <motion.div key="progress" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="grid w-full justify-items-center gap-2">
                <p className="text-sm text-muted-foreground">
                  {t.cleaned} <motion.span className="font-semibold text-foreground tabular-nums">{percent}</motion.span>
                </p>
                <div className="h-1.5 w-full max-w-xs overflow-hidden rounded-full bg-muted">
                  <motion.div style={{ width: barWidth }} className="h-full rounded-full bg-primary" />
                </div>
              </motion.div>
            ) : null}
          </AnimatePresence>
        )}
      </div>

      <p className="mt-4 px-4 text-center text-[11px] text-muted-foreground/70">{t.credit}</p>

      {ready ? <WasherCursor area={section} spray={spray} /> : null}
    </section>
  );
}
