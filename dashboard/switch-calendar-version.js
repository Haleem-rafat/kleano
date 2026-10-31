// Quick script to switch between calendar versions
const fs = require('fs');
const path = require('path');

const routerPath = path.join(__dirname, 'src/app/router/index.tsx');
const versions = {
  fallback: {
    import:
      "import BookingCalendarFallback from '@/modules/booking-calendar/BookingCalendarFallback';",
    element: '<BookingCalendarFallback />',
  },
  fullcalendar: {
    import: "import BookingCalendarFixed from '@/modules/booking-calendar/BookingCalendarFixed';",
    element: '<BookingCalendarFixed />',
  },
  original: {
    import: "import BookingCalendar from '@/modules/booking-calendar/BookingCalendar';",
    element: '<BookingCalendar />',
  },
};

const version = process.argv[2] || 'fallback';

if (!versions[version]) {
  console.log('Available versions: fallback, fullcalendar, original');
  process.exit(1);
}

try {
  let content = fs.readFileSync(routerPath, 'utf8');

  // Replace import
  content = content.replace(
    /import Booking.*Calendar.* from.*booking-calendar.*;/,
    versions[version].import
  );

  // Replace element
  content = content.replace(
    /{ path: ROUTES\.BOOKING_CALENDAR, element: <.*Calendar.*\s*\/> },/,
    `{ path: ROUTES.BOOKING_CALENDAR, element: ${versions[version].element} },`
  );

  fs.writeFileSync(routerPath, content);
  console.log(`✅ Switched to ${version} version`);
} catch (error) {
  console.error('❌ Error switching versions:', error.message);
}
