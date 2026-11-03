import { ArrowRight, Check } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { Phone } from '@/components/landing/phone';
import { ScrollStory, type StoryShot } from '@/components/landing/scroll-story';
import { Display, Label, Parallax, Reveal, Section } from '@/components/landing/shared';
import type { Dictionary } from '@/lib/content';
import washing from '@/public/images/washing.jpg';
import bikerEarnings from '@/public/images/screens/biker-earnings.jpg';
import bikerOrders from '@/public/images/screens/biker-orders.jpg';
import bikerSchedule from '@/public/images/screens/biker-schedule.jpg';
import bikerToday from '@/public/images/screens/biker-today.jpg';

export function Bikers({ t, screens, locale }: { t: Dictionary['bikers']; screens: Dictionary['screens']; locale: string }) {
  const shots: StoryShot[] = [
    { src: bikerToday, alt: screens.bikerToday, tap: [84, 19], pan: [0, 8] }, // the online switch
    { src: bikerOrders, alt: screens.bikerOrders, tap: [36, 51], pan: [0, 14] }, // wash progress
    { src: bikerSchedule, alt: screens.bikerSchedule, tap: [50, 28], pan: [0, 22] }, // a shift
    { src: bikerEarnings, alt: screens.bikerEarnings, tap: [50, 34], pan: [0, 6] }, // today's earnings
  ];
  return (
    <Section id="bikers" className="border-y bg-card/40" pinned>
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
      <div className="mt-20 md:mt-28">
        <Display className="mb-6 lg:mb-0">{t.flowTitle}</Display>
        <ScrollStory steps={t.steps} shots={shots} />
      </div>
    </Section>
  );
}
