/** @type {import('tailwindcss').Config} */
import tailwindAnimate from 'tailwindcss-animate';
import tailwindScrollBarHide from 'tailwind-scrollbar-hide';
export default  {
  darkMode: ['class'],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
        '3xl': '1600px',
      },
    },
    extend: {
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
      fontFamily: {},
      colors: {
        background: {
          DEFAULT: '#F6F6F7',
        },
        primary: {
          DEFAULT: '#533063',
        },
        secondary: {
          DEFAULT: '#8d5ba5',
        },
        brandTint: {
          DEFAULT: '#ECE6EF',
        },
        danger: {},
      },

      boxShadow: {
        // btn: '0px 4px 4px 0px #0E0E0E29',
      },
    },
  },
  plugins: [tailwindAnimate, tailwindScrollBarHide],
};
