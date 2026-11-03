'use client';

import { Bike, CircleHelp, ListChecks, MapPinned, Sparkles } from 'lucide-react';
import { useEffect, useState } from 'react';
import { FloatingDock, type DockItem } from '@/components/ui/floating-dock';
import type { Dictionary } from '@/lib/dictionaries';

/** The page's sections in reading order; each id is a section of app/[locale]/page.tsx. */
const SECTIONS = [
  { id: 'how', icon: <ListChecks aria-hidden="true" /> },
  { id: 'services', icon: <Sparkles aria-hidden="true" /> },
  { id: 'tracking', icon: <MapPinned aria-hidden="true" /> },
  { id: 'bikers', icon: <Bike aria-hidden="true" /> },
  { id: 'faq', icon: <CircleHelp aria-hidden="true" /> },
] as const;

/**
 * Which section is being read: an observer on a band across the middle of the screen, so only
 * one section counts at a time and nothing runs between crossings.
 */
function useActiveSection(): string | null {
  const [active, setActive] = useState<string | null>(null);
  useEffect(() => {
    const elements = SECTIONS.map((s) => document.getElementById(s.id)).filter((e): e is HTMLElement => e !== null);
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) if (entry.isIntersecting) setActive(entry.target.id);
      },
      { rootMargin: '-45% 0px -45% 0px' },
    );
    elements.forEach((e) => observer.observe(e));
    return () => observer.disconnect();
  }, []);
  return active;
}

/** Aceternity Floating Dock with the page's sections, fixed at the bottom (Framecast pattern). */
export function LandingDock({ t }: { t: Dictionary }) {
  const active = useActiveSection();
  const items: DockItem[] = SECTIONS.map((s) => ({ id: s.id, title: t.nav[s.id], icon: s.icon, href: `#${s.id}` }));
  return (
    <div className="pointer-events-none fixed inset-x-0 bottom-[calc(12px+env(safe-area-inset-bottom))] z-40 flex justify-center">
      <div className="pointer-events-auto">
        <FloatingDock items={items} active={active} />
      </div>
    </div>
  );
}

/** Room under the footer so the fixed dock never covers its last line. */
export function LandingDockSpacer() {
  return <div aria-hidden="true" className="h-24" />;
}
