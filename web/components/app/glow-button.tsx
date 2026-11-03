import type { ComponentProps } from 'react';
import { cn } from '@/lib/utils';

/** Aceternity sign-up-form button: solid fill with a glowing line on the bottom edge on hover. */
export function GlowButton({ className, children, ...props }: ComponentProps<'button'>) {
  return (
    <button
      className={cn(
        'group/btn relative flex h-12 w-full items-center justify-center gap-2 rounded-md bg-gradient-to-br from-primary to-[color-mix(in_oklch,var(--primary),black_25%)] font-semibold text-primary-foreground shadow-[0px_1px_0px_0px_#ffffff40_inset,0px_-1px_0px_0px_#ffffff40_inset] transition-opacity disabled:cursor-not-allowed disabled:opacity-50',
        className,
      )}
      {...props}
    >
      {children}
      <BottomGradient />
    </button>
  );
}

function BottomGradient() {
  return (
    <>
      <span className="absolute inset-x-0 -bottom-px block h-px w-full bg-gradient-to-r from-transparent via-[var(--beam-a)] to-transparent opacity-0 transition duration-500 group-hover/btn:opacity-100" />
      <span className="absolute inset-x-10 -bottom-px mx-auto block h-px w-1/2 bg-gradient-to-r from-transparent via-[var(--beam-c)] to-transparent opacity-0 blur-sm transition duration-500 group-hover/btn:opacity-100" />
    </>
  );
}
