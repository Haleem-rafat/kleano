'use client';

import { CartesianGrid, Line, LineChart, XAxis } from 'recharts';
import { useTranslation } from 'react-i18next';

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
        <div>
          <h4 className="text-xs font-medium text-muted-foreground">{t('Total Revenue')}</h4>
          <p className="text-2xl font-semibold tracking-tight text-foreground">
            {data?.yearTotalRevenue || 0}
          </p>
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
              <stop offset="0%" stopColor="hsl(var(--primary))" />
              <stop offset="100%" stopColor="hsl(var(--secondary))" />
            </linearGradient>
          </defs>

          <CartesianGrid vertical={false} strokeDasharray="3 3" className="stroke-border" />
          <XAxis
            dataKey="month"
            tickLine={false}
            axisLine={false}
            tickMargin={8}
            tickFormatter={(value) => value.slice(0, 3)}
            className="text-xs text-muted-foreground"
          />
          <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />

          {/* Line with gradient stroke and drop shadow */}
          <Line
            dataKey="totalEarnings"
            type="monotone"
            stroke="url(#lineGradient)"
            strokeWidth={3}
            dot={{
              fill: 'hsl(var(--card))',
              stroke: 'hsl(var(--primary))',
              strokeWidth: 2,
              r: 5,
            }}
            activeDot={{
              r: 6,
              fill: 'hsl(var(--primary))',
              stroke: 'hsl(var(--card))',
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
