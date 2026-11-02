import path from 'path';
import { defineConfig } from 'vite';

import react from '@vitejs/plugin-react';
import svgr from 'vite-plugin-svgr';
import tsconfigPaths from 'vite-tsconfig-paths';
import { VitePWA } from 'vite-plugin-pwa';

// https://vitejs.dev/config/
// Libraries in their own chunks: downloaded in parallel, cached across deploys
// (app code changes far more often than these).
const VENDOR_CHUNKS: Record<string, string[]> = {
  'vendor-react': ['react', 'react-dom', 'react-router', 'react-router-dom', '@remix-run', 'scheduler'],
  'vendor-ui': ['@radix-ui', 'cmdk', '@floating-ui', 'tailwind-merge', 'class-variance-authority'],
  'vendor-icons': ['react-icons', '@heroicons', 'lucide-react'],
  'vendor-data': ['axios', 'swr', '@reduxjs', 'redux', 'react-redux', 'immer', 'reselect'],
  'vendor-forms': ['react-hook-form', '@hookform', 'yup'],
  'vendor-i18n': ['i18next', 'react-i18next', 'i18next-browser-languagedetector', 'i18next-http-backend'],
};

const vendorChunk = (id: string) => {
  const match = id.match(/node_modules\/((?:@[^/]+\/)?[^/]+)/);
  if (!match) return undefined;
  const pkg = match[1];
  return Object.keys(VENDOR_CHUNKS).find((chunk) =>
    VENDOR_CHUNKS[chunk].some((name) => pkg === name || pkg.startsWith(`${name}/`))
  );
};

export default defineConfig({
  build: {
    rollupOptions: {
      output: { manualChunks: vendorChunk },
    },
  },
  resolve: {
    alias: {
      '@UI': path.resolve(__dirname, './src/shared/UI'),

      '@services': path.resolve(__dirname, './src/app/api/services'),
      '@servicesTypes': path.resolve(__dirname, './src/app/api/types'),
      '@constants': path.resolve(__dirname, './src/app/constants'),

      '@app': path.resolve(__dirname, './src/app'),
      '@assets': path.resolve(__dirname, './src/assets'),
      '@shadecn': path.resolve(__dirname, './src/shadecn'),
      '@components': path.resolve(__dirname, './src/components'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@store': path.resolve(__dirname, './src/store'),

      '@': path.resolve(__dirname, './src'),
    },
  },
  plugins: [
    react(),
    tsconfigPaths(),
    svgr({
      svgrOptions: {
        icon: true,
      },
    }),
    VitePWA({
      devOptions: {
        enabled: true,
        type: 'module',
      },
      workbox: {
        // Precache the app shell only. Page chunks (maps, charts, calendar) and
        // images are cached the first time they are used, not all on first visit.
        globPatterns: ['index.html', 'assets/index-*.{js,css}', 'assets/vendor-*.js', '*.{ico,svg,png}'],
        maximumFileSizeToCacheInBytes: 2 * 1024 * 1024,
        runtimeCaching: [
          {
            // Only content-hashed build files (never change under one name), so
            // cache-first can't serve stale code (dev modules live under /src).
            urlPattern: ({ url, sameOrigin }) => sameOrigin && url.pathname.startsWith('/assets/'),
            handler: 'CacheFirst',
            options: {
              cacheName: 'kleano-assets',
              expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 * 24 * 30 },
            },
          },
        ],
      },
      manifest: {
        theme_color: '#533063',
        background_color: '#533063',
        display: 'standalone',
        scope: '/',
        start_url: '/',
        short_name: ' kleano-admin',
        description: ' kleano-admin',
        name: ' kleano',
      },
      registerType: 'autoUpdate',
    }),
  ],
});
