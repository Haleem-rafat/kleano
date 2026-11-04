'use client';

import { Check, ChevronDown, ChevronRight, Loader2, Search, X } from 'lucide-react';
import { motion } from 'motion/react';
import Link from 'next/link';
import { Dialog as DialogPrimitive } from 'radix-ui';
import { useId, useMemo, useState, type ComponentProps, type ReactNode } from 'react';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';

/**
 * The web app's building blocks: same jobs as the phone app's KSheet, KDialog, KPickerField,
 * KListRow and KSegmented, in the web's own look. Every surface here is solid; glass is only for
 * the navigation layer in app-shell.tsx.
 */

/** Bottom sheet on phones, slide-over from the inline end on tablet and desktop. Esc closes it. */
export function Sheet({
  open,
  onOpenChange,
  title,
  description,
  closeLabel,
  footer,
  wide,
  children,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description?: ReactNode;
  closeLabel: string;
  footer?: ReactNode;
  wide?: boolean;
  children: ReactNode;
}) {
  return (
    <DialogPrimitive.Root open={open} onOpenChange={onOpenChange}>
      <DialogPrimitive.Portal>
        <DialogPrimitive.Overlay className="fixed inset-0 z-50 bg-black/50 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:animate-in data-[state=open]:fade-in-0" />
        <DialogPrimitive.Content
          {...(description ? {} : { 'aria-describedby': undefined })}
          className={cn(
            'fixed inset-x-0 bottom-0 z-50 flex max-h-[92dvh] flex-col rounded-t-[var(--radius-sheet)] bg-card text-card-foreground shadow-xl outline-none',
            'data-[state=closed]:animate-out data-[state=closed]:slide-out-to-bottom data-[state=open]:animate-in data-[state=open]:slide-in-from-bottom',
            'md:inset-x-auto md:inset-y-0 md:end-0 md:max-h-none md:w-full md:rounded-none md:rounded-s-[var(--radius-card)]',
            'md:data-[state=closed]:slide-out-to-end md:data-[state=open]:slide-in-from-end',
            wide ? 'md:max-w-2xl' : 'md:max-w-md',
          )}
        >
          <div className="flex items-start justify-between gap-3 border-b px-5 py-4">
            <div className="min-w-0">
              <DialogPrimitive.Title className="font-heading text-lg font-semibold">{title}</DialogPrimitive.Title>
              {description ? <DialogPrimitive.Description className="mt-1 text-sm text-muted-foreground">{description}</DialogPrimitive.Description> : null}
            </div>
            <DialogPrimitive.Close aria-label={closeLabel} className="grid size-10 shrink-0 place-items-center rounded-full text-muted-foreground transition hover:bg-muted hover:text-foreground">
              <X className="size-5" aria-hidden="true" />
            </DialogPrimitive.Close>
          </div>
          <div className="min-h-0 flex-1 overflow-y-auto px-5 py-4">{children}</div>
          {footer ? <div className="border-t px-5 py-4 pb-[calc(16px+env(safe-area-inset-bottom))]">{footer}</div> : null}
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  );
}

/** A confirmation, always with a real choice. */
export function Confirm({
  open,
  onOpenChange,
  title,
  description,
  confirmLabel,
  cancelLabel,
  destructive,
  busy,
  onConfirm,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description: ReactNode;
  confirmLabel: string;
  cancelLabel: string;
  destructive?: boolean;
  busy?: boolean;
  onConfirm: () => void;
}) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>{description}</AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>{cancelLabel}</AlertDialogCancel>
          <AlertDialogAction
            disabled={busy}
            className={destructive ? 'bg-destructive text-white hover:bg-destructive/90' : undefined}
            onClick={(e) => {
              e.preventDefault();
              onConfirm();
            }}
          >
            {busy ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {confirmLabel}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}

export type PickerOption = { value: string; label: string; hint?: string; leading?: ReactNode };

/** Dropdown replacement: a field that opens a searchable list. */
export function PickerField({
  id,
  label,
  value,
  placeholder,
  options,
  onChange,
  searchLabel,
  emptyText,
  closeLabel,
  error,
  disabled,
  loading,
}: {
  id: string;
  label: string;
  value: string | undefined;
  placeholder: string;
  options: PickerOption[];
  onChange: (value: string) => void;
  searchLabel: string;
  emptyText: string;
  closeLabel: string;
  error?: string;
  disabled?: boolean;
  loading?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const selected = options.find((o) => o.value === value);
  const errorId = `${id}-error`;
  return (
    <div className="flex w-full flex-col gap-2">
      <Label htmlFor={id}>{label}</Label>
      <button
        id={id}
        type="button"
        disabled={disabled}
        aria-haspopup="dialog"
        data-invalid={error ? '' : undefined}
        aria-describedby={error ? errorId : undefined}
        onClick={() => setOpen(true)}
        className="shadow-input flex h-12 w-full items-center justify-between gap-2 rounded-md bg-muted px-3.5 text-start text-base transition focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50 data-invalid:ring-2 data-invalid:ring-destructive"
      >
        <span className={cn('truncate', !(selected || value) && 'text-muted-foreground')}>{selected?.label ?? value ?? placeholder}</span>
        {loading ? <Loader2 className="size-4 shrink-0 animate-spin text-muted-foreground" aria-hidden="true" /> : <ChevronDown className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />}
      </button>
      {error ? (
        <p id={errorId} role="alert" className="text-sm text-destructive">
          {error}
        </p>
      ) : null}
      <PickerSheet
        open={open}
        onOpenChange={setOpen}
        title={label}
        options={options}
        value={value}
        onPick={(v) => {
          onChange(v);
          setOpen(false);
        }}
        searchLabel={searchLabel}
        emptyText={emptyText}
        closeLabel={closeLabel}
      />
    </div>
  );
}

export function PickerSheet({
  open,
  onOpenChange,
  title,
  options,
  value,
  onPick,
  searchLabel,
  emptyText,
  closeLabel,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  options: PickerOption[];
  value: string | undefined;
  onPick: (value: string) => void;
  searchLabel: string;
  emptyText: string;
  closeLabel: string;
}) {
  const [query, setQuery] = useState('');
  const found = useMemo(() => {
    const q = query.trim().toLowerCase();
    return q ? options.filter((o) => `${o.label} ${o.hint ?? ''}`.toLowerCase().includes(q)) : options;
  }, [options, query]);
  return (
    <Sheet
      open={open}
      onOpenChange={(next) => {
        if (!next) setQuery('');
        onOpenChange(next);
      }}
      title={title}
      closeLabel={closeLabel}
    >
      <div className="relative mb-3">
        <Search className="pointer-events-none absolute inset-y-0 start-4 z-10 my-auto size-4 text-muted-foreground" aria-hidden="true" />
        <Input value={query} onChange={(e) => setQuery(e.target.value)} placeholder={searchLabel} aria-label={searchLabel} className="ps-10" />
      </div>
      {found.length === 0 ? (
        <p className="py-8 text-center text-muted-foreground">{emptyText}</p>
      ) : (
        <ul className="grid gap-1">
          {found.map((o) => (
            <li key={o.value}>
              <button
                type="button"
                onClick={() => onPick(o.value)}
                className="flex min-h-12 w-full items-center gap-3 rounded-xl px-3 py-2 text-start transition hover:bg-muted focus-visible:bg-muted focus-visible:outline-none"
              >
                {o.leading}
                <span className="min-w-0 flex-1 truncate">{o.label}</span>
                {o.hint ? (
                  <span className="shrink-0 text-sm text-muted-foreground" dir="ltr">
                    {o.hint}
                  </span>
                ) : null}
                {o.value === value ? <Check className="size-4 shrink-0 text-primary" aria-hidden="true" /> : null}
              </button>
            </li>
          ))}
        </ul>
      )}
    </Sheet>
  );
}

type RowProps = {
  icon?: ReactNode;
  title: ReactNode;
  subtitle?: ReactNode;
  trailing?: ReactNode;
  destructive?: boolean;
  chevron?: boolean;
};

function RowBody({ icon, title, subtitle, trailing, destructive, chevron }: RowProps) {
  return (
    <>
      {icon ? (
        <span className={cn('grid size-10 shrink-0 place-items-center rounded-xl [&_svg]:size-5', destructive ? 'bg-destructive/10 text-destructive' : 'bg-secondary text-primary')}>{icon}</span>
      ) : null}
      <span className="min-w-0 flex-1">
        <span className={cn('block truncate font-medium', destructive && 'text-destructive')}>{title}</span>
        {subtitle ? <span className="block truncate text-sm text-muted-foreground">{subtitle}</span> : null}
      </span>
      {trailing}
      {chevron ? <ChevronRight className="size-4 shrink-0 text-muted-foreground rtl:-scale-x-100" aria-hidden="true" /> : null}
    </>
  );
}

const rowClass = 'flex min-h-16 w-full items-center gap-3 px-4 py-3 text-start transition';

/** A list row: link, button, or plain when it has neither. */
export function Row({ href, onClick, ...props }: RowProps & { href?: string; onClick?: () => void }) {
  if (href) {
    return (
      <Link href={href} className={cn(rowClass, 'hover:bg-muted/60')}>
        <RowBody chevron {...props} />
      </Link>
    );
  }
  if (onClick) {
    return (
      <button type="button" onClick={onClick} className={cn(rowClass, 'hover:bg-muted/60')}>
        <RowBody {...props} />
      </button>
    );
  }
  return (
    <div className={rowClass}>
      <RowBody {...props} />
    </div>
  );
}

/** Rows grouped on one solid card. */
export function RowGroup({ children, className }: { children: ReactNode; className?: string }) {
  return <div className={cn('divide-y overflow-hidden rounded-[var(--radius-card)] border bg-card', className)}>{children}</div>;
}

export function Switch({ checked, onChange, label, disabled }: { checked: boolean; onChange: (next: boolean) => void; label: string; disabled?: boolean }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={cn('relative h-7 w-12 shrink-0 rounded-full transition disabled:opacity-50', checked ? 'bg-primary' : 'bg-muted-foreground/30')}
    >
      <span className={cn('absolute top-1 size-5 rounded-full bg-white shadow transition-[inset-inline-start]', checked ? 'start-6' : 'start-1')} />
    </button>
  );
}

/** Pill tabs where the highlight slides to the chosen one. */
export function Segmented<T extends string>({
  value,
  options,
  onChange,
  label,
  className,
}: {
  value: T;
  options: { value: T; label: string }[];
  onChange: (value: T) => void;
  label: string;
  className?: string;
}) {
  const group = useId();
  return (
    <div role="tablist" aria-label={label} className={cn('inline-flex max-w-full rounded-full bg-muted p-1', className)}>
      {options.map((o) => (
        <button key={o.value} role="tab" type="button" aria-selected={value === o.value} onClick={() => onChange(o.value)} className="relative min-w-0 flex-1 rounded-full px-4 py-2 text-sm font-medium whitespace-nowrap">
          {value === o.value ? <motion.span layoutId={`${group}-pill`} className="absolute inset-0 rounded-full bg-card shadow-sm" transition={{ type: 'spring', bounce: 0.25, duration: 0.5 }} /> : null}
          <span className={cn('relative', value === o.value ? 'text-foreground' : 'text-muted-foreground')}>{o.label}</span>
        </button>
      ))}
    </div>
  );
}

/** Loading shaped like a list of rows. */
export function RowsSkeleton({ count = 4, label }: { count?: number; label: string }) {
  return (
    <div role="status" aria-label={label} className="grid gap-3">
      {Array.from({ length: count }, (_, i) => (
        <div key={i} className="flex items-center gap-4 rounded-2xl border bg-card p-4">
          <Skeleton className="size-12 shrink-0 rounded-xl" />
          <div className="grid flex-1 gap-2">
            <Skeleton className="h-4 w-2/5" />
            <Skeleton className="h-3 w-3/5" />
          </div>
        </div>
      ))}
    </div>
  );
}

/** Loading shaped like a grid of cards. */
export function CardsSkeleton({ count = 3, label, className }: { count?: number; label: string; className?: string }) {
  return (
    <div role="status" aria-label={label} className={cn('grid gap-4 sm:grid-cols-2 lg:grid-cols-3', className)}>
      {Array.from({ length: count }, (_, i) => (
        <div key={i} className="grid gap-3 rounded-[var(--radius-card)] border bg-card p-5">
          <Skeleton className="size-11 rounded-xl" />
          <Skeleton className="h-5 w-3/5" />
          <Skeleton className="h-4 w-4/5" />
        </div>
      ))}
    </div>
  );
}

/** Action bar that stays above the phone dock and at the page bottom on wider screens. */
export function StickyActions({ children, className, ...props }: ComponentProps<'div'>) {
  return (
    <div
      className={cn('sticky bottom-[calc(96px+env(safe-area-inset-bottom))] z-20 -mx-4 mt-6 border-t bg-background px-4 py-3 md:bottom-0 md:mx-0 md:rounded-2xl md:border md:px-4', className)}
      {...props}
    >
      {children}
    </div>
  );
}
