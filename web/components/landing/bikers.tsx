import { ArrowRight, Check } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { Phone } from '@/components/landing/phone';
import { Display, Label, Parallax, Reveal, Section } from '@/components/landing/shared';
import type { Dictionary } from '@/lib/content';
import washing from '@/public/images/washing.jpg';
import bikerToday from '@/public/images/screens/biker-today.jpg';

export function Bikers({ t, screens, locale }: { t: Dictionary['bikers']; screens: Dictionary['screens']; locale: string }) {
  return (
    <Section id="bikers" className="border-y bg-card/40">
      <Reveal className="grid items-center gap-10 md:grid-cols-2 md:gap-16">
        {/* Left is physical on purpose: the man in the photo stands on the right in both languages. */}
        <div className="relative h-[560px] overflow-hidden rounded-3xl md:h-[640px]">
          <Parallax className="absolute inset-x-0 -inset-y-[8%]" distance={24}>
            <Image src={washing} alt={t.photoAlt} fill placeholder="blur" sizes="(max-width: 768px) 100vw, 540px" className="object-cover object-[78%_24%]" />
          </Parallax>
          <div aria-hidden="true" className="absolute inset-0 bg-gradient-to-t from-black/45 to-transparent" />
          <Parallax className="absolute bottom-6 left-5" distance={36}>
            <Phone src={bikerToday} alt={screens.bikerToday} className="w-[200px] rounded-[34px] p-1.5 sm:w-[230px] [&>div]:rounded-[28px]" />
          </Parallax>
        </div>
        <div className="grid gap-6">
          <Label>04 / {t.label}</Label>
          <Display>{t.title}</Display>
          <ul className="grid gap-3 text-lg">
            {t.points.map((point) => (
              <li key={point} className="flex items-start gap-3">
                <Check className="mt-1 size-5 shrink-0 text-primary" aria-hidden="true" />
                {point}
              </li>
            ))}
          </ul>
          <Link href={`/${locale}/biker/login`} className="inline-flex h-12 w-fit items-center gap-2 rounded-full border px-6 font-medium transition hover:bg-muted">
            {t.cta}
            <ArrowRight className="size-5 rtl:-scale-x-100" aria-hidden="true" />
          </Link>
        </div>
      </Reveal>
    </Section>
  );
}
