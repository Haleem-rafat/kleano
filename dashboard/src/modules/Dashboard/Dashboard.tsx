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
  return (
    <div className="min-h-screen bg-background">
      {/* Professional Header */}
      <div className="border-b border-slate-200 bg-white shadow-sm">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-semibold text-slate-900">{t('dashboard')}</h1>
              <p className="mt-1 text-sm text-slate-500">
                Overview of your business metrics and performance
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6">
        <div>
          {ordersListLoading && promoCodesLoading && usersisLoading && bikersIsLoading && (
            <ThreeDotsLoader />
          )}

          {/* Statistics Cards Section */}
          <div className="mb-8">
            <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
              {/* Section Header */}
              <div className="border-b border-slate-200 bg-white px-6 py-4">
                <div className="flex items-center space-x-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-brandTint">
                    <svg
                      className="h-6 w-6 text-primary"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor">
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                      />
                    </svg>
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-slate-900">Key Metrics</h2>
                    <p className="text-sm text-slate-500">
                      Essential business statistics at a glance
                    </p>
                  </div>
                </div>
              </div>

              {/* Section Content */}
              <div className="p-6">
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
                  {dashboardData.map((card, index) => (
                    <DashboardCard
                      key={index}
                      title={t(card.title)}
                      count={card.count}
                      icon={card.icon}
                      theme={card.theme}
                    />
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Charts Section */}
          <div className="mb-8">
            <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
              {/* Section Header */}
              <div className="border-b border-slate-200 bg-white px-6 py-4">
                <div className="flex items-center space-x-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-brandTint">
                    <svg
                      className="h-6 w-6 text-primary"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor">
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
                      />
                    </svg>
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-slate-900">Revenue Analytics</h2>
                    <p className="text-sm text-slate-500">
                      Track your financial performance over time
                    </p>
                  </div>
                </div>
              </div>

              {/* Section Content */}
              <div className="p-6">
                <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
                  <WeeklyRevenueChart />
                  <Earningchart />
                </div>
              </div>
            </div>
          </div>

          {/* Plans Usage Section */}
          {data && data.length > 0 && (
            <div className="mb-8">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
                {/* Section Header */}
                <div className="border-b border-slate-200 bg-white px-6 py-4">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-brandTint">
                      <svg
                        className="h-6 w-6 text-primary"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                        />
                      </svg>
                    </div>
                    <div>
                      <h2 className="text-lg font-semibold text-slate-900">Plan Usage Statistics</h2>
                      <p className="text-sm text-slate-500">
                        Monitor subscription plan utilization
                      </p>
                    </div>
                  </div>
                </div>

                {/* Section Content */}
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                    {data
                      ?.map((e, index) => ({
                        title: typeof e?.type === 'string' ? e?.type : e?.type[lang],

                        count: e?.usageCount,
                        color: e?.color,
                        theme: ['orange', 'emerald', 'purple'][index % 3] as
                          | 'green'
                          | 'purple'
                          | 'indigo'
                          | 'blue'
                          | 'default'
                          | 'orange'
                          | 'emerald',
                      }))
                      ?.map((card, index) => (
                        <DashboardCard
                          key={index}
                          title={t(card.title)}
                          count={card.count}
                          color={card.color}
                          theme={card.theme}
                          isPromo
                        />
                      ))}
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
