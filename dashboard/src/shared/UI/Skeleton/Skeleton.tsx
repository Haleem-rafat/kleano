import type { CSSProperties } from 'react';
import { cn } from '@/shadecn/lib/utils';

/**
 * Loading placeholders shaped like the real page kit (PageHeader, SectionCard,
 * InfoList, DataTable, forms). Use these instead of spinners or "Loading…" text.
 */

export const Skeleton = ({ className, style }: { className?: string; style?: CSSProperties }) => (
  <span
    aria-hidden
    style={style}
    className={cn('block animate-pulse rounded-md bg-muted', className)}
  />
);

/** Matches PageHeader: optional back button + avatar, title, one-line description, actions. */
export const HeaderSkeleton = ({
  details = false,
  actions = 1,
}: {
  details?: boolean;
  actions?: number;
}) => (
  <div className="flex flex-wrap items-center justify-between gap-3">
    <div className="flex items-center gap-3">
      {details && <Skeleton className="h-9 w-9 rounded-full" />}
      {details && <Skeleton className="h-10 w-10 rounded-full" />}
      <div className="space-y-2">
        <Skeleton className="h-5 w-44" />
        <Skeleton className="h-3 w-28" />
      </div>
    </div>
    <div className="flex gap-2">
      {Array.from({ length: actions }).map((_, i) => (
        <Skeleton key={i} className="h-9 w-28 rounded-lg" />
      ))}
    </div>
  </div>
);

/** Matches a SectionCard with InfoList rows. */
export const CardSkeleton = ({
  rows = 4,
  columns = 2,
  className,
}: {
  rows?: number;
  columns?: 1 | 2;
  className?: string;
}) => (
  <div className={cn('rounded-lg border border-border bg-card p-5', className)}>
    <Skeleton className="mb-5 h-4 w-32" />
    <div className={cn('grid gap-x-6', columns === 2 && 'sm:grid-cols-2')}>
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="space-y-2 border-b border-border py-3 last:border-b-0">
          <Skeleton className="h-3 w-20" />
          <Skeleton className="h-4 w-3/5" />
        </div>
      ))}
    </div>
  </div>
);

/** Matches the stat tiles row. */
export const TilesSkeleton = ({ count = 4 }: { count?: number }) => (
  <div
    className={cn('grid gap-3 sm:grid-cols-2', count >= 4 ? 'xl:grid-cols-4' : 'sm:grid-cols-3')}>
    {Array.from({ length: count }).map((_, i) => (
      <div key={i} className="space-y-2 rounded-lg border border-border bg-card px-4 py-3">
        <Skeleton className="h-3 w-24" />
        <Skeleton className="h-6 w-20" />
      </div>
    ))}
  </div>
);

/** Matches DataTable: header row + body rows inside the card frame. */
export const TableSkeleton = ({ rows = 8, columns = 5 }: { rows?: number; columns?: number }) => (
  <div className="overflow-hidden rounded-lg border border-border bg-card">
    <div className="flex gap-6 border-b border-border px-4 py-3">
      {Array.from({ length: columns }).map((_, i) => (
        <Skeleton key={i} className="h-3 flex-1" />
      ))}
    </div>
    {Array.from({ length: rows }).map((_, r) => (
      <div
        key={r}
        className="flex items-center gap-6 border-b border-border px-4 py-3.5 last:border-b-0">
        {Array.from({ length: columns }).map((__, c) =>
          c === 0 ? (
            <div key={c} className="flex flex-1 items-center gap-3">
              <Skeleton className="h-8 w-8 shrink-0 rounded-full" />
              <Skeleton className="h-4 w-2/3" />
            </div>
          ) : (
            <Skeleton key={c} className="h-4 flex-1" />
          )
        )}
      </div>
    ))}
  </div>
);

/** Matches a form: label + 40px field per row, then the submit bar. */
export const FormSkeleton = ({ fields = 5 }: { fields?: number }) => (
  <div className="space-y-5" aria-busy>
    {Array.from({ length: fields }).map((_, i) => (
      <div key={i} className="space-y-2">
        <Skeleton className="h-3.5 w-28" />
        <Skeleton className="h-10 w-full rounded-md" />
      </div>
    ))}
  </div>
);

/** Matches a chart card: title, then bars. */
export const ChartSkeleton = ({ className }: { className?: string }) => (
  <div className={cn('rounded-lg border border-border bg-card p-5', className)}>
    <Skeleton className="mb-6 h-4 w-36" />
    <div className="flex h-48 items-end gap-3">
      {[45, 70, 35, 85, 55, 65, 40].map((h, i) => (
        <Skeleton
          key={i}
          className="flex-1 rounded-b-none rounded-t-md"
          style={{ height: `${h}%` }}
        />
      ))}
    </div>
  </div>
);

type PageKind = 'list' | 'details' | 'dashboard' | 'form';

/** Whole-page placeholder for route loading and first data load. */
export const PageSkeleton = ({ kind = 'list' }: { kind?: PageKind }) => (
  <div className="space-y-5" aria-busy aria-live="polite">
    <HeaderSkeleton details={kind === 'details'} actions={kind === 'details' ? 2 : 1} />
    {kind === 'list' && (
      <>
        <Skeleton className="h-9 w-72 max-w-full rounded-md" />
        <TableSkeleton />
      </>
    )}
    {kind === 'details' && (
      <>
        <TilesSkeleton count={3} />
        <div className="grid gap-5 xl:grid-cols-3">
          <div className="space-y-5 xl:col-span-2">
            <CardSkeleton rows={6} />
            <CardSkeleton rows={4} />
          </div>
          <CardSkeleton rows={4} columns={1} />
        </div>
      </>
    )}
    {kind === 'dashboard' && (
      <>
        <TilesSkeleton count={4} />
        <div className="grid gap-5 xl:grid-cols-2">
          <ChartSkeleton />
          <ChartSkeleton />
        </div>
      </>
    )}
    {kind === 'form' && (
      <div className="mx-auto max-w-2xl rounded-lg border border-border bg-card p-5">
        <FormSkeleton />
      </div>
    )}
  </div>
);
