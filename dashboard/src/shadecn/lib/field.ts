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

/**
 * Boxed segmented switch (tabs, view toggles, quick filters): one bordered box,
 * the selected segment filled with the brand colour. Scrolls sideways when the
 * options don't fit, so labels are never cut.
 */
export const segmentGroup =
  'inline-flex h-10 max-w-full items-stretch overflow-x-auto overscroll-x-contain rounded-lg border border-border bg-card p-0.5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden';

export const segmentItem =
  'inline-flex min-w-[2.25rem] shrink-0 items-center justify-center gap-1.5 whitespace-nowrap rounded-md px-3 text-[13px] font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground data-[state=active]:shadow-sm aria-pressed:bg-primary aria-pressed:text-primary-foreground aria-pressed:shadow-sm';
