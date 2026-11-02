import { useEffect, useState } from 'react';
import { Button, PageHeader, TableSkeleton } from '@UI/Index';
import { toast } from 'react-toastify';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import useSWR from 'swr';
import { useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Tabs, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import ordersService from '@services/orders.service';
import { Input } from '@shadecn/components/ui/input';
import WaitingAssignTable from './_Components/WaitingAssignTable';
import LifeOrderTable from './_Components/LifeOrderTable';
import CompletedTable from './_Components/CompletedTable';
import CancelledTable from './_Components/CancelledTable';
import useDebounce from '@/hooks/useDebounce';

const getDefaultTab = (tabs, defaultStatus) =>
  tabs.find((tab) => tab.status === defaultStatus) || tabs[0];

const OrdersList = () => {
  const [pageIndex, setPageIndex] = useState(1);
  const [activeTab, setActiveTab] = useState(null);
  const [searchParams, setSearchParams] = useSearchParams();
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 800);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const TABS = [
    {
      title: t('watingAssignOrder'),
      route: 'waiting-assign',
      status: 'WAITING_FOR_BIKER_BY_ADMIN',
      render: (data) => <WaitingAssignTable data={data} />,
    },
    {
      title: t('lifeOrder'),
      route: 'life',
      status: 'ACTIVE',
      render: (data) => <LifeOrderTable data={data} />,
      subFilters: [
        { status: 'ACCEPTED_BY_BIKER', title: t('acceptByBiker') },
        { status: 'BIKER_ON_THE_WAY', title: t('bikerOntheWay') },
        { status: 'BIKER_ARRIVED', title: t('BikerArrived') },
        { status: 'ON_WASHING', title: t('onWashing') },
      ],
    },
    {
      title: t('completed'),
      route: 'completed',
      status: 'COMPLETED',
      render: (data) => <CompletedTable data={data} />,
    },
    {
      title: t('cancelled'),
      route: 'cancelled',
      status: ['CANCELLED_BY_USER', 'CANCELLED_BY_ADMIN'],
      render: (data) => <CancelledTable data={data} />,
    },
  ];
  const status = searchParams.getAll('status') || [];
  const defaultTabStatus = 'ACTIVE';
  const defaultSubFilterStatus = 'ACCEPTED_BY_BIKER';
  const { data: ordersListData, isLoading: ordersListLoading } = useSWR(
    ['get-all-order-list', pageIndex, status, debouncedSearch],
    () =>
      ordersService.getAllOrders({
        page: pageIndex,
        perPage: 20,
        status,
        search: debouncedSearch,
      })
  );

  const handleTabChange = (tab, isMain = true) => {
    if (isMain) {
      setActiveTab(tab);
      const newStatus =
        tab.route === 'cancelled'
          ? ['CANCELLED_BY_USER', 'CANCELLED_BY_ADMIN']
          : tab.route === 'life'
          ? [defaultTabStatus, defaultSubFilterStatus]
          : [tab.status];
      setSearchParams({ status: newStatus });
    }
  };

  const handleSubFilterChange = (status) => {
    const currentStatuses = searchParams.getAll('status');
    const updatedStatuses = currentStatuses.includes(defaultTabStatus)
      ? [defaultTabStatus, status]
      : [...currentStatuses.filter((s) => s !== defaultTabStatus), status];
    setSearchParams({ status: updatedStatuses });
  };
  const renderSubFilters = () => {
    if (!activeTab?.subFilters) return null;
    return (
      <div className="w-full">
        <Tabs
          defaultValue={
            activeTab.subFilters.find((sub) => sub.status === defaultSubFilterStatus)?.title
          }
          onValueChange={(value) => {
            const selectedSubFilter = activeTab.subFilters.find((sub) => sub.title === value);
            if (selectedSubFilter) handleSubFilterChange(selectedSubFilter.status);
          }}
          className="my-4">
          <TabsList className="flex max-w-full">
            {activeTab.subFilters.map((subFilter, index) => (
              <TabsTrigger value={subFilter.title} key={index} className="me-2">
                {t(subFilter.title)}
              </TabsTrigger>
            ))}
          </TabsList>
        </Tabs>
      </div>
    );
  };
  const [loading, setloading] = useState(false);

  const handelExport = async () => {
    setloading(true);
    try {
      const response = await ordersService.getOrderExportExcel();
      const url = window.URL.createObjectURL(response);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'orders_export.xlsx');
      // The link must be in the page to click and remove it (it crashed before).
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      const messages = error?.response?.data?.message;
      toast.error(
        (Array.isArray(messages) ? messages.join(', ') : messages?.[lang]) ||
          t('somethingWentWrong')
      );
    } finally {
      setloading(false);
    }
  };

  useEffect(() => {
    const tabStatus = searchParams.getAll('status'); // Get all status values as an array

    // Find the correct tab by checking if the tab's status matches the retrieved status
    const matchingTab = TABS.find(
      (tab) =>
        Array.isArray(tab.status)
          ? tab.status.every((s) => tabStatus.includes(s)) // Ensure all statuses match for array-based statuses
          : tabStatus.includes(tab.status) // Normal single status comparison
    );

    if (matchingTab) {
      setActiveTab(matchingTab);
    } else {
      const defaultTab = getDefaultTab(TABS, defaultTabStatus);
      setActiveTab(defaultTab);
      setSearchParams({ status: [defaultTabStatus, defaultSubFilterStatus] });
    }
    const page = parseInt(searchParams.get('page') || '1', 10);
    setPageIndex(page);
  }, [searchParams]);

  useEffect(() => {
    if (activeTab?.route === 'life' && !searchParams.get('status')) {
      setSearchParams({ status: [defaultTabStatus, defaultSubFilterStatus] });
    }
  }, [activeTab, searchParams]);
  return (
    <div className="relative">
      <div className="pb-5">
        <PageHeader
          title={t('orders')}
          actions={
            <>
              <div className="relative w-64 max-w-full">
                <MagnifyingGlassIcon className="pointer-events-none absolute start-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  onChange={(e) => setSearch(e.target.value)}
                  value={search}
                  placeholder={t('search')}
                  aria-label={t('search')}
                  className="ps-9"
                />
              </div>
              <Button loading={loading} onClick={() => handelExport()}>
                {t('Export')}
              </Button>
            </>
          }
        />
      </div>
      <div className="mb-5 flex w-full flex-col items-start justify-start">
        <Tabs
          value={activeTab?.title}
          defaultValue={activeTab?.title}
          onValueChange={(value) => {
            const selectedTab = TABS.find((tab) => tab.title === value);
            handleTabChange(selectedTab, true);
          }}>
          <TabsList className="flex max-w-full">
            {TABS.map((tab, index) => (
              <TabsTrigger value={tab.title} key={index} className="me-2">
                {t(tab.title)}
              </TabsTrigger>
            ))}
          </TabsList>
        </Tabs>
        {renderSubFilters()}
      </div>
      <div>
        {ordersListLoading ? (
          <TableSkeleton columns={7} />
        ) : (
          ordersListData?.data && activeTab?.render(ordersListData)
        )}
      </div>
      {ordersListData && (
        <PaginationComponent
          page={ordersListData?.pagination?.page}
          pages={ordersListData?.pagination?.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
    </div>
  );
};
export default OrdersList;
