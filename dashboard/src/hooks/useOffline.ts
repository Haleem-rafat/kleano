import React, { useEffect } from 'react';

export default function useOffline() {
  const storedIsOffline = localStorage.getItem('isOffline');
  const [isOffline, setIsOffline] = React.useState(
    storedIsOffline ? JSON.parse(storedIsOffline) : false
  );

  // Set up handlers
  function onOffline() {
    updateOfflineState(true);
  }

  function onOnline() {
    updateOfflineState(false);
  }

  function updateOfflineState(newOfflineState) {
    // Compare with the stored value and update only if different
    if (isOffline !== newOfflineState) {
      setIsOffline(newOfflineState);
      localStorage.setItem('isOffline', JSON.stringify(newOfflineState));
    }
  }

  useEffect(() => {
    // Set up handlers
    window.addEventListener('offline', onOffline);
    window.addEventListener('online', onOnline);

    // Check if the stored value is inconsistent with the actual online/offline status
    const isCurrentlyOffline = !navigator.onLine;
    if (isOffline !== isCurrentlyOffline) {
      updateOfflineState(isCurrentlyOffline);
    }

    // Return a function removing these handlers on unmount
    return () => {
      window.removeEventListener('offline', onOffline);
      window.removeEventListener('online', onOnline);
    };
  }, [isOffline]);

  // Return an object with loading and offline states
  return { isOffline };
}
