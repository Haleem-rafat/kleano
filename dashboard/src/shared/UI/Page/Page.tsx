import { ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { IoArrowBack } from 'react-icons/io5';
import { cn } from '@/shadecn/lib/utils';

/**
 * Page building blocks for every dashboard screen. Theme tokens only
 * (see docs/dashboard-refactor.md): no slate/hex colours, no gradients.
 */

interface IPageHeaderProps {
  title: ReactNode;
  description?: ReactNode;
  /** Buttons on the end side (e.g. "Add plan"). */
  actions?: ReactNode;
  /** Details pages: shows a back button before the title. */
  onBack?: () => void;
  /** Avatar or icon before the title (details pages). */
  leading?: ReactNode;
}

/** Title + one-line description + actions; the top of every page. */
export const PageHeader = ({ title, description, actions, onBack, leading }: IPageHeaderProps) => (
  <header className="flex flex-wrap items-center justify-between gap-3">
    <div className="flex min-w-0 items-center gap-3">
      {onBack && (
        <button
          type="button"
          onClick={onBack}
          aria-label="Back"
          className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-muted text-foreground transition-colors hover:bg-accent">
          <IoArrowBack className="h-4 w-4 rtl:rotate-180" />
        </button>
      )}
      {leading}
      <div className="min-w-0">
        <h1 className="truncate text-xl font-semibold tracking-tight text-foreground">{title}</h1>
        {description && (
          <p className="mt-0.5 truncate text-[13px] text-muted-foreground">{description}</p>
        )}
      </div>
    </div>
    {actions && <div className="flex flex-wrap items-center gap-2">{actions}</div>}
  </header>
);

interface IInfoItem {
  label: ReactNode;
  value: ReactNode;
  /** Take the full row (long text). */
  wide?: boolean;
}

/** Label/value pairs for details pages: compact rows, two columns from `sm`. */
export const InfoList = ({ items, className }: { items: IInfoItem[]; className?: string }) => (
  <dl className={cn('grid gap-x-6 sm:grid-cols-2', className)}>
    {items.map((item, i) => (
      <div
        key={i}
        className={cn(
          'min-w-0 border-b border-border py-3 last:border-b-0',
          item.wide && 'sm:col-span-2'
        )}>
        <dt className="text-xs font-medium text-muted-foreground">{item.label}</dt>
        <dd className="mt-1 break-words text-sm font-medium text-foreground">
          {item.value === undefined || item.value === null || item.value === '' ? '—' : item.value}
        </dd>
      </div>
    ))}
  </dl>
);

interface ISectionCardProps {
  title?: string;
  /** Small link or button on the end of the title row. */
  action?: ReactNode;
  className?: string;
  children: ReactNode;
}

/** A content group on `card`. Replaces the old per-section gradient headers. */
export const SectionCard = ({ title, action, className, children }: ISectionCardProps) => (
  <section className={cn('min-w-0 rounded-lg border border-border bg-card p-5', className)}>
    {(title || action) && (
      <div className="mb-4 flex items-center justify-between gap-3">
        {title && <h2 className="text-sm font-semibold text-card-foreground">{title}</h2>}
        {action}
      </div>
    )}
    {children}
  </section>
);

interface IStatCardProps {
  title: string;
  /** Undefined while loading (shows a skeleton). */
  value?: number;
  icon: ReactNode;
  /** Opens the page behind the number. */
  to?: string;
}

/** One headline number, optionally linking to its page. */
export const StatCard = ({ title, value, icon, to }: IStatCardProps) => {
  const body = (
    <>
      <div className="flex items-center justify-between gap-3">
        <span className="text-[13px] font-medium capitalize text-muted-foreground">{title}</span>
        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-md bg-accent text-accent-foreground">
          {icon}
        </span>
      </div>
      {value === undefined ? (
        <div className="mt-2 h-8 w-20 animate-pulse rounded-md bg-muted motion-reduce:animate-none" />
      ) : (
        <p className="mt-2 text-[28px] font-semibold tabular-nums leading-8 tracking-tight text-card-foreground">
          {value.toLocaleString()}
        </p>
      )}
    </>
  );
  const className =
    'block rounded-lg border border-border bg-card p-5 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring';
  return to ? (
    <Link to={to} className={cn(className, 'hover:border-primary/40')}>
      {body}
    </Link>
  ) : (
    <div className={className}>{body}</div>
  );
};
