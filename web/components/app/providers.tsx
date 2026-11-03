'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState, type ReactNode } from 'react';
import { Toaster } from '@/components/ui/sonner';
import { ApiError } from '@/lib/kleano/client';

/** Data cache for the web apps, like the apps' BLoCs: retries network errors, not auth errors. */
export function AppProviders({ children, rtl }: { children: ReactNode; rtl: boolean }) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 30_000,
            retry: (count, error) => !(error instanceof ApiError && error.status < 500) && count < 2,
          },
        },
      }),
  );
  return (
    <QueryClientProvider client={client}>
      {children}
      <Toaster position={rtl ? 'top-left' : 'top-right'} dir={rtl ? 'rtl' : 'ltr'} richColors />
    </QueryClientProvider>
  );
}
