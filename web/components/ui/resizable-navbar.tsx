'use client';

import { Menu, X } from 'lucide-react';
import { AnimatePresence, motion, useMotionValueEvent, useScroll } from 'motion/react';
import React, { useState } from 'react';
import { cn } from '@/lib/utils';

/**
 * Aceternity Resizable Navbar, Kleano version: fixed, theme colours, lucide icons, a real toggle
 * button, and no spring. It gathers into a glass pill after 100px of scrolling.
 */

const glass = '0 0 24px rgb(34 42 53 / 0.08), 0 0 0 1px var(--border), 0 16px 68px rgb(47 48 55 / 0.08)';
const ease = { duration: 0.5, ease: [0.22, 1, 0.36, 1] } as const;

export const Navbar = ({ children, className }: { children: React.ReactNode; className?: string }) => {
  const { scrollY } = useScroll();
  const [visible, setVisible] = useState(false);
  useMotionValueEvent(scrollY, 'change', (latest) => setVisible(latest > 100));

  return (
    <div className={cn('fixed inset-x-0 top-[env(safe-area-inset-top)] z-40 w-full pt-2', className)}>
      {React.Children.map(children, (child) =>
        React.isValidElement(child) ? React.cloneElement(child as React.ReactElement<{ visible?: boolean }>, { visible }) : child,
      )}
    </div>
  );
};

export const NavBody = ({ children, className, visible }: { children: React.ReactNode; className?: string; visible?: boolean }) => (
  <motion.div
    animate={{ boxShadow: visible ? glass : 'none', width: visible ? 'min(1020px, 94%)' : '100%', y: visible ? 8 : 0 }}
    transition={ease}
    className={cn(
      'relative z-[60] mx-auto hidden max-w-7xl flex-row items-center justify-between rounded-full px-4 py-2 lg:flex',
      visible && 'bg-card/80 backdrop-blur-xl',
      className,
    )}
  >
    {children}
  </motion.div>
);

export const NavItems = ({ items, className, onItemClick }: { items: { name: string; link: string }[]; className?: string; onItemClick?: () => void }) => {
  const [hovered, setHovered] = useState<number | null>(null);
  return (
    <div onMouseLeave={() => setHovered(null)} className={cn('hidden flex-1 flex-row items-center justify-center gap-1 text-sm font-medium lg:flex', className)}>
      {items.map((item, idx) => (
        <a onMouseEnter={() => setHovered(idx)} onClick={onItemClick} className="relative px-3 py-2 whitespace-nowrap text-muted-foreground hover:text-foreground" key={item.link} href={item.link}>
          {hovered === idx && <motion.div layoutId="nav-hovered" className="absolute inset-0 h-full w-full rounded-full bg-muted" />}
          <span className="relative z-20">{item.name}</span>
        </a>
      ))}
    </div>
  );
};

export const MobileNav = ({ children, className, visible }: { children: React.ReactNode; className?: string; visible?: boolean }) => (
  <motion.div
    animate={{ boxShadow: visible ? glass : 'none', y: visible ? 6 : 0 }}
    transition={ease}
    className={cn('relative z-50 mx-auto flex w-[calc(100%-1.5rem)] flex-col rounded-3xl px-3 py-2 lg:hidden', visible && 'bg-card/85 backdrop-blur-xl', className)}
  >
    {children}
  </motion.div>
);

export const MobileNavHeader = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <div className={cn('flex w-full flex-row items-center justify-between gap-2', className)}>{children}</div>
);

export const MobileNavMenu = ({ children, className, isOpen }: { children: React.ReactNode; className?: string; isOpen: boolean }) => (
  <AnimatePresence>
    {isOpen && (
      <motion.div
        initial={{ opacity: 0, y: -8 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -8 }}
        transition={{ duration: 0.25, ease: ease.ease }}
        className={cn('absolute inset-x-0 top-[calc(100%+8px)] z-50 flex w-full flex-col gap-1 rounded-3xl border bg-card p-3 shadow-xl', className)}
      >
        {children}
      </motion.div>
    )}
  </AnimatePresence>
);

export const MobileNavToggle = ({ isOpen, onClick, label }: { isOpen: boolean; onClick: () => void; label: string }) => (
  <button type="button" onClick={onClick} aria-expanded={isOpen} aria-label={label} className="grid size-10 place-items-center rounded-full text-foreground hover:bg-muted">
    {isOpen ? <X className="size-5" aria-hidden="true" /> : <Menu className="size-5" aria-hidden="true" />}
  </button>
);
