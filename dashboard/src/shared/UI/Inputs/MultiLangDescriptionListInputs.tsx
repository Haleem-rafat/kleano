import React, { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import classNames from 'classnames';
import { Input } from '@/shadecn/components/ui/input';
import { FormControl, FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';
import { Button } from '@/shadecn/components/ui/button';

interface IMultiLangDescriptionListInputs {
  field?: ControllerRenderProps<FieldValues, string>;
  label?: string;
  placeholderEn?: string;
  placeholderAr?: string;
  disabled?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'super';
}

interface IMultiLangDescription {
  en: string;
  ar: string;
}

export default function MultiLangDescriptionListInputs({
  field,
  label,
  placeholderEn = 'Enter description in English',
  placeholderAr = 'أدخل الوصف باللغة العربية',
  disabled,
  size = 'md',
}: IMultiLangDescriptionListInputs): JSX.Element {
  const [inputValueEn, setInputValueEn] = useState<string>('');
  const [inputValueAr, setInputValueAr] = useState<string>('');
  const [descriptions, setDescriptions] = useState<IMultiLangDescription[]>(field?.value || []);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  useEffect(() => {
    if (field) {
      setDescriptions(field.value || []);
    }
  }, [field]);

  const handleChangeEn = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValueEn(e.target.value);
  };

  const handleChangeAr = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValueAr(e.target.value);
  };

  const handleAddDescription = () => {
    if (inputValueEn.trim() || inputValueAr.trim()) {
      const updatedDescriptions = [
        ...descriptions,
        { en: inputValueEn.trim(), ar: inputValueAr.trim() },
      ];
      setDescriptions(updatedDescriptions);
      setInputValueEn('');
      setInputValueAr('');
      field?.onChange(updatedDescriptions);
    }
  };

  const handleDeleteDescription = (index: number) => {
    const updatedDescriptions = descriptions.filter((_, i) => i !== index);
    setDescriptions(updatedDescriptions);
    field?.onChange(updatedDescriptions);
  };

  return (
    <FormItem className={classNames({ 'pointer-events-none opacity-50': disabled })}>
      {label && <FormLabel className="text-sm font-semibold">{label}</FormLabel>}
      <FormControl>
        <div className="space-y-2">
          <div>
            <label className="mb-1 block text-xs text-slate-600">English (EN)</label>
            <div className="flex items-center gap-2">
              <Input
                type="text"
                placeholder={placeholderEn}
                disabled={disabled}
                value={inputValueEn}
                onChange={handleChangeEn}
                inputSize={size}
              />
            </div>
          </div>
          <div>
            <label className="mb-1 block text-xs text-slate-600">Arabic (AR)</label>
            <div className="flex items-center gap-2">
              <Input
                type="text"
                placeholder={placeholderAr}
                disabled={disabled}
                value={inputValueAr}
                onChange={handleChangeAr}
                inputSize={size}
                dir="rtl"
              />
            </div>
          </div>
          <Button
            type="button"
            onClick={handleAddDescription}
            disabled={disabled || (!inputValueEn.trim() && !inputValueAr.trim())}
            className="w-full">
            {t('add')}
          </Button>
        </div>
      </FormControl>
      {descriptions.length > 0 && (
        <ul className="mt-2 space-y-2">
          {descriptions.map((description, index) => (
            <li key={index} className="rounded border border-slate-200 bg-slate-50 p-3">
              <div className="mb-2 flex items-start justify-between">
                <span className="text-xs font-semibold text-slate-600">
                  {t('description')} #{index + 1}
                </span>
                <Button
                  type="button"
                  size="sm"
                  variant="destructive"
                  onClick={() => handleDeleteDescription(index)}>
                  {t('delete')}
                </Button>
              </div>
              <div className="space-y-2">
                <div>
                  <span className="text-xs text-slate-500">EN:</span>
                  <p className="text-sm text-slate-700">{description.en || '-'}</p>
                </div>
                <div dir="rtl">
                  <span className="text-xs text-slate-500">AR:</span>
                  <p className="text-sm text-slate-700">{description.ar || '-'}</p>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
      <FormMessage />
    </FormItem>
  );
}
