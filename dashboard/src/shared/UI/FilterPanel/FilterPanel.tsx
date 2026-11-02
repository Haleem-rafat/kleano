import { ReactNode } from 'react';
import { IoSearchOutline } from 'react-icons/io5';
import { Input } from '@shadecn/components/ui/input';
import { cn } from '@/shadecn/lib/utils';

interface IFilterPanelProps {
  /** Top row, start side: Tabs / Segmented (scrolls sideways when long). */
  tabs?: ReactNode;
  /** Top row, end side: view toggle or a small action. */
  trailing?: ReactNode;
  /** Second row: filter controls, laid out in an even grid. */
  children?: ReactNode;
  className?: string;
}

/**
 * One box above every list for its tabs and filters (same as Promo codes):
 * tabs and toggles on top, filters in a grid below, a divider only when both exist.
 */
export default function FilterPanel({ tabs, trailing, children, className }: IFilterPanelProps) {
  const hasTop = !!(tabs || trailing);
  return (
    <div className={cn('space-y-3 rounded-lg border border-border bg-card p-4', className)}>
      {hasTop && (
        <div className="flex flex-wrap items-center gap-3">
          {tabs && <div className="min-w-0 flex-1 space-y-2">{tabs}</div>}
          {trailing && <div className="ms-auto flex shrink-0 items-center gap-2">{trailing}</div>}
        </div>
      )}
      {children && (
        <div
          className={cn(
            'grid gap-2 sm:grid-cols-2 lg:grid-cols-4 [&>*]:min-w-0',
            hasTop && 'border-t border-border pt-3'
          )}>
          {children}
        </div>
      )}
    </div>
  );
}

/** Search box for FilterPanel: leading icon, full width of its grid cell. */
export const FilterSearch = ({
  value,
  onChange,
  placeholder,
  label,
}: {
  value: string;
  onChange: (value: string) => void;
  placeholder: string;
  label?: string;
}) => (
  <label className="relative block">
    <IoSearchOutline className="pointer-events-none absolute start-3 top-1/2 z-10 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
    <Input
      type="search"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      aria-label={label || placeholder}
      className="ps-9"
    />
  </label>
);
