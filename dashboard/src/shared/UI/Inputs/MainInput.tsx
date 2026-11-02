import React, { useEffect, useState } from 'react';
import { ControllerRenderProps } from 'react-hook-form';
import classNames from 'classnames';
import { Input } from '@/shadecn/components/ui/input';
import { FormControl, FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';

interface IMainInputs {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  field?: ControllerRenderProps<any, any>;
  type?: HTMLInputElement['type']; // Made optional
  label?: string;
  placeholder: string;
  leftIcon?: React.ReactNode;
  min?: number;
  max?: number;
  minLength?: number;
  maxLength?: number;
  required?: boolean;
  disabled?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'super';
}

export default function MainInput({
  field,
  type = 'text',
  label,
  placeholder,
  leftIcon,
  disabled,
  min,
  max,
  minLength,
  maxLength,
  required,
  size = 'md',
}: IMainInputs): JSX.Element {
  const [value, setValue] = useState<string>(field?.value ?? '');

  useEffect(() => {
    if (field) {
      setValue(field.value || '');
    }
  }, [field]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    setValue(newValue);
    field?.onChange(newValue);
  };

  return (
    <FormItem className={classNames({ 'pointer-events-none opacity-50': disabled })}>
      {label && <FormLabel className="text-sm font-semibold text-foreground">{label}</FormLabel>}
      <FormControl>
        <Input
          type={type}
          placeholder={placeholder}
          disabled={disabled}
          min={min}
          max={max}
          minLength={minLength}
          maxLength={maxLength}
          required={required}
          value={value}
          onChange={handleChange}
          leftIcon={leftIcon}
          inputSize={size}
        />
      </FormControl>
      <FormMessage />
    </FormItem>
  );
}
