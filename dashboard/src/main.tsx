import { Suspense } from 'react';
import ReactDOM from 'react-dom/client';
import { HelmetProvider } from 'react-helmet-async';
import { I18nextProvider } from 'react-i18next';
import { RouterProvider } from 'react-router-dom';
import { ToastContainer } from 'react-toastify';
import { Provider } from 'react-redux';

import { SWRConfig } from 'swr';
import { registerSW } from 'virtual:pwa-register';

import SuspenseLoader from '@UI/Loaders/SuspenseLoader';

import i18n from '@app/locales/i18n';
import router from '@app/router';

import store from './store/store';
import 'react-international-phone/style.css';
import 'react-toastify/dist/ReactToastify.css';
import 'leaflet/dist/leaflet.css';
import './index.css';

document.querySelector('#loader.kleano-loader')?.remove();

document.addEventListener('orientationchange', () => {
  document.documentElement.style.height = `initial`;
  setTimeout(() => {
    document.documentElement.style.height = `100%`;
    setTimeout(() => {
      // this line prevents the content
      // from hiding behind the address bar
      window.scrollTo(0, 1);
    }, 500);
  }, 500);
});

const root = ReactDOM.createRoot(document.getElementById('root')!);

async function main() {
  // add this to prompt for a refresh
  const updateSW = registerSW({
    onNeedRefresh() {
      if (confirm('New content available. Reload?')) {
        updateSW(true);
      }
    },
  });

  root.render(
    <I18nextProvider i18n={i18n}>
      <Provider store={store}>
        <HelmetProvider>
          <SWRConfig
            value={{
              revalidateIfStale: true,
              revalidateOnMount: true,
              revalidateOnFocus: false,
              revalidateOnReconnect: true,
              errorRetryInterval: 2000,
              dedupingInterval: 3000,
              loadingTimeout: 5000,
              errorRetryCount: 3,
            }}>
            <Suspense fallback={<SuspenseLoader />}>
              <RouterProvider router={router} />
            </Suspense>
            <ToastContainer />
          </SWRConfig>
        </HelmetProvider>
      </Provider>
    </I18nextProvider>
  );
}

main();
