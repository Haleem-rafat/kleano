import i18n from '@app/locales/i18n';

export const formatDate = (isoString) => {
  const date = new Date(isoString);
  if (!isoString || Number.isNaN(date.getTime())) return '—';
  // here i want to add the day name ex friday, saturday, sunday, monday, tuesday, wednesday, thursday
  const day = date.toLocaleDateString('en-US', { weekday: 'long' });

  return `${day} ${date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })}`;
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
    localStorage.setItem('direction', 'rtl')
    document.getElementsByTagName('html')[0].setAttribute('dir', 'rtl')
  } else {
    localStorage.setItem('direction', 'ltr')
    document.getElementsByTagName('html')[0].setAttribute('dir', 'ltr')
  }
  document.getElementsByTagName('html')[0].setAttribute('lang', language)
  i18n.changeLanguage(language)
}