'use client';

import { ArrowRight } from 'lucide-react';
import Link from 'next/link';
import { Button as MovingBorderButton } from '@/components/ui/moving-border';
import { cn } from '@/lib/utils';

/** The primary call to action everywhere on the page: Aceternity Moving Border around a link to booking. */
export function BookButton({ locale, label, size = 'lg' }: { locale: string; label: string; size?: 'sm' | 'lg' }) {
  return (
    <MovingBorderButton
      as={Link}
      href={`/${locale}/app/book`}
      borderRadius="9999px"
      containerClassName={cn('w-auto', size === 'lg' ? 'h-13' : 'h-10')}
      className={cn('whitespace-nowrap', size === 'lg' ? 'gap-2 px-7 text-base' : 'px-5')}
    >
      {label}
      {size === 'lg' ? <ArrowRight className="size-5 rtl:-scale-x-100" aria-hidden="true" /> : null}
    </MovingBorderButton>
  );
}
