/**
 * One look for every form control and popup in the dashboard.
 * Inputs, select triggers, comboboxes, textareas and pickers all use `field`;
 * dropdown panels use `popupSurface`, their rows use `popupItem`.
 */
export const fieldClass =
  'w-full rounded-md border border-input bg-card px-3 text-sm text-foreground shadow-none transition-[border-color,box-shadow] placeholder:text-muted-foreground hover:border-foreground/25 focus:outline-none focus-visible:outline-none focus:border-primary focus:shadow-[0_0_0_3px_hsl(var(--primary)/0.15)] focus-visible:shadow-[0_0_0_3px_hsl(var(--primary)/0.15)] focus-visible:ring-0 disabled:cursor-not-allowed disabled:bg-muted disabled:opacity-60 aria-[invalid=true]:border-destructive';

/** Default control height (40px), shared with Button size md/lg rows in forms. */
export const fieldHeight = 'h-10';

export const popupSurface =
  'z-50 overflow-hidden rounded-xl border border-border bg-popover p-1 text-popover-foreground shadow-lg';

export const popupItem =
  'relative flex w-full cursor-pointer select-none items-center rounded-md px-2.5 py-2 text-sm outline-none transition-colors focus:bg-accent data-[highlighted]:bg-accent data-[disabled]:pointer-events-none data-[disabled]:opacity-50';
