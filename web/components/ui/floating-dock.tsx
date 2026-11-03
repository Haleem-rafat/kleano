'use client';

/**
 * Aceternity Floating Dock, Kleano version.
 * - Desktop keeps Aceternity's magnifying icons under the pointer.
 * - Phones get an always-visible row (Aceternity hides it behind a button); on a long page it
 *   is the only thing showing where you are.
 * - The item for the section being read is highlighted; every link has a label.
 */

import { AnimatePresence, motion, useMotionValue, useSpring, useTransform, type MotionValue } from 'motion/react';
import { useRef, useState, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

export type DockItem = { id: string; title: string; icon: ReactNode; href: string };

export const FloatingDock = ({
  items,
  active,
  desktopClassName,
  mobileClassName,
}: {
  items: DockItem[];
  active?: string | null;
  desktopClassName?: string;
  mobileClassName?: string;
}) => (
  <>
    <FloatingDockDesktop items={items} active={active} className={desktopClassName} />
    <FloatingDockMobile items={items} active={active} className={mobileClassName} />
  </>
);

const FloatingDockMobile = ({ items, active, className }: { items: DockItem[]; active?: string | null; className?: string }) => (
  <nav className={cn('flex items-center gap-1 rounded-full border bg-card/85 p-1.5 shadow-input backdrop-blur-xl md:hidden', className)}>
    {items.map((item) => (
      <a
        key={item.id}
        href={item.href}
        aria-label={item.title}
        aria-current={active === item.id ? 'location' : undefined}
        className={cn(
          'grid size-11 place-items-center rounded-full text-muted-foreground transition [&_svg]:size-5',
          active === item.id && 'bg-secondary text-primary',
        )}
      >
        {item.icon}
      </a>
    ))}
  </nav>
);

const FloatingDockDesktop = ({ items, active, className }: { items: DockItem[]; active?: string | null; className?: string }) => {
  const mouseX = useMotionValue(Infinity);
  return (
    <motion.nav
      onMouseMove={(e) => mouseX.set(e.pageX)}
      onMouseLeave={() => mouseX.set(Infinity)}
      className={cn('mx-auto hidden h-16 items-end gap-4 rounded-2xl border bg-card/85 px-4 pb-3 shadow-input backdrop-blur-xl md:flex', className)}
    >
      {items.map((item) => (
        <IconContainer mouseX={mouseX} key={item.id} item={item} active={active === item.id} />
      ))}
    </motion.nav>
  );
};

function IconContainer({ mouseX, item, active }: { mouseX: MotionValue<number>; item: DockItem; active: boolean }) {
  const ref = useRef<HTMLDivElement>(null);
  const distance = useTransform(mouseX, (val) => {
    const bounds = ref.current?.getBoundingClientRect() ?? { x: 0, width: 0 };
    return val - bounds.x - bounds.width / 2;
  });
  const spring = { mass: 0.1, stiffness: 150, damping: 12 };
  const width = useSpring(useTransform(distance, [-150, 0, 150], [40, 80, 40]), spring);
  const height = useSpring(useTransform(distance, [-150, 0, 150], [40, 80, 40]), spring);
  const widthIcon = useSpring(useTransform(distance, [-150, 0, 150], [20, 40, 20]), spring);
  const heightIcon = useSpring(useTransform(distance, [-150, 0, 150], [20, 40, 20]), spring);
  const [hovered, setHovered] = useState(false);

  return (
    <a href={item.href} aria-label={item.title} aria-current={active ? 'location' : undefined}>
      <motion.div
        ref={ref}
        style={{ width, height }}
        onMouseEnter={() => setHovered(true)}
        onMouseLeave={() => setHovered(false)}
        className={cn(
          'relative flex aspect-square items-center justify-center rounded-full bg-muted text-muted-foreground',
          active && 'bg-secondary text-primary',
        )}
      >
        <AnimatePresence>
          {hovered && (
            <motion.div
              initial={{ opacity: 0, y: 10, x: '-50%' }}
              animate={{ opacity: 1, y: 0, x: '-50%' }}
              exit={{ opacity: 0, y: 2, x: '-50%' }}
              className="absolute -top-8 left-1/2 w-fit rounded-md border bg-card px-2 py-0.5 text-xs whitespace-pre text-foreground"
            >
              {item.title}
            </motion.div>
          )}
        </AnimatePresence>
        <motion.div style={{ width: widthIcon, height: heightIcon }} className="flex items-center justify-center [&_svg]:size-full">
          {item.icon}
        </motion.div>
      </motion.div>
    </a>
  );
}
