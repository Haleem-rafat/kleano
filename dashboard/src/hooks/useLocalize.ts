import { useTranslation } from 'react-i18next';

export const useLocalize = () => {
  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  return {
    lang,
    localize: (localizedText: { en: string; ar: string }): string => localizedText?.[lang],
  };
};
