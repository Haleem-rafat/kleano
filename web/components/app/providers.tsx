'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState, type ReactNode } from 'react';
import { toast } from 'sonner';
import { Toaster } from '@/components/ui/sonner';
import { getAppDictionary } from '@/lib/app-dictionary';
import { ApiError, SESSION_EXPIRED_EVENT } from '@/lib/kleano/client';

/** Toasts for losing the connection and for a session that ended; the latter also goes to log in. */
function ConnectionWatcher({ rtl }: { rtl: boolean }) {
  const router = useRouter();
  const pathname = usePathname();
  useEffect(() => {
    const t = getAppDictionary(rtl ? 'ar' : 'en');
    const offline = () => toast.error(t.session.offline, { id: 'kleano-offline', duration: Infinity });
    const online = () => {
      toast.dismiss('kleano-offline');
      toast.success(t.session.online);
    };
    const expired = () => {
      const [, locale = 'ar', area = 'app'] = pathname.split('/');
      toast.error(t.session.expired, { id: 'kleano-expired' });
      router.replace(`/${locale}/${area === 'biker' ? 'biker' : 'app'}/login`);
      router.refresh();
    };
    window.addEventListener('offline', offline);
    window.addEventListener('online', online);
    window.addEventListener(SESSION_EXPIRED_EVENT, expired);
    return () => {
      window.removeEventListener('offline', offline);
      window.removeEventListener('online', online);
      window.removeEventListener(SESSION_EXPIRED_EVENT, expired);
    };
  }, [rtl, router, pathname]);
  return null;
}

/** Data cache for the web apps, like the apps' BLoCs: retries network errors, not auth errors. */
export function AppProviders({ children, rtl }: { children: ReactNode; rtl: boolean }) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 30_000,
            // Status 0 means the request never reached this site's server.
            retry: (count, error) => !(error instanceof ApiError && error.status > 0 && error.status < 500) && count < 2,
          },
        },
      }),
  );
  return (
    <QueryClientProvider client={client}>
      {children}
      <ConnectionWatcher rtl={rtl} />
      <Toaster position={rtl ? 'top-left' : 'top-right'} dir={rtl ? 'rtl' : 'ltr'} richColors />
    </QueryClientProvider>
  );
}
