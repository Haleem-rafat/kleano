import React, { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import classNames from 'classnames';
import { Input } from '@/shadecn/components/ui/input';
import { FormControl, FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';
import { Button } from '@/shadecn/components/ui/button'; // Assuming you have a Button component

interface IDescriptionListInputs {
  field?: ControllerRenderProps<FieldValues, string>;
  label?: string;
  placeholder: string;
  leftIcon?: React.ReactNode;
  disabled?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'super';
}

export default function MianDescriptionListInputs({
  field,
  label,
  placeholder,
  leftIcon,
  disabled,
  size = 'md',
}: IDescriptionListInputs): JSX.Element {
  const [inputValue, setInputValue] = useState<string>('');
  const [descriptions, setDescriptions] = useState<string[]>(field?.value || []);
  const { t } = useTranslation();
  useEffect(() => {
    if (field) {
      setDescriptions(field.value || []);
    }
  }, [field]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValue(e.target.value);
  };

  const handleAddDescription = () => {
    if (inputValue.trim()) {
      const updatedDescriptions = [...descriptions, inputValue.trim()];
      setDescriptions(updatedDescriptions);
      setInputValue('');
      field?.onChange(updatedDescriptions); // Update react-hook-form field
    }
  };

  const handleDeleteDescription = (index: number) => {
    const updatedDescriptions = descriptions.filter((_, i) => i !== index);
    setDescriptions(updatedDescriptions);
    field?.onChange(updatedDescriptions); // Update react-hook-form field
  };

  return (
    <FormItem className={classNames({ 'pointer-events-none opacity-50': disabled })}>
      {label && <FormLabel className=" text-sm font-semibold">{label}</FormLabel>}
      <FormControl>
        <div className="flex items-center  justify-between space-x-2">
          <Input
            type="text"
            placeholder={placeholder}
            disabled={disabled}
            value={inputValue}
            onChange={handleChange}
            leftIcon={leftIcon}
            inputSize={size}
          />
          <Button
            type="button"
            onClick={handleAddDescription}
            disabled={disabled || !inputValue.trim()}>
            {t('add')}
          </Button>
        </div>
      </FormControl>
      {descriptions.length > 0 && (
        <ul className="mt-2 space-y-1">
          {descriptions.map((description, index) => (
            <li key={index} className="flex items-center justify-between rounded border p-2">
              <span>{description}</span>
              <Button type="button" onClick={() => handleDeleteDescription(index)}>
                {t('delete')}
              </Button>
            </li>
          ))}
        </ul>
      )}
      <FormMessage />
    </FormItem>
  );
}
