'use client';

import { AnimatePresence, motion, useReducedMotion } from 'motion/react';
import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

/**
 * Aceternity Flip Words, Kleano version. It animates whole phrases: Aceternity splits words into
 * single letters, which breaks Arabic, where letters must stay joined. Slow and precise rather
 * than springy, and it stays on the first phrase under reduced motion.
 */
export const FlipWords = ({ words, duration = 3200, className }: { words: string[]; duration?: number; className?: string }) => {
  const [index, setIndex] = useState(0);
  const still = useReducedMotion();

  useEffect(() => {
    if (still) return;
    const id = setInterval(() => setIndex((i) => (i + 1) % words.length), duration);
    return () => clearInterval(id);
  }, [words.length, duration, still]);

  return (
    // The longest phrase holds the width and height, so the headline never jumps.
    <span className={cn('relative inline-grid justify-items-center align-baseline', className)}>
      <span aria-hidden="true" className="invisible col-start-1 row-start-1">
        {words.reduce((a, b) => (b.length > a.length ? b : a))}
      </span>
      <AnimatePresence initial={false} mode="wait">
        <motion.span
          key={words[index]}
          initial={{ opacity: 0, y: '0.35em', filter: 'blur(6px)' }}
          animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
          exit={{ opacity: 0, y: '-0.35em', filter: 'blur(6px)' }}
          transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
          className="col-start-1 row-start-1"
        >
          {words[index]}
        </motion.span>
      </AnimatePresence>
    </span>
  );
};
