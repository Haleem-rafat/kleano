import { ReactNode } from 'react';
import { cn } from '@/shadecn/lib/utils';
import { segmentGroup, segmentItem } from '@/shadecn/lib/field';

export interface ISegmentOption<T extends string> {
  value: T;
  label: string;
  /** Icon-only segments still get the label as their accessible name and tooltip. */
  icon?: ReactNode;
  iconOnly?: boolean;
  /** Small count after the label (e.g. orders per status). */
  count?: number;
}

interface ISegmentedProps<T extends string> {
  options: ISegmentOption<T>[];
  value: T;
  onChange: (value: T) => void;
  label: string;
  className?: string;
  /**
   * `box` (default): the boxed switch. `steps`: light numbered chips joined by arrows,
   * for stages of one flow (e.g. order progress) shown under a main switch.
   */
  variant?: 'box' | 'steps';
}

/**
 * The dashboard's boxed switch: view toggles, quick filters and anything with a
 * few mutually exclusive choices. Same look as the shared Tabs.
 */
export default function Segmented<T extends string>({
  options,
  value,
  onChange,
  label,
  className,
  variant = 'box',
}: ISegmentedProps<T>) {
  if (variant === 'steps') {
    return (
      <div
        role="radiogroup"
        aria-label={label}
        className={cn(
          'flex max-w-full items-center gap-1 overflow-x-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden',
          className
        )}>
        {options.map((o, i) => {
          const on = o.value === value;
          return (
            <div key={o.value} className="flex shrink-0 items-center gap-1">
              {i > 0 && (
                <span aria-hidden className="text-muted-foreground/60">
                  ›
                </span>
              )}
              <button
                type="button"
                role="radio"
                aria-checked={on}
                onClick={() => onChange(o.value)}
                className={cn(
                  'inline-flex h-8 items-center gap-2 whitespace-nowrap rounded-full border px-3 text-[13px] font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
                  on
                    ? 'border-primary/40 bg-accent text-primary'
                    : 'border-border bg-card text-muted-foreground hover:border-foreground/25 hover:text-foreground'
                )}>
                <span
                  className={cn(
                    'flex h-5 w-5 items-center justify-center rounded-full text-[11px] font-semibold tabular-nums',
                    on ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'
                  )}>
                  {i + 1}
                </span>
                {o.label}
                {o.count !== undefined && (
                  <span className="text-[11px] tabular-nums opacity-70">{o.count}</span>
                )}
              </button>
            </div>
          );
        })}
      </div>
    );
  }

  return (
    <div role="radiogroup" aria-label={label} className={cn(segmentGroup, className)}>
      {options.map((o) => {
        const on = o.value === value;
        return (
          <button
            key={o.value}
            type="button"
            role="radio"
            aria-checked={on}
            aria-pressed={on}
            aria-label={o.iconOnly ? o.label : undefined}
            title={o.iconOnly ? o.label : undefined}
            onClick={() => onChange(o.value)}
            className={cn(segmentItem, o.iconOnly && 'px-0')}>
            {o.icon}
            {!o.iconOnly && o.label}
            {o.count !== undefined && (
              <span
                className={cn(
                  'rounded-full px-1.5 text-[11px] tabular-nums',
                  on ? 'bg-primary-foreground/20' : 'bg-muted'
                )}>
                {o.count}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}
