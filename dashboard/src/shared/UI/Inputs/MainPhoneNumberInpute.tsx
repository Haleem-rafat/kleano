import { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import { PhoneInput } from 'react-international-phone';
import { FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';

import 'react-phone-number-input/style.css';

interface IMainPhoneNumberInputeProps {
  field?: ControllerRenderProps<FieldValues, string>;
  label: string;
  placeholder: string;
  min?: number;
  max?: number;
  minLength?: number;
  maxLength?: number;
  required?: boolean;
  disabled?: boolean;
}
export default function MainPhoneNumberInpute({
  field,
  label,
  placeholder,
}: IMainPhoneNumberInputeProps): JSX.Element {
  const [value, setValue] = useState(field?.value ?? '');

  useEffect(() => {
    if (field && field.onChange) {
      field.onChange(value || '');
    }
  }, [value]);

  return (
    <FormItem>
      {label && <FormLabel className="text-sm font-semibold text-foreground">{label}</FormLabel>}
      <PhoneInput
        className="w-full"
        inputClassName="w-full"
        defaultCountry="eg"
        placeholder={placeholder}
        {...field}
      />
      <FormMessage />
    </FormItem>
  );
}
