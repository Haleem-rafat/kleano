import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import HttpBackend from 'i18next-http-backend';
import { ELocalStorageKeys } from '@constants/keys';
import enTranslations from '../locales/en/translation.json';
import arTranslations from '../locales/ar/translation.json';

// eslint-disable-next-line import/no-named-as-default-member
i18n
  .use(HttpBackend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    fallbackLng: 'en',
    lng: localStorage.getItem(ELocalStorageKeys.LANGUAGE),
    supportedLngs: ['en', 'ar'],
    interpolation: {
      escapeValue: false,
    },
    resources: {
      en: {
        translations: enTranslations,
      },
      ar: {
        translations: arTranslations,
      },
    },
    ns: ['translations'],
    defaultNS: 'translations',
  });
i18n.languages = ['en', 'ar'];

export default i18n;
