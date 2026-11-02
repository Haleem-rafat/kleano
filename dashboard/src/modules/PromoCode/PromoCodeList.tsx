import promoCodeService from '@services/promoCode.service';
import { Combobox } from '@UI/comboBox/ComboBox';
import { DatePickerWithPresets } from '@UI/datePickerComponent/DatePicker';
import { Button, DataTable, EmtyState, PageHeader, FormSheet } from '@UI/Index';
import { ColumnDef } from '@tanstack/react-table';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router-dom';
import useSWR from 'swr';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@shadecn/components/ui/select';

import { formatDate } from '@app/utils/helper';

import { Tabs, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import { FaThList } from 'react-icons/fa';

import { BsBarChartLineFill } from 'react-icons/bs';
import { Input } from '@shadecn/components/ui/input';
import { ChartView } from './_Components/ChartView';

import PromoCodeModelForm from './_Components/PromoCodeModelForm';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';

import useGetSegmentsOptions from '@/hooks/useGetSegmentsOptions';

const statusOptions = [
  { label: 'Active', value: 'ACTIVE' },
  { label: 'Expired', value: 'EXPIRED' },
  { label: 'DISABLED', value: 'DISABLED' },
];

const PromoCodeList = () => {
  const { t } = useTranslation();
  // const inputRef = useRef<HTMLInputElement>(null);

  const tabs = [
    { label: t('allType'), searchParam: '' },
    { label: t('users'), searchParam: 'allUsers' },
    { label: t('segments'), searchParam: 'segment' },
    { label: t('newComers'), searchParam: 'newComers' },
    { label: t('aggregator'), searchParam: 'aggregator' },
    { label: t('offline'), searchParam: 'offline' },
    { label: t('B2B'), searchParam: 'b2b' },
  ];
  const { citiesOptions } = useGetCitiesOptions();
  const { segmentsOptions } = useGetSegmentsOptions();

  const [searchParams, setSearchParams] = useSearchParams();
  const initialTargetAudience = searchParams.get('targetAudience') || '';
  const [isChart, setIschart] = useState(false);
  const [openSheet, setOpenSheet] = useState(false);
  const [pageIndex, setPageIndex] = useState(1);
  const [dateObj, setDateObj] = useState({ from: '', to: '' });
  const [activeAudience, setActiveAudience] = useState(() => {
    const foundTab = tabs.find((tab) => tab.searchParam === initialTargetAudience);
    return foundTab ? foundTab : tabs[0]; // Default to the first tab if none match
  });
  const [business, setBusiness] = useState('');
  const { data, isLoading, mutate } = useSWR(
    ['get-all-promo-codes', pageIndex, activeAudience, dateObj, status, searchParams, isChart],
    () =>
      searchParams &&
      promoCodeService.getAllPromoCode({
        status: searchParams.get('status') ?? 'ACTIVE',
        page: pageIndex.toString(),
        targetAudience: activeAudience.searchParam ?? undefined,
        fromDate: dateObj.from ?? undefined,
        toDate: dateObj.to ?? undefined,
        perPage: '10',
        city: searchParams.get('city') ?? undefined,
        segment: searchParams.get('segment') ?? undefined,
        isGraphView: isChart,
        totalItems: 0,
        business: activeAudience.searchParam === 'b2b' && business ? business : undefined,
      })
  );

  const handleTabChange = (tab) => {
    const newParams = new URLSearchParams(searchParams);
    if (tab.searchParam) {
      newParams.set('targetAudience', tab.searchParam);
    } else {
      newParams.delete('targetAudience');
    }
    setSearchParams(newParams);
    setActiveAudience(tab);
    mutate();
  };

  // const handleEdit = async (id) => {
  //   if (inputRef.current) {
  //     await promoCodeService
  //       .editPromoCodeName(inputRef.current.value, id)
  //       .then((data) => {
  //         mutate();
  //       })
  //       .catch((e) => {
  //         console.log(e);
  //       });
  //   }
  // };
  const handleStatus = async (id: string, status: 'activate' | 'disable') => {
    await promoCodeService
      .editPromoCodeStatus(status, id)
      .then(() => {
        mutate();
      })
      .catch((e) => {
        console.log(e);
      });
  };
  useEffect(() => {
    const targetAudienceParam = searchParams.get('targetAudience') || '';
    const foundTab = tabs?.find((tab) => tab?.searchParam === targetAudienceParam);
    if (foundTab && foundTab?.searchParam !== activeAudience?.searchParam) {
      setActiveAudience(foundTab);
    }
  }, [searchParams, activeAudience]);

  const isB2b = searchParams.get('targetAudience') === 'b2b';
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const columns: ColumnDef<any>[] = [
    {
      id: 'code',
      header: t('promoCodeName'),
      accessorKey: 'code',
      cell: ({ row }) => <span className="font-medium text-foreground">{row.original.code}</span>,
    },
    isB2b
      ? { id: 'business', header: t('business'), accessorFn: (p) => p.business || '—' }
      : {
          id: 'discountPercentage',
          header: t('discountPercentage'),
          accessorKey: 'discountPercentage',
          cell: ({ row }) => `${row.original.discountPercentage}%`,
        },
    { id: 'numberOfUses', header: t('numberOfUses'), accessorKey: 'numberOfUses' },
    { id: 'appliedCount', header: t('appliedCount'), accessorKey: 'appliedCount' },
    { id: 'targetAudience', header: t('targetAudience'), accessorKey: 'targetAudience' },
    {
      id: 'createdAt',
      header: t('createddate'),
      accessorKey: 'createdAt',
      cell: ({ row }) => formatDate(row.original.createdAt),
    },
    {
      id: 'expiryDate',
      header: t('expiredDate'),
      accessorKey: 'expiryDate',
      cell: ({ row }) => formatDate(row.original.expiryDate),
    },
    {
      id: 'status',
      header: t('status'),
      accessorKey: 'status',
      cell: ({ row }) => {
        const promoCode = row.original;
        if (promoCode.status === 'EXPIRED') return <MainStatusChipe status="EXPIRED" />;
        return (
          <Select
            value={promoCode.status === 'ACTIVE' ? 'activate' : 'disable'}
            onValueChange={(value: 'activate' | 'disable') => handleStatus(promoCode._id, value)}>
            <SelectTrigger className="h-8 w-36 bg-transparent" aria-label={t('status')}>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectGroup>
                {['activate', 'disable'].map((item) => (
                  <SelectItem value={item} key={item}>
                    <MainStatusChipe status={item} />
                  </SelectItem>
                ))}
              </SelectGroup>
            </SelectContent>
          </Select>
        );
      },
    },
  ];

  return (
    <div className="relative flex h-full w-full flex-col gap-3">
      <div className="pb-2">
        <PageHeader
          title={t('promoCode')}
          actions={<Button onClick={() => setOpenSheet(true)}>{t('addNewPromoCode')}</Button>}
        />
      </div>
      <div className="flex w-full flex-col gap-3 rounded-lg border border-border bg-card p-4">
        <div className="flex w-full items-center gap-3">
          {/* Tabs scroll inside their space so the view switch is never pushed off. */}
          <Tabs
            className="min-w-0 flex-1"
            defaultValue={activeAudience.label}
            onValueChange={(value) => handleTabChange(tabs.find((tab) => tab.label === value))}>
            <TabsList className="w-full justify-start overflow-x-auto scrollbar-hide">
              {tabs.map((tab, index) => (
                <TabsTrigger className="capitalize" value={tab.label} key={index}>
                  {tab.label}
                </TabsTrigger>
              ))}
            </TabsList>
          </Tabs>
          <div
            role="group"
            aria-label={t('view')}
            className="flex shrink-0 overflow-hidden rounded-md border border-border">
            {[
              { chart: false, label: t('table'), icon: <FaThList size={16} /> },
              {
                chart: true,
                label: t('chart'),
                icon: <BsBarChartLineFill className="rotate-90" size={16} />,
              },
            ].map((view) => (
              <button
                key={view.label}
                type="button"
                aria-label={view.label}
                aria-pressed={isChart === view.chart}
                title={view.label}
                className={`flex h-9 w-9 items-center justify-center transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring ${
                  isChart === view.chart
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-card text-muted-foreground hover:bg-accent'
                }`}
                onClick={() => setIschart(view.chart)}>
                {view.icon}
              </button>
            ))}
          </div>
        </div>
        <div className="flex flex-wrap items-center justify-end gap-2 sm:[&>*]:w-56">
          {activeAudience.searchParam === 'b2b' && (
            <div className="flex items-center justify-center gap-2">
              <Input
                className="h-10 w-[200px]"
                value={business}
                onChange={(e) => setBusiness(e.target.value)}
                placeholder={t('business')}
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    mutate();
                  }
                }}
              />
              <Button onClick={() => mutate()} variant="secondary" size="sm">
                {t('search')}
              </Button>
            </div>
          )}{' '}
          <DatePickerWithPresets setDateObj={setDateObj} />
          {citiesOptions && (
            <Combobox placeholder={t('city')} dataArray={citiesOptions} filterParam="city" />
          )}
          {segmentsOptions && activeAudience.searchParam === 'segment' && (
            <Combobox
              placeholder={t('segment')}
              dataArray={segmentsOptions}
              filterParam="segment"
            />
          )}
          {<Combobox placeholder={t('status')} dataArray={statusOptions} filterParam="status" />}
          {/* if type is b2b, show business input field for b2b business name */}
        </div>
      </div>

      {!isChart ? (
        <DataTable
          columns={columns}
          data={data?.data?.dataList ?? []}
          isLoading={isLoading}
          showColumnToggle={false}
          getRowId={(promoCode) => promoCode._id}
          emptyStateComponent={<EmtyState />}
        />
      ) : (
        <ChartView data={data} />
      )}
      {data?.data?.paginationData?.totalPages > 1 && !isChart && (
        <PaginationComponent
          page={data.data.paginationData.page}
          pages={data.data.paginationData.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
      <FormSheet
        open={openSheet}
        onOpenChange={() => {
          setOpenSheet(false);
        }}
        title={t('addNewPromoCode')}>
        <PromoCodeModelForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
};

export default PromoCodeList;
