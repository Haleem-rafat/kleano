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

  function timeSince(datetime) {
    const now = new Date().getTime();
    const seconds = Math.floor((now - datetime) / 1000);
    let interval = seconds / 31536000;

    if (interval > 1) {
      return {
        section: 'old',
        displayDate: `${Math.floor(interval)} ${t('years')} `,
      };
    }

    interval = seconds / 2592000;
    if (interval > 1) {
      return {
        section: 'old',
        displayDate: `${Math.floor(interval)} ${t('month')}`,
      };
    }

    interval = seconds / 86400;
    if (interval >= 2) {
      return {
        section: 'old',
        displayDate: `${Math.floor(interval)} ${t('day')}`,
      };
    }
    if (interval > 1) {
      return {
        section: 'yes',
        displayDate: datetime.toLocaleTimeString(lang, {
          hour: '2-digit',
          minute: '2-digit',
        }),
      };
    }

    interval = seconds / 3600;
    if (interval > 1) {
      return {
        section: 'new',
        displayDate: `${Math.floor(interval)} ${t('hr')}`,
      };
    }

    interval = seconds / 60;
    return {
      section: 'new',
      displayDate: `${Math.ceil(interval)} ${t('min')}`,
    };
  }

  let currentSection = '';

  return (
    <div className="px-4 sm:px-0">
      {data?.map((e) => {
        const notificationDateData = timeSince(new Date(e?.createdAt));
        const isNewSection = notificationDateData.section !== currentSection;

        if (isNewSection) {
          currentSection = notificationDateData.section;
        }

        return (
          <div key={e?._id}>
            {isNewSection && (
              <div className="text-textGray2 px-1 py-2 text-base font-normal sm:px-0">
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
              className={`my-2 border border-b-[0.5px] p-2 ${
                e?.isRead ? 'rounded-xl bg-white' : 'rounded-xl bg-secondary/10'
              } active:dark:bg-darkMood-whitBlack/90 hover:dark:bg-darkMood-whitBlack/50 flex cursor-pointer justify-between hover:rounded-xl hover:bg-secondary/30 hover:text-white active:rounded-xl active:bg-primary/90`}>
              <div className="flex gap-x-2">
                <MainAvatar
                  size="3xl"
                  src={
                    lang === 'en'
                      ? e?.message?.enTitle || 'Pending request'
                      : e?.message?.arTitle || 'Pending request'
                  }
                  name={
                    lang === 'en'
                      ? e?.message?.enTitle || 'Pending request'
                      : e?.message?.arTitle || 'Pending request'
                  }
                  className="h-10 w-10"
                />

                <div>
                  <h1 className="pt-2 text-base font-medium">
                    {lang === 'en' ? e?.message?.enTitle : e?.message?.arTitle}
                  </h1>
                  <p className="text-clip pb-0 text-base font-normal text-[#707070] sm:pb-2">
                    {lang === 'en' ? e?.message?.enBody : e?.message?.arBody}
                  </p>
                  <div className="block text-base font-normal text-[#707070] sm:hidden">
                    {notificationDateData.displayDate}
                  </div>
                </div>
              </div>
              <div className="hidden px-6 pt-4 text-base font-normal text-[#707070] sm:block">
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
