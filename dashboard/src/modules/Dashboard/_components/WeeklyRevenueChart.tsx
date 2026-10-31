import { Bar, BarChart, CartesianGrid, LabelList, XAxis } from 'recharts';
import { useTranslation } from 'react-i18next';
import { IoBarChartOutline } from 'react-icons/io5';

import useSWR from 'swr';
import staticService from '@services/static.service';
import { ThreeDotsLoader } from '@UI/Index';
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
} satisfies ChartConfig;

export function WeeklyRevenueChart() {
  const { t } = useTranslation();

  // Fetch revenue data for the week
  const { data, isLoading } = useSWR('get-revenue-week', () =>
    staticService.getRevenueWeek().then((data) => data.data)
  );

  const weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  const chartData = data
    ? weekDays.map((day, index) => {
        const dayData = data.find((item) => item.day === index + 1);
        return {
          week: day,
          totalEarnings: dayData ? dayData.totalEarnings : 0,
        };
      })
    : [];

  return (
    <div className="h-full">
      {isLoading && <ThreeDotsLoader />}

      <ChartContainer config={chartConfig} className="h-[300px] w-full">
        <BarChart
          accessibilityLayer
          data={chartData}
          margin={{
            top: 20,
          }}>
          <defs>
            <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#543063" />
              <stop offset="100%" stopColor="#8D5BA5" />
            </linearGradient>
          </defs>
          <CartesianGrid vertical={false} strokeDasharray="3 3" className="stroke-slate-200" />
          <XAxis
            dataKey="week"
            tickLine={false}
            tickMargin={10}
            axisLine={false}
            tickFormatter={(value) => value.slice(0, 3)}
            className="text-xs text-slate-500"
          />
          <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />
          <Bar dataKey="totalEarnings" fill="url(#barGradient)" radius={[8, 8, 0, 0]} barSize={24}>
            <LabelList
              position="top"
              offset={8}
              className="fill-slate-600 text-xs font-medium"
              fontSize={12}
            />
          </Bar>
        </BarChart>
      </ChartContainer>
    </div>
  );
}
