import i18n from '@app/locales/i18n';

export const formatDate = (isoString) => {
  const date = new Date(isoString);
  if (!isoString || Number.isNaN(date.getTime())) return '—';
  return date.toLocaleString(i18n.language === 'ar' ? 'ar-EG' : 'en-GB', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
};

export const formatToFilterDate = (date) => {
  if (date) {
    const day = date.getDate();
    const month = date.getMonth() + 1;
    const year = date.getFullYear();
    const formattedDate = `${year}-${month}-${day}`;
    return formattedDate;
  }
};

export const changeLangHandler = (language: 'ar' | 'en') => {
  if (language == 'ar') {
    localStorage.setItem('direction', 'rtl');
    document.getElementsByTagName('html')[0].setAttribute('dir', 'rtl');
  } else {
    localStorage.setItem('direction', 'ltr');
    document.getElementsByTagName('html')[0].setAttribute('dir', 'ltr');
  }
  document.getElementsByTagName('html')[0].setAttribute('lang', language);
  i18n.changeLanguage(language);
};
