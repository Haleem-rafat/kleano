import { useState } from 'react';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import TransactionsService from '@services/transactions.service';
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
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          {t('transactions')}
        </h1>
      </div>
      <div>
        <TransactionsTable data={transactionsListData} isLoading={transactionsListLoading} />
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
