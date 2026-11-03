'use client';

import { motion, useScroll, useTransform, type MotionValue } from 'motion/react';
import Image, { type StaticImageData } from 'next/image';
import { useRef } from 'react';
import { Label } from '@/components/landing/shared';

/**
 * A flow told by scrolling, in the manner of Aceternity's Sticky Scroll Reveal. One phone stays
 * pinned while its real screens scroll and change, and a finger dot shows what is pressed.
 * - Wide screens: steps scroll on one side, the phone is pinned on the other.
 * - Upright phones: phone and caption are pinned together and fill the screen.
 * Driven by scroll position through motion values, so nothing re-renders while scrolling.
 * Reduced motion: every step is listed with its own still screen.
 */

export type StoryShot = {
  src: StaticImageData;
  alt: string;
  /** Where the finger presses, in % of the screen. */
  tap: [number, number];
  /** How far the screen has scrolled at the start and end of the step, in % of its height. */
  pan: [number, number];
};
export type StoryStep = { title: string; body: string; tag: string };

const clamp = (v: number) => Math.min(1, Math.max(0, v));

/** Visible only during step i of count, with a short cross-fade; first and last hold at the ends. */
function stepOpacity(v: number, i: number, count: number) {
  const edge = 0.03;
  const start = i / count;
  const end = (i + 1) / count;
  const fadeIn = i === 0 ? 1 : (v - start + edge) / (edge * 2);
  const fadeOut = i === count - 1 ? 1 : (end + edge - v) / (edge * 2);
  return clamp(Math.min(fadeIn, fadeOut));
}

function Screen({ shot, i, count, progress }: { shot: StoryShot; i: number; count: number; progress: MotionValue<number> }) {
  const local = useTransform(progress, (v) => clamp(v * count - i));
  const opacity = useTransform(progress, (v) => stepOpacity(v, i, count));
  const y = useTransform(local, [0, 1], [`-${shot.pan[0]}%`, `-${shot.pan[1]}%`]);
  const dotOpacity = useTransform(local, [0.15, 0.28, 0.8, 0.92], [0, 0.95, 0.95, 0]);
  const dotX = useTransform(local, [0.15, 0.48], ['22px', '0px']);
  const dotY = useTransform(local, [0.15, 0.48], ['34px', '0px']);
  const press = useTransform(local, [0.48, 0.54, 0.62], [1, 0.72, 1]);
  const ring = useTransform(local, [0.52, 0.74], [0.6, 2.4]);
  const ringOpacity = useTransform(local, [0.52, 0.56, 0.74], [0, 0.6, 0]);

  return (
    <motion.div style={{ opacity }} className="absolute inset-0 overflow-hidden">
      <motion.div style={{ y }} className="relative">
        <Image src={shot.src} alt={shot.alt} placeholder="blur" sizes="(max-width: 1024px) 280px, 340px" className="h-auto w-full" />
        <motion.span aria-hidden="true" style={{ left: `${shot.tap[0]}%`, top: `${shot.tap[1]}%`, opacity: dotOpacity, x: dotX, y: dotY }} className="absolute -mt-5 -ml-5 size-10">
          <motion.span style={{ scale: ring, opacity: ringOpacity }} className="absolute inset-0 rounded-full border-2 border-primary" />
          <motion.span style={{ scale: press }} className="absolute inset-1 rounded-full border border-white/70 bg-black/35 shadow-lg" />
        </motion.span>
      </motion.div>
    </motion.div>
  );
}

function Frame({ children, className, style }: { children: React.ReactNode; className?: string; style?: React.CSSProperties }) {
  return (
    <div dir="ltr" style={style} className={`relative rounded-[36px] border border-border bg-[#26232a] p-1.5 shadow-2xl lg:rounded-[42px] lg:p-2 ${className ?? ''}`}>
      <div className="relative aspect-[1206/2000] overflow-hidden rounded-[30px] bg-background lg:rounded-[34px]">{children}</div>
    </div>
  );
}

function StepText({ step, i }: { step: StoryStep; i: number }) {
  return (
    <>
      <Label>
        {String(i + 1).padStart(2, '0')} · {step.tag}
      </Label>
      <h3 className="font-display text-2xl leading-tight font-semibold rtl:leading-snug lg:text-[clamp(28px,3vw,40px)]">{step.title}</h3>
      <p className="max-w-md text-pretty text-muted-foreground lg:text-lg">{step.body}</p>
    </>
  );
}

function Caption({ step, i, count, progress }: { step: StoryStep; i: number; count: number; progress: MotionValue<number> }) {
  const opacity = useTransform(progress, (v) => stepOpacity(v, i, count));
  return (
    <motion.div style={{ opacity }} className="col-start-1 row-start-1 grid content-start justify-items-center gap-1.5 text-center">
      <StepText step={step} i={i} />
    </motion.div>
  );
}

function ProgressDots({ count, progress }: { count: number; progress: MotionValue<number> }) {
  const width = useTransform(progress, [0, 1], ['0%', '100%']);
  return (
    <div aria-hidden="true" className="h-1 overflow-hidden rounded-full bg-muted" style={{ width: `${count * 22}px` }}>
      <motion.div style={{ width }} className="h-full rounded-full bg-primary" />
    </div>
  );
}

export function ScrollStory({ steps, shots }: { steps: StoryStep[]; shots: StoryShot[] }) {
  const wide = useRef<HTMLDivElement>(null);
  const tall = useRef<HTMLDivElement>(null);
  const { scrollYProgress: wideProgress } = useScroll({ target: wide, offset: ['start 0.3', 'end 0.7'] });
  const { scrollYProgress: tallProgress } = useScroll({ target: tall, offset: ['start start', 'end end'] });
  const count = steps.length;

  return (
    <>
      {/* Reduced motion: each step with its own still screen. CSS chooses, so server and browser agree. */}
      <ol className="hidden gap-14 motion-reduce:grid sm:grid-cols-2">
        {steps.map((step, i) => (
          <li key={step.title} className="grid content-start gap-3">
            <StepText step={step} i={i} />
            <Frame className="mt-3 w-[260px]">
              <Image src={shots[i].src} alt={shots[i].alt} placeholder="blur" sizes="260px" className="h-auto w-full" />
            </Frame>
          </li>
        ))}
      </ol>

      {/* Upright phones and tablets: phone and caption pinned together, sized to fit the screen. */}
      <div ref={tall} className="motion-reduce:hidden lg:hidden" style={{ height: `${count * 85 + 15}dvh` }}>
        <div className="sticky top-0 flex h-dvh flex-col items-center gap-3 pt-[calc(76px+env(safe-area-inset-top))] pb-4">
          <div className="grid w-full">
            {steps.map((step, i) => (
              <Caption key={step.title} step={step} i={i} count={count} progress={tallProgress} />
            ))}
          </div>
          <ProgressDots count={count} progress={tallProgress} />
          <div className="flex min-h-0 flex-1 items-start justify-center">
            {/* As wide as the space below the caption allows (height × the screen's proportions). */}
            <Frame style={{ width: 'min(74vw, 320px, calc((100dvh - 290px) * 0.603))' }}>
              {shots.map((shot, i) => (
                <Screen key={i} shot={shot} i={i} count={count} progress={tallProgress} />
              ))}
            </Frame>
          </div>
        </div>
      </div>

      {/* Wide screens: steps on one side, the phone pinned on the other. */}
      <div ref={wide} className="hidden gap-16 motion-reduce:hidden lg:grid lg:grid-cols-[1fr_auto]">
        <ol>
          {steps.map((step, i) => (
            <li key={step.title} className="flex min-h-[78vh] flex-col justify-center gap-3">
              <StepText step={step} i={i} />
            </li>
          ))}
        </ol>
        <div className="sticky top-[max(88px,calc(50vh-290px))] h-fit self-start">
          <Frame className="w-[340px]">
            {shots.map((shot, i) => (
              <Screen key={i} shot={shot} i={i} count={count} progress={wideProgress} />
            ))}
          </Frame>
        </div>
      </div>
    </>
  );
}
