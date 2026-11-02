import { useTranslation } from 'react-i18next';
import { formatDate } from '@app/utils/helper';
import usersService from '@services/users.service';
import { IRootUser } from '@servicesTypes/user.types';
import Alert from '@UI/Alert/Alert';
import {
  AdminStatus,
  Button,
  DataTable,
  ImageModal,
  InfoList,
  MainAvatar,
  PageHeader,
  SectionCard,
  PageSkeleton,
} from '@UI/Index';
import { ColumnDef } from '@tanstack/react-table';
import { Input } from '@shadecn/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@shadecn/components/ui/select';
import { useState, useMemo } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { toast } from 'react-toastify';
import useSWR from 'swr';
import { ROUTES } from '@constants/routes';

export default function UsersDetails() {
  const navigate = useNavigate();
  const { userId } = useParams();
  const [loading, setLoading] = useState(false);
  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [paymentTypeFilter, setPaymentTypeFilter] = useState('all');
  const [dateRangeFilter, setDateRangeFilter] = useState('all');

  const { t } = useTranslation();

  const {
    data: userDetails,
    isLoading,
    mutate,
  } = useSWR(
    ['get-user-details', userId],
    () =>
      userId &&
      usersService.getUsersDetails(userId).then((data) => {
        return data as IRootUser[];
      })
  );

  const user = userDetails?.[0] as IRootUser;

  // Filter orders based on current filter states
  const filteredOrders = useMemo(() => {
    if (!user?.orders) return [];

    return user.orders.filter((order) => {
      // Search filter
      if (searchTerm) {
        const searchLower = searchTerm.toLowerCase();
        const matchesSearch =
          order._id.toLowerCase().includes(searchLower) ||
          order.vehicle?.brand?.toLowerCase().includes(searchLower) ||
          order.vehicle?.model?.toLowerCase().includes(searchLower) ||
          order.type?.toLowerCase().includes(searchLower) ||
          order.paymentType?.toLowerCase().includes(searchLower);

        if (!matchesSearch) return false;
      }

      // Status filter
      if (statusFilter !== 'all' && order.status !== statusFilter) {
        return false;
      }

      // Payment type filter
      if (paymentTypeFilter !== 'all' && order.paymentType !== paymentTypeFilter) {
        return false;
      }

      // Date range filter
      if (dateRangeFilter !== 'all') {
        const orderDate = new Date(order.createdAt);
        const now = new Date();

        switch (dateRangeFilter) {
          case 'today': {
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            if (orderDate < today) return false;
            break;
          }
          case 'week': {
            const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            if (orderDate < weekAgo) return false;
            break;
          }
          case 'month': {
            const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
            if (orderDate < monthAgo) return false;
            break;
          }
          case 'year': {
            const yearAgo = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
            if (orderDate < yearAgo) return false;
            break;
          }
          default:
            break;
        }
      }

      return true;
    });
  }, [user?.orders, searchTerm, statusFilter, paymentTypeFilter, dateRangeFilter]);

  // Get unique values for filter options
  const uniquePaymentTypes = useMemo(() => {
    if (!user?.orders) return [];
    return [...new Set(user.orders.map((order) => order.paymentType).filter(Boolean))];
  }, [user?.orders]);

  const handleChangeStatus = async (id, status) => {
    setLoading(true);
    await usersService
      .toggleUserStatus(id, status)
      .then(() => {
        toast.success(t('statusUpdated'));
        mutate();
        setLoading(false);
      })
      .catch((e) => {
        setLoading(false);

        toast.error(e?.response?.data?.localizedMessage?.[lang] || t('somethingWentWrong'));
      });
  };
  if (isLoading) return <PageSkeleton kind="details" />;
  if (!user)
    return <p className="py-24 text-center text-muted-foreground">{t('noDataAvailable')}</p>;

  const orders = user.orders ?? [];
  const sum = (pick: (o: (typeof orders)[number]) => unknown) =>
    orders.reduce((total, o) => total + (parseFloat(`${pick(o)}`) || 0), 0);
  const mostCommon = (pick: (o: (typeof orders)[number]) => string | undefined) => {
    const counts: Record<string, number> = {};
    orders.forEach((o) => {
      const key = pick(o);
      if (key) counts[key] = (counts[key] || 0) + 1;
    });
    return Object.entries(counts).sort((x, y) => y[1] - x[1])[0]?.[0];
  };
  const stats = [
    { label: t('Total Orders'), value: user.ordersCount ?? orders.length },
    { label: t('Total Spent'), value: `${user.totalOrdersPrice ?? 0} ${t('SAR')}` },
    {
      label: t('Avg Order Value'),
      value: `${orders.length ? (sum((o) => o.totalPay) / orders.length).toFixed(2) : '0.00'} ${t(
        'SAR'
      )}`,
    },
    { label: t('Total Discounts'), value: `${sum((o) => o.discount).toFixed(2)} ${t('SAR')}` },
    { label: t('Add ons Count'), value: user.addOnsCount ?? 0 },
    { label: t('Total Add ons Price'), value: `${user.totalAddOnsPrice ?? 0} ${t('SAR')}` },
    { label: t('Most Used Vehicle'), value: mostCommon((o) => o.vehicle?.brand) || '—' },
    { label: t('Preferred Payment'), value: mostCommon((o) => o.paymentType) || '—' },
  ];

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const orderColumns: ColumnDef<any>[] = [
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorKey: 'createdAt',
      cell: ({ row }) => formatDate(row.original.createdAt),
    },
    {
      id: 'vehicle',
      header: t('Vehicle'),
      accessorFn: (o) => [o.vehicle?.brand, o.vehicle?.model].filter(Boolean).join(' ') || '—',
    },
    {
      id: 'services',
      header: t('Services'),
      accessorFn: (o) => (o.washingServices?.length || 0) + (o.addOns?.length || 0),
    },
    { id: 'paymentType', header: t('paymentType'), accessorFn: (o) => o.paymentType || '—' },
    {
      id: 'totalPay',
      header: t('Amount Paid'),
      accessorFn: (o) => parseFloat(`${o.totalPay}`) || 0,
      cell: ({ row }) => `${row.original.totalPay ?? 0} ${t('SAR')}`,
    },
    {
      id: 'status',
      header: t('status'),
      accessorKey: 'status',
      cell: ({ row }) => <AdminStatus status={row.original.status} />,
    },
  ];

  const filterSelect = (
    value: string,
    onChange: (v: string) => void,
    label: string,
    options: { value: string; label: string }[]
  ) => (
    <Select value={value} onValueChange={onChange}>
      <SelectTrigger className="h-9 w-full sm:w-44" aria-label={label}>
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {options.map((o) => (
          <SelectItem key={o.value} value={o.value}>
            {o.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
  const statuses = [...new Set(orders.map((o) => o.status).filter(Boolean))] as string[];
  const hasFilters =
    !!searchTerm ||
    statusFilter !== 'all' ||
    paymentTypeFilter !== 'all' ||
    dateRangeFilter !== 'all';

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        leading={<MainAvatar src={user.imageLink} name={user.userName} className="h-10 w-10" />}
        title={user.userName || t('userDetails')}
        description={`${t('userId')} ${user.serialNumber ?? ''} · ${user.phone ?? ''}`}
        actions={
          <>
            <span
              className={`rounded-full px-2.5 py-1 text-xs font-semibold ${
                user.isSuspended
                  ? 'bg-destructive/10 text-destructive'
                  : 'bg-success/10 text-success'
              }`}>
              {user.isSuspended ? t('suspended') : t('active')}
            </span>
            <Alert
              id={user._id}
              description={user.isSuspended ? t('unsuspend') : t('suspendUserConfirm')}
              handler={() =>
                handleChangeStatus(user._id, user.isSuspended ? 'unsuspend' : 'suspend')
              }
              buttonComponent={
                <Button
                  variant={user.isSuspended ? 'secondary' : 'dangerOutline'}
                  loading={loading}>
                  {user.isSuspended ? t('unsuspend') : t('suspend')}
                </Button>
              }
            />
          </>
        }
      />

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        {stats.map((s) => (
          <div key={s.label} className="rounded-lg border border-border bg-card px-4 py-3">
            <p className="truncate text-xs font-medium text-muted-foreground">{s.label}</p>
            <p className="mt-1 truncate text-lg font-semibold tabular-nums text-foreground">
              {s.value}
            </p>
          </div>
        ))}
      </div>

      <div className="grid gap-5 xl:grid-cols-3">
        <SectionCard title={t('userInfo')}>
          <InfoList
            className="sm:grid-cols-1"
            items={[
              { label: t('name'), value: user.userName },
              { label: t('phone'), value: user.phone && <span dir="ltr">{user.phone}</span> },
              { label: t('email'), value: user.email },
              {
                label: t('walletBalance'),
                value: `${(user.walletBalance ?? 0).toFixed(2)} ${t('SAR')}`,
              },
              { label: t('createddate'), value: user.createdAt && formatDate(user.createdAt) },
              {
                label: t('plans'),
                value: user.plans?.length ? (
                  <span className="flex flex-wrap gap-1.5">
                    {user.plans.map((p, i) => (
                      <span
                        key={i}
                        className="rounded-full bg-accent px-2.5 py-0.5 text-xs font-medium text-primary">
                        {typeof p.plan?.type === 'string'
                          ? p.plan.type
                          : p.plan?.type?.[lang] || '—'}
                      </span>
                    ))}
                  </span>
                ) : undefined,
              },
            ]}
          />
        </SectionCard>

        <SectionCard
          className="xl:col-span-2"
          title={t('vehicles')}
          action={
            <span className="text-xs text-muted-foreground">{user.vehicles?.length || 0}</span>
          }>
          {user.vehicles?.length ? (
            <ul className="grid gap-3 sm:grid-cols-2">
              {user.vehicles.map((v, i) => (
                <li key={i} className="flex items-center gap-3 rounded-md border border-border p-3">
                  {v.imageLink ? (
                    <ImageModal
                      src={v.imageLink}
                      alt={`${v.brand} ${v.model}`}
                      className="h-12 w-12 shrink-0 rounded-md"
                      fallbackText=""
                    />
                  ) : (
                    <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-md bg-muted text-xs text-muted-foreground">
                      {v.brand?.slice(0, 2)}
                    </span>
                  )}
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium text-foreground">
                      {[v.brand, v.model].filter(Boolean).join(' ')}
                    </p>
                    <p className="truncate text-xs text-muted-foreground">
                      <span className="font-mono">{v.plateNumber}</span>
                      {v.color ? ` · ${v.color}` : ''}
                    </p>
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-[13px] text-muted-foreground">{t('noVehicles')}</p>
          )}
        </SectionCard>
      </div>

      <SectionCard
        title={t('orders')}
        action={
          <span className="text-xs text-muted-foreground">
            {filteredOrders.length} / {orders.length}
          </span>
        }>
        <div className="mb-3 flex flex-wrap items-center gap-2">
          <Input
            type="search"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder={t('search')}
            aria-label={t('search')}
            className="h-9 w-full sm:w-64"
          />
          {filterSelect(statusFilter, setStatusFilter, t('status'), [
            { value: 'all', label: t('allStatuses') },
            ...statuses.map((s) => ({ value: s, label: t(s) })),
          ])}
          {filterSelect(paymentTypeFilter, setPaymentTypeFilter, t('paymentType'), [
            { value: 'all', label: t('allPayments') },
            ...uniquePaymentTypes.map((p) => ({ value: p as string, label: t(p as string) })),
          ])}
          {filterSelect(dateRangeFilter, setDateRangeFilter, t('date'), [
            { value: 'all', label: t('anyTime') },
            { value: 'today', label: t('today') },
            { value: 'week', label: t('last7Days') },
            { value: 'month', label: t('last30Days') },
            { value: 'year', label: t('lastYear') },
          ])}
          {hasFilters && (
            <Button
              variant="tertiary"
              size="sm"
              onClick={() => {
                setSearchTerm('');
                setStatusFilter('all');
                setPaymentTypeFilter('all');
                setDateRangeFilter('all');
              }}>
              {t('Clear Filters')}
            </Button>
          )}
        </div>
        <DataTable
          columns={orderColumns}
          data={filteredOrders}
          showColumnToggle={false}
          onRowClick={(o) => navigate(ROUTES.ORDER_DETAILS.replace(':orderId', o._id))}
          emptyStateComponent={
            <p className="text-[13px] text-muted-foreground">
              {orders.length ? t('No orders match your filters') : t('No orders found')}
            </p>
          }
        />
      </SectionCard>
    </div>
  );
}
