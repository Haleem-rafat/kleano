import { Check } from 'lucide-react';
import Link from 'next/link';
import { Reveal, Section, SectionHead } from '@/components/landing/shared';
import { GlowingEffect } from '@/components/ui/glowing-effect';
import type { Dictionary } from '@/lib/content';
import { cn } from '@/lib/utils';

/** The brief's pricing section, without invented prices: real prices depend on the visitor's area. */
export function Plans({ t, locale }: { t: Dictionary['plans']; locale: string }) {
  return (
    <Section id="plans">
      <SectionHead number="05" label={t.label} title={t.title} lead={t.note} center />
      <div className="mx-auto grid max-w-4xl gap-5 md:grid-cols-2">
        {t.items.map((plan, i) => (
          <Reveal key={plan.name} delay={i * 0.08} className={cn('relative rounded-3xl border p-1.5', i === 1 && 'border-primary/50')}>
            <GlowingEffect spread={40} proximity={64} inactiveZone={0.01} borderWidth={2} disabled={false} />
            <div className="relative flex h-full flex-col gap-6 rounded-[20px] bg-card p-7">
              <div className="grid gap-2">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <h3 className="font-display text-2xl font-semibold">{plan.name}</h3>
                  {plan.tag ? <span className="rounded-full bg-secondary px-3 py-1 text-xs font-semibold text-secondary-foreground">{plan.tag}</span> : null}
                </div>
                <p className="text-muted-foreground">{plan.body}</p>
              </div>
              <ul className="grid flex-1 content-start gap-3">
                {plan.points.map((point) => (
                  <li key={point} className="flex items-start gap-2.5">
                    <Check className="mt-1 size-4.5 shrink-0 text-primary" aria-hidden="true" />
                    {point}
                  </li>
                ))}
              </ul>
              <Link
                href={plan.href === 'book' ? `/${locale}/app/book` : '#get'}
                className={cn('grid h-12 place-items-center rounded-full font-semibold transition', plan.href === 'book' ? 'bg-primary text-primary-foreground hover:opacity-90' : 'bg-secondary text-secondary-foreground hover:bg-muted')}
              >
                {plan.cta}
              </Link>
            </div>
          </Reveal>
        ))}
      </div>
    </Section>
  );
}
