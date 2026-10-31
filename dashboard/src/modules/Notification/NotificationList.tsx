import notificationService from '@services/notification.service';
import { useState } from 'react';
import useSWR from 'swr';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';

import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import i18next from 'i18next';
import { EmtyState } from '@UI/Index';
import NotificationRow from './_components/NotificationRow';

const NotificationList = () => {
  const lang = i18next.language;
  const { t } = useTranslation();
  const [pageIndex, setPageIndex] = useState(1);
  const { data: notificationList } = useSWR(['get-all-admins-list', pageIndex], () =>
    notificationService
      .getAllNotifications({
        page: pageIndex,
        perPage: 10,
      })
      .then((data) => {
        return data;
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
      })
  );

  if (notificationList?.data?.length === 0) return <EmtyState />;

  return (
    <div>
      <div className="px-4 text-3xl font-medium sm:px-0">{t('notification')}</div>
      {notificationList && <NotificationRow data={notificationList.data} />}
      {notificationList && (
        <PaginationComponent
          page={pageIndex}
          pages={notificationList.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
    </div>
  );
};

export default NotificationList;
