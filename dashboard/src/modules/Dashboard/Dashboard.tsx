import { useTranslation } from 'react-i18next';
import { ThreeDotsLoader } from '@UI/Index';
import useSWR from 'swr';
import promoCodeService from '@services/promoCode.service';
import ordersService from '@services/orders.service';
import usersService from '@services/users.service';
import bikersService from '@services/bikers.service';
import plansService from '@services/plans.service';
import { IPlan } from '@servicesTypes/plan.types';
import DashboardCard from './_components/DashboardCard';
import { Earningchart } from './_components/Earningchart';
import { WeeklyRevenueChart } from './_components/WeeklyRevenueChart';
import bikers_icon from '@/assets/icons/total-bikers-icon.svg';
import orders_icon from '@/assets/icons/total-orders-icons.svg';
import promo_icon from '@/assets/icons/total-promo-code-icon.svg';
import users_icon from '@/assets/icons/total-users-icon.svg';

export default function Dashboard() {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data: ordersListData, isLoading: ordersListLoading } = useSWR(
    ['get-all-order-list'],
    () => ordersService.getAllOrders({ page: 1, perPage: 10 })
  );

  const { data: promoCodesData, isLoading: promoCodesLoading } = useSWR(
    ['get-all-promo-codes'],
    () =>
      promoCodeService.getAllPromoCode({
        isGraphView: false,
        totalItems: 0,
      })
  );

  const { data: usersData, isLoading: usersisLoading } = useSWR(['get-all-users-list'], () =>
    usersService.getUsersList().then((data) => data)
  );

  const { data: bikersData, isLoading: bikersIsLoading } = useSWR(['get-all-bikers-list'], () =>
    bikersService.getAllBikers({}).then((data) => data)
  );

  const dashboardData = [
    {
      title: 'totalOrders',
      count: ordersListData?.pagination?.totalItems,
      icon: orders_icon,
      theme: 'green' as const,
    },
    {
      title: 'totalPromoCodes',
      count: promoCodesData?.data?.paginationData?.totalItems,
      icon: promo_icon,
      theme: 'purple' as const,
    },
    {
      title: 'totalBikers',
      count: bikersData?.data.length,
      icon: bikers_icon,
      theme: 'indigo' as const,
    },
    {
      title: 'totalUsers',
      count: usersData?.data.length,
      icon: users_icon,
      theme: 'blue' as const,
    },
  ];

  const { data, isLoading } = useSWR(['get-all-plans-list'], () =>
    plansService.getAllPlansList().then((data) => data?.data as IPlan[])
  );
  if (isLoading || !data) return <ThreeDotsLoader />;
  const maxUsage = Math.max(...data.map((plan) => plan?.usageCount || 0), 1);

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-xl font-semibold capitalize tracking-tight text-slate-900">
          {t('dashboard')}
        </h1>
        <p className="mt-0.5 text-[13px] text-slate-500">
          Overview of your business metrics and performance
        </p>
      </header>

      {ordersListLoading && promoCodesLoading && usersisLoading && bikersIsLoading && (
        <ThreeDotsLoader />
      )}

      <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {dashboardData.map((card, index) => (
          <DashboardCard
            key={index}
            title={t(card.title)}
            count={card.count}
            icon={card.icon}
            theme={card.theme}
          />
        ))}
      </section>

      <section className="grid grid-cols-1 gap-4 xl:grid-cols-12">
        <div className="rounded-xl border border-slate-200 bg-white p-5 xl:col-span-7">
          <h2 className="mb-4 text-sm font-semibold text-slate-900">Weekly revenue</h2>
          <WeeklyRevenueChart />
        </div>
        <div className="rounded-xl border border-slate-200 bg-white p-5 xl:col-span-5">
          <h2 className="mb-4 text-sm font-semibold text-slate-900">Revenue this year</h2>
          <Earningchart />
        </div>
      </section>

      {data.length > 0 && (
        <section className="rounded-xl border border-slate-200 bg-white p-5">
          <h2 className="mb-4 text-sm font-semibold text-slate-900">Plan usage</h2>
          <ul className="space-y-3">
            {data.map((plan, index) => {
              const name = typeof plan?.type === 'string' ? plan?.type : plan?.type[lang];
              const usage = plan?.usageCount || 0;
              return (
                <li key={index} className="grid grid-cols-[140px_1fr_48px] items-center gap-3">
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
        </section>
      )}
    </div>
  );
}
