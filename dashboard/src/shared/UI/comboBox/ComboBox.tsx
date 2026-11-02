import * as React from 'react';
import { Check, ChevronsUpDown } from 'lucide-react';
import { useSearchParams } from 'react-router-dom';

import { useTranslation } from 'react-i18next';
import { cn } from '@/shadecn/lib/utils';
import { fieldClass } from '@/shadecn/lib/field';
import { Button } from '@/shadecn/components/ui/button';

import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/shadecn/components/ui/command';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';
export function Combobox({
  dataArray,
  filterParam,
  placeholder,
  setState,
}: {
  dataArray: any;
  filterParam?: string;
  placeholder: string;
  setState?: React.Dispatch<React.SetStateAction<any>>;
}) {
  const [open, setOpen] = React.useState(false);
  const [value, setValue] = React.useState<{ label: ''; value: '' } | undefined>();
  const [searchParams, setSearchParams] = useSearchParams();
  const { t } = useTranslation();

  const getButtonValue = (dataArray, value) => {
    const valueData = dataArray.find((item) => item.value === value.value);
    if (valueData) {
      return t(valueData?.label.toLowerCase()) ?? 'no data';
    } else {
      return '';
    }
  };
  React.useEffect(() => {
    if (!value && filterParam) {
      const newParams = new URLSearchParams(searchParams);
      newParams.delete(filterParam);
      setSearchParams(newParams);
    } else if (value && value.value !== '' && filterParam) {
      const newParams = new URLSearchParams(searchParams);
      newParams.set(filterParam, value.value);
      setSearchParams(newParams);
    } else if (!filterParam && value) {
      const targetedItem = dataArray.find((item) => item.value === value.value);
      setState(targetedItem);
    }
  }, [value]);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className={cn(
            fieldClass,
            'h-10 justify-between font-normal hover:bg-card',
            !value && 'text-muted-foreground'
          )}>
          {value && dataArray
            ? getButtonValue(dataArray, value)
            : `${t('select')} ${placeholder}...`}
          <ChevronsUpDown className="ms-2 h-4 w-4 shrink-0 text-muted-foreground" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="max-h-[--radix-popover-content-available-height]  w-[--radix-popover-trigger-width] min-w-full p-0">
        <Command>
          <CommandInput placeholder={`${t('search')} ${t(placeholder)} ... `} />
          <CommandList>
            <CommandEmpty>No {placeholder} found.</CommandEmpty>
            <CommandGroup>
              {dataArray.map((item) => (
                <CommandItem
                  key={item.value}
                  value={JSON.stringify(item)}
                  onSelect={(currentValue) => {
                    const parsedValue = JSON.parse(currentValue);
                    if (!value) setValue(parsedValue);
                    if (value && value.value !== parsedValue.value) setValue(parsedValue);
                    if (value && value.value === parsedValue.value) setValue(undefined);
                    setOpen(false);
                  }}>
                  <Check
                    className={cn(
                      'mr-2 h-4 w-4',
                      value && value.value === item.value ? 'opacity-100' : 'opacity-0'
                    )}
                  />
                  {getButtonValue(dataArray, item)}
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
