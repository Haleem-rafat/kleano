import React from 'react';

const TestCalendar = () => {
  return (
    <div className="flex min-h-screen items-center justify-center bg-primary p-4">
      <div className="rounded-lg bg-white p-8 shadow-xl">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900">🎉 Success!</h1>
          <h2 className="mt-2 text-xl text-gray-700">Enhanced Booking Calendar Route Working</h2>
          <div className="mt-4 space-y-2 text-sm text-gray-600">
            <p>✅ Route: /app/booking-calendar</p>
            <p>✅ Component: Loading successfully</p>
            <p>✅ Navigation: Menu item working</p>
          </div>
          <div className="mt-6 rounded bg-green-100 p-4">
            <p className="text-sm text-green-800">
              If you see this page, the enhanced booking calendar route is working correctly!
            </p>
          </div>
          <div className="mt-4 text-xs text-gray-500">
            Current URL should be: {window.location.pathname}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TestCalendar;
