'use client';

import type { ComponentProps, ReactNode } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

/**
 * Aceternity sign-up-form field: label above an Aceternity Input (glow follows the pointer),
 * with optional fixed text before the value (the +20 dial code) or a button after it.
 */
export function Field({
  id,
  label,
  error,
  start,
  end,
  className,
  dir,
  ...props
}: ComponentProps<typeof Input> & {
  id: string;
  label: string;
  error?: string | null;
  start?: ReactNode;
  end?: ReactNode;
}) {
  const errorId = `${id}-error`;
  return (
    <div className="flex w-full flex-col gap-2">
      <Label htmlFor={id}>{label}</Label>
      {/* A left-to-right value (a phone number) keeps its prefix on the left, even in Arabic. */}
      <div className="relative" dir={dir}>
        {start ? (
          <span className="pointer-events-none absolute inset-y-0 start-4 z-10 flex items-center font-medium text-muted-foreground">
            {start}
          </span>
        ) : null}
        <Input
          id={id}
          dir={dir}
          aria-invalid={Boolean(error)}
          aria-describedby={error ? errorId : undefined}
          className={cn(start && 'ps-14', end && 'pe-12', className)}
          {...props}
        />
        {end ? <span className="absolute inset-y-0 end-2 z-10 flex items-center">{end}</span> : null}
      </div>
      {error ? (
        <p id={errorId} role="alert" className="text-sm text-destructive">
          {error}
        </p>
      ) : null}
    </div>
  );
}
