import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Bar, BarChart, XAxis, YAxis, Tooltip } from 'recharts';
import { ChartConfig, ChartContainer } from '@/shadecn/components/ui/chart';

// Utility function for chart type color
const getTypeColor = (type: string) => {
  const gradients = {
    allUsers: 'url(#allUsersGradient)',
    'segment-promo-code': 'url(#segmentPromoCodeGradient)',
    newComers: 'url(#newComersGradient)',
    aggregator: 'url(#aggregatorGradient)',
  };
  return gradients[type] || 'url(#defaultGradient)';
};

// Utility function for calculating chart pagination pages
const calculatePages = (arrayLength: number) => Math.ceil(arrayLength / 10);

// Utility function for slicing chart data
const sliceDataArray = (array: any[], page: number) => {
  const sliceStart = (page - 1) * 10;
  const sliceEnd = page * 10;
  return array.slice(sliceStart, sliceEnd);
};

// Component for rendering Y Axis ticks
const CustomYAxisTick = ({ x, y, payload, chartConfig }: any) => {
  const label = chartConfig[payload.value]?.label;
  return (
    <g transform={`translate(${x},${y})`}>
      <text x={0} y={0} dy={16} textAnchor="end" fill="#666" style={{ whiteSpace: 'nowrap' }}>
        {label}
      </text>
    </g>
  );
};

// Custom Tooltip content to display appliedCount and targetAudience
const CustomTooltipContent = ({ active, payload }: any) => {
  if (active && payload && payload.length) {
    const { appliedCount, targetAudience } = payload[0].payload;
    return (
      <div className="rounded-md border border-primary bg-white p-2 shadow-md">
        <p>
          Type: <span className="font-bold text-primary">{targetAudience}</span>
        </p>
        <p>
          Applied Count: <span className="font-bold text-primary">{appliedCount}</span>
        </p>
      </div>
    );
  }

  return null;
};

// Main ChartView component
export function ChartView({ data }: { data: any }) {
  const { t } = useTranslation();

  const [pageIndex, setPageIndex] = useState(1);
  const [chartDataArray, setChartDataArray] = useState<any[]>([]);
  const [slicedChartArray, setSlicedChartArray] = useState<any[]>([]);

  // Memoize chart configuration based on data
  const chartConfig = useMemo<ChartConfig>(() => {
    const config: ChartConfig = {
      appliedCount: { label: t('appliedCount') },
    };
    chartDataArray.forEach((item) => {
      config[item.code] = {
        label: item.code,
        color: item.fill,
      };
    });
    return config;
  }, [chartDataArray, t]);

  // Set chart data when `data` prop changes
  useEffect(() => {
    if (data) {
      const chartData = data.data.map((e: any) => ({
        code: e.code,
        targetAudience: e.targetAudience,
        appliedCount: e.appliedCount,
        fill: getTypeColor(e.targetAudience),
      }));
      setChartDataArray(chartData);
    }
  }, [data]);

  // Slice chart data whenever pageIndex or chartDataArray changes
  useEffect(() => {
    setSlicedChartArray(sliceDataArray(chartDataArray, pageIndex));
  }, [pageIndex, chartDataArray]);

  const totalPages = useMemo(() => calculatePages(chartDataArray.length), [chartDataArray.length]);

  const dynamicBarSize = chartDataArray.length > 10 ? 20 : 30;

  return (
    <>
      <div dir="ltr" className="overflow-auto rounded-lg p-4 shadow">
        <ChartContainer config={chartConfig} className="mx-auto h-[500px] w-[90%]">
          <BarChart
            barSize={dynamicBarSize}
            data={slicedChartArray}
            layout="vertical"
            margin={{ left: 60 }}>
            <defs>
              <linearGradient id="allUsersGradient" x1="0" x2="1" y1="0" y2="0">
                <stop offset="0%" stopColor="#533063" />
                <stop offset="100%" stopColor="#7a5094" />
              </linearGradient>
              <linearGradient id="segmentPromoCodeGradient" x1="0" x2="1" y1="0" y2="0">
                <stop offset="0%" stopColor="#b48ac6" />
                <stop offset="100%" stopColor="#d6b2e1" />
              </linearGradient>
              <linearGradient id="newComersGradient" x1="0" x2="1" y1="0" y2="0">
                <stop offset="0%" stopColor="#844d9e" />
                <stop offset="100%" stopColor="#a870b9" />
              </linearGradient>
              <linearGradient id="aggregatorGradient" x1="0" x2="1" y1="0" y2="0">
                <stop offset="0%" stopColor="#a26fb9" />
                <stop offset="100%" stopColor="#c593d3" />
              </linearGradient>
              <linearGradient id="defaultGradient" x1="0" x2="1" y1="0" y2="0">
                <stop offset="0%" stopColor="#281730" />
                <stop offset="100%" stopColor="#402a4b" />
              </linearGradient>

              {/* Shadow effect */}
              <filter id="shadow" x="-10%" y="-10%" width="130%" height="130%">
                <feDropShadow dx="3" dy="3" stdDeviation="3" floodColor="#888" />
              </filter>
            </defs>
            <YAxis
              dataKey="code"
              type="category"
              tick={(props) => <CustomYAxisTick {...props} chartConfig={chartConfig} />}
              interval={0}
            />
            <XAxis dataKey="appliedCount" type="number" />
            <Tooltip content={<CustomTooltipContent />} cursor={false} />
            <Bar dataKey="appliedCount" layout="vertical" radius={[0, 10, 10, 0]} />
          </BarChart>
        </ChartContainer>
      </div>
      <PaginationComponent
        isChart
        page={pageIndex}
        pages={totalPages}
        setPageIndex={setPageIndex}
      />
    </>
  );
}
