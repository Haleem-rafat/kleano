import React, { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import classNames from 'classnames';
import { fieldClass } from '@/shadecn/lib/field';
import { cn } from '@/shadecn/lib/utils';
import { FormControl, FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';

interface IMainColorInputProps {
  field?: ControllerRenderProps<FieldValues, string>;
  label?: string;
  placeholder?: string;
  disabled?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'super';
}

export default function MainColorInput({
  field,
  label,
  disabled,
  size = 'md',
}: IMainColorInputProps): JSX.Element {
  const [value, setValue] = useState<string>(field?.value ?? '#000000'); // Default color

  useEffect(() => {
    if (field) {
      setValue(field.value || '#000000');
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
        <div className={cn(fieldClass, 'flex h-10 items-center gap-3 px-2')}>
          <input
            type="color"
            aria-label={label}
            disabled={disabled}
            value={`${value}`}
            onChange={handleChange}
            className="h-6 w-6 cursor-pointer rounded border-0 bg-transparent p-0"
          />
          <span className="text-[13px] uppercase tabular-nums text-muted-foreground">{value}</span>
        </div>
      </FormControl>
      <FormMessage />
    </FormItem>
  );
}
