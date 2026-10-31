import React, { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import classNames from 'classnames';
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
      {label && <FormLabel className="text-text-600 text-sm font-semibold">{label}</FormLabel>}
      <FormControl>
        <div className="flex h-9 items-center gap-3 rounded-lg border border-slate-200 bg-white px-2">
          <input
            type="color"
            aria-label={label}
            disabled={disabled}
            value={`${value}`}
            onChange={handleChange}
            className="h-6 w-6 cursor-pointer rounded border-0 bg-transparent p-0"
          />
          <span className="text-[13px] uppercase tabular-nums text-slate-600">{value}</span>
        </div>
      </FormControl>
      <FormMessage />
    </FormItem>
  );
}
