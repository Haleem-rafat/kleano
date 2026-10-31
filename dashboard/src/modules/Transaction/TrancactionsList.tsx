import { useState } from 'react';
import { ThreeDotsLoader } from '@UI/Index';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import TransactionsService from '@services/transactions.service'
import TransactionsTable from './_Components/TransactionsTable';


const TrancactionsList = () => {
  const [pageIndex, setPageIndex] = useState(1);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data: transactionsListData, isLoading: transactionsListLoading } = useSWR(
    ['get-all-transactions-list', pageIndex],
    () =>
      TransactionsService.getAllTransactions({
        page: pageIndex,
        perPage: 20,
      })
  );

  return (
    <div className="relative">
      {transactionsListLoading && <ThreeDotsLoader />}

      <div className="flex items-center justify-between pb-10">
        <p className="text-2xl font-semibold">{t('transactions')}</p>
      </div>
      <div className="h-[calc(100vh-300px)] overflow-y-scroll rounded-lg bg-white p-4 shadow">
        {transactionsListData && <TransactionsTable data={transactionsListData} />}
      </div>

      {transactionsListData && (
        <PaginationComponent
          page={transactionsListData?.pagination?.page}
          pages={transactionsListData?.pagination?.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
    </div>
  );
};

export default TrancactionsList;
