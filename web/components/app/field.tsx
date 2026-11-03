'use client';

import type { ComponentProps, ReactNode } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

/**
 * Web version of the apps' KTextField: label above (footnote, secondary colour), filled field,
 * radius 14, purple border when focused, red border and message below on error.
 */
export function Field({
  id,
  label,
  error,
  start,
  end,
  className,
  ...props
}: ComponentProps<typeof Input> & {
  id: string;
  label: string;
  error?: string | null;
  /** Something fixed before the text, e.g. the +20 dial code. */
  start?: ReactNode;
  /** Something after the text, e.g. a show-password button. */
  end?: ReactNode;
}) {
  const errorId = `${id}-error`;
  return (
    <div className="grid gap-1.5">
      <Label htmlFor={id} className="text-[13px] font-normal text-muted-foreground">
        {label}
      </Label>
      <div
        // A left-to-right value (a phone number) keeps its prefix on the left, even in Arabic.
        dir={props.dir}
        className={cn(
          'flex h-[52px] items-center gap-2 rounded-[14px] border-2 border-transparent bg-muted px-3.5 transition-colors focus-within:border-primary',
          error && 'border-destructive focus-within:border-destructive',
        )}
      >
        {start}
        <Input
          id={id}
          aria-invalid={Boolean(error)}
          aria-describedby={error ? errorId : undefined}
          className={cn(
            'h-full min-w-0 flex-1 rounded-none border-0 bg-transparent px-0 text-[17px] shadow-none focus-visible:ring-0 dark:bg-transparent',
            className,
          )}
          {...props}
        />
        {end}
      </div>
      {error ? (
        <p id={errorId} role="alert" className="text-[13px] text-destructive">
          {error}
        </p>
      ) : null}
    </div>
  );
}
