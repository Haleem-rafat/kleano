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

      <div className="flex items-center justify-between pb-6">
        <p className="text-xl font-semibold capitalize tracking-tight text-slate-900">{t('transactions')}</p>
      </div>
      <div className="max-h-[calc(100vh-200px)] overflow-auto rounded-xl border border-slate-200 bg-white p-2">
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
