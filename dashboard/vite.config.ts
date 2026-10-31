import path from 'path';
import { defineConfig } from 'vite';

import react from '@vitejs/plugin-react';
import svgr from 'vite-plugin-svgr';
import tsconfigPaths from 'vite-tsconfig-paths';
import { VitePWA } from 'vite-plugin-pwa';

// https://vitejs.dev/config/
export default defineConfig({
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
        globPatterns: ['**/*'],
        maximumFileSizeToCacheInBytes: 5 * 1024 * 1024, // 5 MB limit
      },
      includeAssets: ['**/*'],
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
