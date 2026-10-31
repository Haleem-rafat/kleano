import React, { useState } from 'react';
import { Button, ThreeDotsLoader } from '@UI/Index';
import useSWR from 'swr';
import bookingService from '@services/booking.service';
import { addDays, format } from 'date-fns';
import { DateRange } from 'react-day-picker';
import { CalendarIcon } from 'lucide-react';
import { toast } from 'react-toastify';

// Components (reusing from original booking)
import DayCard from '../booking/_components/day-card';
import { SprintForm } from '../booking/_components/create-sprint-form';

// Shadcn UI
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';
import { cn } from '@/shadecn/lib/utils';
import { Calendar } from '@/shadecn/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';

const BookingCalendarFallback = () => {
  const [open, setOpen] = useState(false);
  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: new Date(),
    to: addDays(new Date(), 14),
  });

  const fetchDays = async () => {
    return await bookingService
      .getBookings(dateRange)
      .then((data) => data.data)
      .catch((e) => {
        console.error('Booking data fetch error:', e);
        toast.error('Failed to load booking data');
        return [];
      });
  };

  const { data, isLoading, mutate } = useSWR(['bookingDays', dateRange], fetchDays);

  if (isLoading) return <ThreeDotsLoader />;
  if (!data) return <div>No data yet</div>;

  return (
    <div className="flex w-full flex-col gap-4 p-4">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-4">
          <h1 className="text-xl font-semibold tracking-tight text-slate-900">Booking Calendar</h1>
          <div className="rounded bg-brandTint px-2 py-1 text-xs text-primary">
            Phase 1 - Basic Implementation
          </div>
        </div>
      </div>

      {/* Date Range Filter */}
      <div className={cn('grid gap-2')}>
        <Popover>
          <PopoverTrigger asChild>
            <Button
              id="date"
              variant={'secondary'}
              className={cn(
                'w-[300px] justify-start text-left font-normal',
                !dateRange && 'text-muted-foreground'
              )}>
              <CalendarIcon />
              {dateRange?.from ? (
                dateRange.to ? (
                  <>
                    {format(dateRange.from, 'LLL dd, y')} - {format(dateRange.to, 'LLL dd, y')}
                  </>
                ) : (
                  format(dateRange.from, 'LLL dd, y')
                )
              ) : (
                <span>Pick a date</span>
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

      {/* Create Sprint Button */}
      <div className="flex w-full justify-end">
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button>Create Sprint</Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-[425px]">
            <DialogHeader>
              <DialogTitle>Manage Sprint</DialogTitle>
              <DialogDescription>
                Make changes to your Sprint here. Click save when you&lsquo;re done.
              </DialogDescription>
            </DialogHeader>
            <SprintForm setOpen={setOpen} />
          </DialogContent>
        </Dialog>
      </div>

      {/* Enhanced Card Grid */}
      <div className="rounded-lg border bg-white p-6">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-semibold">Sprint Days</h2>
          <div className="text-sm text-gray-600">
            {data.filter((day) => day.isActive).length} of {data.length} days active
          </div>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {data.map((day, index) => (
            <DayCard key={index} day={day} mutate={mutate} />
          ))}
        </div>
      </div>

      {/* Future Calendar Integration Notice */}
      <div className="rounded-lg border border-dashed border-gray-300 bg-gray-50 p-6">
        <div className="text-center">
          <h3 className="text-lg font-medium text-gray-900">🚀 Coming Soon</h3>
          <p className="mt-2 text-sm text-gray-600">
            Full FullCalendar integration with advanced calendar views, drag & drop, and biker
            management.
          </p>
          <div className="mt-4 text-xs text-gray-500">
            Current: Enhanced card-based view with all existing functionality
          </div>
        </div>
      </div>
    </div>
  );
};

export default BookingCalendarFallback;
