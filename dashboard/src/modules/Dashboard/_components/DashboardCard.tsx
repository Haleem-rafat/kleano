import { HiCurrencyDollar } from 'react-icons/hi2';
import { IoMdTrendingUp } from 'react-icons/io';
import { Card, CardContent } from '@shadecn/components/ui/card';

interface IDashboardCardProps {
  title: string;
  count: number;
  icon?: string;
  trend?: number;
  trendDirection?: 'up' | 'down';
  trendText?: string;
  isPromo?: boolean;
  color?: string;
  theme?: 'blue' | 'purple' | 'green' | 'emerald' | 'orange' | 'indigo' | 'default';
}

const DashboardCard = ({
  title,
  count,
  icon,
  trend,
  trendDirection,
  trendText,
  isPromo,
  color,
  theme = 'default',
}: IDashboardCardProps) => {
  // Theme color mappings
  // One calm look for every metric, matching the apps. `theme` stays for callers.
  const neutral = {
    bg: 'bg-white',
    border: 'border-slate-200',
    iconBg: 'bg-brandTint',
    iconColor: 'text-primary',
    titleColor: 'text-slate-500',
    valueColor: 'text-slate-900',
  };
  const themeColors: Record<string, typeof neutral> = new Proxy(
    {},
    { get: () => neutral }
  );

  const colors = themeColors[theme];

  return (
    <Card
      className={`overflow-hidden rounded-xl border ${colors.border} ${
        colors.bg
      } shadow-sm transition-all duration-200 hover:shadow-md hover:${colors.border.replace(
        '200',
        '300'
      )}`}>
      <CardContent className="p-6">
        <div className="flex items-center justify-between">
          <div>
            <h4 className={`mb-2 text-sm font-semibold ${colors.titleColor}`}>{title}</h4>
            <p className={`text-2xl font-bold ${colors.valueColor}`}>{count || 0}</p>
          </div>
          {isPromo ? (
            <div
              style={{ backgroundColor: `${color || '#533063'}20` }}
              className="flex h-12 w-12 items-center justify-center rounded-full">
              <HiCurrencyDollar style={{ color: color || '#533063' }} className="h-6 w-6" />
            </div>
          ) : (
            <div
              className={`flex h-12 w-12 items-center justify-center rounded-full ${colors.iconBg}`}>
              <img src={icon} alt={`${title}`} className="h-6 w-6" />
            </div>
          )}
        </div>
        {trend !== undefined && (
          <div className="mt-4 flex items-center gap-2">
            <div
              className={`flex items-center gap-1 ${
                trendDirection === 'up' ? 'text-green-600' : 'text-red-600'
              }`}>
              <IoMdTrendingUp
                className={`h-4 w-4 ${trendDirection === 'down' ? 'rotate-180' : ''}`}
              />
              <span className="text-sm font-medium">{trend}%</span>
            </div>
            {trendText && <span className="text-sm text-slate-500">{trendText}</span>}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default DashboardCard;
