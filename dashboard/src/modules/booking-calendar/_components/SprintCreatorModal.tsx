import React, { useState } from 'react';
import { addDays, format } from 'date-fns';
import { Calendar as CalendarIcon } from 'lucide-react';
import { DateRange } from 'react-day-picker';
import { Button } from '@UI/Index';
import { toast } from 'react-toastify';
import bookingService from '@services/booking.service';
import i18n from '@app/locales/i18n';
import { useTranslation } from 'react-i18next';

// Shadcn UI
import { createSprintDates } from '../_utils/dateHelpers';
import { cn } from '@/shadecn/lib/utils';
import { Calendar } from '@/shadecn/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';

// Utils

interface SprintCreatorModalProps {
  onClose: () => void;
  onSuccess: () => void;
}

const SprintCreatorModal: React.FC<SprintCreatorModalProps> = ({ onClose, onSuccess }) => {
  const { t } = useTranslation();
  const [loading, setLoading] = useState(false);
  const lang = i18n.language as 'en' | 'ar';

  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: addDays(new Date(), 1),
    to: addDays(new Date(), 14),
  });

  const handleCreateSprint = async () => {
    if (!dateRange?.from || !dateRange?.to) {
      toast.error('Please select a date range');
      return;
    }

    // Validate 14-day requirement (same as original)
    const daysCount =
      Math.ceil((dateRange.to.getTime() - dateRange.from.getTime()) / (1000 * 60 * 60 * 24)) + 1;

    if (daysCount !== 14) {
      toast.error(t('Sprint must be exactly 14 days, Please select 14 days'));
      return;
    }

    setLoading(true);

    try {
      const sprintDates = createSprintDates(dateRange.from, dateRange.to);

      await bookingService.createBookingSprint({
        bookingAvailabilityDates: sprintDates,
      });

      toast.success('Sprint created successfully');
      onSuccess();
    } catch (error: any) {
      const errorMessage = error?.response?.data?.message?.[lang] || 'Failed to create sprint';
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={cn('grid gap-4')}>
      {/* Date Range Picker */}
      <div className="grid gap-2">
        <label className="text-sm font-medium">{t('Select Sprint Date Range')}</label>
        <Popover>
          <PopoverTrigger asChild>
            <Button
              variant="secondary"
              className={cn(
                'w-full justify-start text-left font-normal',
                !dateRange && 'text-muted-foreground'
              )}>
              <CalendarIcon className="mr-2 h-4 w-4" />
              {dateRange?.from ? (
                dateRange.to ? (
                  <>
                    {format(dateRange.from, 'LLL dd, y')} - {format(dateRange.to, 'LLL dd, y')}
                  </>
                ) : (
                  format(dateRange.from, 'LLL dd, y')
                )
              ) : (
                <span>{t('Pick a date range')}</span>
              )}
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-auto p-0" align="start">
            <Calendar
              initialFocus
              mode="range"
              defaultMonth={dateRange?.from}
              selected={dateRange}
              onSelect={setDateRange}
              numberOfMonths={2}
            />
          </PopoverContent>
        </Popover>
      </div>

      {/* Sprint Info */}
      {dateRange?.from && dateRange?.to && (
        <div className="rounded-lg border bg-muted p-3">
          <h4 className="text-sm font-medium text-foreground">{t('Sprint Details')}</h4>
          <div className="mt-2 space-y-1 text-sm text-muted-foreground">
            <p>
              <strong>Duration:</strong>{' '}
              {Math.ceil(
                (dateRange.to.getTime() - dateRange.from.getTime()) / (1000 * 60 * 60 * 24)
              ) + 1}{' '}
              days
            </p>
            <p>
              <strong>Start Date:</strong> {format(dateRange.from, 'EEEE, MMMM dd, yyyy')}
            </p>
            <p>
              <strong>End Date:</strong> {format(dateRange.to, 'EEEE, MMMM dd, yyyy')}
            </p>
          </div>
          {Math.ceil((dateRange.to.getTime() - dateRange.from.getTime()) / (1000 * 60 * 60 * 24)) +
            1 !==
            14 && (
            <p className="mt-2 text-sm text-destructive">⚠️ Sprint must be exactly 14 days</p>
          )}
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex justify-end gap-2">
        <Button variant="secondary" onClick={onClose} disabled={loading}>
          {t('Cancel')}
        </Button>
        <Button
          loading={loading}
          disabled={!dateRange?.from || !dateRange?.to}
          onClick={handleCreateSprint}>
          {t('Create Sprint')}
        </Button>
      </div>
    </div>
  );
};

export default SprintCreatorModal;
