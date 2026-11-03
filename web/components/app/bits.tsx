'use client';

import { AlertCircle, RotateCw } from 'lucide-react';
import type { ReactNode } from 'react';
import { Button } from '@/components/ui/button';
import { LoaderOne } from '@/components/ui/loader';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { OrderStatus } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

/** Shared pieces of the customer web app: headings, money, status and the three states. */

export function PageTitle({ title, subtitle, action }: { title: string; subtitle?: ReactNode; action?: ReactNode }) {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div className="grid gap-1">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl rtl:tracking-normal">{title}</h1>
        {subtitle ? <p className="text-muted-foreground">{subtitle}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function SectionTitle({ title, action }: { title: string; action?: ReactNode }) {
  return (
    <div className="mt-10 mb-3 flex items-center justify-between gap-3">
      <h2 className="text-xl font-semibold">{title}</h2>
      {action}
    </div>
  );
}

export function Money({ value, t, className }: { value: number | undefined; t: AppDictionary; className?: string }) {
  const amount = new Intl.NumberFormat(undefined, { maximumFractionDigits: 2 }).format(value ?? 0);
  return (
    <span className={cn('tabular-nums', className)}>
      {amount} <span className="text-[0.8em] font-medium opacity-70">{t.common.sar}</span>
    </span>
  );
}

const tone: Partial<Record<OrderStatus, string>> = {
  COMPLETED: 'bg-success/15 text-success',
  CANCELLED_BY_USER: 'bg-destructive/10 text-destructive',
  CANCELLED_BY_ADMIN: 'bg-destructive/10 text-destructive',
  CANCELLED_BY_BIKER: 'bg-destructive/10 text-destructive',
  PAYMENT_FAILED: 'bg-destructive/10 text-destructive',
  SCHEDULED: 'bg-muted text-muted-foreground',
};

export function StatusBadge({ status, t }: { status: OrderStatus; t: AppDictionary }) {
  return (
    <span className={cn('inline-flex h-7 items-center rounded-full px-3 text-xs font-semibold', tone[status] ?? 'bg-secondary text-secondary-foreground')}>
      {t.status[status] ?? status}
    </span>
  );
}

export function Loading({ label }: { label: string }) {
  return (
    <div role="status" aria-label={label} className="grid place-items-center py-16">
      <LoaderOne />
    </div>
  );
}

export function Empty({ icon, text, action }: { icon: ReactNode; text: string; action?: ReactNode }) {
  return (
    <div className="grid justify-items-center gap-4 rounded-2xl bg-muted/60 px-6 py-12 text-center">
      <span className="grid size-14 place-items-center rounded-full bg-secondary text-primary [&_svg]:size-7">{icon}</span>
      <p className="max-w-sm text-muted-foreground">{text}</p>
      {action}
    </div>
  );
}

export function Failed({ message, onRetry, t }: { message: string; onRetry: () => void; t: AppDictionary }) {
  return (
    <div role="alert" className="grid justify-items-center gap-3 rounded-2xl bg-destructive/5 px-6 py-10 text-center">
      <AlertCircle className="size-7 text-destructive" aria-hidden="true" />
      <p className="max-w-md text-foreground">{message}</p>
      <Button variant="outline" size="chip" onClick={onRetry}>
        <RotateCw />
        {t.common.retry}
      </Button>
    </div>
  );
}

export function formatWhen(iso: string | undefined, locale: string) {
  if (!iso) return '';
  return new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(iso));
}
