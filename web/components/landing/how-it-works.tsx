'use client';

import { motion, useReducedMotion, useScroll, useTransform, type MotionValue } from 'motion/react';
import Image, { type StaticImageData } from 'next/image';
import { useRef } from 'react';
import { Label, Section, SectionHead } from '@/components/landing/shared';
import type { Dictionary } from '@/lib/content';
import bookingOrder from '@/public/images/screens/booking-order.jpg';
import customerHome from '@/public/images/screens/customer-home.jpg';
import customerStatus from '@/public/images/screens/customer-status.jpg';

/**
 * How it works as a scroll story, in the manner of Aceternity's Sticky Scroll Reveal: as you
 * scroll, the phone moves through the real screens the way someone using the app would, and a
 * finger dot shows what they press. Everything is driven by scroll position through motion
 * values, so nothing re-renders while scrolling. Reduced motion: still screens, no dot.
 */

type Shot = {
  src: StaticImageData;
  alt: keyof Dictionary['screens'];
  /** Where the finger presses, in % of the screen. */
  tap: [number, number];
  /** How far the screen has scrolled at the start and end of the step, in % of its height. */
  pan: [number, number];
};

const SHOTS: Shot[] = [
  { src: customerHome, alt: 'customerHome', tap: [19, 58], pan: [0, 20] }, // press a service
  { src: bookingOrder, alt: 'bookingOrder', tap: [30, 20], pan: [0, 6] }, // press your car
  { src: bookingOrder, alt: 'bookingOrder', tap: [42, 58], pan: [8, 22] }, // press a free time
  { src: customerStatus, alt: 'customerStatus', tap: [50, 28], pan: [0, 12] }, // follow the wash
];

function clamp(v: number) {
  return Math.min(1, Math.max(0, v));
}

/** One screen with its glide and finger dot. `progress` runs 0 to 1 across this step. */
function Screen({ shot, alt, progress, opacity }: { shot: Shot; alt: string; progress: MotionValue<number>; opacity?: MotionValue<number> }) {
  const still = useReducedMotion();
  // The screen scrolls under the frame, as it does under a finger.
  const scrollY = useTransform(progress, [0, 1], [`-${shot.pan[0]}%`, `-${shot.pan[1]}%`]);
  const dotOpacity = useTransform(progress, [0.2, 0.32, 0.8, 0.92], [0, 0.95, 0.95, 0]);
  const dotX = useTransform(progress, [0.2, 0.5], ['22px', '0px']);
  const dotY = useTransform(progress, [0.2, 0.5], ['34px', '0px']);
  const press = useTransform(progress, [0.5, 0.56, 0.64], [1, 0.72, 1]);
  const ring = useTransform(progress, [0.54, 0.76], [0.6, 2.4]);
  const ringOpacity = useTransform(progress, [0.54, 0.58, 0.76], [0, 0.6, 0]);

  return (
    <motion.div style={{ opacity }} className="absolute inset-0 overflow-hidden">
      <motion.div style={still ? undefined : { y: scrollY }} className="relative">
        <Image src={shot.src} alt={alt} placeholder="blur" sizes="(max-width: 1024px) 270px, 340px" className="h-auto w-full" />
        {still ? null : (
          <motion.span aria-hidden="true" style={{ left: `${shot.tap[0]}%`, top: `${shot.tap[1]}%`, opacity: dotOpacity, x: dotX, y: dotY }} className="absolute -ml-5 -mt-5 size-10">
            <motion.span style={{ scale: ring, opacity: ringOpacity }} className="absolute inset-0 rounded-full border-2 border-primary" />
            <motion.span style={{ scale: press }} className="absolute inset-1 rounded-full border border-white/70 bg-black/35 shadow-lg backdrop-blur-[1px]" />
          </motion.span>
        )}
      </motion.div>
    </motion.div>
  );
}

function PhoneShell({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={`relative rounded-[42px] border border-border bg-[#26232a] p-2 shadow-2xl ${className ?? ''}`}>
      <div className="relative aspect-[1206/2000] overflow-hidden rounded-[34px] bg-background">{children}</div>
    </div>
  );
}

/** Wide screens: the phone stays pinned while the steps scroll past. */
function PinnedScreen({ shot, i, count, alt, progress }: { shot: Shot; i: number; count: number; alt: string; progress: MotionValue<number> }) {
  const local = useTransform(progress, (v) => clamp(v * count - i));
  const edge = 0.04;
  const opacity = useTransform(progress, (v) => {
    const start = i / count;
    const end = (i + 1) / count;
    if (i === 0 && v < end) return 1;
    if (i === count - 1 && v > start) return 1;
    return clamp(Math.min((v - start + edge) / edge, (end + edge - v) / edge));
  });
  return <Screen shot={shot} alt={alt} progress={local} opacity={opacity} />;
}

function StepText({ step, i }: { step: Dictionary['how']['steps'][number]; i: number }) {
  return (
    <>
      <Label className="text-primary">
        {String(i + 1).padStart(2, '0')} · {step.tag}
      </Label>
      <h3 className="font-display text-[clamp(28px,3.4vw,44px)] leading-tight font-medium rtl:font-semibold rtl:leading-snug">{step.title}</h3>
      <p className="max-w-md text-lg text-pretty text-muted-foreground">{step.body}</p>
    </>
  );
}

/** Small screens: each step keeps its own phone, playing as it crosses the screen. */
function MobileStep({ step, shot, i, alt }: { step: Dictionary['how']['steps'][number]; shot: Shot; i: number; alt: string }) {
  const ref = useRef<HTMLLIElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start 0.75', 'end 0.55'] });
  return (
    <li ref={ref} className="grid gap-6">
      <div className="grid gap-3">
        <StepText step={step} i={i} />
      </div>
      <PhoneShell className="mx-auto w-[270px]">
        <Screen shot={shot} alt={alt} progress={scrollYProgress} />
      </PhoneShell>
    </li>
  );
}

export function HowItWorks({ t, screens }: { t: Dictionary['how']; screens: Dictionary['screens'] }) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start 0.3', 'end 0.7'] });

  return (
    <Section id="how" className="border-y bg-card/40" pinned>
      <SectionHead number="02" label={t.label} title={t.title} />

      <ol className="grid gap-16 lg:hidden">
        {t.steps.map((step, i) => (
          <MobileStep key={step.title} step={step} shot={SHOTS[i]} i={i} alt={screens[SHOTS[i].alt]} />
        ))}
      </ol>

      <div ref={ref} className="hidden gap-16 lg:grid lg:grid-cols-[1fr_auto]">
        <ol>
          {t.steps.map((step, i) => (
            <li key={step.title} className="flex min-h-[78vh] flex-col justify-center gap-3">
              <StepText step={step} i={i} />
            </li>
          ))}
        </ol>
        <div className="sticky top-[max(88px,calc(50vh-290px))] h-fit self-start">
          <PhoneShell className="w-[340px]">
            {SHOTS.map((shot, i) => (
              <PinnedScreen key={i} shot={shot} i={i} count={SHOTS.length} alt={screens[shot.alt]} progress={scrollYProgress} />
            ))}
          </PhoneShell>
        </div>
      </div>
    </Section>
  );
}
