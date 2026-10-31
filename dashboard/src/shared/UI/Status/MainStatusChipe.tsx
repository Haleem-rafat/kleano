import { useTranslation } from 'react-i18next';

const MainStatusChipe = ({ status }) => {
  const { t } = useTranslation();
  return (
    <div>
      {status === 'activate' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-green-500/30  px-2.5 py-0.5 text-xs font-medium text-slate-800 ">
          {t('activate')}
        </div>
      )}
      {/* active */}
      {status === 'ACTIVE' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-green-500/30  px-2.5 py-0.5 text-xs font-medium text-slate-800 ">
          {t('active')}
        </div>
      )}
      {status === 'disable' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-red-600/30  px-4 py-0.5 text-slate-800">
          {t('disable')}
        </div>
      )}
      {status === 'ONLINE' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-green-200/40  px-2.5 py-0.5 text-xs font-medium text-slate-800 ">
          {t('online')}
        </div>
      )}
      {status === 'SUSPENDED' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-red-600/30  px-4 py-0.5 text-slate-800">
          {t('suspend')}
        </div>
      )}
      {status === 'EXPIRED' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-red-600/30  px-4 py-0.5 text-slate-800">
          {t('expired')}
        </div>
      )}
      {status === 'OFFLINE' && (
        <div className="w-fit whitespace-nowrap rounded-full bg-orange-500/30  px-4 py-0.5 text-slate-800">
          {t('ofline')}
        </div>
      )}
      {status === 'BIKER_ON_THE_WAY' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#6787C61A] px-4 py-0.5 text-slate-800">
          {t('bikerOntheWay')}
        </div>
      )}
      {status === 'ACCEPTED_BY_BIKER' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#6FFB4C19]  px-4 py-0.5 text-slate-800">
          {t('acceptByBiker')}
        </div>
      )}
      {status === 'BIKER_ARRIVED' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#FBAE4C19]  px-4 py-0.5 text-slate-800">
          {t('BikerArrived')}
        </div>
      )}
      {status === 'ON_WASHING' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#FFE43619] px-4 py-0.5 text-slate-800">
          {t('onWashing')}
        </div>
      )}
      {status === 'WAITING_FOR_BIKER_BY_ADMIN' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#F5F0FA] px-4 py-0.5 text-slate-800">
          {t('watingForBikerOrder')}
        </div>
      )}
      {status === 'COMPLETED' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#F5F0FA] px-4 py-0.5 text-slate-800">
          {t('completed')}
        </div>
      )}
      {(status === 'CANCELLED_BY_ADMIN' || status === 'CANCELLED_BY_USER') && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-[#F5F0FA] px-4 py-0.5 text-slate-800">
          {t(status)}
        </div>
      )}

      {status === 'PENDING_USER_PAYMENT' && (
        <div className="whitespace-nowrapl w-fit rounded-full bg-yellow-500/30 px-1.5 py-0.5 text-slate-800">
          {t('pendingUserPayment')}
        </div>
      )}
    </div>
  );
};

export default MainStatusChipe;
