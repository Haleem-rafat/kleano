import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';
import { cn } from '@shadecn/lib/utils';
import { fieldClass } from '@shadecn/lib/field';
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
          <div className="absolute left-3 top-1/2 -translate-y-1/2 transform text-muted-foreground transition-colors group-focus-within:text-primary">
            {leftIcon}
          </div>
        )}
        <input
          type={inputType}
          className={cn(
            fieldClass,
            'file:border-0 file:bg-transparent file:text-sm file:font-medium',
            {
              'h-[1.9375rem] px-[0.625rem] py-[0.3125rem] text-sm font-medium': inputSize === 'xs',
              'h-[2.375rem] px-[0.875rem] py-[0.375rem] text-sm font-medium': inputSize === 'sm',
              'h-10': inputSize === 'md' || inputSize === 'lg',
              'h-[3.5rem] px-[1.5rem] py-[1rem] text-base font-bold': inputSize === 'super',
            },
            { 'ps-10': leftIcon },
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
            className="absolute end-3 top-1/2 -translate-y-1/2 transform cursor-pointer text-muted-foreground"
            aria-label={isPasswordVisible ? 'Hide password' : 'Show password'}>
            {isPasswordVisible ? (
              <EyeIcon className="size-5" />
            ) : (
              <EyeSlashIcon className="size-5" />
            )}
          </button>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';

export { Input };
