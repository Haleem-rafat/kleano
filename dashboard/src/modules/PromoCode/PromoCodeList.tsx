import promoCodeService from '@services/promoCode.service';
import { Combobox } from '@UI/comboBox/ComboBox';
import { DatePickerWithPresets } from '@UI/datePickerComponent/DatePicker';
import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
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
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';

import { Tabs, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import { FaThList } from 'react-icons/fa';

import { BsBarChartLineFill } from 'react-icons/bs';
import { Input } from '@shadecn/components/ui/input';
import { ChartView } from './_Components/ChartView';

import PromoCodeModelForm from './_Components/PromoCodeModelForm';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

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
        business: activeAudience.label === 'b2b' && business ? business : undefined,
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

  return (
    <div className="relative flex h-full w-full flex-col gap-3">
      {isLoading && <ThreeDotsLoader />}
      <div className="flex items-center justify-between pb-6">
        <p className="text-xl font-semibold capitalize tracking-tight text-slate-900">{t('promoCode')}</p>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewPromoCode')}</Button>
        </div>
      </div>
      <div className="flex w-full flex-col flex-wrap items-center justify-between gap-3 rounded-lg p-4 shadow">
        <div className="flex min-h-[3rem] w-full flex-col items-center justify-between gap-2 self-start md:flex-row ">
          <Tabs
            className="w-full  scrollbar-hide"
            defaultValue={activeAudience.label}
            onValueChange={(value) => handleTabChange(tabs.find((tab) => tab.label === value))}>
            <TabsList className="w-full overflow-scroll scrollbar-hide">
              {tabs.map((tab, index) => (
                <TabsTrigger className="capitalize" value={tab.label} key={index}>
                  {tab.label}
                </TabsTrigger>
              ))}
            </TabsList>
          </Tabs>
          {/* setIschart */}
          <div className="flex items-center rounded-lg border  ">
            <button
              type="button"
              className={`${
                isChart ? 'bg-white text-gray-400' : 'bg-primary text-white'
              } rounded-l-lg p-2 transition-colors  duration-300 ease-in`}
              onClick={() => setIschart(false)}>
              <FaThList size={30} />
            </button>
            <button
              type="button"
              className={`${
                isChart ? 'bg-primary text-white' : 'bg-white text-gray-400'
              } rounded-r-lg p-2 transition-colors duration-300 ease-in`}
              onClick={() => setIschart(true)}>
              <BsBarChartLineFill className="rotate-90" size={30} />
            </button>
          </div>
        </div>
        <div className="flex flex-col items-center justify-start gap-2 self-end md:flex-row ">
          {activeAudience.label === 'B2B' && (
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
          {segmentsOptions && activeAudience.label === 'Segments' && (
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
        <div className="h-[calc(100vh-300px)] w-full overflow-y-scroll rounded-lg  p-4 shadow">
          <Table className="scrollbar-hide">
            <TableHeader>
              <TableRow>
                {[
                  t('promoCodeName'),
                  searchParams.get('targetAudience') !== 'b2b'
                    ? t('discountPercentage')
                    : 'business',
                  t('numberOfUses'),
                  t('appliedCount'),
                  t('targetAudience'),
                  t('createddate'),
                  t('expiredDate'),
                  t('status'),
                  // t('action'),
                ].map((item, index) => (
                  <TableHead key={index}>{item}</TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {data &&
                data?.data.dataList?.map((promoCode) => (
                  <TableRow className="cursor-pointer hover:bg-primary/10" key={promoCode._id}>
                    <TableCell>{promoCode.code}</TableCell>
                    <TableCell>
                      {searchParams.get('targetAudience') !== 'b2b'
                        ? promoCode.discountPercentage
                        : promoCode.business || '-'}
                    </TableCell>
                    <TableCell>{promoCode.numberOfUses}</TableCell>
                    <TableCell>{promoCode.appliedCount}</TableCell>
                    <TableCell>{promoCode.targetAudience}</TableCell>
                    <TableCell>{formatDate(promoCode.createdAt)}</TableCell>
                    <TableCell>{formatDate(promoCode.expiryDate)}</TableCell>
                    <TableCell>
                      <Select
                        disabled={promoCode.status === 'EXPIRED'}
                        defaultValue={promoCode.status === 'ACTIVE' ? 'activate' : 'disable'}
                        onValueChange={(value: 'activate' | 'disable') =>
                          handleStatus(promoCode._id, value)
                        }>
                        <SelectTrigger className="bg-transparent">
                          <SelectValue placeholder={promoCode.status} />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectGroup>
                            {['activate', 'disable'].map((item, index) => (
                              <SelectItem value={item} key={index}>
                                {promoCode.status === 'EXPIRED' ? (
                                  <MainStatusChipe status={'EXPIRED'} />
                                ) : (
                                  <MainStatusChipe status={item} />
                                )}
                              </SelectItem>
                            ))}
                          </SelectGroup>
                        </SelectContent>
                      </Select>
                    </TableCell>
                    {/* <TableCell>
                      <Popover>
                        <PopoverTrigger asChild>
                          <Button variant="primary">Edit</Button>
                        </PopoverTrigger>
                        <PopoverContent className="w-80">
                          <div className="grid gap-4">
                            <div className="space-y-2">
                              <h4 className="font-medium leading-none">Promo Name</h4>
                              <p className="text-muted-foreground text-sm">Edit your promo name</p>
                            </div>

                            <div className="flex flex-col gap-2 ">
                              <Label htmlFor="name">Name</Label>
                              <Input
                                ref={inputRef}
                                id="name"
                                defaultValue={promoCode.code}
                                className="col-span-2 h-8"
                              />
                            </div>
                            <Button onClick={() => handleEdit(promoCode._id)}>Submit</Button>
                          </div>
                        </PopoverContent>
                      </Popover>
                    </TableCell> */}
                  </TableRow>
                ))}
            </TableBody>
          </Table>
          {data?.data?.dataList?.length === 0 && <EmtyState />}
        </div>
      ) : (
        <ChartView data={data} />
      )}
      {data && !isChart && (
        <PaginationComponent
          page={data.data.paginationData.page}
          pages={data.data.paginationData.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
      <Sheet
        open={openSheet}
        onOpenChange={() => {
          setOpenSheet(false);
        }}
        modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('addNewPromoCode')}</SheetTitle>
            <SheetDescription>
              <PromoCodeModelForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
};

export default PromoCodeList;
