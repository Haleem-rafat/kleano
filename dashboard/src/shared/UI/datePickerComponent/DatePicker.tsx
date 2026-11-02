import * as React from 'react';
import { addDays, format } from 'date-fns';
import { Calendar as CalendarIcon } from 'lucide-react';
import { DateRange } from 'react-day-picker';
import { useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

import { formatToFilterDate } from '@app/utils/helper';
import { cn } from '@/shadecn/lib/utils';
import { fieldClass } from '@/shadecn/lib/field';
import { Button } from '@/shadecn/components/ui/button';
import { Calendar } from '@/shadecn/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shadecn/components/ui/select';

export function DatePickerWithPresets({
  setDateObj,
}: {
  setDateObj: React.Dispatch<
    React.SetStateAction<{
      from: string | undefined;
      to: string | undefined;
    }>
  >;
}) {
  const [date, setDate] = React.useState<DateRange | undefined>(undefined);
  const [searchParams, setSearchParams] = useSearchParams();
  const { t } = useTranslation();
  const handleDateChange = (value: string) => {
    if (value !== 'reset') {
      date && date.from
        ? setDate({
            from: date.from,
            to: addDays(date.from, parseInt(value)),
          })
        : setDate({
            from: new Date(),
            to: addDays(new Date(), parseInt(value)),
          });
    } else {
      const newParams = new URLSearchParams(searchParams);
      newParams.delete('fromDate');
      newParams.delete('toDate');
      setSearchParams(newParams);
      setDate(undefined);
      setDateObj({ from: undefined, to: undefined });
    }
  };
  React.useEffect(() => {
    if (date) {
      setDateObj({
        from: formatToFilterDate(date?.from),
        to: formatToFilterDate(date?.to),
      });
      const newParams = new URLSearchParams(searchParams);

      newParams.set('fromDate', formatToFilterDate(date?.from));
      newParams.set('toDate', formatToFilterDate(date?.to));
      setSearchParams(newParams);
    }
  }, [date]);

  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button
          id="date"
          variant={'outline'}
          className={cn(
            fieldClass,
            'h-10 w-auto justify-start text-start font-normal hover:bg-card',
            !date && 'text-muted-foreground'
          )}>
          <CalendarIcon className="me-2 h-4 w-4 text-muted-foreground" />
          {date?.from ? (
            date.to ? (
              <>
                {format(date.from, 'LLL dd, y')} - {format(date.to, 'LLL dd, y')}
              </>
            ) : (
              format(date.from, 'LLL dd, y')
            )
          ) : (
            <span>{t('pickUpData')}</span>
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="flex w-fit flex-col space-y-2 p-2">
        <Select onValueChange={handleDateChange}>
          <SelectTrigger>
            <SelectValue placeholder={t('select')} />
          </SelectTrigger>
          <SelectContent position="popper">
            <SelectItem value="reset" className="cursor-pointer text-destructive">
              {t('Reset')}
            </SelectItem>
            <SelectItem value="0">{t('Today')}</SelectItem>
            <SelectItem value="1">{t('Tomorrow')}</SelectItem>
            <SelectItem value="3">In 3 days</SelectItem>
            <SelectItem value="7">{t('In a week')}</SelectItem>
          </SelectContent>
        </Select>
        <div className="rounded-md border">
          <Calendar mode="range" selected={date} onSelect={setDate} />
        </div>
      </PopoverContent>
    </Popover>
  );
}
