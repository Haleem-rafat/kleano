import { useTranslation } from 'react-i18next';

type Tone = 'success' | 'danger' | 'warning' | 'info' | 'brand' | 'neutral';

const TONES: Record<Tone, string> = {
  success: 'bg-emerald-50 text-emerald-700 ring-emerald-600/20',
  danger: 'bg-red-50 text-red-700 ring-red-600/20',
  warning: 'bg-amber-50 text-amber-700 ring-amber-600/20',
  info: 'bg-sky-50 text-sky-700 ring-sky-600/20',
  brand: 'bg-brandTint text-primary ring-primary/20',
  neutral: 'bg-slate-100 text-slate-600 ring-slate-500/20',
};

const STATUSES: Record<string, { tone: Tone; label: string }> = {
  activate: { tone: 'success', label: 'activate' },
  ACTIVE: { tone: 'success', label: 'active' },
  disable: { tone: 'danger', label: 'disable' },
  ONLINE: { tone: 'success', label: 'online' },
  SUSPENDED: { tone: 'danger', label: 'suspend' },
  EXPIRED: { tone: 'danger', label: 'expired' },
  OFFLINE: { tone: 'neutral', label: 'ofline' },
  BIKER_ON_THE_WAY: { tone: 'info', label: 'bikerOntheWay' },
  ACCEPTED_BY_BIKER: { tone: 'brand', label: 'acceptByBiker' },
  BIKER_ARRIVED: { tone: 'warning', label: 'BikerArrived' },
  ON_WASHING: { tone: 'warning', label: 'onWashing' },
  WAITING_FOR_BIKER_BY_ADMIN: { tone: 'warning', label: 'watingForBikerOrder' },
  COMPLETED: { tone: 'success', label: 'completed' },
  CANCELLED_BY_ADMIN: { tone: 'danger', label: 'CANCELLED_BY_ADMIN' },
  CANCELLED_BY_USER: { tone: 'danger', label: 'CANCELLED_BY_USER' },
  PENDING_USER_PAYMENT: { tone: 'neutral', label: 'pendingUserPayment' },
};

const MainStatusChipe = ({ status }: { status?: string }) => {
  const { t } = useTranslation();
  const config = status ? STATUSES[status] : undefined;
  if (!config) return null;
  return (
    <span
      className={`inline-flex w-fit items-center whitespace-nowrap rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset ${TONES[config.tone]}`}>
      {t(config.label)}
    </span>
  );
};

export default MainStatusChipe;
