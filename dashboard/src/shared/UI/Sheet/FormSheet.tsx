import { ReactNode } from 'react';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { cn } from '@/shadecn/lib/utils';

interface IFormSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: ReactNode;
  /** One short line under the title. */
  description?: ReactNode;
  /** Pinned under the body (e.g. Cancel / Save). Forms that render their own submit
   * button can leave this out; the body keeps bottom padding either way. */
  footer?: ReactNode;
  /** `md` (default) for forms, `lg` for lists or tables inside the sheet. */
  size?: 'md' | 'lg';
  modal?: boolean;
  children: ReactNode;
}

/**
 * The only way to open a side panel in the dashboard.
 * Layout is fixed: pinned title row → padded, scrolling body → optional pinned footer.
 * Pages never compose Sheet/SheetHeader/SheetDescription themselves, so content
 * can't lose its padding or get cut off.
 */
export default function FormSheet({
  open,
  onOpenChange,
  title,
  description,
  footer,
  size = 'md',
  modal = true,
  children,
}: IFormSheetProps) {
  return (
    <Sheet open={open} onOpenChange={onOpenChange} modal={modal}>
      <SheetContent
        className={cn('gap-0 p-0', size === 'lg' ? 'max-w-3xl' : 'max-w-xl')}
        onOpenAutoFocus={(e) => e.preventDefault()}>
        <SheetHeader className="sticky top-0 z-10 gap-1 border-b border-border bg-card/95 px-6 py-4 pe-16 backdrop-blur">
          <SheetTitle>{title}</SheetTitle>
          {description ? (
            <SheetDescription className="text-[13px]">{description}</SheetDescription>
          ) : (
            <SheetDescription className="sr-only">{title}</SheetDescription>
          )}
        </SheetHeader>
        <div className="flex min-w-0 flex-1 flex-col px-6 py-5 [&>div]:flex [&>div]:flex-1 [&>div]:flex-col [&_form]:flex-1">
          {children}
        </div>
        {footer && (
          <div className="sticky bottom-0 z-10 flex flex-col-reverse gap-2 border-t border-border bg-card px-6 py-4 sm:flex-row sm:justify-end">
            {footer}
          </div>
        )}
      </SheetContent>
    </Sheet>
  );
}

/**
 * Submit row for a form inside FormSheet: pinned to the bottom of the scroll and
 * takes its own space, so it never covers the last field.
 */
export const SheetActions = ({ children }: { children: ReactNode }) => (
  <div className="sm:[&>button]:min-w-32 sticky bottom-0 z-10 -mx-6 -mb-5 mt-auto flex flex-col-reverse gap-2 border-t border-border bg-card px-6 py-4 sm:flex-row sm:justify-end [&>button]:w-full sm:[&>button]:w-auto">
    {children}
  </div>
);
