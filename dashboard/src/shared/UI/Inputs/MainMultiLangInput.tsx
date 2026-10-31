import React, { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import classNames from 'classnames';
import { Input } from '@/shadecn/components/ui/input';
import { FormControl, FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';

interface IMainMultiLangInputProps {
  field?: ControllerRenderProps<FieldValues, string>;
  label?: string;
  placeholderEn?: string;
  placeholderAr?: string;
  disabled?: boolean;
  required?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'super';
}

export default function MainMultiLangInput({
  field,
  label,
  placeholderEn = 'Enter English name',
  placeholderAr = 'ادخل الاسم باللغة العربية',
  disabled,
  required,
  size = 'md',
}: IMainMultiLangInputProps): JSX.Element {
  const [valueEn, setValueEn] = useState<string>(field?.value?.en || '');
  const [valueAr, setValueAr] = useState<string>(field?.value?.ar || '');

  useEffect(() => {
    if (field) {
      setValueEn(field.value?.en || '');
      setValueAr(field.value?.ar || '');
    }
  }, [field]);

  const handleChangeEn = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    setValueEn(newValue);
    field?.onChange({ en: newValue, ar: valueAr });
  };

  const handleChangeAr = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    setValueAr(newValue);
    field?.onChange({ en: valueEn, ar: newValue });
  };

  return (
    <FormItem className={classNames({ 'pointer-events-none opacity-50': disabled })}>
      {label && <FormLabel className="text-text-600 text-sm font-semibold">{label}</FormLabel>}
      <FormControl>
        <div className="space-y-2">
          <div>
            <label className="mb-1 block text-xs text-slate-600">English (EN)</label>
            <Input
              type="text"
              placeholder={placeholderEn}
              disabled={disabled}
              required={required}
              value={valueEn}
              onChange={handleChangeEn}
              inputSize={size}
            />
          </div>
          <div>
            <label className="mb-1 block text-xs text-slate-600">Arabic (AR)</label>
            <Input
              type="text"
              placeholder={placeholderAr}
              disabled={disabled}
              required={required}
              value={valueAr}
              onChange={handleChangeAr}
              inputSize={size}
              dir="rtl"
            />
          </div>
        </div>
      </FormControl>
      <FormMessage />
    </FormItem>
  );
}
