import { VariantProps, cva } from 'class-variance-authority';
import React from 'react';
import { IconType } from 'react-icons/lib';
import { ArrowPathIcon } from '@heroicons/react/24/solid';
import { cn } from '@/shadecn/lib/utils';

interface IButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  disabled?: boolean;
  loading?: boolean;
  startIcon?: IconType; // react icons - hi2
  endIcon?: IconType; // react icons - hi2
}

// Variants use only the Kleano theme tokens (src/index.css).
const buttonVariants = cva(
  'inline-flex select-none relative rounded-lg items-center justify-center shrink-0 text-sm transition-colors disabled:pointer-events-none disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background',
  {
    variants: {
      variant: {
        primary:
          'bg-primary text-primary-foreground shadow-sm hover:bg-primary/90 active:bg-primary',
        secondary: 'border border-input bg-card text-primary hover:bg-accent active:bg-accent/80',
        tertiary: 'w-fit !py-0 text-primary underline-offset-4 hover:underline',
        danger:
          'bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90 active:bg-destructive',
        // Destructive action that opens a confirmation (e.g. Cancel order).
        dangerOutline:
          'border border-destructive/40 bg-card text-destructive hover:bg-destructive/10 active:bg-destructive/15',
        success: 'bg-success text-white shadow-sm hover:bg-success/90 active:bg-success',
      },
      size: {
        xs: 'h-[1.9375rem] px-[0.625rem] py-[0.3125rem] text-sm font-medium',
        sm: 'h-8 px-3 text-[13px] font-medium',
        md: 'h-9 px-4 text-[13px] font-medium',
        lg: 'h-9 px-4 text-[13px] font-medium',
        super: 'h-[3.5rem] px-[1.5rem] py-[1rem] text-base font-bold',
        icon: '!h-8 w-8 rounded-super',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'lg',
    },
  }
);

const Button = React.forwardRef<HTMLButtonElement, IButtonProps>(
  (
    {
      className,
      variant,
      size,
      children,
      type = 'button',
      startIcon,
      endIcon,
      disabled,
      loading,
      ...props
    },
    ref
  ) => {
    const StartIcon = startIcon;
    const EndIcon = endIcon;
    const isDisabled = disabled || loading;
    return (
      <button
        type={type}
        disabled={isDisabled}
        className={cn(
          buttonVariants({ variant, size, className }),
          'whitespace-nowrap transition-all duration-75 ease-in-out',
          { 'ps-12': !!startIcon, 'pe-12': !!endIcon },
          { 'pointer-events-none text-muted-foreground': isDisabled },
          { 'bg-text-100 text-muted-foreground': loading }
        )}
        ref={ref}
        {...props}>
        {loading ? (
          <span className="flex items-center gap-2">
            <ArrowPathIcon className="z-10 h-5 w-5 animate-spin duration-1000" />
            loading...
          </span>
        ) : (
          children
        )}

        {startIcon && (
          <div className="absolute left-4 top-1/2 z-10 -translate-y-1/2 text-[inherit]">
            {<StartIcon className="z-10 h-5 w-5" />}
          </div>
        )}
        {endIcon && (
          <div className="absolute right-4 top-1/2 z-10 -translate-y-1/2 text-[inherit]">
            {<EndIcon className="z-10 h-5 w-5" />}
          </div>
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';

export default Button;
