import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';
import { cn } from '@shadecn/lib/utils';
import React from 'react';

export type InputProps = React.InputHTMLAttributes<HTMLInputElement> & {
  leftIcon?: React.ReactNode;
  inputSize?: 'xs' | 'sm' | 'md' | 'lg' | 'super'; // Renamed to inputSize
};

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type = 'text', leftIcon, inputSize = 'lg', ...props }, ref) => {
    const [isPasswordVisible, setIsPasswordVisible] = React.useState(false);

    const handleTogglePasswordVisibility = () => {
      setIsPasswordVisible((prev) => !prev);
    };

    const inputType = type === 'password' && isPasswordVisible ? 'text' : type;

    return (
      <div className="group relative flex-grow">
        {leftIcon && (
          <div className="text-text-400 absolute left-3 top-1/2 -translate-y-1/2 transform transition-colors group-focus-within:text-primary">
            {leftIcon}
          </div>
        )}
        <input
          type={inputType}
          className={cn(
            'bg-neutral-20 placeholder:text-text-400 inline-flex w-full shrink-0 rounded-lg border border-primary/50 ring-0 transition-colors',
            'focus-within:ring-0  focus:border-[1.5px] focus:border-primary focus-visible:outline-none focus-visible:ring-0',
            'file:border-0 file:bg-transparent file:text-sm file:font-medium',
            'disabled:cursor-not-allowed disabled:opacity-50',
            'dark:border-text-300 dark:placeholder:text-text-400 dark:focus-visible:ring-slate-300',
            {
              'h-[1.9375rem] px-[0.625rem] py-[0.3125rem] text-sm font-medium': inputSize === 'xs',
              'h-[2.375rem] px-[0.875rem] py-[0.375rem] text-sm font-medium': inputSize === 'sm',
              'h-9 text-[13px]': inputSize === 'md' || inputSize === 'lg',
              'h-[3.5rem] px-[1.5rem] py-[1rem] text-base font-bold': inputSize === 'super',
            },
            { 'px-10': leftIcon },
            { 'px-3': !leftIcon },
            className
          )}
          ref={ref}
          {...props}
        />
        {type === 'password' && (
          <button
            type="button"
            onClick={handleTogglePasswordVisibility}
            className="text-text-400 absolute right-3 top-1/2 -translate-y-1/2 transform cursor-pointer"
            aria-label={isPasswordVisible ? 'Hide password' : 'Show password'}>
            {isPasswordVisible ? (
              <EyeIcon className="size-6" />
            ) : (
              <EyeSlashIcon className="size-6" />
            )}
          </button>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';

export { Input };
