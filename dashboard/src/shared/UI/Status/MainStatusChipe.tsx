import { useTranslation } from 'react-i18next';

type Tone = 'success' | 'danger' | 'warning' | 'info' | 'brand' | 'neutral';

// Same colours as the apps' KStatusChip: tinted background, readable label.
const TONES: Record<Tone, string> = {
  success: 'bg-success/10 text-success ring-success/25',
  danger: 'bg-destructive/10 text-destructive ring-destructive/25',
  warning: 'bg-warning/10 text-warning ring-warning/25',
  info: 'bg-warning/10 text-warning ring-warning/25',
  brand: 'bg-accent text-accent-foreground ring-primary/20',
  neutral: 'bg-muted text-muted-foreground ring-border',
};

const STATUSES: Record<string, { tone: Tone; label: string }> = {
  activate: { tone: 'success', label: 'activate' },
  ACTIVE: { tone: 'success', label: 'active' },
  disable: { tone: 'danger', label: 'disable' },
  ONLINE: { tone: 'success', label: 'online' },
  SUSPENDED: { tone: 'danger', label: 'suspended' },
  EXPIRED: { tone: 'danger', label: 'expired' },
  OFFLINE: { tone: 'neutral', label: 'offline' },
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
      className={`inline-flex w-fit items-center whitespace-nowrap rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset ${
        TONES[config.tone]
      }`}>
      {t(config.label)}
    </span>
  );
};

export default MainStatusChipe;
