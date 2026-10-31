import { useTranslation } from 'react-i18next';
import React, { useState, useEffect } from 'react';
import { format, parseISO } from 'date-fns';
import { Button } from '@UI/Index';
import { toast } from 'react-toastify';
import bookingService from '@services/booking.service';

// Shadcn UI
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/shadecn/components/ui/dialog';
import { Switch } from '@/shadecn/components/ui/switch';
import { Label } from '@/shadecn/components/ui/label';

// Types and Utils
import { EnhancedSprint } from '../_types/calendar.types';
import {
  generateTimeSlots,
  extractHoursFromTimeSlots,
  createTimeSlotPayload,
} from '../_utils/dateHelpers';

interface TimeSlotEditorModalProps {
  open: boolean;
  onClose: () => void;
  sprint: EnhancedSprint;
  onSuccess: () => void;
}

const TimeSlotEditorModal: React.FC<TimeSlotEditorModalProps> = ({
  open,
  onClose,
  sprint,
  onSuccess,
}) => {
  const { t } = useTranslation();
  const [loading, setLoading] = useState(false);
  const [selectedHours, setSelectedHours] = useState<string[]>([]);
  const [sprintActive, setSprintActive] = useState(sprint.isActive);

  // Initialize selected hours from existing time slots
  useEffect(() => {
    if (sprint) {
      const hours = extractHoursFromTimeSlots(sprint.timeSlots);
      setSelectedHours(hours);
      setSprintActive(sprint.isActive);
    }
  }, [sprint]);

  // Handle hour toggle
  const handleHourToggle = (time: string) => {
    setSelectedHours((prevSelected) =>
      prevSelected.includes(time) ? prevSelected.filter((h) => h !== time) : [...prevSelected, time]
    );
  };

  // Handle sprint status toggle
  const handleSprintToggle = async (checked: boolean) => {
    setLoading(true);
    try {
      const payload = {
        date: sprint.date,
        timeSlots: sprint.timeSlots.map((slot) => ({
          ...slot,
          isActive: true,
        })),
        isActive: checked,
      };

      await bookingService.updateBooking(payload);
      setSprintActive(checked);
      toast.success(`Sprint ${checked ? 'activated' : 'deactivated'} successfully`);
      onSuccess();
    } catch (error) {
      toast.error('Failed to update sprint status');
    } finally {
      setLoading(false);
    }
  };

  // Handle save time slots
  const handleSave = async () => {
    if (selectedHours.length === 0) {
      toast.error('Please select at least one time slot');
      return;
    }

    setLoading(true);
    try {
      const timeSlots = createTimeSlotPayload(sprint.date, selectedHours);

      const payload = {
        date: sprint.date,
        timeSlots,
        isActive: sprintActive,
      };

      await bookingService.updateBooking(payload);
      toast.success('Time slots updated successfully');
      onSuccess();
    } catch (error) {
      toast.error('Failed to update time slots');
    } finally {
      setLoading(false);
    }
  };

  // Generate all possible time slots (48 slots for 24 hours)
  const allTimeSlots = generateTimeSlots(sprint.date);

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl">
        <DialogHeader>
          <DialogTitle>
            Edit Time Slots - {format(parseISO(sprint.date), 'EEEE, MMMM dd, yyyy')}
          </DialogTitle>
          <DialogDescription>
            Select available time slots and manage sprint status.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* Sprint Status Toggle */}
          <div className="flex items-center justify-between rounded-lg border p-4">
            <div>
              <h3 className="font-medium">{t('Sprint Status')}</h3>
              <p className="text-sm text-gray-600">{t('Enable or disable the entire sprint')}</p>
            </div>
            <div className="flex items-center space-x-2">
              <Switch
                checked={sprintActive}
                onCheckedChange={handleSprintToggle}
                disabled={loading}
              />
              <Label className="text-sm">{sprintActive ? 'Active' : 'Inactive'}</Label>
            </div>
          </div>

          {/* Time Slot Selection */}
          <div className="space-y-4">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <h3 className="font-medium">{t('Available Time Slots')}</h3>
              <div className="text-sm text-gray-600">Selected: {selectedHours.length} slots</div>
            </div>

            {/* Time Slot Grid */}
            <div className="max-h-96 overflow-y-auto rounded-lg border">
              <div className="grid grid-cols-8 gap-2 p-4">
                {allTimeSlots.map((timeSlot) => {
                  const isSelected = selectedHours.includes(timeSlot);
                  return (
                    <button
                      key={timeSlot}
                      type="button"
                      onClick={() => handleHourToggle(timeSlot)}
                      disabled={loading}
                      className={`
                        flex cursor-pointer items-center justify-center rounded-md p-2 text-center text-sm transition-colors
                        ${
                          isSelected
                            ? 'bg-primary text-white hover:bg-primary'
                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                        }
                        ${loading ? 'cursor-not-allowed opacity-50' : ''}
                      `}>
                      {timeSlot}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Quick Selection Buttons */}
          <div className="flex flex-wrap gap-2">
            <Button
              type="button"
              variant="secondary"
              size="sm"
              onClick={() => setSelectedHours([])}
              disabled={loading}>
              {t('Clear All')}
            </Button>
            <Button
              type="button"
              variant="secondary"
              size="sm"
              onClick={() => {
                // Select business hours (9 AM to 6 PM)
                const businessHours = allTimeSlots.filter((slot) => {
                  const hour = parseInt(slot.split(':')[0]);
                  return hour >= 9 && hour < 18;
                });
                setSelectedHours(businessHours);
              }}
              disabled={loading}>
              {t('Business Hours')}
            </Button>
            <Button
              type="button"
              variant="secondary"
              size="sm"
              onClick={() => setSelectedHours(allTimeSlots)}
              disabled={loading}>
              {t('Select All')}
            </Button>
          </div>

          {/* Action Buttons */}
          <div className="flex justify-end gap-2 border-t pt-4">
            <Button variant="secondary" onClick={onClose} disabled={loading}>
              {t('Cancel')}
            </Button>
            <Button loading={loading} onClick={handleSave}>
              {t('Save Changes')}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default TimeSlotEditorModal;
