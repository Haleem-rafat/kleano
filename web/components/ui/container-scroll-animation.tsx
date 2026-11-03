'use client';

import { motion, useReducedMotion, useScroll, useTransform } from 'motion/react';
import { useRef, type ReactNode } from 'react';

/**
 * Aceternity Container Scroll Animation, Kleano version: the card holds a phone instead of a
 * wide laptop screen, tilts flat as the page scrolls, and stays flat under reduced motion.
 */
export const ContainerScroll = ({ titleComponent, children }: { titleComponent: ReactNode; children: ReactNode }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const still = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: containerRef, offset: ['start start', 'center start'] });
  const rotate = useTransform(scrollYProgress, [0, 1], [still ? 0 : 18, 0]);
  const scale = useTransform(scrollYProgress, [0, 1], [still ? 1 : 0.96, 1]);
  const translate = useTransform(scrollYProgress, [0, 1], [0, still ? 0 : -48]);

  return (
    <div ref={containerRef} className="relative px-4 pt-28 pb-16 md:pt-36 md:pb-24" style={{ perspective: '1000px' }}>
      <motion.div style={{ translateY: translate }} className="mx-auto max-w-4xl text-center">
        {titleComponent}
      </motion.div>
      <motion.div style={{ rotateX: rotate, scale }} className="mx-auto mt-14 w-fit origin-top md:mt-16">
        {children}
      </motion.div>
    </div>
  );
};
