import { useEffect, useState } from 'react';
import { Button, PageHeader, TableSkeleton, FilterPanel, FilterSearch, Segmented } from '@UI/Index';
import { toast } from 'react-toastify';
import useSWR from 'swr';
import { useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Tabs, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import ordersService from '@services/orders.service';
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
    const statuses = searchParams.getAll('status');
    const current =
      activeTab.subFilters.find((sub) => statuses.includes(sub.status))?.status ||
      defaultSubFilterStatus;
    return (
      <div className="flex flex-wrap items-center gap-x-3 gap-y-2">
        <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          {t('stage')}
        </span>
        <Segmented
          variant="steps"
          label={t('stage')}
          value={current}
          onChange={handleSubFilterChange}
          options={activeTab.subFilters.map((sub) => ({ value: sub.status, label: sub.title }))}
        />
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
      <PageHeader
        title={t('orders')}
        actions={
          <Button variant="secondary" loading={loading} onClick={() => handelExport()}>
            {t('Export')}
          </Button>
        }
      />
      <FilterPanel
        className="my-5"
        tabs={
          <>
            <Tabs
              value={activeTab?.title}
              onValueChange={(value) => {
                const selectedTab = TABS.find((tab) => tab.title === value);
                handleTabChange(selectedTab, true);
              }}>
              <TabsList>
                {TABS.map((tab, index) => (
                  <TabsTrigger value={tab.title} key={index}>
                    {t(tab.title)}
                  </TabsTrigger>
                ))}
              </TabsList>
            </Tabs>
            {renderSubFilters()}
          </>
        }>
        <FilterSearch value={search} onChange={setSearch} placeholder={t('search')} />
      </FilterPanel>
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
