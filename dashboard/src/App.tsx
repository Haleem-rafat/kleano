import { Suspense, useEffect } from 'react';
import { ThreeDotsLoader } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import { Navigate, Outlet, useLoaderData } from 'react-router-dom';

import { ROUTES } from '@constants/routes';
import AppLayouts from './shared/Layouts/AppLayouts';

function App() {
  const { i18n } = useTranslation();

  useEffect(() => {
    document.documentElement.dir = i18n.dir();
  }, [i18n, i18n.language]);

  const { isLoggedIn } = useLoaderData() as { isLoggedIn: boolean };
  if (!isLoggedIn) return <Navigate to={ROUTES.LOG_IN} />;

  return (
    <AppLayouts>
      <Suspense fallback={<ThreeDotsLoader />}>
        <Outlet />
      </Suspense>
    </AppLayouts>
  );
}

export default App;
