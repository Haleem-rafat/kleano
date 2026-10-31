import { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import { PhoneInput } from 'react-international-phone';

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
export default function MainPhoneNumberInpute({ field }: IMainPhoneNumberInputeProps): JSX.Element {
  const [value, setValue] = useState(field?.value ?? '');

  useEffect(() => {
    if (field && field.onChange) {
      field.onChange(value || '');
    }
  }, [value]);

  return (
    <PhoneInput
      className="w-full "
      inputClassName="w-full !border-0 !h-full !py-2 !px-4 !rounded-lg "
      defaultCountry="sa"
      {...field}
    />
  );
}
