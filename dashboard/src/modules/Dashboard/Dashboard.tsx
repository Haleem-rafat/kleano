import { generatePath, Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useSWR from 'swr';
import {
  ClipboardDocumentListIcon,
  TicketIcon,
  TruckIcon,
  UsersIcon,
} from '@heroicons/react/24/outline';
import promoCodeService from '@services/promoCode.service';
import ordersService from '@services/orders.service';
import usersService from '@services/users.service';
import bikersService from '@services/bikers.service';
import plansService from '@services/plans.service';
import { IPlan } from '@servicesTypes/plan.types';
import { ROUTES } from '@constants/routes';
import { IOrderList } from '@servicesTypes/order.types';
import { AdminStatus } from '@UI/Index';
import DashboardCard from './_components/DashboardCard';
import { Earningchart } from './_components/Earningchart';
import { WeeklyRevenueChart } from './_components/WeeklyRevenueChart';

const iconClass = 'h-5 w-5';
const panel = 'rounded-xl border border-slate-200 bg-white p-5';

export default function Dashboard() {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data: orders } = useSWR(['get-all-order-list'], () =>
    ordersService.getAllOrders({ page: 1, perPage: 6 })
  );
  const { data: promoCodes } = useSWR(['get-all-promo-codes'], () =>
    promoCodeService.getAllPromoCode({ isGraphView: false, totalItems: 0 })
  );
  const { data: users } = useSWR(['get-all-users-list'], () => usersService.getUsersList());
  const { data: bikers } = useSWR(['get-all-bikers-list'], () => bikersService.getAllBikers({}));
  const { data: plans } = useSWR(['get-all-plans-list'], () =>
    plansService.getAllPlansList().then((response) => response?.data as IPlan[])
  );

  const maxUsage = Math.max(...(plans ?? []).map((plan) => plan?.usageCount || 0), 1);
  const recentOrders = (orders?.data ?? []) as IOrderList[];

  return (
    <div className="space-y-5">
      <header>
        <h1 className="text-xl font-semibold capitalize tracking-tight text-slate-900">
          {t('dashboard')}
        </h1>
        <p className="mt-0.5 text-[13px] text-slate-500">{t('dashboardSubtitle')}</p>
      </header>

      <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <DashboardCard
          title={t('totalOrders')}
          count={orders?.pagination?.totalItems}
          icon={<ClipboardDocumentListIcon className={iconClass} />}
          to={ROUTES.ORDER}
        />
        <DashboardCard
          title={t('totalUsers')}
          count={users?.pagination?.totalItems ?? users?.data?.length}
          icon={<UsersIcon className={iconClass} />}
          to={ROUTES.USERS}
        />
        <DashboardCard
          title={t('totalBikers')}
          count={bikers?.data?.length}
          icon={<TruckIcon className={iconClass} />}
          to={ROUTES.BIKERS}
        />
        <DashboardCard
          title={t('totalPromoCodes')}
          count={promoCodes?.data?.paginationData?.totalItems}
          icon={<TicketIcon className={iconClass} />}
          to={ROUTES.PROMO_CODE}
        />
      </section>

      <section className="grid grid-cols-1 gap-4 xl:grid-cols-12">
        <div className={`${panel} min-w-0 xl:col-span-7`}>
          <h2 className="mb-4 text-sm font-semibold text-slate-900">{t('weeklyRevenue')}</h2>
          <WeeklyRevenueChart />
        </div>
        <div className={`${panel} min-w-0 xl:col-span-5`}>
          <h2 className="mb-4 text-sm font-semibold text-slate-900">{t('yearRevenue')}</h2>
          <Earningchart />
        </div>
      </section>

      <section className="grid grid-cols-1 gap-4 xl:grid-cols-12">
        <div className={`${panel} min-w-0 xl:col-span-7`}>
          <div className="mb-3 flex items-center justify-between gap-3">
            <h2 className="text-sm font-semibold text-slate-900">{t('recentOrders')}</h2>
            <Link to={ROUTES.ORDER} className="text-[13px] font-medium text-primary hover:underline">
              {t('viewAll')}
            </Link>
          </div>
          {orders && recentOrders.length === 0 && (
            <p className="py-8 text-center text-[13px] text-slate-500">{t('noOrdersYet')}</p>
          )}
          <ul className="divide-y divide-slate-100">
            {recentOrders.map((order) => (
              <li key={order._id}>
                <Link
                  to={generatePath(ROUTES.ORDER_DETAILS, { orderId: order._id })}
                  className="-mx-2 flex items-center justify-between gap-3 rounded-lg px-2 py-2.5 hover:bg-slate-50">
                  <span className="min-w-0">
                    <span className="block truncate text-[13px] font-medium text-slate-900">
                      {order.user?.userName || '—'}
                    </span>
                    <span className="block truncate text-xs text-slate-500">
                      {[order.vehicle?.brand, order.vehicle?.model].filter(Boolean).join(' ') ||
                        order.location?.streetName}
                    </span>
                  </span>
                  <AdminStatus status={order.status} />
                </Link>
              </li>
            ))}
          </ul>
        </div>
        <div className={`${panel} min-w-0 xl:col-span-5`}>
          <h2 className="mb-4 text-sm font-semibold text-slate-900">{t('planUsage')}</h2>
          <ul className="space-y-3">
            {(plans ?? []).map((plan) => {
              const name = typeof plan?.type === 'string' ? plan.type : plan?.type?.[lang];
              const usage = plan?.usageCount || 0;
              return (
                <li key={plan._id} className="grid grid-cols-[110px_1fr_40px] items-center gap-3">
                  <span className="truncate text-[13px] text-slate-700">{name}</span>
                  <span className="h-2 overflow-hidden rounded-full bg-slate-100">
                    <span
                      className="block h-full rounded-full bg-primary"
                      style={{ width: `${(usage / maxUsage) * 100}%` }}
                    />
                  </span>
                  <span className="text-end text-[13px] font-medium tabular-nums text-slate-900">
                    {usage}
                  </span>
                </li>
              );
            })}
          </ul>
        </div>
      </section>
    </div>
  );
}
