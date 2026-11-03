'use client';

import { motion, useReducedMotion, useScroll, useTransform } from 'motion/react';
import { useRef, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

/** Slow, precise entrance used across the page: one ease, nothing bouncy. */
export function Reveal({ children, className, delay = 0 }: { children: ReactNode; className?: string; delay?: number }) {
  return (
    <motion.div
      className={className}
      initial={{ opacity: 0, y: 16 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-60px' }}
      transition={{ duration: 0.8, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  );
}

/** Rises and fades in tied to the scroll position, so the whole page moves as you scroll. */
export function ScrollIn({ children, className }: { children: ReactNode; className?: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const still = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start 1', 'start 0.6'] });
  const opacity = useTransform(scrollYProgress, [0, 1], [still ? 1 : 0.15, 1]);
  const y = useTransform(scrollYProgress, [0, 1], [still ? 0 : 70, 0]);
  const scale = useTransform(scrollYProgress, [0, 1], [still ? 1 : 0.97, 1]);
  return (
    <motion.div ref={ref} style={{ opacity, y, scale }} className={className}>
      {children}
    </motion.div>
  );
}

/** Drifts gently against the page as it scrolls; stands still under reduced motion. */
export function Parallax({ children, className, distance = 30 }: { children: ReactNode; className?: string; distance?: number }) {
  const ref = useRef<HTMLDivElement>(null);
  const still = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start end', 'end start'] });
  const y = useTransform(scrollYProgress, [0, 1], [still ? 0 : distance, still ? 0 : -distance]);
  return (
    <motion.div ref={ref} style={{ y }} className={className}>
      {children}
    </motion.div>
  );
}

/** Section frame: thin column guides behind, the numbered mono label and a serif headline. */
export function Section({ id, children, className, pinned }: { id?: string; children: ReactNode; className?: string; pinned?: boolean }) {
  return (
    <section id={id} className={cn('relative scroll-mt-24 py-20 md:py-28', className)}>
      {/* A section with a pinned phone runs its own scroll story instead. */}
      {pinned ? <div className="mx-auto max-w-6xl px-4 md:px-8">{children}</div> : <ScrollIn className="mx-auto max-w-6xl px-4 md:px-8">{children}</ScrollIn>}
    </section>
  );
}

export function SectionHead({ number, label, title, lead, center }: { number: string; label: string; title: string; lead?: string; center?: boolean }) {
  return (
    <Reveal className={cn('mb-12 grid max-w-3xl gap-4', center && 'mx-auto justify-items-center text-center')}>
      <Label>
        {number} / {label}
      </Label>
      <Display as="h2">{title}</Display>
      {lead ? <p className="max-w-2xl text-lg text-pretty text-muted-foreground">{lead}</p> : null}
    </Reveal>
  );
}

/** Small engraved-style label. */
export function Label({ children, className }: { children: ReactNode; className?: string }) {
  return <span className={cn('font-label text-xs tracking-[0.14em] text-muted-foreground uppercase rtl:font-sans rtl:text-sm rtl:font-medium rtl:tracking-normal', className)}>{children}</span>;
}

export function Display({ as: Tag = 'h2', children, className }: { as?: 'h1' | 'h2' | 'h3'; children: ReactNode; className?: string }) {
  return (
    <Tag
      className={cn(
        'font-display font-medium tracking-[-0.025em] text-balance rtl:font-semibold rtl:tracking-normal',
        Tag === 'h1' ? 'text-[clamp(42px,6.8vw,80px)] leading-[1.03] rtl:text-[clamp(36px,5.8vw,68px)] rtl:leading-[1.25]' : 'text-[clamp(32px,4.4vw,54px)] leading-[1.08] rtl:text-[clamp(28px,3.6vw,44px)] rtl:leading-[1.3]',
        className,
      )}
    >
      {children}
    </Tag>
  );
}
