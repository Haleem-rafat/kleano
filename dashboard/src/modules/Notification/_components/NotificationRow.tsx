import { ROUTES } from '@constants/routes';
import notificationService from '@services/notification.service';
import { MainAvatar } from '@UI/Index';
import i18next from 'i18next';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';

const NotificationRow = ({ data }) => {
  const lang = i18next.language; // Assuming useLanguage sets the default language
  const navigate = useNavigate(); // useHistory() for React Router v5
  const { t } = useTranslation();
  const handleIsRead = (id) => {
    notificationService
      .readNotifications(id)
      .then()
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
      });
  };

  function timeSince(datetime: Date) {
    const days = (Date.now() - datetime.getTime()) / 86400000;
    const relative = new Intl.RelativeTimeFormat(lang, { numeric: 'auto' });
    const section = days >= 2 ? 'old' : days >= 1 ? 'yes' : 'new';
    if (days >= 365) {
      return { section, displayDate: relative.format(-Math.floor(days / 365), 'year') };
    }
    if (days >= 30) {
      return { section, displayDate: relative.format(-Math.floor(days / 30), 'month') };
    }
    if (days >= 1) return { section, displayDate: relative.format(-Math.floor(days), 'day') };
    const minutes = days * 1440;
    if (minutes >= 60) {
      return { section, displayDate: relative.format(-Math.floor(minutes / 60), 'hour') };
    }
    return { section, displayDate: relative.format(-Math.max(1, Math.ceil(minutes)), 'minute') };
  }

  let currentSection = '';

  return (
    <div>
      {data?.map((e) => {
        const notificationDateData = timeSince(new Date(e?.createdAt));
        const isNewSection = notificationDateData.section !== currentSection;

        if (isNewSection) {
          currentSection = notificationDateData.section;
        }

        return (
          <div key={e?._id}>
            {isNewSection && (
              <div className="px-1 pb-1 pt-3 text-xs font-medium text-slate-500 sm:px-0">
                {currentSection === 'old'
                  ? t('older')
                  : currentSection === 'yes'
                  ? t('yesterday')
                  : t('today')}
              </div>
            )}
            <div
              onClick={() => {
                handleIsRead(e?._id);
                navigate(generatePath(ROUTES.ORDER_DETAILS, { orderId: e.clickableItem }));
              }}
              className={`my-2 rounded-xl border border-slate-200 p-3 ${
                e?.isRead ? 'bg-white' : 'bg-brandTint/60'
              } hover:border-primary/40 active:dark:bg-darkMood-whitBlack/90 hover:dark:bg-darkMood-whitBlack/50 flex cursor-pointer justify-between hover:rounded-xl hover:bg-secondary/30 hover:text-white active:rounded-xl active:bg-primary/90`}>
              <div className="flex gap-x-2">
                <MainAvatar
                  src=""
                  name={
                    lang === 'en'
                      ? e?.message?.enTitle || 'Pending request'
                      : e?.message?.arTitle || 'Pending request'
                  }
                  className="h-10 w-10 shrink-0"
                />

                <div>
                  <h2 className="text-[13px] font-medium text-slate-900">
                    {lang === 'en' ? e?.message?.enTitle : e?.message?.arTitle}
                  </h2>
                  <p className="text-[13px] text-slate-500">
                    {lang === 'en' ? e?.message?.enBody : e?.message?.arBody}
                  </p>
                  <div className="block text-xs text-slate-500 sm:hidden">
                    {notificationDateData.displayDate}
                  </div>
                </div>
              </div>
              <div className="hidden shrink-0 px-2 text-xs text-slate-500 sm:block">
                {notificationDateData.displayDate}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default NotificationRow;
