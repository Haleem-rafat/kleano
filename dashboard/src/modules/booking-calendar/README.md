# Enhanced Booking Calendar System

## Overview

This is the new enhanced booking calendar system built with FullCalendar React. It provides a
professional, Google Calendar-like interface for managing booking sprints and time slots while
maintaining all current functionality.

## Features

### ✅ Current Features Implemented

- **Professional Calendar Interface**: Month, week, day, and list views
- **Sprint Creation**: Create 14-day booking sprints (same validation as original)
- **Time Slot Management**: Edit time slots with 30-minute intervals
- **Day Management**: Enable/disable entire days
- **Visual Calendar**: Events displayed on calendar with color coding
- **Responsive Design**: Works on all device sizes
- **Real-time Updates**: Uses SWR for data synchronization

### 🎨 UI/UX Improvements

- **Calendar Views**: Multiple view options (Month/Week/Day/List)
- **Interactive Events**: Click events to edit time slots
- **Color Coding**:
  - Green: Active sprints/slots
  - Red: Inactive sprints/slots
  - Blue: Selected time slots
- **Quick Actions**: Business hours, select all, clear all buttons
- **Enhanced Modals**: Better time slot selection interface

## File Structure

```
src/modules/booking-calendar/
├── BookingCalendar.tsx              # Main calendar component
├── _components/
│   ├── CalendarHeader.tsx           # View controls and filters
│   ├── SprintCreatorModal.tsx       # Sprint creation modal
│   └── TimeSlotEditorModal.tsx      # Time slot editing modal
├── _types/
│   └── calendar.types.ts            # TypeScript interfaces
├── _utils/
│   └── dateHelpers.ts               # Date manipulation utilities
└── README.md                        # This documentation
```

## Usage

### Accessing the Calendar

Navigate to `/app/booking-calendar` or use the "Booking Calendar" link in the sidebar navigation.

### Creating Sprints

1. Click "Create Sprint" button
2. Select a date range (must be exactly 14 days)
3. Review sprint details
4. Click "Create Sprint"

### Managing Time Slots

1. Click on any sprint event in the calendar
2. Toggle sprint status (Active/Inactive)
3. Select individual time slots by clicking them
4. Use quick selection buttons:
   - **Clear All**: Remove all selections
   - **Business Hours**: Select 9 AM to 6 PM
   - **Select All**: Select all 48 time slots
5. Click "Save Changes"

### Calendar Navigation

- **Month View**: High-level overview of all sprints
- **Week View**: Detailed weekly view with time slots
- **Day View**: Granular daily management
- **List View**: List format of all events

## API Integration

The system uses the existing booking service API:

- `GET /booking-availabilities/admin` - Fetch sprints
- `POST /booking-availabilities/admin` - Create sprint
- `PATCH /booking-availabilities/admin` - Update sprint/time slots

## Technical Details

### Dependencies

- `@fullcalendar/react` - Main calendar component
- `@fullcalendar/daygrid` - Month view
- `@fullcalendar/timegrid` - Week/Day views
- `@fullcalendar/interaction` - User interactions
- `@fullcalendar/list` - List view
- `@fullcalendar/resource-timeline` - Future biker management

### State Management

- Uses SWR for data fetching and caching
- React state for UI interactions
- Real-time updates with `mutate()`

### Styling

- Tailwind CSS for layout and styling
- Shadcn/UI components for consistent design
- Custom FullCalendar theme integration

## Migration from Old System

The old booking system (`/app/booking`) remains fully functional. This new calendar system:

1. **Maintains API Compatibility**: Uses the same backend endpoints
2. **Preserves Data Format**: No changes to existing data structure
3. **Parallel Operation**: Both systems can run simultaneously
4. **Feature Parity**: All current features are implemented

## Future Enhancements

### Phase 2: Biker Integration (Planned)

- Resource timeline view for biker assignments
- Drag-and-drop biker scheduling
- Biker availability management
- Conflict resolution

### Phase 3: Advanced Features (Planned)

- Analytics dashboard
- Performance metrics
- Export functionality
- Mobile app integration

## Development Notes

### Adding New Features

1. Add types to `_types/calendar.types.ts`
2. Create utility functions in `_utils/`
3. Add components to `_components/`
4. Update main `BookingCalendar.tsx`

### Customizing Calendar

FullCalendar configuration is in `BookingCalendar.tsx`. Key options:

```javascript
<FullCalendar
  plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin]}
  headerToolbar={{
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek',
  }}
  // ... other options
/>
```

### Styling Customization

Calendar styling can be customized via:

1. CSS classes in Tailwind
2. FullCalendar's built-in theming
3. Custom event rendering functions

## Testing

To test the implementation:

1. Navigate to `/app/booking-calendar`
2. Create a new sprint
3. Edit time slots
4. Toggle sprint status
5. Test different calendar views
6. Verify data persistence

## Support

For issues or questions about the enhanced booking calendar:

1. Check the original booking system for comparison
2. Review FullCalendar documentation
3. Test API endpoints with existing booking service
4. Verify TypeScript types are correct

---

**Status**: ✅ Phase 1 Complete - All current features implemented **Next**: Phase 2 - Biker
management integration **Version**: 1.0.0
