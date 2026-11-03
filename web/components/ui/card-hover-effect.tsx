'use client';

import { AnimatePresence, motion } from 'motion/react';
import Link from 'next/link';
import { useState, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

/**
 * Aceternity Card Hover Effect: a highlight slides between cards on hover.
 * Kleano version: cards take any content (icon, price, duration) and use theme colours.
 */
export const HoverEffect = ({
  items,
  className,
}: {
  items: { id: string; href?: string; content: ReactNode }[];
  className?: string;
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <div className={cn('grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3', className)}>
      {items.map((item, idx) => {
        const inner = (
          <>
            <AnimatePresence>
              {hoveredIndex === idx && (
                <motion.span
                  className="absolute inset-0 block h-full w-full rounded-3xl bg-secondary"
                  layoutId="hoverBackground"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1, transition: { duration: 0.15 } }}
                  exit={{ opacity: 0, transition: { duration: 0.15, delay: 0.2 } }}
                />
              )}
            </AnimatePresence>
            <Card>{item.content}</Card>
          </>
        );
        const props = {
          className: 'group relative block h-full w-full p-2',
          onMouseEnter: () => setHoveredIndex(idx),
          onMouseLeave: () => setHoveredIndex(null),
        };
        return item.href ? (
          <Link key={item.id} href={item.href} {...props}>
            {inner}
          </Link>
        ) : (
          <div key={item.id} {...props}>
            {inner}
          </div>
        );
      })}
    </div>
  );
};

export const Card = ({ className, children }: { className?: string; children: ReactNode }) => (
  <div
    className={cn(
      'relative z-20 h-full w-full overflow-hidden rounded-2xl border border-border bg-card p-5 group-hover:border-primary/40',
      className,
    )}
  >
    <div className="relative z-50">{children}</div>
  </div>
);
