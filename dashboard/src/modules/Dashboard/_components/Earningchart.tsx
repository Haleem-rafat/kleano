'use client';

import { CartesianGrid, Line, LineChart, XAxis } from 'recharts';
import { useTranslation } from 'react-i18next';
import { HiCurrencyDollar } from 'react-icons/hi2';

import useSWR from 'swr';
import staticService from '@services/static.service';
import {
  ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/shadecn/components/ui/chart';

const chartConfig = {
  totalEarnings: {
    label: 'Total Earnings',
    color: 'hsl(var(--chart-1))',
  },
  totalOrders: {
    label: 'Total Orders',
    color: 'hsl(var(--chart-2))',
  },
} satisfies ChartConfig;

export function Earningchart() {
  const { t } = useTranslation();

  // Fetch revenue data for the month
  const { data, isLoading } = useSWR('get-revenue-month', () =>
    staticService.getRevenueMonth().then((data) => {
      return data;
    })
  );

  // If month is a number, format it as a string (e.g., 'January', 'February')
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  const chartData = data
    ? data.data.map((item, index) => ({
        month: monthNames[index],
        totalEarnings: item.totalEarnings,
        totalOrders: item.totalOrders,
      }))
    : [];

  return (
    <div className="h-full">
      <div className="mb-4 flex items-center justify-between">
        <div className="rounded-lg border border-slate-200 bg-brandTint p-4">
          <h4 className="mb-2 text-sm font-semibold text-primary">Total Revenue</h4>
          <p className="text-lg font-bold text-primary">{data?.yearTotalRevenue || 0}</p>
        </div>
      </div>

      <ChartContainer config={chartConfig} className="h-[300px] w-full">
        <LineChart
          accessibilityLayer
          data={chartData}
          margin={{
            left: 12,
            right: 12,
          }}>
          {/* Defining the gradient for the line stroke */}
          <defs>
            <linearGradient id="lineGradient" x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stopColor="#543063" />
              <stop offset="100%" stopColor="#8D5BA5" />
            </linearGradient>
          </defs>

          <CartesianGrid vertical={false} strokeDasharray="3 3" className="stroke-slate-200" />
          <XAxis
            dataKey="month"
            tickLine={false}
            axisLine={false}
            tickMargin={8}
            tickFormatter={(value) => value.slice(0, 3)}
            className="text-xs text-slate-500"
          />
          <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />

          {/* Line with gradient stroke and drop shadow */}
          <Line
            dataKey="totalEarnings"
            type="natural"
            stroke="url(#lineGradient)"
            strokeWidth={3}
            dot={{
              fill: '#ffffff',
              stroke: '#543063',
              strokeWidth: 2,
              r: 5,
            }}
            activeDot={{
              r: 6,
              fill: '#543063',
              stroke: '#ffffff',
              strokeWidth: 2,
            }}
            style={{
              filter: 'drop-shadow(0px 2px 4px rgba(16, 185, 129, 0.2))',
            }}
          />
        </LineChart>
      </ChartContainer>
    </div>
  );
}
