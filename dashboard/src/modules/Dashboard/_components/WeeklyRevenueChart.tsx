import { Bar, BarChart, CartesianGrid, LabelList, XAxis } from 'recharts';
import { useTranslation } from 'react-i18next';

import useSWR from 'swr';
import staticService from '@services/static.service';
import { Skeleton } from '@UI/Index';
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
      {isLoading ? (
        <div className="flex h-[300px] items-end gap-3 px-2 pb-2">
          {[45, 70, 35, 85, 55, 65, 40].map((h, i) => (
            <Skeleton key={i} className="flex-1 rounded-b-none" style={{ height: `${h}%` }} />
          ))}
        </div>
      ) : (
        <ChartContainer config={chartConfig} className="h-[300px] w-full">
          <BarChart
            accessibilityLayer
            data={chartData}
            margin={{
              top: 20,
            }}>
            <defs>
              <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="hsl(var(--primary))" />
                <stop offset="100%" stopColor="hsl(var(--primary))" />
              </linearGradient>
            </defs>
            <CartesianGrid vertical={false} strokeDasharray="3 3" className="stroke-border" />
            <XAxis
              dataKey="week"
              tickLine={false}
              tickMargin={10}
              axisLine={false}
              tickFormatter={(value) => value.slice(0, 3)}
              className="text-xs text-muted-foreground"
            />
            <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />
            <Bar
              dataKey="totalEarnings"
              fill="url(#barGradient)"
              radius={[8, 8, 0, 0]}
              barSize={24}>
              <LabelList
                position="top"
                offset={8}
                className="fill-muted-foreground text-xs font-medium"
                fontSize={12}
              />
            </Bar>
          </BarChart>
        </ChartContainer>
      )}
    </div>
  );
}
