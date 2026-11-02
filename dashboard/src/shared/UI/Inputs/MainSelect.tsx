import { useTranslation } from 'react-i18next';
import React, { useEffect, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';
import { ChevronDown } from 'lucide-react';
import { XCircleIcon } from '@heroicons/react/24/solid';

import { Button } from '@shadecn/components/ui/button';
import { Badge } from '@/shadecn/components/ui/badge';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/shadecn/components/ui/command';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';
import { cn } from '@/shadecn/lib/utils';
import { fieldClass } from '@/shadecn/lib/field';
import { FormItem, FormLabel, FormMessage } from '@/shadecn/components/ui/form';

interface Option {
  label: string;
  value: string;
  icon?: React.ComponentType<{ className?: string }>;
}

interface SelectProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  asChild?: boolean;
  options: Option[];
  defaultValue?: string[];
  disabled?: boolean;
  placeholder: string;
  className?: string;
  title: string;
  field?: ControllerRenderProps<FieldValues, string>;
  multiSelect?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'super';
}

export default function MainSelect({
  className,
  options,
  defaultValue,
  disabled,
  placeholder,
  field,
  title,
  multiSelect = false,
  size = 'md',
  ...props
}: SelectProps) {
  const [selectedValues, setSelectedValues] = useState<string[]>(
    Array.isArray(field?.value) ? field.value : defaultValue || []
  );
  const [filteredOptions, setFilteredOptions] = useState(options);
  const { t } = useTranslation();
  const [isPopoverOpen, setIsPopoverOpen] = useState(false);

  useEffect(() => {
    setFilteredOptions(
      options.filter((option) => !multiSelect || !selectedValues.includes(option.value))
    );
  }, [selectedValues, options, multiSelect]);

  const toggleOption = (value: string) => {
    let updatedValues: string[];
    if (multiSelect) {
      updatedValues = selectedValues.includes(value)
        ? selectedValues.filter((v) => v !== value)
        : [...selectedValues, value];
    } else {
      updatedValues = [value];
      setIsPopoverOpen(false); // Close on single select
    }

    setSelectedValues(updatedValues);

    if (multiSelect) {
      const selectedOptions = updatedValues
        .map((val) => {
          const option = options.find((o) => o.value === val);
          return { label: option?.label || '', value: option?.value || '' };
        })
        .filter((option) => option.value); // Filter out empty or undefined values

      field?.onChange(selectedOptions);
    } else {
      // Return single object {label, value}
      const selectedOption = options.find((o) => o.value === updatedValues[0]);
      field?.onChange(selectedOption || { label: '', value: '' });
    }
  };

  useEffect(() => {
    if (field?.value) {
      if (multiSelect) {
        // Convert field.value to array of strings if needed
        setSelectedValues(
          field.value.map((item: { value: string }) => item?.value).filter(Boolean)
        );
      } else {
        // Set single value for non-multi-select
        setSelectedValues(field.value.value ? [field.value.value] : []);
      }
    }
  }, [field?.value]);

  const handleButtonClick = (event: React.MouseEvent) => {
    event.stopPropagation();
    setIsPopoverOpen((prev) => !prev);
  };

  return (
    <FormItem className={cn({ 'group pointer-events-none opacity-50': disabled })}>
      <FormLabel className="text-sm font-medium text-foreground">{title}</FormLabel>
      <Popover open={isPopoverOpen} onOpenChange={setIsPopoverOpen} modal>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            {...props}
            onClick={handleButtonClick}
            className={cn(
              fieldClass,
              'min-h-10 h-auto min-w-0 py-1.5 font-normal hover:bg-card',
              { 'min-h-8 text-xs': size === 'xs' },
              className
            )}>
            <div className="flex w-full min-w-0 items-center justify-between gap-2">
              {selectedValues.length === 0 ? (
                <p className="truncate text-muted-foreground">{placeholder || t('search')}</p>
              ) : (
                <div className="flex min-w-0 flex-1 flex-wrap gap-2 overflow-hidden">
                  {multiSelect &&
                    selectedValues?.map((value, index) => {
                      const option = options.find((o) => o.value === value);
                      const IconComponent = option?.icon;
                      return (
                        <Badge className="flex gap-1" key={index}>
                          {IconComponent && <IconComponent className="mr-2 h-4 w-4" />}
                          {option?.label}
                          <XCircleIcon
                            className="h-5 w-5 cursor-pointer text-current"
                            onClick={(event) => {
                              event.stopPropagation();
                              toggleOption(value);
                            }}
                          />
                        </Badge>
                      );
                    })}
                  {!multiSelect && (
                    <span className="block truncate text-sm font-medium">
                      {options.find((o) => o.value === selectedValues[0])?.label || ''}
                    </span>
                  )}
                </div>
              )}
              <ChevronDown
                className={cn(
                  'size-4 shrink-0 cursor-pointer text-muted-foreground transition-transform',
                  {
                    'rotate-180': isPopoverOpen,
                  }
                )}
              />
            </div>
          </Button>
        </PopoverTrigger>
        <PopoverContent
          className="bg-popover p-0 drop-shadow-sm"
          onEscapeKeyDown={() => setIsPopoverOpen(false)}>
          <Command>
            <CommandList>
              <CommandInput className="h-9" placeholder={t('search')} />
              <CommandEmpty className="p-2 text-sm text-muted-foreground">
                {t('noResults')}
              </CommandEmpty>
              <CommandGroup>
                {filteredOptions.map((option) => (
                  <CommandItem
                    key={option.value}
                    onSelect={() => toggleOption(option.value)}
                    className="cursor-pointer rounded-lg px-3 transition-colors hover:bg-accent active:bg-accent/80">
                    {option.label}
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
      <FormMessage />
    </FormItem>
  );
}
