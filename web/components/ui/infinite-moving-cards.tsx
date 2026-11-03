'use client';

import { useEffect, useRef, useState, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

/**
 * Aceternity Infinite Moving Cards, logo-strip version. The strip always runs left to right (also
 * in Arabic, or the loop would jump), copies are hidden from screen readers, and it stands still
 * under reduced motion (see the keyframes in globals.css).
 */
export const InfiniteMovingCards = ({
  items,
  seconds = 40,
  className,
}: {
  items: { key: string; content: ReactNode }[];
  seconds?: number;
  className?: string;
}) => {
  const listRef = useRef<HTMLUListElement>(null);
  const [start, setStart] = useState(false);

  useEffect(() => {
    const list = listRef.current;
    if (!list) return;
    const originals = Array.from(list.children);
    for (const item of originals) {
      const copy = item.cloneNode(true) as HTMLElement;
      copy.setAttribute('aria-hidden', 'true');
      list.appendChild(copy);
    }
    const frame = requestAnimationFrame(() => setStart(true));
    return () => {
      cancelAnimationFrame(frame);
      list.replaceChildren(...originals);
    };
  }, []);

  return (
    <div
      dir="ltr"
      style={{ '--animation-duration': `${seconds}s` } as React.CSSProperties}
      className={cn('relative overflow-hidden [mask-image:linear-gradient(to_right,transparent,white_15%,white_85%,transparent)]', className)}
    >
      <ul ref={listRef} className={cn('flex w-max min-w-full shrink-0 flex-nowrap gap-12 py-2', start && 'animate-marquee hover:[animation-play-state:paused]')}>
        {items.map((item) => (
          <li key={item.key} className="shrink-0">
            {item.content}
          </li>
        ))}
      </ul>
    </div>
  );
};
