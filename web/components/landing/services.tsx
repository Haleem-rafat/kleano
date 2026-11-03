import { Car, Check, MapPin, Plus, Wallet } from 'lucide-react';
import Image, { type StaticImageData } from 'next/image';
import type { ReactNode } from 'react';
import { Parallax, Reveal, Section, SectionHead } from '@/components/landing/shared';
import { BentoGrid } from '@/components/ui/bento-grid';
import { GlowingEffect } from '@/components/ui/glowing-effect';
import type { Dictionary } from '@/lib/content';
import inside from '@/public/images/inside.jpg';
import outside from '@/public/images/outside.jpg';
import { cn } from '@/lib/utils';

function Tile({ className, children }: { className?: string; children: ReactNode }) {
  return (
    <Reveal className={cn('relative min-h-64 rounded-3xl border p-1.5', className)}>
      <GlowingEffect spread={40} proximity={64} inactiveZone={0.01} borderWidth={2} disabled={false} />
      <div className="relative flex h-full flex-col justify-between gap-6 overflow-hidden rounded-[20px] bg-card p-6">{children}</div>
    </Reveal>
  );
}

function PhotoTile({ img, alt, title, body, className }: { img: StaticImageData; alt: string; title: string; body: string; className?: string }) {
  return (
    <Reveal className={cn('relative min-h-80 rounded-3xl border p-1.5', className)}>
      <GlowingEffect spread={40} proximity={64} inactiveZone={0.01} borderWidth={2} disabled={false} />
      <div className="group relative isolate flex h-full items-end overflow-hidden rounded-[20px] text-white">
        <Parallax className="absolute inset-x-0 -inset-y-[10%] -z-20" distance={26}>
          <Image src={img} alt={alt} fill placeholder="blur" sizes="(max-width: 768px) 100vw, 560px" className="object-cover transition-transform duration-700 ease-out group-hover:scale-105 motion-reduce:transition-none" />
        </Parallax>
        <div className="absolute inset-0 -z-10 bg-gradient-to-t from-black/85 via-black/20 to-transparent" />
        <div className="grid gap-1 p-6">
          <h3 className="font-display text-3xl font-medium rtl:text-2xl rtl:font-semibold">{title}</h3>
          <p className="text-white/80">{body}</p>
        </div>
      </div>
    </Reveal>
  );
}

function TileText({ title, body }: { title: string; body: string }) {
  return (
    <div className="grid gap-1.5">
      <h3 className="font-display text-2xl font-medium rtl:text-xl rtl:font-semibold">{title}</h3>
      <p className="text-pretty text-muted-foreground">{body}</p>
    </div>
  );
}

export function Services({ t }: { t: Dictionary['services'] }) {
  return (
    <Section id="services">
      <SectionHead number="01" label={t.label} title={t.title} lead={t.from} />
      <BentoGrid className="max-w-none md:auto-rows-auto md:grid-cols-3">
        <PhotoTile className="md:col-span-2" img={outside} alt={t.outside.alt} title={t.outside.title} body={t.outside.body} />
        <PhotoTile img={inside} alt={t.inside.alt} title={t.inside.title} body={t.inside.body} />
        <Tile>
          <span className="grid size-11 place-items-center rounded-full bg-secondary text-primary">
            <Plus className="size-5" aria-hidden="true" />
          </span>
          <TileText title={t.extras.title} body={t.extras.body} />
        </Tile>
        <Tile>
          {/* The same on/off switch as the booking screen. */}
          <span aria-hidden="true" className="relative block h-8 w-14 rounded-full bg-primary">
            <span className="absolute end-1 top-1 grid size-6 place-items-center rounded-full bg-white text-primary">
              <Check className="size-4" />
            </span>
          </span>
          <TileText title={t.freshener.title} body={t.freshener.body} />
        </Tile>
        <Tile>
          <div className="flex flex-wrap gap-2">
            {t.places.chips.map((chip, i) => (
              <span key={chip} className="inline-flex h-10 items-center gap-1.5 rounded-full bg-secondary px-4 text-sm font-medium text-secondary-foreground">
                {i === 0 ? <MapPin className="size-4" aria-hidden="true" /> : <Car className="size-4" aria-hidden="true" />}
                {chip}
              </span>
            ))}
          </div>
          <TileText title={t.places.title} body={t.places.body} />
        </Tile>
        <Tile className="md:col-span-3 md:min-h-0">
          <div className="flex flex-wrap items-center gap-5">
            <span className="grid size-11 shrink-0 place-items-center rounded-full bg-secondary text-primary">
              <Wallet className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <TileText title={t.pay.title} body={t.pay.body} />
            </div>
          </div>
        </Tile>
      </BentoGrid>
    </Section>
  );
}
