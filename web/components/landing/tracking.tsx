import Image from 'next/image';
import { Parallax, Reveal, Section, SectionHead } from '@/components/landing/shared';
import { PointerHighlight } from '@/components/ui/pointer-highlight';
import type { Dictionary } from '@/lib/content';
import statusCard from '@/public/images/screens/status-card.jpg';
import outside from '@/public/images/outside.jpg';

export function Tracking({ t, screens }: { t: Dictionary['tracking']; screens: Dictionary['screens'] }) {
  return (
    <Section id="tracking">
      <div className="grid items-center gap-14 lg:grid-cols-[1.05fr_0.95fr]">
        <div>
          <SectionHead number="03" label={t.label} title={t.title} lead={t.lead} />
          <ul className="grid gap-8">
            {t.callouts.map((c, i) => (
              <li key={c.title}>
                <Reveal delay={i * 0.08} className="grid gap-5">
                  <PointerHighlight rectangleClassName="rounded-md" containerClassName="px-1" pointerClassName="h-4 w-4">
                    <h3 className="relative z-10 px-2 py-0.5 text-xl font-semibold">{c.title}</h3>
                  </PointerHighlight>
                  <p className="max-w-lg text-pretty text-muted-foreground">{c.body}</p>
                </Reveal>
              </li>
            ))}
          </ul>
        </div>
        {/* The real status card from the customer app, over a photo of a wash. */}
        <Reveal className="relative pb-8">
          <div className="relative aspect-[4/5] overflow-hidden rounded-3xl sm:aspect-square">
            <Image src={outside} alt="" fill placeholder="blur" sizes="(max-width: 1024px) 100vw, 480px" className="object-cover" />
          </div>
          <Parallax className="absolute inset-x-4 bottom-0 sm:inset-x-8" distance={28}>
            <div className="overflow-hidden rounded-[24px] shadow-2xl">
              <Image src={statusCard} alt={screens.statusCard} sizes="(max-width: 1024px) 90vw, 420px" className="h-auto w-full" />
            </div>
          </Parallax>
        </Reveal>
      </div>
      <p className="mt-10 text-center text-xs text-muted-foreground">{screens.note}</p>
    </Section>
  );
}
