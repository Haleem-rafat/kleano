import { useTranslation } from 'react-i18next';
/* eslint-disable no-unused-vars */
import React from 'react';
import { Button, Segmented } from '@UI/Index';
import { CalendarView, CalendarFilters } from '../_types/calendar.types';
import { Switch } from '@/shadecn/components/ui/switch';
import { Label } from '@/shadecn/components/ui/label';

interface CalendarHeaderProps {
  currentView: CalendarView;
  onViewChange: (view: CalendarView) => void;
  filters: CalendarFilters;
  onFiltersChange: (filters: CalendarFilters) => void;
  onNavigate?: (action: 'prev' | 'next' | 'today') => void;
}

const CalendarHeader: React.FC<CalendarHeaderProps> = ({
  currentView,
  onViewChange,
  filters,
  onFiltersChange,
  onNavigate,
}) => {
  const { t } = useTranslation();
  const viewButtons = [
    { key: 'dayGridMonth' as CalendarView, label: 'Month' },
    { key: 'timeGridWeek' as CalendarView, label: 'Week' },
    { key: 'timeGridDay' as CalendarView, label: 'Day' },
    { key: 'listWeek' as CalendarView, label: 'List' },
  ];

  const handleShowInactiveToggle = (checked: boolean) => {
    onFiltersChange({
      ...filters,
      showInactive: checked,
    });
  };

  return (
    <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-border bg-card p-4">
      {/* Navigation and View Controls */}
      <div className="flex flex-wrap items-center gap-3">
        {/* Navigation Buttons */}
        {onNavigate && (
          <div className="flex items-center gap-1">
            <Button
              variant="secondary"
              size="sm"
              onClick={() => onNavigate('prev')}
              className="px-3 py-1 text-sm">
              ←
            </Button>
            <Button
              variant="secondary"
              size="sm"
              onClick={() => onNavigate('today')}
              className="px-3 py-1 text-sm">
              {t('Today')}
            </Button>
            <Button
              variant="secondary"
              size="sm"
              onClick={() => onNavigate('next')}
              className="px-3 py-1 text-sm">
              →
            </Button>
          </div>
        )}

        <Segmented
          label={t('view')}
          value={currentView}
          onChange={onViewChange}
          options={viewButtons.map((v) => ({ value: v.key, label: t(v.label) }))}
        />
      </div>

      {/* Filters */}
      <div className="flex items-center gap-4">
        <div className="flex items-center space-x-2">
          <Switch
            id="show-inactive"
            checked={filters.showInactive || false}
            onCheckedChange={handleShowInactiveToggle}
          />
          <Label htmlFor="show-inactive" className="text-sm">
            {t('Show Inactive')}
          </Label>
        </div>

        {/* Sprint Count */}
        <div className="text-sm text-muted-foreground">
          {/* This will be populated with actual sprint count */}
        </div>
      </div>
    </div>
  );
};

export default CalendarHeader;
