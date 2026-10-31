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

const buttonVariants = cva(
  'inline-flex select-none relative rounded-lg items-center justify-center shrink-0 text-sm  disabled:pointer-events-none focus-visible:outline-none',
  {
    variants: {
      variant: {
        primary: cn(
          'text-white',
          'bg-primary hover:bg-primary/80 active:bg-primary',
          'dark:bg-secondary-light-heavy dark:hover:bg-secondary-accent-heavier dark:active:bg-secondary-accent-heaviest',
          'shadow-[0px_5px_30px_0px_rgba(103, 198, 185, 0.24) active:shadow-[0px_5px_10px_0px_rgba(103, 198, 185, 0.24) dark:shadow-[0px_5px_30px_0px_rgba(249,113,13,0.25)] disabled:shadow-none',
          'disabled:bg-primary/80 '
        ),

        secondary: cn(
          'bg-white text-primary dark:text-secondary-accent-heavy',
          'border-primary disabled:border-disabled dark:border-secondary-accent-heavy border hover:border-primary-light-100',
          'hover:bg-primary-light-100 active:bg-primary-light-300',
          'dark:bg-secondary-accent-heavy dark:hover:bg-secondary-accent-heavier dark:active:bg-secondary-accent-heaviest',
          'disabled:bg-surface-disabled'
        ),

        tertiary: cn(
          'text-primary hover:text-primary-dark-700 hover:underline active:text-primary',
          'disabled:text-disabled underline',
          '!py-0 w-fit'
        ),

        danger: 'bg-red-500 text-white shadow-sm hover:bg-danger-heaviest/90 border border-red-500',
        success: cn(
          'text-white text-primary-heavy',
          'bg-success-heavy hover:bg-success-heavier active:bg-success-heaviest',
          'border border-success-heavy',
          'hover:shadow-md active:shadow-sm',
          'disabled:bg-surface-disabled disabled:border-disabled'
        ),
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
          { 'text-disabled pointer-events-none': isDisabled },
          { 'bg-text-100 text-text-400': loading }
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
