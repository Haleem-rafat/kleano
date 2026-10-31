import { useTranslation } from 'react-i18next';
/* eslint-disable no-unused-vars */
import React from 'react';
import { Button } from '@UI/Index';
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
    <div className="flex items-center justify-between rounded-lg border bg-white p-4">
      {/* Navigation and View Controls */}
      <div className="flex items-center gap-4">
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

        {/* View Toggle Buttons */}
        <div className="flex items-center gap-1 rounded-lg bg-gray-100 p-1">
          {viewButtons.map((view) => (
            <Button
              key={view.key}
              variant={currentView === view.key ? 'primary' : 'secondary'}
              size="sm"
              onClick={() => onViewChange(view.key)}
              className={`px-3 py-1 text-sm ${
                currentView === view.key ? 'bg-primary text-white shadow-sm' : 'hover:bg-white'
              }`}>
              {view.label}
            </Button>
          ))}
        </div>
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
        <div className="text-sm text-gray-600">
          {/* This will be populated with actual sprint count */}
        </div>
      </div>
    </div>
  );
};

export default CalendarHeader;
