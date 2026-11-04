'use client';

import { AlertCircle, RotateCw } from 'lucide-react';
import type { ReactNode } from 'react';
import { Button } from '@/components/ui/button';
import { LoaderOne } from '@/components/ui/loader';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { OrderStatus } from '@/lib/kleano/types';
import { cn } from '@/lib/utils';

/** Kleano works in Saudi Arabia, so every time shows the Saudi clock, wherever the viewer is. */
export const SAUDI_TIME = 'Asia/Riyadh';

/** Shared pieces of the customer web app: headings, money, status and the three states. */

export function PageTitle({ title, subtitle, action }: { title: string; subtitle?: ReactNode; action?: ReactNode }) {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div className="grid gap-1">
        <h1 className="text-2xl font-bold tracking-tight md:text-3xl rtl:tracking-normal">{title}</h1>
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

export function StatusBadge({ status, t, label }: { status: OrderStatus; t: AppDictionary; label?: string }) {
  return (
    <span className={cn('inline-flex h-7 items-center rounded-full px-3 text-xs font-semibold', tone[status] ?? 'bg-secondary text-secondary-foreground')}>
      {label ?? t.status[status] ?? status}
    </span>
  );
}

/** The money and rewards hero: Kleano purple in both themes, so a balance feels like a card you own. */
export function BalanceCard({ icon, label, children, className }: { icon: ReactNode; label: string; children: ReactNode; className?: string }) {
  return (
    <section className={cn('relative isolate grid gap-5 overflow-hidden rounded-[var(--radius-card)] bg-gradient-to-br from-[#6b3f80] via-[#543063] to-[#2c1838] p-6 text-white shadow-lg shadow-black/10 md:p-7', className)}>
      <span aria-hidden="true" className="absolute -end-16 -top-20 -z-10 size-64 rounded-full bg-white/10 blur-2xl" />
      <span aria-hidden="true" className="absolute -start-10 -bottom-24 -z-10 size-56 rounded-full bg-[#b88cd0]/25 blur-2xl" />
      <div className="flex items-center gap-2.5 text-sm font-medium text-white/80">
        <span className="grid size-9 place-items-center rounded-full bg-white/15 [&_svg]:size-[18px]">{icon}</span>
        {label}
      </div>
      {children}
    </section>
  );
}

const stageIndex = (status: OrderStatus) => (status === 'COMPLETED' ? 3 : status === 'ON_WASHING' ? 2 : status === 'BIKER_ON_THE_WAY' || status === 'BIKER_ARRIVED' ? 1 : 0);

/** Where an active wash has got to, in four steps. */
export function OrderStages({ status, t, className }: { status: OrderStatus; t: AppDictionary; className?: string }) {
  const at = stageIndex(status);
  return (
    <ol className={cn('grid grid-cols-4 gap-1.5', className)}>
      {t.home.stages.map((label, i) => (
        <li key={label} className="grid gap-1.5" aria-current={i === at ? 'step' : undefined}>
          <span className={cn('h-1 rounded-full', i < at ? 'bg-primary' : i === at ? 'animate-pulse bg-primary motion-reduce:animate-none' : 'bg-muted')} />
          <span className={cn('truncate text-[11px] font-medium md:text-xs', i <= at ? 'text-foreground' : 'text-muted-foreground')}>{label}</span>
        </li>
      ))}
    </ol>
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
  return new Intl.DateTimeFormat(locale === 'ar' ? 'ar-EG' : 'en-GB', { dateStyle: 'medium', timeStyle: 'short', timeZone: SAUDI_TIME }).format(new Date(iso));
}
